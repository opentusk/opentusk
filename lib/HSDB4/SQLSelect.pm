=head1 NAME

B<HSDB4::SQLSelect> - Object representation of a SQL select statement

=head1 DESCRIPTION

B<HSDB4::SQLSelect> is intended as an object interface for creating and manipulating SQL select statements.

The idea is to quickly create the object and store it not as a complicated string that cannot be manipulated but as an object so that pieces can be added and dropped and the final form is only generated at query time.

The module also includes B<HSDB4::SQLCondition>, which is a simple class for manipulating AND/OR structures and returning the complete SQL at the end.

=head1 SYNOPSIS

 use HSDB4::SQLSelect;

 # Prepare the statement  
 $select = HSDB4::SQLSelect->new (-tables => [ 'table1' ],
				  -fields => [ ],
				  -conditions => [ 'OR',
						   'table1.baz > 32',
						   'table1.boz < 16' ] 
				  );
 # Get/set table list
 print join (", ", $select->tables);
 # Append to table list
 $select->add_tables ('table2');
 # Get/set field list
 print join (", ", $select->fields);
 # Append to the field list
 $select->add_fields ('foo', 'bar', 'baz');
 $select->add_fields ('table2.qux');
 # Get a Condition object back with condition() and manipulate it
 $select->conditions()->add_and ('table1.quxx = table2.qux');
 $select->conditions()->add_or ('USER = frank');
 # Get/set order_by list
 $select->order_by ('foo');
 # Append to the order list
 $self->add_order_by ('bar')

 # Now, form the whole statement and print it out
 print $select->statement ();
 # Or send it to a database connection.

=cut

# POD continues after code...

package HSDB4::SQLTable;

use strict;

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = { -fields => [] };
    bless $self, $class;
    if (@_ == 1) {
	$self->table($_[0]);
	$self->alias($_[0]);
	return $self;
    }
    my %inattrs = @_;

    if ($inattrs{-table}) { $self->table($inattrs{-table}) }

    if ($inattrs{-fields}) { $self->fields($inattrs{-fields}) }

    if ($inattrs{-alias}) { $self->alias($inattrs{-alias}) }

    return $self;
}

sub fields {
    my $self = shift;
    $self->{-fields} = () if @_;
    foreach (@_) {
	if (ref($_) eq 'ARRAY') { push @{$self->{-fields}}, @$_ }
	else { push @{$self->{-fields}}, $_ }
    }
    return @{$self->{-fields}};
}

sub fullfields {
    my $self = shift;
    my $alias = $self->alias;
    return map { $self->alias . '.' . $_ } $self->fields;
}

sub add_fields {
    my $self = shift;
    push @{$self->{-fields}}, @_;
    return @{$self->{-fields}};
}

sub table {
    my $self = shift;
    $self->{-table} = shift if @_;
    return $self->{-table};
}

sub alias {
    my $self = shift;
    $self->{-alias} = shift if @_;
    return $self->{-alias} || $self->{-table};
}

sub from_item {
    my $self = shift;
    my $from = $self->table;
    if ($self->alias ne $from) { $from .= ' ' . $self->alias }
    return $from;
}

package HSDB4::SQLCondition;

use strict;

sub new {
    # Takes an arbitrary number of strings and joins them together as a
    # set of conditions, and returns the object. If first element is "AND"
    # or "OR", that is considered a connector; otherwise, the elements are
    # considered joined by "AND".  Returns the blessed reference.

    # Get either the class name or a prototype reference, and parse it to
    # a class name
    my $class = shift;
    $class = ref($class) || $class;
    # Create our hash reference and bless it
    my $self = {};
    bless $self, $class;

    # Initialize the ANDOR element of the hash
    
    if ($_[0] and ($_[0] eq 'AND' or $_[0] eq 'OR')) { $self->{ANDOR} = shift }
    else { $self->{ANDOR} = 'AND' }

    # Initialize the actual condition list
    my @conds = ();
    # Foreach remaining argument, check if it's an array reference; if it is,
    # recursively call this function on it, and push that into the tree; if not
    # (it's a string, or possible a SQLCondition itself!) just push it onto
    # the end of the condition list.
    foreach (@_) { 
	push @conds, ref eq 'ARRAY' ? $HSDB4::SQLCondition->new (@{$_}) : $_;
    }
    # Now, store a reference to the condition list in the self hashref.
    $self->{CONDS} = \@conds;

    return $self;
}

