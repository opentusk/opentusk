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


package TUSK::Core::HSDB4Tables::User;

=head1 NAME

B<TUSK::Core::HSDB4Tables::User> - Class for manipulating entries in table user in hsdb4 database

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
					'database' => 'hsdb4',
					'tablename' => 'user',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_id' => 'pk',
					'status' => '',
					'tufts_id' => '',
					'sid' => '',
					'trunk' => '',
					'password' => '',
					'email' => '',
					'preferred_email' => '',
					'profile_status' => '',
					'modified' => '',
					'password_reset' => '',
					'expires' => '',
					'lastname' => '',
					'firstname' => '',
					'midname' => '',
					'suffix' => '',
					'degree' => '',
					'affiliation' => '',
					'gender' => '',
					'body' => '',
					'source' => '',
					'uid' => '',
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

=item B<getStatus>

my $string = $obj->getStatus();

Get the value of the status field

=cut

sub getStatus{
    my ($self) = @_;
    return $self->getFieldValue('status');
}

#######################################################

=item B<setStatus>

$obj->setStatus($value);

Set the value of the status field

=cut

sub setStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('status', $value);
}


#######################################################

=item B<getTuftsID>

my $string = $obj->getTuftsID();

Get the value of the tufts_id field

=cut

sub getTuftsID{
    my ($self) = @_;
    return $self->getFieldValue('tufts_id');
}

#######################################################

=item B<setTuftsID>

$obj->setTuftsID($value);

Set the value of the tufts_id field

=cut

sub setTuftsID{
    my ($self, $value) = @_;
    $self->setFieldValue('tufts_id', $value);
}


#######################################################

=item B<getSid>

my $string = $obj->getSid();

Get the value of the sid field

=cut

sub getSid{
    my ($self) = @_;
    return $self->getFieldValue('sid');
}

#######################################################

=item B<setSid>

$obj->setSid($value);

Set the value of the sid field

=cut

sub setSid{
    my ($self, $value) = @_;
    $self->setFieldValue('sid', $value);
}


#######################################################

=item B<getTrunk>

my $string = $obj->getTrunk();

Get the value of the trunk field

=cut

sub getTrunk{
    my ($self) = @_;
    return $self->getFieldValue('trunk');
}

#######################################################

=item B<setTrunk>

$obj->setTrunk($value);

Set the value of the trunk field

=cut

sub setTrunk{
    my ($self, $value) = @_;
    $self->setFieldValue('trunk', $value);
}


#######################################################

=item B<getPassword>

my $string = $obj->getPassword();

Get the value of the password field

=cut

sub getPassword{
    my ($self) = @_;
    return $self->getFieldValue('password');
}

#######################################################

=item B<setPassword>

$obj->setPassword($value);

Set the value of the password field

=cut

sub setPassword{
    my ($self, $value) = @_;
    $self->setFieldValue('password', $value);
}


#######################################################

=item B<getEmail>

my $string = $obj->getEmail();

Get the value of the email field

=cut

sub getEmail{
    my ($self) = @_;
    return $self->getFieldValue('email');
}

#######################################################

=item B<setEmail>

$obj->setEmail($value);

Set the value of the email field

=cut

sub setEmail{
    my ($self, $value) = @_;
    $self->setFieldValue('email', $value);
}

#######################################################

=item B<getPreferredEmail>

my $string = $obj->getPreferredEmail();

Get the value of the email field

=cut

sub getPreferredEmail{
    my ($self) = @_;
    return $self->getFieldValue('preferred_email');
}

#######################################################

=item B<setPreferredEmail>

$obj->setPreferredEmail($value);

Set the value of the email field

=cut

sub setPreferredEmail{
    my ($self, $value) = @_;
    $self->setFieldValue('preferred_email', $value);
}



#######################################################

=item B<getDefaultEmail>

my $string = $obj->getDefaultEmail();

Get the value of the default email

=cut

sub getDefaultEmail{
    my ($self) = @_;
    return ($self->getFieldValue('preferred_email')) ? $self->getFieldValue('preferred_email') : $self->getFieldValue('email');
}


#######################################################

=item B<getProfileStatus>

my $string = $obj->getProfileStatus();

Get the value of the profile_status field

=cut

sub getProfileStatus{
    my ($self) = @_;
    return $self->getFieldValue('profile_status');
}


#######################################################

=item B<setProfileStatus>

$obj->setProfileStatus($value);

Set the value of the profile_status field

=cut

sub setProfileStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('profile_status', $value);
}


#######################################################

=item B<getModified>

my $string = $obj->getModified();

Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
}

#######################################################

=item B<setModified>

$obj->setModified($value);

Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
}


#######################################################

=item B<getPasswordReset>

