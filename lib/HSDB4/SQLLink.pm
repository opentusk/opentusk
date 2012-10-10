package HSDB4::SQLLinkDefinition;

use strict;
use Carp;
use Data::Dumper;
require HSDB4::Constants;
require HSDB4::SQLSelect;
require DBI;

BEGIN {
    # remember all of the definitions as we make them...
    use vars qw($VERSION %LinkDefs);

    %LinkDefs = ();
    $VERSION = do { my @r = (q$Revision: 1.45 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

    sub new {
	
	# Usual get class name, suck in attributes, bless the anon hash ref
	my $class = shift;
	$class = ref($class) || $class;
	my $self = { @_ };
	bless $self, $class;
	$LinkDefs{$self->{-link_table}} = $self;

	eval "require $self->{-parent_class}";
	die  "$@\t...error compiling parent class ($self->{-parent_class})" if $@;

	
	eval "require $self->{-child_class}";
	die  "$@\t...error compiling child class ($self->{-child_class})" if $@;

	return $self;
    }

# Get the link definitions...
do 'HSDB4/link_definitions.pl' or die; # or die "Error in link definitions: $@";

}

# All the possible attributes for a link
my @attributes = qw(parent_class
		    parent_id_field
		    child_class
		    child_id_field
		    link_fields
		    order_by
		    school
		    );

# Make attribute functions for all of the definition attributes
{
    # We're going to directly manipulate the namespace, so...
    no strict "refs";
    # For each attribute...
    foreach my $attr (@attributes) {
	# Create a closure with exactly the same name that 
	*$attr = sub {
	    my $self = shift;
	    $self->{"-$attr"} = shift if @_;
	    return $self->{"-$attr"};
	}
    }
}

# Link table is special, though, since it needs to take into account the
# school stuff
sub link_table {
    my $self = shift;
    return $self->{-link_table};
}

sub child_select {
    #
    # Make a select statement based on a finding a bunch of children given
    # the parent ID.
    # child_select ( parent_id, [ condition, [ condition, ... ] ] )
    #

    # Get the link definition
    my $self = shift;
    # Get the parent_id, which is the argument
    my $parent_id = shift;
    # Get the name of the child class, for convenience
    my $child_class = $self->child_class ();

    # Define some SQLTables:
    # ...the child table
    my $c_tab = HSDB4::SQLTable->new (-table => $child_class->table($self->school),
				      -alias => 'child',
				      -fields => [ $child_class->fields($self->school) ]
				      );
    # ...and the link table
    my $l_tab = HSDB4::SQLTable->new (-table => $self->link_table,
				      -alias => 'link',
				      -fields => $self->link_fields);
    # Define the conditions, to restrict the links to those relevant to the
    # parent, and to link to the actual child object
    my $cond_temp = 
      HSDB4::SQLCondition->new ('AND',
				sprintf ("link.%s='%s'", 
					 $self->parent_id_field,
					 $parent_id),
				sprintf ("link.%s=child.%s", 
					 $self->child_id_field,
					 $child_class->primary_key_field($self->school())));
    # If there are more arguments, assume that they are intended to be added
    # conditions on the arrangement, so add them in

    my ($cond, $order_by) = $self->process_cond($cond_temp, $self->order_by, @_);

    # Now actually form the select object and return it
    return HSDB4::SQLSelect->new (-tables => [$c_tab, $l_tab],
				  -order_by => $order_by,
				  -conditions => $cond
				  );
}

sub parent_select {
    #
    # Make a select statement based on a finding a bunch of parents given
    # the child ID.
    # parent_select ( child_id, [ condition, [ condition, ... ] ] )
    #

    # Get the link definition
    my $self = shift;
    # Get the child_id, which is the argument
    my $child_id = shift;
    # Get the name of the child class, for convenience
    my $parent_class = $self->parent_class ();

    # Define some SQLTables:
    # ...the parent table
    my $p_tab = HSDB4::SQLTable->new (-table => $parent_class->table($self->school),
				      -alias => 'parent',
				      -fields => [$parent_class->fields($self->school())]
				      );

    # ...and the link table
    my $l_tab = HSDB4::SQLTable->new (-table => $self->link_table,
				      -alias => 'link',
				      -fields => $self->link_fields);
    # Define the conditions, to restrict the links to those relevant to the
    # child, and to link to the actual parent object
    my $cond_temp = 
      HSDB4::SQLCondition->new ('AND',
				sprintf ("link.%s='%s'", $self->child_id_field,
					 $child_id),
				sprintf ("link.%s=parent.%s", 
					 $self->parent_id_field,
					 $parent_class->primary_key_field($self->school())));
    # If there are more arguments, assume that they are intended to be added
    # conditions on the arrangement, so add them in

    my ($cond, $order_by) = $self->process_cond($cond_temp, [], @_);

    # Now actually form the select object and return it
    return HSDB4::SQLSelect->new (-tables => [$p_tab, $l_tab],
				  -conditions => $cond,
				  -order_by => $order_by
				  );
}

sub get_row {
    #
    # Given a parent ID and a child ID, return the row
    #

    my $self = shift;
    my $parent_id = shift;
    my $child_id = shift;
    my $conds = shift || '';

    my $dbh = HSDB4::Constants::def_db_handle();
    my $sql = sprintf("SELECT * FROM %s WHERE %s=? AND %s=? %s", 
		      $self->link_table(), 
		      $self->parent_id_field(), 
		      $self->child_id_field,
		      $conds);
	my $sth = $dbh->prepare($sql);
	my $vals;
	eval {
		$sth->execute( $parent_id, $child_id );
		$vals = $sth->fetchrow_hashref();
	     $sth->finish;
    };
    confess $@ if $@;
    return $vals;
}

sub process_cond{
    my ($self, $condobj, $order_by, @conds) = @_;

    foreach my $cond (@conds){
	if ($cond =~ /order by (.*)/i){
	    push (@$order_by, $1);
	}else{
	    $condobj->add_and ($cond);
	}
    }
    return ($condobj, $order_by);
}

sub get_count{
    my ($self, $sel) = @_;
    # OK, here's where the actual query gets performed; we're going to stick
    # the results in a LinkSet...
    my $dbh;
    my $count = 0;
    eval {
	# Connect to the database
	$dbh = HSDB4::Constants::def_db_handle();
    };
    confess "$@\t... unable to obtain db handle in SQLLink method get_links" if $@;
    my $sql = $sel->get_sql(); 
    eval {
	# Prepare the query and execute it
	my $qry = $dbh->prepare ($sql);
	$qry->execute;

	# For each set of results...
	while ($qry->fetch) {
	    $count++;
	}
    };
    confess "$@\t... unable to execute query: $sql" if $@;

    return $count;
}


sub get_links {
    #
    # Given a SQLSelect, actually perform the query, and make the appropriate
    # SQLLinkSet from its results
    # $linkset = $linkdef->get_links ( select_object )
    #

    my ($self, $sel) = @_;
    # OK, here's where the actual query gets performed; we're going to stick
    # the results in a LinkSet...
    my $results = HSDB4::SQLLinkSet->new;
    my $dbh;

    eval {
      # Connect to the database
      $dbh = HSDB4::Constants::def_db_handle();
  };
    confess "$@\t... unable to obtain db handle in SQLLink method get_links" if $@;

    # Create arrays to hold the child, parent, and link fields, and
    # make references to the entires, which we'll store in the @binds
    # array for fast queries.
    my %linkdata = ();
    my %childdata = ();
    my %parentdata = ();
    my @binds = ();
    for ($sel->all_fields) {
	# See whether it's a child.* field or a link.* field; put it
	# in the %childdata or %linkdata hash, depending
	if (/^link\.(\w+)$/) { 
	    $linkdata{$1} = undef;
	    push @binds, \$linkdata{$1};
	} elsif (/^child\.(\w+)$/) {
	    $childdata{$1} = undef;
	    push @binds, \$childdata{$1};
	} elsif (/^parent\.(\w+)$/) {
	    $parentdata{$1} = undef;
	    push @binds, \$parentdata{$1};
	}
    }

    my $sql = $sel->get_sql();

    eval {
	# Prepare the query and execute it
	my $qry = $dbh->prepare ($sql);
	$qry->execute;
	# Set up the binding references we prepared...
	$qry->bind_columns (undef, @binds);

	# For each set of results...
	while ($qry->fetch) {
	    # Now, make an appropriate object out of the %childdata and/or
	    # %parentdata hash and put it in $child/$parent

	    my ($child, $parent) = (undef, undef);
	    if (%childdata) {
		$child = $self->child_class()->new(_school => $self->school,
						   %childdata);
		$child->set_aux_info (%linkdata);
	    }

	    if (%parentdata) { 

		my $class = $self->parent_class();

		$parent = $self->parent_class()->new(_school => $self->school, 
						     %parentdata);

		$parent->set_aux_info (%linkdata);
	    }

	    # ...and make an appropriate link out of the %linkdata hash
	    # and the $child and/or parent object we just created

	    $results->push (HSDB4::SQLLink->new (-child => $child, 
						 -parent => $parent,
						 -linkdef => $self, 
						 %linkdata
						 )
			    );

	}
	$qry->finish;
    };

    confess "$@\t... unable to issue the following query in SQLLink method get_links: $sql" if $@;

    return $results;
}

sub update_children_sort_order {

   
	my $self = shift;
	my $params = shift;
    my $aref = $params->{'child_arrayref'};

	my ($index,$insert)=split('-',$params->{'change_order_string'});
	splice(@$aref, ($insert-1), 0,splice(@$aref,($index-1),1));

	my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{$params->{'link_def_type'}};
	my $length = scalar(@$aref);

			for (my $i=0; $i < $length; $i++) {
				my ($r, $msg) = $linkdef->update(-user => $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},
						-password=> $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword},
						-parent_id => $params->{'parent_id'},
						-child_id => @$aref[$i]->primary_key(),
						sort_order => 10*($i+1),
					);
			}

	return $aref;
}

