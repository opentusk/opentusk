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


package TUSK::UMLS::UmlsDefinitionType;

=head1 NAME

B<TUSK::UMLS::UmlsDefinitionType> - Class for manipulating entries in table umls_definition_type in tusk database

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
					'tablename' => 'umls_definition_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'umls_definition_type_id' => 'pk',
					'definition_type_name' => '',
					'definition_type_code' => '',
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

=item B<getDefinitionTypeName>

my $string = $obj->getDefinitionTypeName();

Get the value of the definition_type_name field

=cut

sub getDefinitionTypeName{
    my ($self) = @_;
    return $self->getFieldValue('definition_type_name');
}

#######################################################

=item B<setDefinitionTypeName>

$obj->setDefinitionTypeName($value);

Set the value of the definition_type_name field

=cut

sub setDefinitionTypeName{
    my ($self, $value) = @_;
    $self->setFieldValue('definition_type_name', $value);
}


#######################################################

=item B<getDefinitionTypeCode>

my $string = $obj->getDefinitionTypeCode();

Get the value of the definition_type_code field

=cut

sub getDefinitionTypeCode{
    my ($self) = @_;
    return $self->getFieldValue('definition_type_code');
}

#######################################################

=item B<setDefinitionTypeCode>

$obj->setDefinitionTypeCode($value);

Set the value of the definition_type_code field

=cut

sub setDefinitionTypeCode{
    my ($self, $value) = @_;
    $self->setFieldValue('definition_type_code', $value);
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

