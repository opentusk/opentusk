package HSDB45::LDAP;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# This is a stub for the LDAP Module 

# This allows declaration use LDAP ':all';

# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.01';


# Preloaded methods go here.

1;
__END__

=head1 NAME


=head1 SYNOPSIS

  use LDAP;

=head1 DESCRIPTION

This stub replaces organization specific ldap integration module(s) 

=head2 EXPORT

None by default.

=head1 HISTORY

=item 0.01

Original version

LDAP

=back


=head1 SEE ALSO

In the original implementation there are two modules
One to auth to ldap and one to map LDAP user info to TUSK user info
If the user exists in LDAP 

=head1 AUTHOR

TLHS Tusk, <lt>opentusk@tufts.edu<gt>