sub get_children_count {
    #
    # Return a LinkSet given a child ID
    #

    my $self = shift;
    my $sel = $self->child_select (@_);
    return $self->get_count ($sel);
}

sub get_children {
    #
    # Return a LinkSet given a child ID
    #

    my $self = shift;
    my $sel = $self->child_select (@_);
    return $self->get_links ($sel);
}

sub get_parent_count{
    # 
    # Return a count of the parents
    #

    my $self = shift;
    my $sel = $self->parent_select (@_);
    return $self->get_count ($sel);
}

sub get_parents {
    # 
    # Return a LinkSet given a parent ID
    #

    my $self = shift;
    my $sel = $self->parent_select (@_);
    return $self->get_links ($sel);
}

sub update_parent_timestamp {
    #
    # Touches the timestamp of a parent object. Only call from within an eval{}; block.
    # $dbh: the live database handle
    # $parent_id: the ID of the parent object to do.
    #
    my $self = shift;
    my $dbh = shift;
    my $parent_id = shift;

    my $pclass = $self->parent_class();
    my $retval;
    if (grep { /^modified$/ } $pclass->fields($self->school())) {
	my $stmt = sprintf("UPDATE %s SET modified=now() WHERE %s=?",
			   $pclass->table($self->school), $pclass->primary_key_field($self->school));
	$retval = $dbh->do($stmt, undef, $parent_id);
    }
    else {
	$retval = 1;
    }
    return $retval;
}

