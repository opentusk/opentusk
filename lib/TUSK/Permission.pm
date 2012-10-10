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


package TUSK::Permission;

=head1 NAME

B<TUSK::Permission> - Class for handling new permission scheme

=head1 SYNOPSIS

Object to check feature permissions

=head1 DESCRIPTION

This object will use the new permission tables (http://docs.tusk.tufts.edu/twiki/bin/view/Documents/NewTUSKPermissions) to check permissions in our system. It uses TUSK::Permission::UserRole, TUSK::Permission::Role, TUSK::Permission::RoleFunction, TUSK::Permission::Function, and TUSK::Permission::FeatureType.

Examples:

load one particular permission and then check for a function_token

my $perm = TUSK::Permission->new({
       'user_id'=> 'psilev01', 
       'feature_type_token' => 'quiz', 
       'feature_id' => 1,
});

if ($perm->check('view_grades')){ 

        # function allowed 

}

load many permissions and then check against one for a function_token

my $perm = TUSK::Permission->new({
        'user_id'=> 'psilev01', 
        'feature_type_token' => 'quiz', 
        'feature_id' => [1, 2, 3],
});

if ($perm->check({'function_token' => 'view_grades', 'feature_id' => 2})){

        # function allowed

}

load all permissions for a user and then check against one for a function_token

my $perm = TUSK::Permission->new('psilev01');

if ($perm->check({
        'function_token' => 'view_grades', 
        'feature_id' => 2, 
        'feature_type_token' => 'quiz'
})){

        # function allowed

}

new feature to this module is the ability to pass in school_admin flag.  If the application has already figured out that this person is a school admin ten there is no need to do anymore checking.

my $perm = TUSK::Permission->new({ 'user_ud' => 'psilev01', 'school_admin' => 1 });

=cut

use strict;

BEGIN {
    require Exporter;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use TUSK::Permission::UserRole;
use TUSK::Permission::Role;
use TUSK::Permission::RoleFunction;
use TUSK::Permission::Function;
use TUSK::Permission::FeatureType;
use TUSK::Core::JoinObject;

# Non-exported package globals go here
use vars ();

=head2 METHODS

=over 4

=item B<new>

$obj = TUSK::Permissions->new($args);
   
Constructor method;  Basically calls setPermissions method with parameter $args.

=cut

sub new {
    # Find out what class we are
    my ($class, $args) = @_;
    $class = ref $class || $class;

    my $self = {}; 

    bless $self, $class;
    # Finish initialization...

    if ($args->{allow_flag}){
	$self->setAllowFlag(1); # already looked up that this person is a school admin
    }
    else{
	$self->setPermissions($args);
    }

    return ($self);
}

=item B<setPermissions>

$obj->setPermissions($args);
   
Method that actually grab permissions from the database (a nasty looking TUSK::Core::SQLRow call with many many TUSK::Core::JoinObjects).  If $args is a string, then lookup all permissions where user_id = $args.  If $args is a hashref, build a condition statement based on the parameters given. Here are some possibilities:

{ 'user_id' => 'psilev01', 
'feature_type_token' => 'quiz'}

{'user_id' => 'psilev01', 
'feature_type_token' => 'quiz', 
'feature_id' => 1}

{ 'user_id' => 'psilev01', 
'feature_type_token' => 'quiz', 
'feature_id' => [1,2]}

There will be more options in the future.  Giving a course object, user_id and a feature_token will return all permissions for that feature in that course for that user (does that make sense?)

=cut

sub setPermissions{
    my ($self, $args) = @_;
    my $cond;
    
    $self->setInstanceFlag(0);
    unless (ref($args) eq 'HASH'){
	$cond = "user_id = '" . $args . "'"; # grab all permissions for a user;
    }else{
	my @conds;
	push(@conds, "user_id = '" . $args->{'user_id'} . "'") if ($args->{'user_id'});
	push(@conds, "feature_type_token = '" . $args->{'feature_type_token'} . "'") if ($args->{'feature_type_token'});
	if ($args->{'feature_id'}){
	    if (ref($args->{'feature_id'}) eq 'ARRAY'){
		push(@conds, "permission_user_role.feature_id in (" . join(',', @{$args->{'feature_id'}}) . ")") if (scalar(@{$args->{'feature_id'}})); 
	    }else{
		push(@conds, "permission_user_role.feature_id = " . $args->{'feature_id'});
		$self->setInstanceFlag(1);
	    }
	}
	$cond = join(' and ', @conds);

	if ($args->{check_school_admin}){
	    $cond = "(" . $cond . ") or (permission_user_role.feature_id = " . int($args->{check_school_admin}) . " and permission_user_role.user_id = '" . $args->{'user_id'} . "' and feature_type_token = 'school')";
	    $self->setSchoolID($args->{check_school_admin});
	}
    }

    return unless $cond; # input was not correct

    my $perms = TUSK::Permission::UserRole->new()->lookup($cond, undef, undef, undef,
							  [
							   TUSK::Core::JoinObject->new("TUSK::Permission::Role"),
							   TUSK::Core::JoinObject->new("TUSK::Permission::FeatureType", {'origkey' => "permission_role.feature_type_id", 'joinkey' => 'feature_type_id', 'objtree' => ['TUSK::Permission::Role'] }),
							   TUSK::Core::JoinObject->new("TUSK::Permission::RoleFunction",{'origkey' => "permission_role.role_id", 'joinkey' => 'role_id',  'objtree' => ['TUSK::Permission::Role']} ),
							   TUSK::Core::JoinObject->new("TUSK::Permission::Function",{'origkey' => "permission_role_function.function_id", 'joinkey' => 'function_id', 'objtree' => ['TUSK::Permission::Role', 'TUSK::Permission::RoleFunction'] } ),
							   ]);

    # set up a hashref to make checking permissions easier
    foreach my $perm (@$perms){ 
	my $roles = $perm->getRoleObjects();
	foreach my $role (@$roles){
	    my $feature_type_token = $role->getFeatureTypeToken();
	    push (@{$self->{_permissions}->{$feature_type_token}}, $perm);
	}
    }
}

=item B<getPermissions>

$hash_ref = $obj->getPermissions();
   
Returns a hash ref of all the permissions.  The keys to the hashref are feature_tokens.  The values of the hashref are an array of TUSK::Permission::UserRole objects.

=cut

sub getPermissions{
    my ($self) = @_;
    return $self->{_permissions};
}

=item B<setInstanceFlag>

$obj->setInstanceFlag($int);
   
The instance flag is used to remind the object that a call to the check method without a feature_id could be valid.  If the flag is set to 1, then a permission call was made where the feature_id was a scalar.  If the flag is set to 0, then a permission call was made where feature_id was either an array ref or undefined.  This method sets that flag.

=cut

sub setInstanceFlag{
    my ($self, $value) = @_;
    $self->{_instance_flag} = $value;
}

=item B<getInstanceFlag>

$int = $obj->getInstanceFlag();
   
Method to return the value of the Instance Flag.

=cut

sub getInstanceFlag{
    my ($self) = @_;
    return $self->{_instance_flag};
}

=item B<setSchoolID>

$obj->setSchoolID($int);
   
Store the school_id if we are also going to check if the user is a school admin.

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->{_school_id} = $value;
}

=item B<getSchoolID>

$int = $obj->getSchoolID();
   
Method to return the value of the school id.

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->{_school_id};
}

