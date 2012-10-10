package HSDB4::SQLRow::NonUser;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

#
# File-private lexicals
#
my $tablename         = 'non_user';
my $primary_key_field = 'non_user_id';
my @fields =       qw(non_user_id email modified institution lastname firstname midname suffix degree body);
my %numeric_fields = ();
my %blob_fields =    (body => 1
		      );
my %cache = ();

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Do the default creation stuff
    #

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
				    @_);
    # Finish initialization...
    return $self;
}

#
# >>>>> Linked objects <<<<<
#

#
# >>>>>  Output Methods <<<<<
#

sub out_abbrev {
    #
    # SQLRow's function...
    #

    my $self = shift;
    return $self->out_short_name;
}

sub out_label {
    #
    # SQLRow's function...
    #

    my $self = shift;
    return $self->out_full_name; 
}

sub out_full_name {
    #
    # Make a nice full name for the user
    #

    my $self = shift;
    my ($fn, $ln, $mn, $sfx, $dg) = 
	$self->get_field_values(qw(firstname lastname midname suffix degree));
    return $self->primary_key unless $ln;
    # Process the suffix
    $sfx = '' unless $sfx;
    # Make sure there are not spaces in it
    $sfx =~ s/\s//g;
    # If it's a roman numeral (VIII or less, that is), just use a space...
    if ($sfx =~ /^[iv]+$/i) { $sfx = " $sfx" }
    # ...otherwise, use a comma and a space
    elsif ($sfx) { $sfx = ", $sfx" }
    # Just say lastname if we don't know anything else
    if (not $fn and not $mn and not $dg) { return "$ln" }
    # Otherwise, format it all out nicely
    return sprintf ("%s%s%s%s%s", $fn ? "$fn " : '', $mn ? "$mn " : '',
		    $ln, $sfx, $dg ? ", $dg" : '');
}

sub out_short_name {
    #
    # A short version of the user's name
    #

    my $self = shift;
    my ($fn, $ln, $mn) = 
	$self->get_field_values (qw(firstname lastname midname));
    return $self->primary_key unless $ln;
    my $out = "";
    # First initial, if available
    if ($fn) { $out .= sprintf "%s. ", substr ($fn, 0, 1) }
    # Middle initial, if available
    if ($mn) { $out .= sprintf "%s. ", substr ($mn, 0, 1) }
    # And tack on the last name
    if ($ln) { $out .= $ln }
    return $out;
}

1;

__END__

=head1 NAME

B<HSDB4::SQLRow::NonUser> - Instatiation of the a B<SQLRow> to
represent a non user (someone who is not a student or faculty).  Also serves as the
interface for user updates, profiles, preferences, etc.

=head1 SYNOPSIS

    use HSDB4::SQLRow::NonUser;
    
    # Make a new object
    my $user = HSDB4::SQLRow::NonUser->new ();
    # And feed in the data from the database
    $user->lookup_key ($key);

=head1 AUTHOR

Michael Kruckenberg <michael.kruckenberg@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>, L<HSDB4::SQLLink>, L<HSDB4::XML>.

=cut



