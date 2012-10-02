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
					'profile_status' => '',
					'modified' => '',
					'password_reset' => '',
					'expires' => '',
					'login' => '',
					'previous_login' => '',
					'lastname' => '',
					'firstname' => '',
					'midname' => '',
					'suffix' => '',
					'degree' => '',
					'affiliation' => '',
					'gender' => '',
					'body' => '',
					'loggedout_flag' => '',
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

=item B<getLogin>

my $string = $obj->getLogin();

Get the value of the login field

=cut

sub getLogin{
    my ($self) = @_;
    return $self->getFieldValue('login');
}

#######################################################

=item B<setLogin>

$obj->setLogin($value);

Set the value of the login field

=cut

sub setLogin{
    my ($self, $value) = @_;
    $self->setFieldValue('login', $value);
}


#######################################################

=item B<getPreviousLogin>

my $string = $obj->getPreviousLogin();

Get the value of the previous_login field

=cut

sub getPreviousLogin{
    my ($self) = @_;
    return $self->getFieldValue('previous_login');
}

#######################################################

=item B<setPreviousLogin>

$obj->setPreviousLogin($value);

Set the value of the previous_login field

=cut

sub setPreviousLogin{
    my ($self, $value) = @_;
    $self->setFieldValue('previous_login', $value);
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

=item B<getLoggedoutFlag>

my $string = $obj->getLoggedoutFlag();

Get the value of the loggedout_flag field

=cut

sub getLoggedoutFlag{
    my ($self) = @_;
    return $self->getFieldValue('loggedout_flag');
}

#######################################################

=item B<setLoggedoutFlag>

$obj->setLoggedoutFlag($value);

Set the value of the loggedout_flag field

=cut

sub setLoggedoutFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('loggedout_flag', $value);
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


# Show lastname, comma, then firstname
sub outLastFirstName{
    my $self = shift;
    return $self->getFieldValue('lastname') . ", " . $self->getFieldValue('firstname');
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

