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


package TUSK::UMLS::UmlsDefinition;

=head1 NAME

B<TUSK::UMLS::UmlsDefinition> - Class for manipulating entries in table umls_definition in tusk database

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
					'tablename' => 'umls_definition',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'umls_definition_id' => 'pk',
					'umls_definition_type_id'=>'',
					'keyword_id' => '',
					'definition' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [
					TUSK::Core::JoinObject->new("TUSK::UMLS::UmlsDefinitionType")
					],
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

=item B<getDefinition>

my $string = $obj->getDefinition();

Get the value of the definition field

=cut

sub getDefinition{
    my ($self) = @_;
    return $self->getFieldValue('definition');
}

#######################################################

=item B<setDefinition>

$obj->setDefinition($value);

Set the value of the definition field

=cut

sub setDefinition{
    my ($self, $value) = @_;
    $self->setFieldValue('definition', $value);
}


#######################################################

=item B<getUmlsDefinitionTypeID>

my $string = $obj->getUmlsDefinitionTypeID();

Get the value of the umls_definition_type_id field

=cut

sub getUmlsDefinitionTypeID{
    my ($self) = @_;
    return $self->getFieldValue('umls_definition_type_id');
}

#######################################################

=item B<setUmlsDefinitionTypeID>

$obj->setUmlsDefinitionTypeID($value);

Set the value of the umls_definition_type_id field

=cut

sub setUmlsDefinitionTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('umls_definition_type_id', $value);
}



=back

=cut

### Other Methods

sub getUmlsDefinitionTypeObject {
        my $self = shift;
        return $self->getJoinObject('TUSK::UMLS::UmlsDefinitionType');

}


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

