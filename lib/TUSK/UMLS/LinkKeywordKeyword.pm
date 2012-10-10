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


package TUSK::UMLS::LinkKeywordKeyword;

=head1 NAME

B<TUSK::UMLS::LinkKeywordKeyword> - Class for manipulating entries in table link_keyword_keyword in tusk database

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
					'tablename' => 'link_keyword_keyword',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_keyword_keyword_id' => 'pk',
					'parent_keyword_id' => '',
					'child_keyword_id' => '',
					'concept_relationship' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
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

=item B<getParentKeywordID>

my $string = $obj->getParentKeywordID();

Get the value of the parent_keyword_id field

=cut

sub getParentKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('parent_keyword_id');
}

#######################################################

=item B<setParentKeywordID>

$obj->setParentKeywordID($value);

Set the value of the parent_keyword_id field

=cut

sub setParentKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_keyword_id', $value);
}


#######################################################

=item B<getChildKeywordID>

my $string = $obj->getChildKeywordID();

Get the value of the child_keyword_id field

=cut

sub getChildKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('child_keyword_id');
}

#######################################################

=item B<setChildKeywordID>

$obj->setChildKeywordID($value);

Set the value of the child_keyword_id field

=cut

sub setChildKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_keyword_id', $value);
}


#######################################################

=item B<getConceptRelationship>

my $string = $obj->getConceptRelationship();

Get the value of the concept_relationship field

=cut

sub getConceptRelationship{
    my ($self) = @_;
    return $self->getFieldValue('concept_relationship');
}

#######################################################

=item B<setConceptRelationship>

$obj->setConceptRelationship($value);

Set the value of the concept_relationship field

=cut

sub setConceptRelationship{
    my ($self, $value) = @_;
    $self->setFieldValue('concept_relationship', $value);
}



=back

=cut

### Other Methods

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

