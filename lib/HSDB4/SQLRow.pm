package HSDB4::SQLRow;

use strict;
use Carp;
use XML::EscapeText;

BEGIN {
    require Exporter;
    require HSDB4::Constants;
    require DBI;
    require HSDB4::SQLSelect;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.76 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    #
    # Does the default creation stuff
    #

    # Get the class name
    my $incoming = shift;
    my $class = ref($incoming) || $incoming;

    # Get the field/value pairs that are being initialized from @_ and
    # use them to form the hash reference, bless the ref and return it
    
    my $self = { _tablename => '',
		 _fields => [],
		 _blob_fields => {},
		 _numeric_fields => {},
		 _primary_key_field => '',
		 _school => '',
		 _dontescapesql => 0,
		 @_
		 };
    if (ref $incoming && $incoming->isa('HASH') && $incoming->{_school}) {
	$self->{_school} = $incoming->{_school};
    }

    bless $self, $class;

    # Now, check on the school
    if ( $self->split_by_school() ) {
	if ($self->school_db()) {
	    $self->{_tablename} = $self->school_db() . "." . $self->{_tablename};
	}
	else {
	    if (my $school = $self->school()) {
		confess "Cannot construct $class with school=$school";
	    }
	    else {
		confess "Cannot construct $class without specifying a school.";
	    }
	}
    }

    # Check on the ID...
    if ($self->{_id}) {
	$self->lookup_key ($self->{_id});
    }

    return $self;
}

#
# >>>>>  Table Methods <<<<<
#

sub school {
    my $self = shift;
    my ($school,$schoolObject);
    if (defined($self->{_school}) && ($self->{_school} =~ /^\d+$/)){
            $school = $self->{_school};
            $schoolObject = TUSK::Core::School->lookupKey($school);
            if (!defined($schoolObject)){
                     confess "Cannot find school with ID $school";
             }
             $self->{_school} = $schoolObject->getSchoolName();
        }
    return $self->{_school};
}

sub school_db {
    my $self = shift;
    return HSDB4::Constants::get_school_db ($self->school);
}

sub school_id {
    my $self = shift;
    
    unless (defined $self->{_school_id}){
	my $school_obj = TUSK::Core::School->lookupReturnOne("school_name = '" . lc($self->school()) . "'");
	$self->{_school_id} = $school_obj->getPrimaryKeyID();
    }
    
    return $self->{_school_id};
}

sub split_by_school {
    my $self = shift;
    return 0;
}

sub table { 
    #
    # Return the defined table name
    #

    my $self = shift;
    my $school = shift || '';
    $self = $self->new(_school => $school) unless ref $self;
    return $self->{_tablename};
}

sub primary_key_field {
    #
    # Return the name of the defined primary key field
    #

    my $self = shift;
    my $school = shift || '';
    $self = $self->new(_school => $school) unless ref $self;
    return $self->{_primary_key_field};
}

sub is_primary_key_field {
    #
    # Returns a true value if the argument is or is part of the table's 
    # primary key
    #

    my $self = shift;

    my $field = shift or return 0;

    if (ref $self->primary_key_field eq 'ARRAY') {
	return 1 if grep { $_ eq $field } @{$self->primary_key_field};
    }
    else {
	return 1 if $field eq $self->primary_key_field;
    }

    return 0;
}

