# Copyright 2013 Tufts University
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


package TUSK::User::Login;

=head1 NAME

B<TUSK::User::Login> - Class for manipulating entries in table user_login in tusk database

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
					'tablename' => 'user_login',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_login_id' => 'pk',
					'uid' => '',
					'login' => '',
					'previous_login' => '',
					'loggedout_flag' => '',
					'cas_login' => '',
					'shib_session' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
					no_created => 1,
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

=item B<getUid>

my $string = $obj->getUid();

Get the value of the uid field

=cut

sub getUid{
    my ($self) = @_;
    return $self->getFieldValue('uid');
}

#######################################################

=item B<setUid>

$obj->setUid($value);

Set the value of the uid field

=cut

sub setUid{
    my ($self, $value) = @_;
    $self->setFieldValue('uid', $value);
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

=item B<getCasLogin>

my $string = $obj->getCasLogin();

Get the value of the cas_login field

=cut

sub getCasLogin{
    my ($self) = @_;
    return $self->getFieldValue('cas_login');
}

#######################################################

=item B<setCasLogin>

$obj->setCasLogin($value);

Set the value of the cas_login field

=cut

sub setCasLogin{
    my ($self, $value) = @_;
    $self->setFieldValue('cas_login', $value);
}


#######################################################

=item B<getShibSession>

my $string = $obj->getShibSession();

Get the value of the shib_session field

=cut

sub getShibSession{
    my ($self) = @_;
    return $self->getFieldValue('shib_session');
}

#######################################################

=item B<setShibSession>

$obj->setShibSession($value);

Set the value of the shib_session field

=cut

sub setShibSession{
    my ($self, $value) = @_;
    $self->setFieldValue('shib_session', $value);
}

#######################################################

=item B<updatePreviousLogin>

$obj->updatePreviousLogin();

Move the value of login to previous_login and set the new value of login

=cut

sub updatePreviousLogin{
    my ($self, $value) = @_;
    $self->setPreviousLogin($self->getLogin());
    $self->setLogin( HSDB4::DateTime->new->out_mysql_timestamp );
    $self->save();
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

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

