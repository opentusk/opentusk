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


package HSDB4::XML::PharmAgent;

use strict;
BEGIN {
    require HSDB4::XML;
    require HSDB4::XML::XHTML;
}

# Shorthand for the XML types
my $simple = 'HSDB4::XML::SimpleElement';
my $empty = 'HSDB4::XML::EmptyElement';
my $attr = 'HSDB4::XML::Attribute';
my $element = 'HSDB4::XML::Element';

my $inline = HSDB4::XML::XHTML->inline_elements;
my $flow = HSDB4::XML::XHTML->flow_elements;

my $concept_id_attr = $attr->new (-name => 'concept_id');

sub xhtml_filter {
    my ($self, $writer) = @_;
    my %attrs = (class => 'title');
    $writer->startTag ('h3', %attrs);
    $writer->characters ($self->label);
    $writer->endTag;
    $writer->startTag ('div');
    # Go through the value list
    foreach my $node ($self->value) {
	next unless $node;
	# If it's a object, then get it to write itself to the writer
	if (ref $node) { $node->out_xml ($writer, 1) }
	# Otherwise, just put the text blob onto the list
	else { $writer->characters ($node) if $node =~ /\S/ }
    }
    $writer->endTag;
}

my $description = $element->new (-tag => 'description',
				 -allow_pcdata => 1,
				 -xhtml_filter => \&xhtml_filter,
				 -subelements => $inline);
my $mechanism = $element->new (-tag => 'mechanism',
			       -allow_pcdata => 1,
			       -xhtml_filter => \&xhtml_filter,
			       -subelements => $inline);
my $drug_of_choice = $element->new (-tag => 'drug_of_choice',
				    -allow_pcdata => 1,
				    -xhtml_filter => \&xhtml_filter,
				    -subelements => $inline);
my $pharmacokinetics = $element->new (-tag => 'pharmacokinetics',
				      -allow_pcdata => 1,
				      -xhtml_filter => \&xhtml_filter,
				      -subelements => $inline);
my $adverse_effects = $element->new (-tag => 'adverse_effects',
				     -allow_pcdata => 1,
				     -xhtml_filter => \&xhtml_filter,
				     -subelements => $inline);
my $contraindications = $element->new (-tag => 'contraindications',
				       -allow_pcdata => 1,
				       -xhtml_filter => \&xhtml_filter,
				       -subelements => $inline);

my $name = $element->new (-tag => 'name',
			  -subelements => $inline);
my $note = $element->new (-tag => 'note',
			  -subelements => $inline);
my $short_note = $element->new (-tag => 'short_note',
				-subelements => $inline);
my $notes = [ [$name], [$note], [$short_note] ];

my $indication = $element->new (-tag => 'indication',
				-attributes => [ $concept_id_attr ],
				-subelements => $notes);
my $adverse_effect = $element->new (-tag => 'adverse_effect',
				    -attributes => [ $concept_id_attr ],
				    -subelements => $notes);
my $contraindication = $element->new (-tag => 'contraindication',
				      -attributes => [ $concept_id_attr ],
				      -subelements => $notes);

my $pharm_body = [ [ $description,      0, 1 ],
		   [ $mechanism,        0, 1 ],
		   [ $drug_of_choice,   0, 1 ],
		   [ $pharmacokinetics, 0, 1 ],
		   [ $indication,       0, 0 ],
		   [ $adverse_effects,  0, 1 ],
		   [ $adverse_effect,   0, 0 ],
                   [ $contraindications,0, 0 ],
                   [ $contraindication, 0, 0 ]
		 ];

sub pharm_agent_xhtml {
    my ($self, $writer) = @_;
    $writer->startTag ('div');
    # Go through the value list
    foreach my $node ($self->value) {
	next unless $node;
	# If it's a object, then get it to write itself to the writer
	if (ref $node) { $node->out_xml ($writer, 1) }
	# Otherwise, just put the text blob onto the list
	else { $writer->characters ($node) if $node =~ /\S/ }
    }
    $writer->endTag;
}

my $status_attr = 
  $attr->new (-name => 'status',
	      -choices => { '0_blank' => 'Blank',
			    '1_started' => 'Work Started',
			    '2_review_wait' => 'Review Pending',
			    '3_review' => 'Being Reviewed',
			    '4_revision_wait' => 'Revision Pending',
			    '5_phaseidone' => 'Phase I Complete',
			  },
	      -default => '0_blank'
	     );

my $pharm_agent = $element->new (-tag => 'pharm_agent',
				 -label => 'Pharmacological Agent Information',
				 -subelements => $pharm_body,
				 -attributes => [ $concept_id_attr,
						  $status_attr,
						],
				 -xhtml_filter => \&pharm_agent_xhtml,
				 #-dtd_preface => $pharm_dtd_preface,
				 #-dtd_definition => $pharm_dtd_definition,
				);

sub description { return $description->new }
sub mechanism { return $mechanism->new }
sub drug_of_choice { return $drug_of_choice->new }
sub pharmacokinetics { return $pharmacokinetics->new }
sub status_attr { return $status_attr->new }
sub adverse_effects { return $adverse_effects->new }
sub adverse_effect { return $adverse_effect->new }
sub contraindication { return $contraindication->new }
sub contraindications { return $contraindications->new }
sub indication { return $indication->new }

sub new { return $pharm_agent->new }

1;
__END__
