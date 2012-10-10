
package HSDB4::SQLRow::Preference;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "preference";
my $primary_key_field = [ 'user_id', 'preference' ];
my @fields = qw(user_id
                preference
                value);
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();

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
				    # _cache => \%cache,
				    _cache => {},
				    @_);
    # Finish initialization...
    return $self;
}

#
# >>>>> Linked objects <<<<<
#



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

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::Preference> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::Preference;
    
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