sub add_and {
    # Combines conditions/conditions objects with AND.
    # Obviously, if the condition is an AND already, that's no problem.
    # If it wasn't, we have to make a new object to AND with.
    my $self = shift;
    return unless @_; # Forget it if there aren't conditions to combine
    if ($self->{ANDOR} eq 'AND') { push @{$self->{CONDS}}, @_ }
    else { 
	my $subcond = $self->new ($self->{ANDOR}, @{$self->{CONDS}});
	$self->{ANDOR} = 'AND';
	$self->{CONDS} = [ $subcond, @_ ];
    }
    return $self;
}

sub add_or (\$@) {
    # Combines conditions/conditions objects with OR.
    # Obviously, if the condition is an OR already, that's no problem.
    # If it wasn't, we have to make a new object to OR with.
    my $self = shift;
    return unless @_; # Forget it if there aren't conditions to combine
    if ($self->{ANDOR} eq 'OR') { push @{$self->{CONDS}}, @_ }
    else { 
	my $subcond = $self->new ($self->{ANDOR}, @{$self->{CONDS}});
	$self->{ANDOR} = 'OR';
	$self->{CONDS} = [ $subcond, @_ ];
    }
    return $self;
}

sub get_sql {
    # Return the actual SQL code which is the condition.
    my $self = shift;
    return '' unless @{$self->{CONDS}};
    # Get the connector
    my $connector = sprintf " %s ", $self->{ANDOR};
    # Now recurse down the tree structure and pull out the SQL string
    return join $connector, map { ref($_) ? '(' . $_->get_sql . ')' : $_ 
				  } @{$self->{CONDS}};
}

package HSDB4::SQLSelect;

use strict;
BEGIN {
    require Exporter;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.15 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}
use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
# my (...) = (...);

sub new {
    # Get either the class name or a prototype reference, and parse it to
    # a class name
    my $class = shift;
    $class = ref($class) || $class;
    # Create our hash reference and bless it
    my $self = {};
    bless $self, $class;

    my %inargs = @_;

    # Process the -tables or -table argument if it exists
    $inargs{-tables} = $inargs{-table} if $inargs{-table};
    if ($inargs{-tables} and ref $inargs{-tables} eq 'ARRAY') {
	$self->tables (@{$inargs{-tables}});
    }
    elsif ($inargs{-tables}) {
	$self->tables ($inargs{-tables});
    }

    # Process the -fields or -field argument if it exists
    $inargs{-fields} = $inargs{-field} if $inargs{-field};
    if ($inargs{-fields} and ref $inargs{-fields} eq 'ARRAY') {
	$self->fields (@{$inargs{-fields}})
    }
    elsif ($inargs{-fields}) {
	$self->fields ($inargs{-fields});
    }

    # Process the -order_by argument if it exists
    if ($inargs{-order_by} and ref $inargs{-order_by} eq 'ARRAY') {
	$self->order_by (@{$inargs{-order_by}});
    }
    elsif ($inargs{-order_by}) {
	$self->order_by ($inargs{-order_by});
    }

    # Process the conditions argument if it exists
    if ($inargs{-conditions}) {
	# If it's a SQLCondition, just use that object
	if (ref $inargs{-conditions} eq 'HSDB4::SQLCondition') {
	    $self->{-conditions} = $inargs{-conditions};
	}
	# If it's an array reference, use the array
	elsif (ref $inargs{-conditions} eq 'ARRAY') {
	    $self->{-conditions} = 
	      HSDB4::SQLCondition->new (@{$inargs{-conditions}});
	}
	# Otherwise, just treat it as a single string
	else {
	    $self->{-conditions} = 
	      HSDB4::SQLCondition->new ($inargs{-conditions});
	}
    }

    # And return the object we built
    return $self;
}

# Manipulate Tables
sub tables {
    my $self = shift;
    # If we have arguments, we're going to re-initialize the table list
    # and then add the arguments to it
    if (@_) {
	# Reinitialize the table list and the table index
	$self->{-tables} = [];
	# And then add the tables
	$self->add_tables (@_);
    }
    # Now, return a list of the aliases of the tables
    return @{$self->{-tables}} if @{$self->{-tables}};
    return;
}

