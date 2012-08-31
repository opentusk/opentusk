package XML::Twig::Compare;

use strict;
use vars qw(@EXPORT);
use base qw(Exporter);
@EXPORT = qw(compare_elts);

require XML::Twig;

sub compare_elts {
    my ($elt1, $elt2) = @_;

    # Make sure the inputs are reasonable
    die "Must pass XML::Twig::Elt objects" 
	unless ref $elt1 && $elt1->isa ('XML::Twig::Elt') and ref $elt2 && $elt2->isa ('XML::Twig::Elt');

    # Same Element name
    return unless $elt1->gi eq $elt2->gi;

    # If they're text, then compare the text
    if ($elt1->is_text) {
	if ($elt1->text eq $elt2->text) { return 1 }
	else { return }
    }
    # Check the attributes
    {
	my $atts1 = $elt1->atts() || {};
	my $atts2 = $elt2->atts() || {};
	# Fail unless the keys look the same
	return unless join (' ', sort keys %$atts1) eq join (' ', sort keys %$atts2);
	# And fail unless all the values are the same
	for (keys %$atts1) { return unless $atts1->{$_} eq $atts2->{$_} }
    }

    # Check the children one by one...
    {
	my @children1 = $elt1->children ();
	my @children2 = $elt2->children ();
	# Make sure they have the same number of children
	return unless @children1 == @children2;
	# And check them all in sequence
	while (@children1 && @children2) {
	    return unless compare_elts (shift @children1, shift @children2);
	}
    }

    # Well, they must be the same, then :-)
    return 1;
}

1;
__END__

=head1 NAME

XML::Twig::Compare - Routine to test XML::Twig::Elt objects for equality.

=head1 SYNOPSIS

    use XML::Twig;
    use XML::Twig::Compare;

    my $twig = XML::Twig->new;
    $twig->parsefile ('test1.xml');
    my $elt1 = $twig->first_elt ('some_tag');
    $twig->parsefile ('test2.xml');
    my $elt2 = $twig->second_elt ('some_tag');

    if (compare_elts ($elt1, $elt2)) { print "They're equal!" }
    else { print "They're not equal." }

=head1 DESCRIPTION

XML::Twig::Compare compares two XML element trees for equality. It does this by performing the following checks:

=over 4

=item *

Same tag names.

=item *

Same text, if they're text elements.

=item *

Same attributes are declared, and set to the same values (note that attribute order is not significant).

=item *

Children are the same (by the same criteria).

=back

If comments are dropped and spaces are discarded by XML::Twig (as they are by default), then these are also not factors.

=head1 AUTHOR

Copyright (c) 2001 Tarik Alkasab, E<lt>tarik@alkasab.comE<gt>

All rights reserved. This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<XML::Twig>

=cut


