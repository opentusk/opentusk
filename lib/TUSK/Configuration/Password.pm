package TUSK::Configuration::Password;

=head1 NAME

B<TUSK::Configuration::Password> - Class for encrypting and decrypting test

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Storable;
use Carp qw(confess cluck);

sub encrypt {
	my ($class, $plainText) = @_;
	if($class ne __PACKAGE__) {$plainText = $class;}
	my @oneNumberArray;
	my @twoNumberArray;
	foreach my $character (split //, $plainText) {
		my $hexValueOfCharacter = sprintf("%x", ord($character));
		my ($value1, $value2) = split //, $hexValueOfCharacter;
		push @oneNumberArray, $value1;
		push @twoNumberArray, $value2;
	}

	@twoNumberArray = reverse @twoNumberArray;
	my $cypherText;
	foreach (0..$#oneNumberArray) {
		$cypherText.= chr(hex($oneNumberArray[$_] . $twoNumberArray[$_]));
	}
	return "enc($cypherText)";
}

sub decrypt {
	my ($class, $cypherText) = @_;
	if($class ne __PACKAGE__) {$cypherText = $class;}

	if($cypherText !~ /^enc\(.*\)$/)	{return $cypherText;}
	$cypherText =~ s/^enc\(//;
	$cypherText =~ s/\)$//;

	my @oneNumberArray;
	my @twoNumberArray;
	foreach my $character (split //, $cypherText) {
		my $hexValueOfCharacter = sprintf("%x", ord($character));
		my ($value1, $value2) = split //, $hexValueOfCharacter;
		push @oneNumberArray, $value1;
		push @twoNumberArray, $value2;
	}

	@twoNumberArray = reverse @twoNumberArray;
	my $plainText;
	foreach (0..$#oneNumberArray) {
		$plainText.= chr(hex($oneNumberArray[$_] . $twoNumberArray[$_]));
	}
	return $plainText;
}

sub isEncrypted {
	my ($class, $cypherText) = @_;
	if($class ne __PACKAGE__) {$cypherText = $class;}

	if($cypherText !~ /^enc\(.*\)/) {return 0;}
	else				{return 1;}
}
1;