sub check_for_link {
    #
    # Given a parent ID and a child ID, finds out if there is a link
    #

    my $self = shift;
    my $parent_id = shift;
    my $child_id = shift;
    my $conds = shift || '';

    my $dbh = HSDB4::Constants::def_db_handle();
    my $sql = sprintf("SELECT 1 FROM %s WHERE %s=? AND %s=? %s", 
		      $self->link_table(), 
		      $self->parent_id_field(), 
		      $self->child_id_field,
		      $conds);
    my $sth = $dbh->prepare($sql);
    my $id = undef;
    eval {
	$sth->execute( $parent_id, $child_id );
	($id) = $sth->fetchrow_array();
	$sth->finish;
    };
    confess $@ if $@;
    return $id ? 1 : 0;
}

sub load_aux_info {
	#
	# Given a parent id and a child id, this method will
	# load the aux_info for the passed SQLRow object 
	# based on the row returned
	#
	my $self = shift;
	my $sqlRow = shift;
	my $parent_id = shift;
	my $child_id = shift;
	my $cond = shift || '';
	if (!$sqlRow->isa('HSDB4::SQLRow')){
		confess "the load_aux_info requires an object that is a HSDB4::SQLRow";
	}
	if (!defined($child_id) || !defined($parent_id)){
		confess "both a child_id and parent_id are required for load_aux_info";
	}
	my $dbh = HSDB4::Constants::def_db_handle();
	my $sql = sprintf("SELECT * FROM %s WHERE %s=%s AND %s=%s %s",
		        $self->link_table(), 
			$self->parent_id_field(), 
			$parent_id,
			$self->child_id_field(),
			$child_id,
			$cond);
	my $sth = $dbh->prepare($sql);
	my $sqlHash = undef;
	eval {
		$sth->execute( ) ;
		$sqlHash = $sth->fetchrow_hashref() ;
	     $sth->finish;
	};
	confess $@ if $@;
	$sqlRow->set_aux_info(%{$sqlHash});
}

