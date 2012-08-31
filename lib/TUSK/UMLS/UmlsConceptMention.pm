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


package TUSK::UMLS::UmlsConceptMention;

=head1 NAME

B<TUSK::UMLS::UmlsConceptMention> - Class for manipulating entries in table umls_concept_mention in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'umls_concept_mention',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'umls_concept_mention_id' => 'pk',
					'keyword_id' => '',
					'content_id' => '',
					'context_mentioned' => '',
					'map_weight' => '',
					'mapped_text' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_join_objects => [
                                        TUSK::Core::JoinObject->new("TUSK::Core::Keyword")
                                        ],
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getKeywordID>

my $string = $obj->getKeywordID();

Get the value of the keyword_id field

=cut

sub getKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('keyword_id');
}

#######################################################

=item B<setKeywordID>

$obj->setKeywordID($value);

Set the value of the keyword_id field

=cut

sub setKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('keyword_id', $value);
}


#######################################################

=item B<getContentID>

my $string = $obj->getContentID();

Get the value of the content_id field

=cut

sub getContentID{
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}

#######################################################

=item B<setContentID>

$obj->setContentID($value);

Set the value of the content_id field

=cut

sub setContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_id', $value);
}


#######################################################

=item B<getContextMentioned>

my $string = $obj->getContextMentioned();

Get the value of the context_mentioned field

=cut

sub getContextMentioned{
    my ($self) = @_;
    return $self->getFieldValue('context_mentioned');
}

#######################################################

=item B<setContextMentioned>

$obj->setContextMentioned($value);

Set the value of the context_mentioned field

=cut

sub setContextMentioned{
    my ($self, $value) = @_;
    $self->setFieldValue('context_mentioned', $value);
}


#######################################################

=item B<getMapWeight>

my $string = $obj->getMapWeight();

Get the value of the map_weight field

=cut

sub getMapWeight{
    my ($self) = @_;
    return $self->getFieldValue('map_weight');
}

#######################################################

=item B<setMapWeight>

$obj->setMapWeight($value);

Set the value of the map_weight field

=cut

sub setMapWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('map_weight', $value);
}


#######################################################

=item B<getMappedText>

my $string = $obj->getMappedText();

Get the value of the mapped_text field

=cut

sub getMappedText{
    my ($self) = @_;
    return $self->getFieldValue('mapped_text');
}

#######################################################

=item B<setMappedText>

$obj->setMappedText($value);

Set the value of the mapped_text field

=cut

sub setMappedText{
    my ($self, $value) = @_;
    $self->setFieldValue('mapped_text', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getKeywordObject>

    $keyword = $obj->getKeywordObject($value);

    Return the TUSK::Core::Keyword object associated with this link record

=cut

sub getKeywordObject {
        my $self = shift;
        return $self->getJoinObject("TUSK::Core::Keyword");
}

=back


=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

