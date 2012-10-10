# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package XML::Lister;

use strict;
use HSDB4::SQLRow;
use HSDB4::Constants qw/:school/;
use XML::Twig;

BEGIN {
    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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