sub insert {
    #
    # Make a new link. Arguments come like...
    # -user      : DB username
    # -password  : DB password
    # -parent_id : parent ID value
    # -child_id  : child ID value
    # field      : field value
    #
    my $self = shift;

    # Get the args, and make sure we have a parent and child ID
    my %args = @_;
    return ("0","Missing parent or child id")  unless ($args{-parent_id} and $args{-child_id});

    my $retval = 0;
    my $dbh;
    my @dbc = ();
    if ($args{-user} and $args{-password}) {
	@dbc = HSDB4::Constants::db_connect;
	$dbc[1] = $args{-user};
	$dbc[2] = $args{-password};
	$dbc[3] = {'RaiseError'=>1};
    }
    my $no_parent_update = $args{-no_parent_update}; 

    eval {
	# Set up the database connection
	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    if ($@) {
	croak("$@\t... unable to obtain db handle in SQLLink method insert");
    }

    # Set up the fields and values. Start with the ID fields...
    my @fields = ($self->parent_id_field, $self->child_id_field);
    my @values = map { $dbh->quote ($_) } ($args{-parent_id}, $args{-child_id});
    # And then do the other fields
    foreach (@{$self->link_fields}) {
	if (exists $args{$_}) {
	    push @fields, $_;
	    push @values, $dbh->quote ($args{$_});
	}
    }

    my $sql = sprintf("INSERT INTO %s (%s) VALUES (%s)", $self->link_table,
		      join(', ', @fields), join(', ', @values));

    eval {
	# Now actually do it
	$dbh->do($sql);
	unless($no_parent_update){
		$retval = $self->update_parent_timestamp($dbh, $args{-parent_id}) 
	}
    };
    croak "$@\t... unable to issue the following query in SQLLink method insert: $sql" if $@;

    # Clean up if we failed
    my $msg = $@ || '';
    # Disconnect if we connected
    $dbh->disconnect if $dbh && @dbc;
    # Set up the return value
    return wantarray ? ($retval, $msg) : $retval;
}

sub delete {
    #
    # Delete a new link. Arguments are the parent_id and the child_id.
    #

    my $self = shift;

    # Get the args, and make sure we have a parent and child ID
    my %args = @_;

    die "Missing parent id" unless $args{-parent_id};
    die "Missing child id"  unless $args{-child_id};
#    return ("0","Missing parent or child id") unless ($args{-parent_id} and $args{-child_id});

    my $retval = 0;
    my $dbh;
    my @dbc = ();
    if ($args{-user} and $args{-password}) {
	@dbc = HSDB4::Constants::db_connect;
	$dbc[1] = $args{-user};
	$dbc[2] = $args{-password};
	$dbc[3] = {'RaiseError'=>1};
    }

    my $user_cond = $args{-cond} || '';

    eval {
	# Set up the database connection
	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    if ($@) {
	croak("$@\t... unable to obtain db handle in SQLLink method delete ");
    }

    # Make the conditions
    my $conds = sprintf("%s=%s AND %s=%s", 
			$self->parent_id_field, 
			$dbh->quote($args{-parent_id}),
			$self->child_id_field, 
			$dbh->quote($args{-child_id})
			);

    $conds .= $user_cond;
    my $stmt = sprintf("DELETE FROM %s WHERE %s", $self->link_table, $conds);

    eval {
	# Now actually do it
	$retval = $dbh->do($stmt);
	# If we got here, we succeeded
	$retval = $self->update_parent_timestamp($dbh, $args{-parent_id});
    };
    croak "$@\t... unable to issue the following query in SQLLink method delete: $stmt" if $@;

    # Clean up if we failed
    my $msg = $@ || '';
    # Disconnect if we connected
    $dbh->disconnect if $dbh && @dbc;
    # Set up the return value
    return wantarray ? ($retval, $msg) : $retval;
}

sub delete_children {
    #
    # Delete all links with a certain parent_id
    #

    my $self = shift;

    # Get the args, and make sure we have a parent and child ID
    my %args = @_;

    die "Missing parent id" unless $args{-parent_id};
    return ("0","Missing parent id") unless ($args{-parent_id});

    my $retval = 0;
    my $dbh;
    my @dbc = ();
    if ($args{-user} and $args{-password}) {
	@dbc = HSDB4::Constants::db_connect;
	$dbc[1] = $args{-user};
	$dbc[2] = $args{-password};
    }

    eval {
	# Set up the database connection
	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    if ($@) {
	croak("$@\t... unable to obtain db handle in SQLLink method delete_children");
    }

    # Make the conditions
    my $conds = sprintf("%s=%s", 
			$self->parent_id_field, 
			$dbh->quote($args{-parent_id}),
			);

    my $stmt = sprintf("DELETE FROM %s WHERE %s", $self->link_table, $conds);

    eval {
	# Now actually do it
	$retval = $dbh->do($stmt);
	# If we got here, we succeeded
	$retval = $self->update_parent_timestamp($dbh, $args{-parent_id});
    };
    die "$@\t... unable to issue the following query in SQLLink method delete: $stmt" if $@;

    # Clean up if we failed
    my $msg = $@ || '';
    # Disconnect if we connected
    $dbh->disconnect if $dbh && @dbc;
    # Set up the return value
    return wantarray ? ($retval, $msg) : $retval;
}

sub update {
    # 
    # Some day I might want to be able to update
    #
    
    my $self = shift;
    # Get the args, and make sure we have a parent and child ID
    my %args = @_;
    return unless ($args{-parent_id} and $args{-child_id});

    my $retval = 0;
    my $dbh;
    my @dbc = ();

    if ($args{-user} and $args{-password}) {
	@dbc = HSDB4::Constants::db_connect;
	$dbc[1] = $args{-user};
	$dbc[2] = $args{-password};
    }
    my $user_cond = $args{-cond} || '';
    my $no_parent_update = $args{-no_parent_update}; 
    delete $args{-user};
    delete $args{-cond};
    delete $args{-password};
    delete $args{-no_parent_update};
	
	
    eval {
	# Set up the database connection
	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    if ($@) {
	die("$@\t... unable to obtain db handle in SQLLink method update");
    }

    # Make the conditions
    my $conds = sprintf ("%s=%s AND %s=%s %s", 
			 $self->parent_id_field, 
			 $dbh->quote($args{-parent_id}),
			 $self->child_id_field, 
			 $dbh->quote($args{-child_id}),
			 $user_cond
			 );
    my $parent_id = $args{-parent_id};
    delete $args{-parent_id};
    delete $args{-child_id};

    my @sets = ();
    while (my ($field, $val) = each %args) {
	push @sets, sprintf ("%s=%s", $field, $dbh->quote($val));
    }

    my $sql = sprintf("UPDATE %s SET %s WHERE %s",
		      $self->link_table, join (', ', @sets),
		      $conds);

    eval {
	# Now actually do it
	$retval = $dbh->do ($sql);
	unless($no_parent_update){
		$retval = $self->update_parent_timestamp($dbh, $parent_id) 
	}
    };
    die "$@\t... unable to issue the following query in SQLLink method update: $sql" if $@;

    # Clean up if we failed
    my $msg = $@ || '';
    # Disconnect if we connected
    $dbh->disconnect if @dbc && $dbh && $dbh->ping();
    # Set up the return value
    return wantarray ? ($retval, $msg) : $retval;
}

package HSDB4::SQLLink;

use strict;
use vars qw(@fields $VERSION);

@fields = ();
$VERSION = do { my @r = (q$Revision: 1.45 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub new {
    #
    # Usual get class name, suck in attributes, bless the anon hash ref
    #

    my $class = shift;
    $class = ref($class) || $class;
    # Make the anon hash ref
    my $self = { @_ };
    # Bless the reference...
    bless $self, $class;
}

# Make attribute functions for all of the link fields for all of the links
# which have been defined
{
    # We're going to directly manipulate the namespace, so...
    no strict "refs";
    my %attr_flags = ();
    # For each link definition...
    foreach my $linkdef (values %HSDB4::SQLLinkDefinition::LinkDefs) {
	# ...and foreach field in the link table in that definition...
	foreach my $attr (@{$linkdef->link_fields()}) {
	    $attr_flags{$attr} = 1;
	}
    }
    foreach my $attr (keys %attr_flags) {
	# ... create a closure with exactly the same name that 
	# get/sets the link's attribute
	*$attr = sub {
	    my $self = shift;
	    $self->{$attr} = shift if @_;
	    return $self->{$attr} if $self->{$attr};
	    return;
	};
    }
    @fields = keys %attr_flags;
}

sub parent {
    #
    # Return the parent object of the link
    #

    my $self = shift;
    return $self->{-parent} if defined $self->{-parent};
    return;
}

sub child {
    #
    # Return the child object of the link
    #

    my $self = shift;
    return $self->{-child} if defined $self->{-child};
    return;
}

sub linkdef {
    # Return the LinkDefinition object of the link
    my $self = shift;
    return $self->{-linkdef} if defined $self->{-linkdef};
    return;
}

package HSDB4::SQLLinkSet;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.45 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub new {
    #
    # Usual get class name, suck in attributes, bless the anon hash ref
    #

    my $class = shift;
    $class = ref($class) || $class;
    my $self = {};
    bless $self, $class;

    # Set up the array refs
    $self->{_list} = [];
    $self->{_ids} = [];

    return $self;
}

sub push {
    # 
    # Put a Link object on the end of the LinkSet
    #

    # Get the object...
    my $self = shift;
    # And push the remaining args onto the list
    push @{$self->{_list}}, @_;
    push (@{$self->{_ids}}, map {ref $_->child && $_->child->can('id') ? $_->child->id : undef} @_);
}

sub children {
    #
    # Get a list of the children objects in a link set
    #

    # Get the object...
    my $self = shift;
    # And get all of the children in a nice row
    return map { $_->child } @{$self->{_list}};
}

sub parents {
    # 
    # Get a list of parent objects in a link set
    #

    # Get the object...
    my $self = shift;
    # And get all of the nice parents in a row
    return map { $_->parent } @{$self->{_list}};
}

sub iterate_children {
    #
    # Iterate a coderef over the children
    #

    # Get the set...
    my $self = shift;
    # And get the subroutine
    my $sub = shift;
    # Make sure it's a subroutine, or return nothing
    return unless ref $sub eq 'CODE';
    # Otherwise, call the subroutine on all the children
    return map { &{$sub}($_->child) } @{$self->{_list}};
}

sub iterate_parents {
    #
    # Iterate a coderef over the parents
    #

    # Get the set...
    my $self = shift;
    # And get the subroutine
    my $sub = shift;
    # Make sure it's a subroutine, or return nothing
    return unless ref $sub eq 'CODE';
    # Otherwise, call the subroutine on all the parents
    return map { &{$sub}($_->parent) } @{$self->{_list}};
}

sub count { 
    #
    # Return the number of elements in the set
    #

    my $self = shift;
    return scalar @{$self->{_list}};
}

sub get_link {
    #
    # Returns a link given the index
    #

    my $self = shift;
    my $index = shift;
    return unless defined $index && $index < $self->count && $index >= 0;
    return $self->{_list}[$index];
}

sub get_child_index {
    #
    # Function to find out what index a particular child has in the set of 
    # children
    #

    my ($self, $child) = @_;
    # Make sure we have a child that we can get an ID from
    return unless defined $child && ref $child && $child->can('id');
    # Then search through the list of IDs we keep, and see where the one we're
    # looking for falls
    my $index = undef;
    my $id = $child->id;
    for (0..$self->count - 1) {	$index = $_, last if $self->{_ids}[$_] eq $id }
    return $index;
}

sub get_next_child {
    #
    # Given a child, find the next child (for NEXT link on a page,
    # for example)
    #

    my ($self, $child) = @_;
    # Find the index, and return the next larger; this will be undef if the
    # child is the last one
    my $index = $self->get_child_index($child);
    return unless defined $index;
    my $link = $self->get_link($index+1) or return;
    return $link->child;
}

sub get_prev_child {
    #
    # Given a child, find the previous child (for PREV link on a page,
    # for example)
    #

    my ($self, $child) = @_;
    # Find the index, and get the previous item
    my $index = $self->get_child_index($child);
    return unless defined $index;
    my $link = $self->get_link($index-1) or return;
    return $link->child;
}

sub sort_links {
    #
    # Designed solely for sorting, it compares lexically two array refs of the
    # form... [3, 'field1', 'fields'] and [12, 'field1', 'field'].  It skips
    # the first element and compares the rest lexically until one differs,
    # and then it returns the result.
    #

    my ($i, $result);
    for (($i, $result) = (1, 0); 
	 not $result and defined $HSDB4::LinkSet::a->[$i];
	 $i++) {
	$result = $HSDB4::LinkSet::a->[$i] cmp $HSDB4::LinkSet::b->[$i];
    }
    return $result;
}

sub resort_children_by {
    #
    # Causes a set of links to be resorted by a field in the children.
    # Note: This is not very efficient, so it should only be used for small
    # sets of links.  If we're using it on big sets, we should probably be
    # re-doing the query and letting the DB engine do the sorting.
    #

    my $self = shift;
    # Get the list of fields to sort by
    my @fields = @_;
    my ($ind, $child);
    # Make a list of the items that we're actually going to sort, and use
    # the sort_field_value() method to get even numeric fields in a format 
    # that it can be sorted lexically without worrying about it.  Put that
    # in a big list with the indices first, and then the items to sort by
    # in order.
    my @sort_objs = map { $ind=$_;
			  $child=$self->link($ind)->child;
			  [$ind, map { $child->sort_field_value($_) } @fields ]
			  } (0..$self->count-1);
    # Now, actually sort those sort_objs using sort_links(), and then get
    # a list of the indices and then use that list to get a re-sorted slice
    # of the original list, which we then set.  (We also do the _ids...)
    my @new_indices = map { $_->[0] } sort sort_links @sort_objs;
    @{$self->{_ids}} = @{$self->{_ids}}[@new_indices];
    @{$self->{_list}} = @{$self->{_list}}[@new_indices];
}

sub resort_parents_by {
    #
    # Causes a set of links to be resorted by a field in the parents
    # Note: This is not very efficient, so it should only be used for small
    # sets of links.  If we're using it on big sets, we should probably be
    # re-doing the query and letting the DB engine do the sorting.
    #

    my $self = shift;
    # Get the list of fields to sort by
    my @fields = @_;
    my ($ind, $parent);
    # Make a list of the items that we're actually going to sort, and use
    # the sort_field_value() method to get even numeric fields in a format 
    # that it can be sorted lexically without worrying about it.  Put that
    # in a big list with the indices first, and then the items to sort by
    # in order.
    my @sort_objs = map { $ind=$_;
			  $parent=$self->link($ind)->parent;
			  [$ind, map { $parent->sort_field_value($_) } @fields ]
			  } (0..$self->count-1);
    # Now, actually sort those sort_objs using sort_links(), and then get
    # a list of the indices and then use that list to get a re-sorted slice
    # of the original list, which we then set.
    my @new_indices = map { $_->[0] } sort sort_links @sort_objs;
    @{$self->{_ids}} = @{$self->{_ids}}[@new_indices];
    @{$self->{_list}} = @{$self->{_list}}[@new_indices];
}

1;

__END__

=head1 NAME

B<HSDB4::SQLLink> - Classes for dealing with many-to-many relationships between HSDB4 tables

=head1 DESCRIPTION

B<HSDB4::SQLLinkDefinition> is an object representation of a many-to-many relationship between two HSDB4 tables.  From a B<SQLLinkDefinition>, one can create generate a B<SQLLinkSet>, which is an aggregate of B<SQLLink>s between a single row in one table and the appropriate set of rows in another.  

=head1 SYNOPSIS

    use HSDB4::SQLLink;

    # Get the pre-loaded definition
    my $def = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    # Now get the child users rows (as a LinkSet)
    my $children = $linkdef->get_children;

=head1 B<HSDB4::SQLLinkDefinition>

The B<HSDB4::SQLLinkDefinition> object stores a definition for the
relationships between different HSDB4 tables.  It captures the
appropriate tables names and fields to use.  It can return
B<HSDB4::SQLSelect> objects to search for parents from a child ID or
children from a parent ID.

B<new()> defines new objects.  In general, there is no need to call
this function.  The actual B<SQLLinkDefinition> objects are
initialized in F<HSDB4/link_definitions.pl>.  To actually get a new
object, use C<%HSDB4::SQLLinkDefinition::LinkDefs>, the keys of which
are the names of link tables.

    my $ld = HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};

B<child_select()> returns a B<HSDB4::SQLSelect> object which captures
the search for a set of children given a parent ID.

    my $sel = $ld->child_select ($parent_id);
    print $sel->get_sql ();

B<parent_select()> gets passed an ID of a child, and returns a
B<HSDB4::SQLSelect> object which is a query for parents for this
child.

    my $sel = $ld->parent_select ($child_id)
    print $sel->get_sql ();

B<get_links()>: given a B<SQLSelect>, actually get a B<SQLLinkSet> which matches it.

    my $linkset = $ld->get_links ($sel);

B<get_children()> actually performs the query for the children of a
given parent ID and returns the B<LinkSet>.

B<get_parents()> actually performs the query for the parents of a
 given child ID and returns the B<LinkSet>.

=head1 B<HSDB4::SQLLink>

An actual representation of a connection between a child and a parent.  Contains all of the data of the link, plus references to the child (if linked from a parent) or the parent (if linked from a child).

B<new()> makes a new B<SQLLink> object from the
B<HSDB4::SQLLinkDefinition> and the objects it retrieves.  Not needed,
in general; B<HSDB4::SQLLinkDefinition::get_*> functions return a
bunch of these nicely packaged.

    my $link = HSDB4::SQLLink->new (-child => $child_obj,
				    -parent => $parent_obj,
				    -linkdef => $ld,
				    sort_order => 30,
				    ...
				    );

B<parent()> returns the parent B<SQLRow> object of the link, if the
link was from a child.

B<child()> returns the child B<SQLRow> object of the link, if the link
was from a parent.

B<linkdef()> returns the B<SQLLinkDefinition> that was used to create
the link.

=head1 HSDB4::SQLLinkSet

Stores an aggregation of B<SQLLink> objects, and provides convenience functions for manipulating them as a set (iteration, sorting, indexing, etc.).

B<new()> creates a new B<SQLLinkSet> which is initially empty.

B<push()> adds a new B<SQLLink> onto the end of the set.

B<children()> gets a list of children from the set.

B<parents()> gets the list of parents from the set.

B<iterate_children()> given reference to a subroutine, returns a list
which is the results of running that bit of code on each child of the
set.

    my $code = sub {
	my $child = shift;
	return "This is :" . $child->get_attribute;
    }
    my @child_results = $linkset->iterate_children ($code);


B<iterate_parents()>: given reference to a subroutine, returns a list
which is the results of running that bit of code on each parent of the
set.

    my $code = sub {
	my $parent = shift;
	return "This is :" . $parent->get_attribute;
    }
    my @parent_results = $linkset->iterate_parents ($code);

B<count()> returns the number of B<SQLLink> objects in the set.

B<get_link()> returns the B<SQLLink> object at the given index in the
set.

B<get_child_index()> given a child object, finds the integer index
that that child has in the set.

B<get_next_child()>: given a child object, finds the child object
which comes next in the sequence.

B<get_next_child()>: given a child object, finds the child object
which came previously in the set.

B<resort_children_by()>: given a list of relevant child fields, resort
the set based on those fields.

B<resort_parents_by()>: given a list of parent fields, resort the set
based on those fields.



=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLSelect>, L<HSDB4::SQLRow>.

=head1 BUGS

=over 4

=item *

Inadequately tested.

=item *

The fact that it isn't finished?  That's a major one.  

=back

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=cut

