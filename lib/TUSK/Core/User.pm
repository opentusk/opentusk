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


package TUSK::Core::User;

=head1 NAME

B<TUSK::Core::User> - Class for manipulating entries in table user in tusk database

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
					'tablename' => 'user',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_id' => 'pk',
					'user_status_id' => '',
					'netid' => '',
					'sid' => '',
					'trunk' => '',
					'ssn' => '',
					'lastname' => '',
					'firstname' => '',
					'midname' => '',
					'suffix' => '',
					'degree' => '',
					'email' => '',
					'password' => '',
					'password_reset' => '',
					'login' => '',
					'recent_login' => '',
					'expires' => '',
					'gender' => '',
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

=item B<getUserStatusID>

    $string = $obj->getUserStatusID();

    Get the value of the user_status_id field

=cut

sub getUserStatusID{
    my ($self) = @_;
    return $self->getFieldValue('user_status_id');
}

#######################################################

=item B<setUserStatusID>

    $string = $obj->setUserStatusID($value);

    Set the value of the user_status_id field

=cut

sub setUserStatusID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_status_id', $value);
}


#######################################################

=item B<getNetID>

    $string = $obj->getNetID();

    Get the value of the netid field

=cut

sub getNetID{
    my ($self) = @_;
    return $self->getFieldValue('netid');
}

#######################################################

=item B<setNetID>

    $string = $obj->setNetID($value);

    Set the value of the netid field

=cut

sub setNetID{
    my ($self, $value) = @_;
    $self->setFieldValue('netid', $value);
}


#######################################################

=item B<getSid>

    $string = $obj->getSid();

    Get the value of the sid field

=cut

sub getSid{
    my ($self) = @_;
    return $self->getFieldValue('sid');
}

#######################################################

=item B<setSid>

    $string = $obj->setSid($value);

    Set the value of the sid field

=cut

sub setSid{
    my ($self, $value) = @_;
    $self->setFieldValue('sid', $value);
}


#######################################################

=item B<getTrunk>

    $string = $obj->getTrunk();

    Get the value of the trunk field

=cut

sub getTrunk{
    my ($self) = @_;
    return $self->getFieldValue('trunk');
}

#######################################################

=item B<setTrunk>

    $string = $obj->setTrunk($value);

    Set the value of the trunk field

=cut

sub setTrunk{
    my ($self, $value) = @_;
    $self->setFieldValue('trunk', $value);
}


#######################################################

=item B<getSsn>

    $string = $obj->getSsn();

    Get the value of the ssn field

=cut

sub getSsn{
    my ($self) = @_;
    return $self->getFieldValue('ssn');
}

#######################################################

=item B<setSsn>

    $string = $obj->setSsn($value);

    Set the value of the ssn field

=cut

sub setSsn{
    my ($self, $value) = @_;
    $self->setFieldValue('ssn', $value);
}


#######################################################

=item B<getLastname>

    $string = $obj->getLastname();

    Get the value of the lastname field

=cut

sub getLastname{
    my ($self) = @_;
    return $self->getFieldValue('lastname');
}

#######################################################

=item B<setLastname>

    $string = $obj->setLastname($value);

    Set the value of the lastname field

=cut

sub setLastname{
    my ($self, $value) = @_;
    $self->setFieldValue('lastname', $value);
}


#######################################################

=item B<getFirstname>

    $string = $obj->getFirstname();

    Get the value of the firstname field

=cut

sub getFirstname{
    my ($self) = @_;
    return $self->getFieldValue('firstname');
}

#######################################################

=item B<setFirstname>

    $string = $obj->setFirstname($value);

    Set the value of the firstname field

=cut

sub setFirstname{
    my ($self, $value) = @_;
    $self->setFieldValue('firstname', $value);
}


#######################################################

=item B<getMidname>

    $string = $obj->getMidname();

    Get the value of the midname field

=cut

sub getMidname{
    my ($self) = @_;
    return $self->getFieldValue('midname');
}

#######################################################

=item B<setMidname>

    $string = $obj->setMidname($value);

    Set the value of the midname field

=cut