=item B<setAllowFlag>

$obj->setAllowFlag($int);
   
If we have already looked up if this user is allowed permission (school admin, course director etc)

=cut

sub setAllowFlag{
    my ($self, $value) = @_;
    $self->{_allow_flag} = $value;
}

=item B<getAllowFlag>

$int = $obj->getAllowFlag();
   
Method to return the value of allow_flag.

=cut

sub getSchoolAdmin{
    my ($self) = @_;
    return $self->{_allow_flag};
}

=item B<check>

$int = $obj->check($args);
   
The *important* method of this object.  This object accepts either a hashref or a scalar.  If a scalar, the value is assumed to be the function_token and if possible it tries to check permissions (only will work if instance flag set).  If hashref, tries to see if there is enough info to figure out permissions.  feature_type_token is needed unless we have only looked up one type of feature_type (ie in setPermissions call).  Note - assumes same user_id context when setPermissions was called

=cut

sub check{
    my ($self, $args) = @_;

    return 1 if ($self->getSchoolAdmin());

    unless (ref($args) eq 'HASH'){
	my $temp = $args;
	$args = {};
	$args->{'function_token'} = $temp;
    }
    my $perm_hashref = $self->getPermissions();
    my $perm_count = scalar(keys %$perm_hashref);

    return 0 unless ($self->getInstanceFlag() or $args->{'feature_id'}); # shouldn't be checking these permissions
    
    # check to see if school admin
    if ($self->getSchoolID()){
	if (exists($perm_hashref->{'school'})){
	    foreach my $user_role (@{$perm_hashref->{'school'}}){
		next unless ($user_role->getFeatureID() == $self->getSchoolID());
		my $roles = $user_role->getRoleObjects();
		foreach my $role (@$roles){
		    return 1 if ($role->getRoleToken() eq "admin");
		}
		last;
	    }
	}
    }

    foreach my $perm_key (keys %$perm_hashref){
	next if ($perm_count > 1 and $perm_key ne $args->{'feature_type_token'});

	# create a hash to see if we have information about more then one feature ID
	my %feature_hash = ();
	%feature_hash = map { $_->getFeatureID() => 1 }  @{$perm_hashref->{$perm_key}};
	my $feature_count = scalar(keys %feature_hash);

	return 0 if ($feature_count > 1 and ! $args->{'feature_id'}); # no need to check if no feature_id given and more then one user_role returned

	foreach my $user_role (@{$perm_hashref->{$perm_key}}){
	    next if ($args->{'feature_id'} and $user_role->getFeatureID() ne $args->{'feature_id'});
	    my $roles = $user_role->getRoleObjects();
	    foreach my $role (@$roles){
		foreach my $rolefunction (@{$role->getRoleFunctionObjects()}){
		    if ($args->{'function_token'} eq $rolefunction->getFunctionToken()){
			return 1;
		    }
		}	
	    }
	}
    }
    return 0;
}

=head1 BUGS

None Reported.

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2005

=cut

1;