sub add_tables {
    # Get our current object
    my $self = shift;
    # Initialize the -tables attribute with a blank array if it doesn't exist
    $self->{-tables} = [] unless defined $self->{-tables};
    # Foreach argument...
    foreach (@_) {
	# Check to see if it's already a HSDB4::SQLTable; if it is, just
	# push it on
	if (ref $_ and $_->isa ('HSDB4::SQLTable')) { 
	    push @{$self->{-tables}}, $_;
	}
	# Otherwise, make sure it isn't a ref, and push on a newly created
	# SQLTable object
	elsif (not ref $_) {
	    # Create the new SQLTable with the same table name and alias
	    # and a blank field list
	    my $newtable = HSDB4::SQLTable->new (-table => $_, -alias => $_,
						 -fields => []);
	    # And push it onto the list...
	    push @{$self->{-tables}}, $newtable;
	}
    }
}

sub get_table {
    # Return the actual SQLTable objects as indicated by their aliases 

    # Get the object in question
    my $self = shift;
    # If the user is looking for a list...
    if (wantarray) {
	# Set up a list for them
	my @return_tables = ();
	# Check all their inputs
	foreach my $input (@_) {
	    # Check all the table aliases
	    foreach (@{$self->{-tables}}) {
		# ... and add the ones that match to the lsit
		push (@return_tables, $_), last if $input eq $_->alias;
	    }
	}
	# Now return them
	return @return_tables;
    }
    # But if the user is looking for a scalar...
    else {
	# Get a place to put it...
	my $return_table = undef;
	# Find out what they're looking for...
	my $input = shift;
	# And check each table to see whether it matches
	foreach (@{$self->{-tables}}) {
	    $return_table = $_, last if $input eq $_->alias;
	}
	# ... and return whatever we got
	return $return_table;
    }
}

# Manipulate Fields
sub fields {
    my $self = shift;
    $self->{-fields} = [ @_ ] if @_;
    return @{$self->{-fields}} if $self->{-fields};
    return;
}

sub all_fields {
    my $self = shift;
    return $self->fields, map { $_->fullfields } $self->tables;
}

sub add_fields {
    # Get our current object
    my $self = shift;
    # For each field candidate...
    foreach (@_) {
	my $table;
	# If the name is of the form "foo.bar", see if we have a table with
	# alias "foo", and if we do, get it in $table, and push the field
	# "bar" onto the end of that.
	if (/^(\w+)\.(\w+)$/ and $table = $self->get_table($1)) {
	    $table->add_fields ($2);
	}
	# Otherwise, push it onto the end of the select statement's field list
	# instead
	else { 
	    # Initialize the -fields attribute with a blank array if necessary
	    $self->{-fields} = [] unless $self->{-fields};
	    push @{ $self->{-fields} }, $_;
	}
    }
    return $self->fields;
}

# Manipulate Conditions (HSDB4::SQLCondition object)
sub conditions {
    # Get the current object
    my $self = shift;
    # If we're being passed something, make it the new -conditions
    $self->{-conditions} = HSDB4::SQLCondition->new (@_) if @_;
    # Return whatever the current -conditions attribute is
    return  $self->{-conditions} if $self->{-conditions};
    return;
}

# Manipulate Order
sub order_by {
    # Get the current object
    my $self = shift;
    # Set -order_by if we're being passed arguments
    $self->{-order_by} = [ @_ ] if @_;
    # Return the current -order_by
    return @{$self->{-order_by}} if $self->{-order_by};
    return;
}

# Manipulate Limit
sub limit {
    # Get the current object
    my $self = shift;
    my $value = shift;
    # Set -limit if we're being passed arguments
    $self->{-limit} = $value  if $value;
    # Return the current -limit
    return $self->{-limit} if $self->{-limit};
    return;
}

sub add_order_by {
    # Get our current object
    my $self = shift;
    # Initialize -order_by if it doesn't already exist
    $self->{-order_by} = [] unless $self->{-order_by};
    # And add the arguments to whatever our current object is
    push @{ $self->{-order_by} }, @_;
    return $self->order_by;
}

