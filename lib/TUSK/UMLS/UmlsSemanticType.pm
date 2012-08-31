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


package TUSK::UMLS::UmlsSemanticType;

=head1 NAME

B<TUSK::UMLS::UmlsSemanticType> - Class for manipulating entries in table umls_semantic_type in tusk database

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
					'tablename' => 'umls_semantic_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'umls_semantic_type_id' => 'pk',
					'semantic_type_id' => '',
					'semantic_type' => '',
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

=item B<getSemanticTypeID>

my $string = $obj->getSemanticTypeID();

Get the value of the semantic_type_id field

=cut

sub getSemanticTypeID{
    my ($self) = @_;
    return $self->getFieldValue('semantic_type_id');
}

#######################################################

=item B<setSemanticTypeID>

$obj->setSemanticTypeID($value);

Set the value of the semantic_type_id field

=cut

sub setSemanticTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('semantic_type_id', $value);
}


#######################################################

=item B<getSemanticType>

my $string = $obj->getSemanticType();

Get the value of the semantic_type field

=cut

sub getSemanticType{
    my ($self) = @_;
    return $self->getFieldValue('semantic_type');
}

#######################################################

=item B<setSemanticType>

$obj->setSemanticType($value);

Set the value of the semantic_type field

=cut

sub setSemanticType{
    my ($self, $value) = @_;
    $self->setFieldValue('semantic_type', $value);
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

