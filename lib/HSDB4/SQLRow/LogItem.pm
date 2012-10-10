package HSDB4::SQLRow::LogItem;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.9 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

require HSDB4::Constants;
use TUSK::Core::LogItemType;

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "log_item";
my $primary_key_field = "log_item_id";
my @fields = qw(log_item_id
                user_id
                hit_date
		log_item_type_id
                course_id
                content_id
                personal_content_id);
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();
my %logItemType = map { ( $_->getLabel , $_->getPrimaryKeyID() ) } @{TUSK::Core::LogItemType->lookup(" 1 = 1")};

# Creation methods

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    _dontescapesql => 1,
				    @_);
    # Finish initialization...
    return $self;
}

#
# >>>>> Linked objects <<<<<
#

#
# >>>>> Database methods <<<<<
#

sub save_loglist {
    #
    # Take a list of the form...
    #    ( [user_id, timestamp, type, course_id, content_id, p_content_id],
    #      [user_id, timestamp, type, course_id, content_id, p_content_id],
    #      ...
    #      [user_id, timestamp, type, course_id, content_id, p_content_id],
    #    )
    # ...and does a single giant insert into the database, and returns
    # a list of the number of rows affected followed by a message (for an
    # error log) if appropriate.  (-1 indicates an error before any database
    # writing).  undef *should* be included.
    #

    my $class = shift;
    my $dbh;
    my $rows = -1;
    my $tablename = $class->table;
    eval {
	# Make the database connection
	$dbh = HSDB4::Constants::def_db_handle;
	# Go through each entry and quote them
	my @values = ();
	my $col_count = 0;
	foreach my $entry (@_) {
	    my @quoted = ();
	    $col_count = 0;
	    foreach my $item (@$entry) {
	        $col_count++;
		if (defined $item) { 
			if ($col_count == 3) {
			# handle type field
				push @quoted,  $logItemType{$item};
			} else {
				push @quoted, $dbh->quote($item) }
			}
		else { 
			push @quoted, 'NULL' 
		}
	    }
	    push @values, '(' . join (',', @quoted) . ')' 
		if $quoted[2] ne 'NULL'
	}
	if (@values) {
	    # Start the SQL statement
	    my $sql = qq[INSERT INTO $tablename (user_id, hit_date, log_item_type_id, 
			  		         course_id, content_id, 
					         personal_content_id) 
 			 VALUES ];
	    # Now tack on the big list of items
	    $sql .= join (', ', @values);
	    # Now actually put it all in the database
	    $rows = $dbh->do($sql);
	}
    };
    # Get the error message if it's there
    my $msg = $@ if $@;
    # Return the results
    return ($rows, $msg);
}

#
# >>>>>  Input Methods <<<<<
#

sub in_xml {
    #
    # Suck in a bunch of XML and push it into the appropriate places
    #

    my $self = shift;
}

sub in_fdat_hash {
    #
    # Read in a hash of key => value pairs and make changes
    #

    my $self = shift;
    while (my ($key, $val) = splice(@_, 0, 2)) {
    }
}

#
# >>>>>  Output Methods  <<<<<
#

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;

}

package HSDB4::SQLRow::RecentLogItem;
use strict;
use vars qw(@ISA);

@ISA='HSDB4::SQLRow::LogItem';

my $r_primary_key_field = "recent_log_item_id";
my @r_fields = qw(recent_log_item_id
                user_id
                hit_date
                log_item_type_id
                course_id
                content_id
                personal_content_id);
my $r_tablename = 'recent_log_item';
my %r_cache = ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $r_tablename,
				    _fields => \@r_fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $r_primary_key_field,
				    _cache => \%r_cache,
				    @_);
    # Finish initialization...
    return $self;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::LogItem> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::LogItem;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects



=head2 Input Methods

B<in_xml()> is not yet implemenented.

B<in_fdat_hash()> is not yet implemented.

=head2 Output Methods

B<out_html_div()> 

B<out_xml()> is not yet implemented.

B<out_html_row()> 

B<out_label()> 

B<out_abbrev()> 

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut

