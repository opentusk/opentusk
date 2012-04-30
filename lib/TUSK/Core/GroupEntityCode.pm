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


package TUSK::Core::GroupEntityCode;

=head1 NAME

B<TUSK::Core::GroupEntityCode> - Class for manipulating entries in table group_entity_code in tusk database

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
					'tablename' => 'group_entity_code',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'group_entity_code_id' => 'pk',
					'group_entity_id' => '',
					'code' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
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

=item B<getGroupEntityID>

    $string = $obj->getGroupEntityID();

    Get the value of the group_entity_id field

=cut

sub getGroupEntityID{
    my ($self) = @_;
    return $self->getFieldValue('group_entity_id');
}

#######################################################

=item B<setGroupEntityID>

    $string = $obj->setGroupEntityID($value);

    Set the value of the group_entity_id field

=cut

sub setGroupEntityID{
    my ($self, $value) = @_;
    $self->setFieldValue('group_entity_id', $value);
}


#######################################################

=item B<getCode>

    $string = $obj->getCode();

    Get the value of the code field

=cut

sub getCode{
    my ($self) = @_;
    return $self->getFieldValue('code');
}

#######################################################

=item B<setCode>

    $string = $obj->setCode($value);

    Set the value of the code field

=cut

sub setCode{
    my ($self, $value) = @_;
    $self->setFieldValue('code', $value);
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

