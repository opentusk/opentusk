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


package TUSK::Permission::RoleFunction;

=head1 NAME

B<TUSK::Permission::RoleFunction> - Class for manipulating entries in table permission_role_function in tusk database

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
					'tablename' => 'permission_role_function',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'role_function_id' => 'pk',
					'role_id' => '',
					'function_id' => '',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getRoleID>

    $string = $obj->getRoleID();

    Get the value of the role_id field

=cut

sub getRoleID{
    my ($self) = @_;
    return $self->getFieldValue('role_id');
}

#######################################################

=item B<setRoleID>

    $obj->setRoleID($value);

    Set the value of the role_id field

=cut

sub setRoleID{
    my ($self, $value) = @_;
    $self->setFieldValue('role_id', $value);
}


#######################################################

=item B<getFunctionID>

    $string = $obj->getFunctionID();

    Get the value of the function_id field

=cut

sub getFunctionID{
    my ($self) = @_;
    return $self->getFieldValue('function_id');
}

#######################################################

=item B<setFunctionID>

    $obj->setFunctionID($value);

    Set the value of the function_id field

=cut

sub setFunctionID{
    my ($self, $value) = @_;
    $self->setFieldValue('function_id', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getFunctionObject>

    $obj->getFunctionObject();

    Gets the TUSK::Permission::Function object associated with this record;  Should be only one object associated (1 to 1 relationship)

=cut

sub getFunctionObject{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Permission::Function');
}

#######################################################

=item B<getFunctionToken>

    $obj->getFunctionToken();

    Gets the Function Token from the associated TUSK::Permission::Function object

=cut

sub getFunctionToken{
    my ($self) = @_;
    my $obj =  $self->getFunctionObject();
    if ($obj){
	return $obj->getFunctionToken();
    }else{
	return();
    }
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

