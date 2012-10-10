package TUSK::Permission::UserRole;

=head1 NAME

B<TUSK::Permission::UserRole> - Class for manipulating entries in table permission_user_role in tusk database

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

use TUSK::Core::HSDB4Tables::User;
use TUSK::Permission::Role;

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
					'tablename' => 'permission_user_role',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'user_role_id' => 'pk',
					'user_id' => '',
					'role_id' => '',
					'feature_id' => '',
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

=item B<getUserID>

$string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}


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

=item B<getFeatureID>

$string = $obj->getFeatureID();

Get the value of the feature_id field

=cut

sub getFeatureID{
    my ($self) = @_;
    return $self->getFieldValue('feature_id');
}

#######################################################

=item B<setFeatureID>

$obj->setFeatureID($value);

Set the value of the feature_id field

=cut

sub setFeatureID{
    my ($self, $value) = @_;
    $self->setFieldValue('feature_id', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getRoleObjects>

my $roles = $obj->getRoleObjects();

Gets the TUSK::Permission::Role object associated with this record;

=cut

sub getRoleObjects{
    my ($self) = @_;
    return $self->getJoinObjects('TUSK::Permission::Role');
}

#######################################################

=item B<lookupFeature>
    
my $array_ref = $obj->lookupFeature($feature_type_token, $feature_id);

Gets an array ref of any matching user role records for a particular feature_type_token and feature_id

=cut

sub lookupFeature{
    my ($self, $feature_type_token, $feature_id) = @_;

    return $self->lookup("permission_feature_type.feature_type_token='" . $feature_type_token . "' and feature_id = $feature_id", 
			     ['hsdb4.user.lastname', 'hsdb4.user.firstname'], 
			      undef, 
			      undef, 
			 [ TUSK::Core::JoinObject->new("TUSK::Permission::Role"), 
			   TUSK::Core::JoinObject->new("TUSK::Permission::FeatureType", {origkey => 'permission_role.feature_type_id', joinkey => 'feature_type_id' }),
			   TUSK::Core::JoinObject->new("TUSK::Core::HSDB4Tables::User"),
			   ] );

}


#######################################################

=item B<getFeatureUserByRole>
    
my $array_ref = $obj->getFeatureUserByRole($feature_type_token, $feature_id, $role_token);

Gets an array ref of any matching user role records for a particular feature_type_token, feature_id, and role_token. For instance, gets all authors for a particular case.

=cut

sub getFeatureUserByRole{
    my ($self, $feature_type_token, $feature_id, $role_token) = @_;

	my $user_roles = $self->lookupFeature($feature_type_token, $feature_id);

	my @filtered_user_roles = grep { $_->getJoinObject('TUSK::Permission::Role')->getRoleToken() eq $role_token } @$user_roles;

	return \@filtered_user_roles;

}



#######################################################

=item B<getUserObject>

my $user_obj = $obj->getUserObject();

Return the user object associated with this object

=cut

sub getUserObject{
    my ($self) = @_;
    
    return $self->getJoinObject("TUSK::Core::HSDB4Tables::User");
}

#######################################################

=item B<getFullUserName>

my $string = $obj->getFullUserName();

Returns the full name of the user 

=cut

sub getFullUserName{
    my ($self) = @_;
    my $user_obj = $self->getUserObject();
	if(ref($user_obj) eq "TUSK::Core::HSDB4Tables::User"){
		return $user_obj->getLastname() . ", " . $user_obj->getFirstname();
	}
	else{
		return "User removed from TUSK";
	}
}

#######################################################

=item B<getNameFirstLastDegree>

my $string = $obj->getNameFirstLastDegree();

Returns the full name of the user with their credentials

=cut

sub getNameFirstLastDegree{
	my ($self) = @_;
	my $user_obj = $self->getUserObject();
	if(ref($user_obj) eq "TUSK::Core::HSDB4Tables::User"){
		my $fn = $user_obj->getFirstname();
		my $ln = $user_obj->getLastname();
		my $dg = $user_obj->getDegree();

		return sprintf ("%s%s%s", $fn ? "$fn " : '', $ln, $dg ? ", $dg" : '');
	}
	else{
		return "User removed from TUSK";
	}
}


#######################################################

=item B<getUserNameFirstLast>

my $string = $obj->getUserNameFirstLast();

Returns the name of the user formatted: Firstname Lastname

=cut

sub getUserNameFirstLast{
	my ($self) = @_;
	my $user_obj = $self->getUserObject();
	if(ref($user_obj) eq "TUSK::Core::HSDB4Tables::User"){
		return $user_obj->getFirstname() . " " . $user_obj->getLastname();
	}
	else {
		return '';
	}
}


sub getUserNameFirstInitialLast{
	my ($self) = @_;
	my $user_obj = $self->getUserObject();
	return (ref($user_obj) eq "TUSK::Core::HSDB4Tables::User") ? substr($user_obj->getFirstname(),0,1) . " " . $user_obj->getLastname() : '';
}


#######################################################

=item B<setRoleToken>

$obj->setRoleToken($feature_type_token, $role_token);

Given a role_token, figure out its role_id and set it for this object

=cut

sub setRoleToken{
    my ($self, $feature_type_token, $role_token) = @_;
    my $roles = TUSK::Permission::Role->new()->lookup("role_token='" . $role_token ."' and feature_type_token = '" . $feature_type_token . "'", undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Permission::FeatureType", {origkey => 'permission_role.feature_type_id', joinkey => 'feature_type_id' }), ]);
    return unless (scalar(@$roles) == 1);
    $self->setRoleID($roles->[0]->getPrimaryKeyID());
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