sub setMidname{
    my ($self, $value) = @_;
    $self->setFieldValue('midname', $value);
}


#######################################################

=item B<getSuffix>

    $string = $obj->getSuffix();

    Get the value of the suffix field

=cut

sub getSuffix{
    my ($self) = @_;
    return $self->getFieldValue('suffix');
}

#######################################################

=item B<setSuffix>

    $string = $obj->setSuffix($value);

    Set the value of the suffix field

=cut

sub setSuffix{
    my ($self, $value) = @_;
    $self->setFieldValue('suffix', $value);
}


#######################################################

=item B<getDegree>

    $string = $obj->getDegree();

    Get the value of the degree field

=cut

sub getDegree{
    my ($self) = @_;
    return $self->getFieldValue('degree');
}

#######################################################

=item B<setDegree>

    $string = $obj->setDegree($value);

    Set the value of the degree field

=cut

sub setDegree{
    my ($self, $value) = @_;
    $self->setFieldValue('degree', $value);
}


#######################################################

=item B<getEmail>

    $string = $obj->getEmail();

    Get the value of the email field

=cut

sub getEmail{
    my ($self) = @_;
    return $self->getFieldValue('email');
}

#######################################################

=item B<setEmail>

    $string = $obj->setEmail($value);

    Set the value of the email field

=cut

sub setEmail{
    my ($self, $value) = @_;
    $self->setFieldValue('email', $value);
}


#######################################################

=item B<getPassword>

    $string = $obj->getPassword();

    Get the value of the password field

=cut

sub getPassword{
    my ($self) = @_;
    return $self->getFieldValue('password');
}

#######################################################

=item B<setPassword>

    $string = $obj->setPassword($value);

    Set the value of the password field

=cut

sub setPassword{
    my ($self, $value) = @_;
    $self->setFieldValue('password', $value);
}


#######################################################

=item B<getPasswordReset>

    $string = $obj->getPasswordReset();

    Get the value of the password_reset field

=cut

sub getPasswordReset{
    my ($self) = @_;
    return $self->getFieldValue('password_reset');
}

#######################################################

=item B<setPasswordReset>

    $string = $obj->setPasswordReset($value);

    Set the value of the password_reset field

=cut

sub setPasswordReset{
    my ($self, $value) = @_;
    $self->setFieldValue('password_reset', $value);
}


#######################################################

=item B<getLogin>

    $string = $obj->getLogin();

    Get the value of the login field

=cut

sub getLogin{
    my ($self) = @_;
    return $self->getFieldValue('login');
}

#######################################################

=item B<setLogin>

    $string = $obj->setLogin($value);

    Set the value of the login field

=cut

sub setLogin{
    my ($self, $value) = @_;
    $self->setFieldValue('login', $value);
}


#######################################################

=item B<getPreviousLogin>

    $string = $obj->getPreviousLogin();

    Get the value of the previous_login field

=cut

sub getPreviousLogin{
    my ($self) = @_;
    return $self->getFieldValue('previous_login');
}

#######################################################

=item B<setPreviousLogin>

    $string = $obj->setPreviousLogin($value);

    Set the value of the previous_login field

=cut

sub setPreviousLogin{
    my ($self, $value) = @_;
    $self->setFieldValue('previous_login', $value);
}


#######################################################

=item B<getExpires>

    $string = $obj->getExpires();

    Get the value of the expires field

=cut

sub getExpires{
    my ($self) = @_;
    return $self->getFieldValue('expires');
}

#######################################################

=item B<setExpires>

    $string = $obj->setExpires($value);

    Set the value of the expires field

=cut

sub setExpires{
    my ($self, $value) = @_;
    $self->setFieldValue('expires', $value);
}


#######################################################

=item B<getGender>

    $string = $obj->getGender();

    Get the value of the gender field

=cut

sub getGender{
    my ($self) = @_;
    return $self->getFieldValue('gender');
}

#######################################################

=item B<setGender>

    $string = $obj->setGender($value);

    Set the value of the gender field

=cut

sub setGender{
    my ($self, $value) = @_;
    $self->setFieldValue('gender', $value);
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