sub primary_key_condition {
    #
    # Returns a bit of SQL which gets a single, appropriate row, based on the
    # primary key
    #

    my $self = shift;
    # This is usually called right before a query, so we'll let the caller
    # pass us the dbh
    my $dbh = HSDB4::Constants::def_db_handle;

    # Now get keys coming in as arguments, if they're there
    my @keys = @_;

    $self = $self->new() unless ref $self;

    # Make up a list of fields to be quoted
    my @to_be_quoted = ();
    # If it's an arrayref, then use that array
    if (ref $self->primary_key_field eq 'ARRAY') {
	push @to_be_quoted, @{$self->primary_key_field};
    }
    # Otherwise, use just the one field
    else { push @to_be_quoted, $self->primary_key_field }

    # If we didn't get enough keys as arguments, get them from primary_key()
    if (@keys < @to_be_quoted) { @keys = $self->primary_key }
    
    # Make the condition using the field names in @to_be_quoted, the actual
    # key values in @keys, and the $dbh to quote them
    my $cond = 
      HSDB4::SQLCondition->new('AND',
			       map { sprintf ("%s=%s", $to_be_quoted[$_],
					      $dbh->quote ($keys[$_])) 
				     } 0..$#to_be_quoted);
    # Now return the condition
    return $cond->get_sql;
}
	  
sub fields { 
    #
    # Returns the complete field list for this table
    #

    my $self = shift;
    my $school = shift || '';
    $self = $self->new(_school => $school) unless ref $self;
    return @{$self->{'_fields'}};
 }

sub is_field_numeric {
    #
    # Determines whether a field name should be sorted numerically rather
    # than lexically
    #

    my ($self, $field) = @_;
    my $school = shift || '';
    $self = $self->new(_school => $school) unless ref $self;
    return unless $self->{_numeric_fields}{$field};
    return 1;
}

sub is_field_blob { 
    #
    # Determines whether a field name is a BLOB field (ie, is external to the
    # database)
    #

    my ($self, $field) = @_;
    $self = $self->new() unless ref $self;
    return unless $self->{_blob_fields}{$field};
    return 1;
}

sub non_blob_fields {
    #
    # Return a list of non BLOb fields
    #

    my $self = shift;
    return grep { not $self->is_field_blob ($_) } $self->fields;
}

sub get_sql_table {
    #
    # Return a SQLTable object with the table name set right and the whole
    # list of fields
    #

    my $self = shift;
    return HSDB4::SQLTable->new (-table => $self->table,
				 -fields => [ $self->non_blob_fields ]
				 );
}

#
# >>>>> Accessor Methods <<<<<
#

sub field_value_esc{
    my $self = shift;
    my $value = $self->field_value(@_);
    $value =~s/"/\\"/g;
    $value =~s/'/\\'/g;
    return $value;
}

sub field_value {
    #
    # [GS]ets the value of the a field for an object
    #

    my ($self, $field, $val, $flag) = @_;
    # Get a list of fields
    my %fields = map { ($_, 1) } $self->fields;

    confess "invalid field name '" . $field . "' in field_value for class " . ref($self) unless $fields{$field};

    # If it's a BLOb field...
    if ($self->is_field_blob($field)) {
	# Check to see whether we already have the value...
	if (not defined $self->{$field}) {
	    # And get it using lookup_fields() if we don't
	    $self->{$field} = $self->lookup_fields ($field) unless $val;
	}
    }

    # If there are more arguments and it isn't the primary key field, then
    # set the value
    if (defined $val
	and not $self->is_primary_key_field ($field)
	and (!defined($self->{$field}) 
		or $self->{$field} ne $val)) {
	unless ($flag){
	    # Initialize the modified array if necessary
	    $self->{_modified} = {} unless $self->{_modified};
	    # Store the old value
	    $self->{_modified}{$field} = $self->{$field};
	}
	# ...and replace with the new value
	$self->{$field} = $val;
    }

    # Return the current value, whatever it is
    return $self->{$field};
}

sub primary_key {
    #
    # Return the value of the primary key field for this object. Also, reset
    # the object, since we've destroyed its identity
    #

    my $self = shift;
    # Get the new values for the primary key
    my @newkeys = @_;
    # Get the field(s) of the primary key
    my @keyfields = ref $self->primary_key_field eq 'ARRAY' ?
	@{$self->primary_key_field} : ( $self->primary_key_field );
    # If there are arguments, then we're resetting the whole value here
    if (@newkeys && @keyfields == @newkeys) {
	# Do the reset (if we previously had a value)
	$self->reset if @{$self}{@keyfields};
	# Set to the new keys
	@{$self}{@keyfields} = @newkeys;
    }
    # Get the current values of the keys
    my @keys = @{$self}{@keyfields};
    # Return them depending on how we want them

    $self->{_modified} = {} unless $self->{_modified};
    if(ref($self->primary_key_field) eq 'ARRAY') {
	foreach my $pk_field (@{$self->primary_key_field}) {
	    $self->{_modified}{$pk_field} = $self->{$pk_field};
	}
    }
    else {
	$self->{_modified}{$self->primary_key_field} = $self->{$self->primary_key_field};
    }

    return unless grep { $_ } @keys;
    return wantarray ? @keys : join (':', @keys);
}

sub getPrimaryKeyID(){
    my ($self) = @_;
    return $self->primary_key();
}

sub id {
    #
    # Returns an absolutely unique ID based on the table name and the
    # primary key.
    #

    my $self = shift;
    return $self->table . $self->primary_key;
}

sub sort_field_value {
    #
    # Puts a field value in a format where it's appropriate for lexical
    # sorting.
    #

    my ($self, $field) = @_;
    # Get the field value
    my $val = $self->field_value ($field);
    # Return it unless it's numeric...
    return $val unless $self->is_field_numeric ($field);
    # ...in which case, format it so that it will sort properly lexically
    return sprintf "%+018.3f", $val;
}

sub get_field_values {
    #
    # Gets (NOT sets) a bunch of field values
    #

    my $self = shift;

    # Make a hash of the appropriate field values
    my %fields = map { ($_, 1) } $self->fields;

    foreach (@_) { die "invalid field name in get_field_values '" . $_ . "' for class " . ref($self) unless $fields{$_} }

    # And then get a slice of the %{$self} hash with the good field names
    return @{$self}{ grep { $fields{$_} } @_ }
}

sub set_field_values {
    #
    # Sets a whole bunch of field/value pairs 
    # Note: works with the _modified hashref to keep track of old values
    # Note: *cannot* be used to set the primary key. Use primary_key() for that
    #

    my $self = shift;
    # Get the field list
    my %fields = map { ($_, 1) } $self->fields;
    # Go through the argument list in (field, value) pairs
    while (my ($field, $val) = splice (@_, 0, 2)) {
	unless($fields{$field}) {
	    confess "invalid field name '" . $field . "' in set_field_values for class " . ref($self);
	}

	if($self->is_primary_key_field($field)) {
	    confess "tried to set primary key '" . $field . "' in set_field_values for class " . ref($self);
	}

	if (!defined ($self->{$field}) or (!defined($val)) 
		or $self->{$field} ne $val) {
	    # Initialize the modified array if necessary
	    $self->{_modified} = {} unless $self->{_modified};
	    # Store the old value
	    $self->{_modified}{$field} = $self->{$field} || undef;
	    # ...and replace with the new value
	    $self->{$field} = $val;
	}
    }
}

sub changed_fields {
    # 
    # Returns the fields which have changed
    #

    my $self = shift;
    return () unless ref $self->{_modified} eq 'HASH';
    return keys %{$self->{_modified}};
}

sub changed_field_values {
    #
    # Returns key/value pairs for the field values which have changed
    #

    my $self = shift;
    return () unless ref $self->{_modified} eq 'HASH';
    return (%{$self->{_modified}});
}

sub aux_info {
    #
    # Get a value back from aux_info if it's there
    #

    my $self = shift;
    # Forget it unless _aux_info has a hashref
    return unless ref $self->{_aux_info} eq 'HASH';
    # What are we looking for?
    my $key = shift;
    return $self->{_aux_info}{$key};
}

sub set_aux_info {
    #
    # Hold onto auxiliary information about a row (ie, some context thing,
    # not intrinsic to the row)
    #

    my $self = shift;
    # Unless it's already a hashref, make it one
    $self->{_aux_info} = {} unless ref $self->{_aux_info} eq 'HASH';
    # Now go through a set of key => val pairs, setting them one by one
    while (my ($key, $val) = splice (@_, 0, 2)) {
	$self->{_aux_info}{$key} = $val;
	
    }
}

sub clear_aux_info {
    # 
    # Clear all the aux info
    #

    my $self = shift;
    $self->{_aux_info} = {};
}

sub init_values {
    #
    # Takes a list of values in a canonical order, and puts then into the 
    # object associated with the correct fields.  The keys are assumed to
    # be at the front in the canonical order.
    #

    my $self = shift;
    # Get the field list
    my @fields = $self->non_blob_fields;
    my @data = @_;

    # Now just set the remaining values
    @{$self}{@fields} = @data;
    
}

sub reset {
    # 
    # Reset the object to a blank hashref rather than one filled in with
    # interesting bits. (Actually, *not* blank, but rather containing the
    # important stuff. Really, a copy of a new object.)
    #

    my $self = shift;
    return unless ref $self;
    # Make a blank new object... (Make sure school gets carried over)
    my $blank = $self->new (_school => $self->school);
    # ...and copy it
    %$self = %$blank;
}

#
# >>>>> Database interaction <<<<<
#

sub lookup_time {
    #
    # Gets/sets the time the object was looked up ago
    #

    my $self = shift;
    my $time = 0 + shift;
    if ($time) { $self->{_lookup_time} = $time, return $time }
    else { return $self->{_lookup_time} if $self->{_lookup_time} }
    return;
}

sub lookup_key {
    #
    # Attempts to retrive a document from the database based on an ID.
    # Called like HSDB4::SQLRow::SubClass->new->lookup_id (3323). Returns
    # a object.
    #

    # Figure out what class we're talking about and get an object reference
    my $self = shift;
    my @keys = @_;

    my $dbh;
    eval {
	$dbh = HSDB4::Constants::def_db_handle();
    };
    die "$@\t...lookup_key failed to obtain database handle for class " . ref($self) if $@;

    # Form the statement
    my $cond = $self->primary_key_condition (@keys);
    my $select = 
      HSDB4::SQLSelect->new (-table => $self->get_sql_table,
			     -conditions => $cond);
	


    # Prepare/execute/fetchrow using selectrow_array and use that list of 
    # values as the values (with the init_values() method).
    $self->primary_key (@keys);



    my $query;
    eval {
	$query = $select->get_sql;
	$self->init_values ($dbh->selectrow_array($query));
    };
    die "$@\t...lookup_key failed for class " . ref($self) . " with query: " . $query if $@;

    $self->lookup_time (time ());
    return $self;
}

sub lookup_fields {
    #
    # Returns the value of fields from looking up up in the database, if
    # necessary
    #

    my $self = shift;
    my @fields = @_;
    my %fields = map { ( $_, 1) } $self->fields;
    @fields = grep { $fields{$_} } @fields;
    return unless @fields;

    my @values;
    my $query;
    eval {
	my $dbh = HSDB4::Constants::def_db_handle;
	# Get the ID value we're looking for
	my $key = $self->primary_key;
	# Get a full table object...
	my $table = $self->get_sql_table;
	# ...and set its field list to just the field of interest
	$table->fields (@fields);

	# Form the select statement
	my $cond = $self->primary_key_condition ();
	my $select = 
	  HSDB4::SQLSelect->new (-table => $table,
				 -conditions=>$cond);

	# Prepare/execute/fetchrow it using selectrow_array and pull in 
	# the value
	$query = $select->get_sql;
	@values = $dbh->selectrow_array($query);
    };
    die "$@\t...lookup_fields failed for class " . ref($self) . " with query: " . $query if $@;

    # Set all the values...
    @{$self}{@fields} = @values;
    # $self->set_field_values (map { (shift @fields, $_) } @values);
    # ...and return the values
    return $#values > 0 ? @values : $values[0];
}

sub lookup_conditions {
    #
    # Get a bunch of objects based on a set of SQL conditions from the 
    # appropriate table
    #
    # Get the incoming object or class name
    my $self = shift;
    # Make $self a new object for sure
    $self = $self->new (_school => ref $self ? $self->school() : undef);
    my $school = $self->school();
    # An empty list to push the rows onto
    my @out_objects = ();

    # Get the DB connection
    my $dbh;
    eval {
	$dbh = HSDB4::Constants::def_db_handle();
    };
    die "$@\t...lookup_conditions failed to obtain database handle for class " . ref($self) if $@;

    # Get the satement handle using a SQLSelect statement with the
    # the table name and field names as defined, and the conditions coming
    # from the arguments
    my @conditions =  ();
    my $order = '';
    # Go through the list, and check for ORDER BY clauses in among them
    foreach (@_) {
	if (/^order\s+by\s+(.+)$/i) { $order = $1; }
	else { push @conditions, $_ if $_ }
    }
    my $sel = HSDB4::SQLSelect->new (-table => $self->get_sql_table (),
				     -conditions => [ @conditions ],
				     -order_by => $order);
    # Prepare the statement...
    my $query = $sel->get_sql;
    my $st = $dbh->prepare($query);
    # ...and execute it

    eval {
	$st->execute;
    };
    die "$@\t...lookup_conditions failed for class " . ref($self) . " with query: " . $query if $@;


    # While we're getting rows...

    while (my @field_values = $st->fetchrow_array) {
	# Make a new object...
	my $rowobj = $self->new (_school => $school || '');

        # ...and set its values to the values we got from the DB
	$rowobj->init_values (@field_values);
	$rowobj->lookup_time  (time ());

	# And push it onto our return list
	push @out_objects, $rowobj;
    }

    # Clean up the database stuff
    $st->finish;

    # And return our list of objects
    return @out_objects;
}

sub lookup_all { 
    #
    # Getting all the rows is just a special case where there are no 
    # conditions, so run it like that.
    #

    my $self = shift;
    my @conditions = @_;
    return $self->lookup_conditions (@conditions);
}

sub save {
    #
    # Saves the current values of the in-memory object back to the database.
    #

    my $self = shift;
    my ($db_user, $db_password) = @_;

    my @dbc = ();
    my $retval;
    my $dbh;

    my $stored;
    if($self->split_by_school) {
	$stored = $self->new(_school => $self->school)->lookup_key($self->primary_key)->primary_key();
    }
    else {
	$stored = $self->new()->lookup_key($self->primary_key)->primary_key();
    }


    # Forget it unless there's stuff in modified
    return $self->primary_key unless $self->changed_fields or not $stored;

    # Set up the database connection. Get the default values, but overwrite
    # them with the next arguments if they're both defined

    eval {
	if ($db_user and $db_password) {
	    @dbc = HSDB4::Constants::db_connect();
	    @dbc[1,2] = ($db_user, $db_password);
	}

	# Make the database connection
	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    die "$@\t...save failed to obtain database handle for class " . ref($self) if $@;

    if ($self->primary_key and $stored) {
	# Get the set of field/new val pairs in a field='val' form
	my @changes=();
	foreach ($self->changed_fields) {
	    push @changes, sprintf ("%s=%s", $_, 
				    $dbh->quote($self->field_value ($_)));
	}
	my $cond = $self->primary_key_condition ();
	# And then use that to make up the right SQL statement and do() it

	my $query = sprintf("UPDATE %s SET %s WHERE %s",
			    $self->table, join (',', @changes),
			    $cond);

	$query = escape_text($query) unless ($self->{_dontescapesql});

	eval {
	    $dbh->do($query);
	};
	die "$@\t...save failed for class " . ref($self) . " with query: " . $query if $@;

	$retval = $self->primary_key;
    }
    # Otherwise, it's a whole new thing, and we need to insert
    else {
	# Make a list of fields and values
	my @fields = grep { defined $self->field_value($_) } $self->fields;
	my @values = map { $dbh->quote($self->field_value($_)) } @fields;
	my $query = sprintf("INSERT INTO %s (%s) VALUES (%s)",
			    $self->table, join (', ', @fields), join (', ', @values));

	$query = escape_text($query) unless ($self->{_dontescapesql});

	eval {
	    $dbh->do($query);
	};
	die "$@\t...save failed for class " . ref($self) . " with query: " . $query if $@;

	# Set our own internal primary key and set that val to 
	# the return val for the function

	$self->primary_key($dbh->{'mysql_insertid'}) unless($self->primary_key);
	$retval = $self->primary_key;
    }

    # my $msg = $@ || '';
    if (defined($dbh)){
    	$dbh->disconnect if @dbc;
    } else {
	#  $msg = sprintf ('Unable to connect: %s', $DBI::errstr);
	$retval = 0;
    }

    # The retval will have -1 if we died, 0 if we changed no rows, 1 if
    # we changed just the correct row, and more than one if we changed many
    # rows. If an array is wanted, also return the reason.
    return $retval;
}

sub delete {
    my $self = shift;
    my ($db_user, $db_password) = @_;

    my @dbc = ();
    my $retval;
    my $dbh;

    eval {
	if ($db_user and $db_password) {
	    @dbc = HSDB4::Constants::db_connect();
	    @dbc[1,2] = ($db_user, $db_password);
	}

	$dbh = @dbc ? DBI->connect (@dbc) : HSDB4::Constants::def_db_handle();
    };
    die "$@\t...delete failed to obtain database handle for class " . ref($self) if $@;

    my $query = sprintf("DELETE FROM %s WHERE %s",
			$self->table, 
			$self->primary_key_condition);
    eval {
	$retval = $dbh->do($query);
    };
    die "$@\t...delete failed for class " . ref($self) . " with query: " . $query if $@;

    if (defined($dbh)){
    	$dbh->disconnect if @dbc;
    } else {
	$retval = 0;
    }

    # 0 if we changed no rows, 1 if we changed just the correct row,
    # and more than one if we changed many rows. 
    return $retval;   
}

sub out_html_save {
    #
    # Return an English summary (with HTML markup) of what will be done
    # in saving an object
    #

    my $self = shift;

    # If there's not a primary key, forget it
    return unless $self->primary_key;

    # If there aren't any changes, forget it
    return unless $self->changed_fields;

    # Make up the list of changes
    my @changes = ();
    foreach ($self->changed_fields) {
	push @changes, sprintf ("change <B>%s</B> from [%s] to [%s]",
				$_, $self->{_modified}{$_},
				$self->field_value($_));
    }

    # And return it!
    return @changes;
}

sub out_url {
    #
    # Returns a URL for accessing complete info on the row
    #

    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::URLs{$class};
    if ($class->split_by_school() && ref $self) { $url = $url . '/' . $self->school() }
    # And we're done if this is a class method; but otherwise...
    return $url unless ref $self && $self->isa(__PACKAGE__) && $self->primary_key();
    # ...and tack on the primary key
    return $url . '/' . $self->primary_key;
}

sub out_edit_url {
    #
    # Returns a URL for editing a row
    #

    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::EditURLs{$class} or return;
    # ...and tack on the primary key
    if ($class->split_by_school() && ref $self) { $url = $url . '/' . $self->school() }
    return $url unless ref $self && $self->isa(__PACKAGE__) && $self->primary_key();
    return sprintf ("$url/%s", $self->primary_key);
}

sub out_html_label {
    #
    # Returns the label with tags for a link.
    #
    my $self = shift;
    return sprintf ("<A HREF=\"%s\">%s</A>", $self->out_url, $self->out_label);
}

sub out_html_label_nolink {
    #
    # Returns the label with tags for a link.
    #
    my $self = shift;
    return sprintf ("%s", $self->out_label);
}

sub out_html_abbrev {
    #
    # Returns an abbreviation with tags for a link.
    #

    my $self = shift;
    return sprintf ("<A HREF=\"%s\">%s</A>", $self->out_url, 
		    $self->out_abbrev);
}

sub lookup_path {
    #
    # Takes the info from an Apache path and returns an object which can
    # be derived from the path
    #

    my ($self, $path) = @_;
    # Look for path items containing something other than white space
    my @path = grep { /\S/ } split '/', $path;
    # If there's nothing there, then there's no object
    return undef unless @path;
    # Otherwise, do the lookup and return the result
    if ($self->split_by_school()) {
	return $self->new( _school => $path[0], _id => $path[1] );
    }
    else {
	return $self->lookup_key($path[0]);
    }
}

sub is_user_authorized {
    # 
    # Decide whether a named user is authorized to look at an item from
    # the database. By default, everything is public.
    #

    my ($self, $user) = @_;
    return 1;
}

sub escape_text {
    #
    # escape text before putting into database
    #

    my ($text) = @_;
    return XML::EscapeText::spec_chars_name($text);
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow> - Virtual class for manipulating entries in HSDB4 tables

=head1 DESCRIPTION

A virtual class intended to be subclassed.  Used to get retrieve individual rows from HSDB4 tables and perform generic manipulations on them.  Also intended to provide a standard set of methods for dealing with table rows to take advantage of polymorphism.

=head1 SYNOPSIS

    # A subclass of SQLRow
    package HSDB4::SQLRow::Subclass; 
    use HSDB4::SQLRow;
    @ISA = qw(SQLRow Exporter);

    # Set the table properties
    my $tablename         = 'tablename';
    my $primary_key_field = 'id_field';
    my @fields =       qw(id_field field1 num_field2 body_field ...
			  );
    my %numeric_fields = qw(num_field2 => 1
			    );
    my %blob_fields =    (body_field => 1
			  );

    # Create a cache
    my %cache = ();
    
    # Make a constructor that calls the SQLRow constructor
    sub new {
	# Find out what class we are
	my $class = shift;
	$class = ref $class || $class;
	# Call the super-class's constructor and give it all the values
	my $self = 
	    $class->SUPER::new ( _tablename => $tablename,
				 _fields => \@fields,
				 _blob_fields => \%blob_fields,
				 _numeric_fields => \%numeric_fields,
				 _primary_key_field => $primary_key_field,
				 _cache => \%cache,
				 _school => $school,
				 @_);
	# Finish initialization...
	...
	return $self;
    }

=cut

=head1 METHODS

=head2 Table Methods

B<table()> returns the name of the table in the database definition.

B<primary_key_field()> returns the name of the field which is the
primary key.

B<is_field_numeric()> returns TRUE if the field named in the argument
should be sorted numerically rather than lexically.

B<is_field_blob()> returns TRUE if the field named in the argument is
a BLOB field that should not be returned as a matter of course.

B<fields()> returns the list of fields in the table.

B<non_blob_fields()> returns the list of fields in the table which are
not BLOB (should be returns as a matter of course).

B<get_sql_table()> returns a B<HSDB4::SQLTable> object representation
of the table with the appropriate table name and non-BLOB field list.

=head2 Constructor

B<new()> intended to be used as the default creation tool for
subclasses.  It is required that subclasses which override it still
call it during the override.  Subclasses need to pass the
C<_tablename>, C<primary_key_field>, C<_fields>, C<_numeric_fields>,
C<_blob_fields>, and C<_cache> variables to B<HSDB4::SQLRow::new> so
that other B<SQLRow> functions can work properly.  B<new()> returns a
blank object which can then have data read into it in other ways.

=head2 Accessors

B<primary_key()> returns the value in the primary key field for a
particular row object. Also can be used to set it.

B<id()> returns a concatanation of the table name and the primary key
to be used as a unique identified for the row across all tables.

B<field_value()>

    $val = $rowobj->field_value ('field1');
    $rowobj->field_value ('field1', $newval);

Used to get or set the values in the object representations of the row.

B<get_field_values()> gets a the values for the fields named in the
arguments.

B<set_field_values()> is called with C<(key =E<gt> 'value')> pairs,
and it used to set all of the field/value pairs for a row object.

B<set_aux_info()> is called with C<(key =E<gt> 'value')> and is used
to set the values is a separate sub-hash which stores context
information, specifically information about from where an object is
linked.

B<aux_info()> is called with the name of C<aux_info> fields. It
returns the value of that C<aux_info> field, if it is set.

B<clear_aux_info()> clears all of the auxiliary information for a row.

=head2 Database Interaction

B<lookup_conditions()>

    @objs = HSDB4::SQLRow::Subclass->lookup_conditions ('OR',
							'field1=val',
							'field2=val');

Performs a lookup on a table based on the conditions given as
arguments and returns appropriate objects in a list.  The arguments to
the list are just like the C<-conditions> parameter to the
B<HSDB4::SQLSelect::new()> method.

B<lookup_key()> can be used to fill in the values an I<existing>
B<SQLRow> object of a particular B<SQLRow> subclass from the database
(or the cache) by the table's primary key, given as an argument.

B<lookup_all()> returns a big list of objects of the type which are
all of those in the databse.

B<lookup_fields()> returns the value of a particular set of fields for
a particular row object.

B<lookup_path()> converts the extra path information in a URI into a
primary key query for an object.

B<save()> takes the values of the object which have changed since its
initialization and saves them back to the database in using an
C<UPDATE> SQL command.  The arguments are the username/password to be
given for connecting to the database for this purpose; if they are not
given, it is assumed to be the default user, who might not have
sufficient permission. If the primary key is not set, then a C<INSERT>
command is used instead, and the C<mysql_insertid> is used to set the
primary key of the object.

B<save_replace()> saves an object where its primary key has been set
already. It will replace that value if it's already in the database.

=head2 Other Input Methods

B<in_xml()> is not yet implemented.  Most of it should be implemented
at the subclass level.  B<in_xml()> will probably eventually figure
out what the root level element is and create appropriate XML objects
and parse them.  Most of the business should probably be implemented
at the subclass level.

B<in_fdat_hash()> is not yet implemented, and should also probably be
implemented at the subclass level.

=head2 Output Methods

B<is_user_authorized()> takes a user name as an argument and decides
whether the named user is authorized to view the object.

B<out_url()> returns the URL to get to the primary display of the
object, as defined in B<HSDB4::Constants>.

B<out_edit_url()> returns a URL to an editable version of the page, as
defined in B<HSDB4::Constants>.

B<out_html_div()> returns a nicely formatted chunk of HTML,
appropriate for including in a page, wrapped in C<E<lt>DIVE<gt>> tags.

B<out_xml()> should be implemented at the subclass level.

B<out_html_row()> should be implemented by each subclass. The
overridden method should return a four-column HTML row for a summary
display.  (Note: C<COLSPAN=2> is OK, of course.)

B<out_label> should be overridden by the subclss and return a nice
name for the object

B<out_abbrev> should be overridden by the subclass and return a nice
abbreviation for the object.

B<out_html_label> uses the B<out_label()> method and returns the label wrapped in an HTML C<E<lt>A HREF="..."E<gt>> tag with the url of the object.

B<out_html_abbrev> is the same as C<out_html_label()>, but uses the
abbreviation rather than the full name.

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLSelect>.

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