my $string = $obj->getPasswordReset();

Get the value of the password_reset field

=cut

sub getPasswordReset{
    my ($self) = @_;
    return $self->getFieldValue('password_reset');
}

#######################################################

=item B<setPasswordReset>

$obj->setPasswordReset($value);

Set the value of the password_reset field

=cut

sub setPasswordReset{
    my ($self, $value) = @_;
    $self->setFieldValue('password_reset', $value);
}


#######################################################

=item B<getExpires>

my $string = $obj->getExpires();

Get the value of the expires field

=cut

sub getExpires{
    my ($self) = @_;
    return $self->getFieldValue('expires');
}

#######################################################

=item B<setExpires>

$obj->setExpires($value);

Set the value of the expires field

=cut

sub setExpires{
    my ($self, $value) = @_;
    $self->setFieldValue('expires', $value);
}


#######################################################

=item B<getLastname>

my $string = $obj->getLastname();

Get the value of the lastname field

=cut

sub getLastname{
    my ($self) = @_;
    return $self->getFieldValue('lastname');
}

#######################################################

=item B<setLastname>

$obj->setLastname($value);

Set the value of the lastname field

=cut

sub setLastname{
    my ($self, $value) = @_;
    $self->setFieldValue('lastname', $value);
}


#######################################################

=item B<getFirstname>

my $string = $obj->getFirstname();

Get the value of the firstname field

=cut

sub getFirstname{
    my ($self) = @_;
    return $self->getFieldValue('firstname');
}

#######################################################

=item B<setFirstname>

$obj->setFirstname($value);

Set the value of the firstname field

=cut

sub setFirstname{
    my ($self, $value) = @_;
    $self->setFieldValue('firstname', $value);
}


#######################################################

=item B<getMidname>

my $string = $obj->getMidname();

Get the value of the midname field

=cut

sub getMidname{
    my ($self) = @_;
    return $self->getFieldValue('midname');
}

#######################################################

=item B<setMidname>

$obj->setMidname($value);

Set the value of the midname field

=cut

sub setMidname{
    my ($self, $value) = @_;
    $self->setFieldValue('midname', $value);
}


#######################################################

=item B<getSuffix>

my $string = $obj->getSuffix();

Get the value of the suffix field

=cut

sub getSuffix{
    my ($self) = @_;
    return $self->getFieldValue('suffix');
}

#######################################################

=item B<setSuffix>

$obj->setSuffix($value);

Set the value of the suffix field

=cut

sub setSuffix{
    my ($self, $value) = @_;
    $self->setFieldValue('suffix', $value);
}


#######################################################

=item B<getDegree>

my $string = $obj->getDegree();

Get the value of the degree field

=cut

sub getDegree{
    my ($self) = @_;
    return $self->getFieldValue('degree');
}

#######################################################

=item B<setDegree>

$obj->setDegree($value);

Set the value of the degree field

=cut

sub setDegree{
    my ($self, $value) = @_;
    $self->setFieldValue('degree', $value);
}


#######################################################

=item B<getAffiliation>

my $string = $obj->getAffiliation();

Get the value of the affiliation field

=cut

sub getAffiliation{
    my ($self) = @_;
    return $self->getFieldValue('affiliation');
}

#######################################################

=item B<setAffiliation>

$obj->setAffiliation($value);

Set the value of the affiliation field

=cut

sub setAffiliation{
    my ($self, $value) = @_;
    $self->setFieldValue('affiliation', $value);
}


#######################################################

=item B<getGender>

my $string = $obj->getGender();

Get the value of the gender field

=cut

sub getGender{
    my ($self) = @_;
    return $self->getFieldValue('gender');
}

#######################################################

=item B<setGender>

$obj->setGender($value);

Set the value of the gender field

=cut

sub setGender{
    my ($self, $value) = @_;
    $self->setFieldValue('gender', $value);
}


#######################################################

=item B<getBody>

my $string = $obj->getBody();

Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

$obj->setBody($value);

Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}


#######################################################

=item B<getSource>

my $string = $obj->getSource();

Get the value of the source field

=cut

sub getSource{
    my ($self) = @_;
    return $self->getFieldValue('source');
}

#######################################################

=item B<setSource>

$obj->setSource($value);

Set the value of the source field

=cut

sub setSource{
    my ($self, $value) = @_;
    $self->setFieldValue('source', $value);
}


#######################################################

=item B<getUID>

my $integer = $obj->getUID();

Get the value of the uid field

=cut

sub getUID{
    my ($self) = @_;
    return $self->getFieldValue('uid');
}

#######################################################

=item B<setUID>

$obj->setUID($value);

Set the value of the uid field

=cut

