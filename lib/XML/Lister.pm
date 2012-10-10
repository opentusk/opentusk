package XML::Lister;

use strict;
use HSDB4::SQLRow;
use HSDB4::Constants qw/:school/;
use XML::Twig;

BEGIN {
    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub sqlrow_class {
    die "Must override XML::Lister::sqlrow_class().";
}

sub list_element_name {
    return "list";
}

sub get_xml_text {
    my $lister = shift;
    my $blank_obj;
    my %atts = ();
    if ($lister->sqlrow_class()->split_by_school()) {
	my $school = shift;
	get_school_db($school) or die "Got an invalid school.";
	$atts{school} = $school;
	$blank_obj = $lister->sqlrow_class()->new( _school => $school );
    }
    else {
	$blank_obj = $lister->sqlrow_class()->new();
    }
    my @objects = $blank_obj->lookup_conditions(@_);

    my $elt = XML::Twig::Elt->new($lister->list_element_name(), \%atts,
				  map { $lister->get_element_elt($_) } @objects);
    return $elt->sprint();
}

sub get_element_elt {
    my $lister = shift;
    my $object = shift;
    my %atts = ();
    if ($object->split_by_school()) {
	$atts{school} = ucfirst($object->school);
    }
    $atts{$object->primary_key_field} = $object->primary_key();
    return XML::Twig::Elt->new($object->table(), \%atts, $object->out_label());
}

1;
