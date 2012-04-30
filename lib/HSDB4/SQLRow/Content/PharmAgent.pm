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


package HSDB4::SQLRow::Content::PharmAgent;

use strict;

BEGIN {
    require HSDB4::SQLRow::Content;
    require HSDB4::SQLRow::Concept;
    require HSDB4::SQLRow::Objective::PharmCategory;
    require HSDB4::XML::PharmAgent;
    require HSDB4::SQLRow::UserGroup;
    use vars qw($VERSION @ISA);
    @ISA = qw(HSDB4::SQLRow::Content);
    $VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

my $tablename = "epharm.content";
my %cache = ();

sub max_cache_age { return 0; }

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

sub save {
    my $self = shift;
    $self->field_value ('body', $self->body->out_xml);
    $self->SUPER::save;
}

my $epharm_group_id = 45;
sub epharm_team {
    return HSDB4::SQLRow::UserGroup->new->lookup_key ($epharm_group_id);
}

sub parent_objectives {
    #
    # Return the objectives this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_objectives}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'epharm.link_objective_content'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_objectives} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_objectives}->parents();
}

sub body {
    #
    # Return an XML structure of the body
    #

    my $self = shift;
    unless ($self->{-body}) {
	$self->{-body} = HSDB4::XML::PharmAgent->new;
	my $bodytext = $self->field_value ('body');
	$self->{-body}->parse ($bodytext) if $bodytext;
    }
    return $self->{-body};
}

sub get_list_item {
    my ($self, $info_tag, $index) = @_;
    my $tag = $info_tag->tag;
    my @tags = $self->body->tag_values ($tag);
    return unless @tags && @tags > $index;
    return $tags[$index];
}

sub get_list_item_field {
    my ($self, $info_tag, $index, $name) = @_;
    my $item = $self->get_list_item ($info_tag, $index);
    my $tag = $info_tag->tag;
    my ($string) = $item->tag_values ($name);
    return unless $string;
    $string = $string->value;
    $string =~ s/\n>/>/msg;
    $string =~ /<$tag[^\>]*>(.+)<\/$tag[^\>]*>/;
    return $1;
}

sub get_list_name {
    my ($self, $info_tag, $index) = @_;
    return $self->get_list_item_field ($info_tag, $index, 'name');
}

sub get_list_short_note {
    my ($self, $info_tag, $index) = @_;
    return $self->get_list_item_field ($info_tag, $index, 'short_note');
}

sub get_list_note {
    my ($self, $info_tag, $index) = @_;
    return $self->get_list_item_field ($info_tag, $index, 'note');
}

sub get_list_concept {
}

sub set_list_name {
}

sub set_list_concept_id {
}

sub set_list_short_note {
}

sub set_list_note {
}

sub get_body_information {
    my $self = shift;
    my $info_tag = shift;
    my $tag = $info_tag->tag;
    my ($desc) = $self->body->tag_values ($tag);
    return unless $desc;
    my $string = $desc->out_xml;
    $string =~ s/\n>/>/msg;
    $string =~ /<$tag[^\>]*>(.+)<\/$tag[^\>]*>/ms;
    $string = $1;
    # FIXME: these shouldn't be specified like this.
    my %ents = (lt => '<', gt => '>', amp => '&');
    my $entsel = join ('|', keys %ents);
    $string =~ s/&($entsel);/$ents{$1}/gms;
    return $string;
}

sub set_body_information {
    my $self = shift;
    my $info_tag = shift;
    my $tag = $info_tag->tag;
    my $newval = shift;
    $newval =~ s/[\s\cJ\cM]+$//gsm;
    $newval =~ s/^\s+//gsm;
    my ($info) = $self->body->tag_values ($tag);
    eval {
	if ($info) {
	    $info->new->parse ("<$tag><![CDATA[" . $newval . "]]></$tag>");
	    $info->clear_contents;
	    $info->parse ("<$tag><![CDATA[" . $newval . "]]></$tag>");
	}
	else {
	    $info = $info_tag->new;
	    $info->parse ("<$tag><![CDATA[" . $newval . "]]></$tag>");
	    $self->body->xml_push ($info);
	}
    };
    if ($@) { return 0, $@ }
    return 1;
}

my ($description, $mechanism, $drug_of_choice, $pharmacokinetics,
    $adverse_effects, $contraindications) =
  (HSDB4::XML::PharmAgent->description,
   HSDB4::XML::PharmAgent->mechanism,
   HSDB4::XML::PharmAgent->drug_of_choice,
   HSDB4::XML::PharmAgent->pharmacokinetics,
   HSDB4::XML::PharmAgent->adverse_effects,
   HSDB4::XML::PharmAgent->contraindications,
  );

sub description {
    my $self = shift;
    return $self->get_body_information ($description);
}

sub set_description {
    my $self = shift;
    $self->set_body_information ($description, @_);
}

sub mechanism {
    my $self = shift;
    return $self->get_body_information ($mechanism);
}

sub set_mechanism {
    my $self = shift;
    $self->set_body_information ($mechanism, @_);
}

sub drug_of_choice {
    my $self = shift;
    return $self->get_body_information ($drug_of_choice, @_);
}

sub set_drug_of_choice {
    my $self = shift;
    $self->set_body_information ($drug_of_choice, @_);
}

sub pharmacokinetics {
    my $self = shift;
    return $self->get_body_information ($pharmacokinetics);
}

sub set_pharmacokinetics {
    my $self = shift;
    $self->set_body_information ($pharmacokinetics, @_);
}

sub adverse_effects {
    my $self = shift;
    return $self->get_body_information ($adverse_effects);
}

sub set_adverse_effects {
    my $self = shift;
    $self->set_body_information ($adverse_effects, @_);
}

sub contraindications {
    my $self = shift;
    return $self->get_body_information ($contraindications);
}

sub set_contraindications {
    my $self = shift;
    $self->set_body_information ($contraindications, @_);
}

my $status_attr = HSDB4::XML::PharmAgent->status_attr;

sub status {
    my $self = shift;
    my $status = $self->body->get_attribute_values('status');
    return $status->value if $status && $status->value;
    return $status_attr->default;
}

sub set_status {
    my $self = shift;
    my $value = shift;
    $self->body->set_attributes('status', $value);
}

sub out_html_status_options {
    my $self = shift;
    my $status = $self->status;
    my $outval = '';
    my %choices = $status_attr->choices;
    foreach (sort keys %choices) {
	$outval .= sprintf ("<option value=\"%s\"%s>%s</option>\n",
			    $_, $_ eq $status ? ' selected' : '',
			    $choices{$_});
    }
    return $outval;
}

sub concept {
    my $self = shift;
    my $concept_id = $self->body->get_attribute_values('concept_id');
    return unless $concept_id;
    return HSDB4::SQLRow::Concept->new->lookup_key ($concept_id->value);
}

sub set_concept_id {
    my $self = shift;
    my $value = shift;
    $self->body->set_attributes('concept_id', $value);
}

sub out_html_div {
    #
    # Return HTML stuff
    #
    my $self = shift;
    return $self->body->out_xhtml;
}

1;
__END__