sub setUID{
    my ($self, $value) = @_;
    $self->setFieldValue('uid', $value);
}

=back

=cut

### Other Methods

=item
    Return lastname, firstname
=cut
sub outLastFirstName{
    my $self = shift;
    my ($fn, $ln) =  @{$self->getFieldValues(['firstname', 'lastname'])};
    return $self->getPrimaryKeyID() unless $ln;
    return $ln unless $fn;
    return "$ln, $fn";
}

=item
    Return firstname lastname
=cut
sub outName{
    my $self = shift;
    my ($fn, $ln) =  @{$self->getFieldValues(['firstname', 'lastname'])};
    return $self->getPrimaryKeyID() unless $ln;
    return $ln unless $fn;
    return "$fn $ln";
}

sub getSites {
    my $self = shift;
    return $self->getJoinObjects('TUSK::Core::HSDB45Tables::TeachingSite');
}


sub getFormattedSites {
    my $self = shift;
    return join ',  ', sort { lc($a) cmp lc($b) } map { $_->getSiteName() } @{$self->getJoinObjects('TUSK::Core::HSDB45Tables::TeachingSite')};
}

## some applications ie patientlog will have only one site director for each site
sub getSiteID {
    my $self = shift;
    return ($self->checkJoinObject('TUSK::Core::HSDB45Tables::TeachingSite')) ? $self->getJoinObject('TUSK::Core::HSDB45Tables::TeachingSite')->getPrimaryKeyID() : undef;
}

sub getRole {
    my $self = shift;
    return  (grep { !$_->getVirtualRole() }  @{$self->getJoinObjects('TUSK::Permission::Role')})[0];
}

sub getRoleDesc {
    my $self = shift;
    return  (map { $_->getRoleDesc() } grep { !$_->getVirtualRole() }  @{$self->getJoinObjects('TUSK::Permission::Role')})[0];
}

sub hasRole {
    my ($self, $role_tokens) = @_;
    my $user_role = $self->getRole();
    my @tokens = (ref $role_tokens eq 'ARRAY') ?  @$role_tokens : $role_tokens;

    foreach my $token (@tokens) {
	return 1 if ($user_role && $user_role->getRoleToken() eq $token);
    }
    return 0;
}

sub getLabels {
    my $self = shift;
    return [ grep { $_->getVirtualRole() } @{$self->getJoinObjects('TUSK::Permission::Role')} ];
}

sub getFormattedLabels {
    my $self = shift;
    return join( ', ', sort { lc($a) cmp lc($b) } map { $_->getRoleDesc() } grep { $_->getVirtualRole() }  @{$self->getJoinObjects('TUSK::Permission::Role')});
}

sub getRoleLabels {
    my $self = shift;
    return $self->getJoinObjects('TUSK::Permission::Role');
}

sub getFormattedRoleLabels {
    my $self = shift;
    return join ', ', sort { lc($a) cmp lc($b) }  map { $_->getRoleDesc() } @{$self->getJoinObjects('TUSK::Permission::Role')};
}

sub getUserRoles {
    my $self = shift;
    return $self->getJoinObjects('TUSK::Permission::UserRole');
}

sub setSortOrder {
    my ($self, $val, $author_id) = @_;
    return unless $val;
    if (my $course_user = $self->getJoinObject('TUSK::Course::User')) {
	$course_user->setSortOrder($val);	
	$course_user->save({ user => $author_id });
    }
}

sub getCourseUser {
    my $self = shift;
    return $self->getJoinObject('TUSK::Course::User');
}

sub getCourseUserID {
    my $self = shift;
    return $self->getJoinObject('TUSK::Course::User')->getPrimaryKeyID();
}

sub getCourseUserSites {
    my $self = shift;
    return $self->getJoinObjects('TUSK::Course::User::Site');
}

sub outFullName {
    my $self = shift;
    my ($fn, $ln, $sfx, $dg) =  @{$self->getFieldValues(['firstname', 'lastname', 'suffix', 'degree'])};
    return $self->getPrimaryKeyID() unless $ln;

    # Process the suffix
    $sfx = '' unless $sfx;

    # Make sure there are not spaces in it
    $sfx =~ s/\s//g;

    # If it's a roman numeral (VIII or less, that is), just use a space...
    if ($sfx =~ /^[iv]+$/i) { 
	$sfx = " $sfx";
    } elsif ($sfx) { # ...otherwise, use a comma and a space
	$sfx = ", $sfx";
    } 

    # Just say lastname if we don't know anything else
    return $ln if (not $fn and not $dg);

    # Otherwise, format it all out nicely
    return sprintf ("%s%s%s%s", $fn ? "$fn " : '', $ln, $sfx, $dg ? ", $dg" : '');
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