# Get the SQL statement out
sub get_sql {
    # Get the current object
    my $self = shift;

    # Do basic error checking...
    die "No tables named for SELECT" unless $self->tables;

    # Start with SELECT; use the field list if we have it, * if not
    my $statement = 'SELECT ';
    $statement .= join (', ', 
			$self->fields,
			map { $_->fullfields } $self->tables 
			) . "\n";
    
    # Now do FROM the table list
    $statement .= "FROM " . 
	join (', ', map { $_->from_item } $self->tables) . "\n";
    
    # Now add in WHERE if we have conditions...
    $statement .= "WHERE " . $self->conditions()->get_sql() . "\n"
	if $self->conditions()->get_sql();

    # Toss in ORDER BY
    $statement .= "ORDER BY " . join (', ', $self->order_by) . "\n"
	if $self->order_by;
    
    # why not add a LIMIT here
    $statement .= "LIMIT " . $self->limit ."\n" if $self->limit;

    return $statement;

}

1;
__END__

=head1 B<HSDB4::SQLSelect> Methods

B<new()> accepts a named parameter list and returns an appropriately
initialized B<SQLSelect> object.  All of the named parameters are
optional; they may be in any order.  If a value is a scalar, its
attribute will be initialized as a list containing only that one
item. If a value is an array reference, the list will be initialized
with a copy of that array. In addition, the C<-conditions> attribute
may be initialized with a B<SQLCondition> object.  The individual
elements are any string that might be part of the SELECT, FROM, WHERE,
or ORDER BY clauses in a SQL SELECT statement.

    $sel = HSDB4::SQLSelect->new (-tables => [ ... ],
				  -fields => [ ... ],
				  -order_by => [ ... ],
				  -conditions => [ ... ] );

B<tables()> sets/gets the table list of the object.

    # Reset tables, regardless of value
    $sel->tables ('foo', 'bar b', 'bar b2', ...);
    # Return the list of tables
    @tables = $sel->tables;

B<add_tables()> appends table names to the list of tables in the
object, and returns the new list of tables.

    # Append table names to the list
    @newlist = $sel->add_tables ('qux');

B<fields()> sets/gets the field list of the object.

    # Reset fields, regardless of value
    $sel->fields ('foo.cat', 'b.dog', 
		  'foo.cat + b.dog as total', ...);
    # Return the list of fields
    @fields = $sel->fields;

B<add_fields()> appends field names to the list of fields in the
object, and returns the new list of fields.

    # Append field names to the list
    @newlist = $sel->add_field ('qux.fish');

B<order_by()> sets/gets the order_by field list of the object.

    # Reset order_by, regardless of value
    $sel->order_by ('total');
    # Return the list of order_by
    @order_by = $sel->order_by;

B<add_order_by()> appends fields names to the list of fields to order
by in the object, and returns the new list of order_by.

    # Append order_by field names to the list
    @newlist = $sel->add_order_by ('qux.fish');

B<get_sql()> forms and returns the actual SQL statement that has been
built up.  The different clauses are separated by newlines.  This
output can then be sent to a SQL engine.

=head1 B<HSDB4::SQLCondition> Methods

B<new()> forms a new B<SQLCondition> from the listed items.  If the
first item of the list is the string "AND" or "OR", that is considered
the connector for the top level of the condition set.  If the first
element is I<not> AND/OR, then AND is assumed.  The rest of the
elements of the list can be one of the following:

=over 4

=item *

Simple strings which represent conditions.

=item *

Array references which will be translated into B<SQLCondition> objects and joined to the tree.

=item *

B<SQLCondition> objects, which are joined into the tree.

=back

    $cond = HSDB4::SQLCondition->new ("OR", "foo=1", "bar in (1,3)",
				      ["AND", 'baz like "%nap"' ]
				      );


B<add_or()> or B<add_add()> Appends (a) new condition(s) to the top level of the condition set, using either AND or OR.

B<get_sql()> outputs the total condition set, with appropriate
parentheses.  Usable as part of a B<HSDB4::SQLSelect>'s WHERE clause.

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=head1 BUGS

=over 4

=item *

Inadequate testing is a major bug.  Do I<you> want to help test it?

=item *

Doesn't yet handle GROUP BY clauses, though this is simple to fix.

=item *

Doesn't automatically related tables and fields.  There should be a way to take care of this automatically, but I haven't sorted it out yet.  When this gets implemented, the odds are that the interface will change and break your old code.  Sorry.

=item *

B<SQLCondition> should break the individual conditions up more finely, so they aren't just strings; they should be objects down to the operators and operands so that you could more easily parse the specifics of your statement.  I'm beginning to understand why LISP was a Good Thing.

=item *

B<SQLCondition> might have '?' in it for B<DBI> (see L<DBI>). The order of those is important for using them, but it's hard to tell what order things came out in.  This should be fixed somehow.

=back

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=cut



