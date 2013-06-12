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


package TUSK::Permission::Role;

=head1 NAME

B<TUSK::Permission::Role> - Class for manipulating entries in table permission_role in tusk database

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
					'tablename' => 'permission_role',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'role_id' => 'pk',
					'role_token' => '',
					'role_desc' => '',
					'feature_type_id' => '',
					'virtual_role' => ''
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

=item B<getRoleToken>

my $string = $obj->getRoleToken();

Get the value of the role_token field

=cut

sub getRoleToken{
    my ($self) = @_;
    return $self->getFieldValue('role_token');
}

#######################################################

=item B<setRoleToken>

$obj->setRoleToken($value);

Set the value of the role_token field

=cut

sub setRoleToken{
    my ($self, $value) = @_;
    $self->setFieldValue('role_token', $value);
}


#######################################################

=item B<getRoleDesc>

my $string = $obj->getRoleDesc();

Get the value of the role_desc field

=cut

sub getRoleDesc{
    my ($self) = @_;
    return $self->getFieldValue('role_desc');
}

#######################################################

=item B<setRoleDesc>

$obj->setRoleDesc($value);

Set the value of the role_desc field

=cut

sub setRoleDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('role_desc', $value);
}


#######################################################

=item B<getFeatureTypeID>

my $string = $obj->getFeatureTypeID();

Get the value of the feature_type_id field

=cut

sub getFeatureTypeID{
    my ($self) = @_;
    return $self->getFieldValue('feature_type_id');
}

#######################################################

=item B<setFeatureTypeID>

$obj->setFeatureTypeID($value);

Set the value of the feature_type_id field

=cut

sub setFeatureTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('feature_type_id', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getRoleFunctionObjects>

$obj->getRoleFunctionObjects();

Gets the TUSK::Permission::RoleFunctions objects associated with this record;

=cut

sub getRoleFunctionObjects{
    my ($self) = @_;
    return $self->getJoinObjects('TUSK::Permission::RoleFunction');
}

#######################################################

=item B<getFeatureTypeObject>

$obj->getFeatureTypeObject();

Gets the TUSK::Permission::FeatureType object associated with this record;  Should be only one object associated (1 to 1 relationship)

=cut

sub getFeatureTypeObject{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Permission::FeatureType');
}

#######################################################

=item B<getFeatureTypeToken>

$obj->getFeatureTypeToken();

Gets the FeatureType Token from the associated TUSK::Permission::FeatureType object

=cut

sub getFeatureTypeToken{
    my ($self) = @_;
    my $obj =  $self->getFeatureTypeObject();
    if ($obj){
	return $obj->getFeatureTypeToken();
    }else{
	return();
    }
}


#######################################################

=item B<getRoles>

my $roles = $obj->getRoles($feature_type_token);

Returns all the roles and associated functions for a particular $feature_type_token.

=cut

sub getRoles{
    my ($self, $feature_type_token) = @_;
    my $roles = $self->lookup("permission_feature_type.feature_type_token='" . $feature_type_token . "'", 
			      undef, 
			      undef, 
			      undef, 
			      [ 
				TUSK::Core::JoinObject->new("TUSK::Permission::FeatureType"),
				TUSK::Core::JoinObject->new("TUSK::Permission::RoleFunction",{'origkey' => "permission_role.role_id", 'joinkey' => 'role_id' } ),
				TUSK::Core::JoinObject->new("TUSK::Permission::Function",{'origkey' => "permission_role_function.function_id", 'joinkey' => 'function_id', 'objtree' => ['TUSK::Permission::RoleFunction'] })
			      ] );
    return $roles;
}

#######################################################

=item B<getPrettyRoleToken>

my $string = $obj->getPrettyRoleToken();

Returns a pretty form of the role_token field

=cut

sub getPrettyRoleToken{
    my ($self) = @_;
    return TUSK::Core::SQLRow::MakePretty($self->getRoleToken());
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

