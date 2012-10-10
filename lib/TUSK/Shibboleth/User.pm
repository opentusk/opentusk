package TUSK::Shibboleth::User;

=head1 NAME

B<TUSK::Shibboleth::User> - Class for manipulating entries in table shibboleth_user in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Constants;

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
					'tablename' => 'shibboleth_user',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'shibboleth_user_id' => 'pk',
					'shibboleth_institution_name' => '',
					'http_variable' => '',
					'http_value' => '',
					'user_greeting' => '',
					'enabled' => '',
					'logout_page' => '',
					'needs_regen' => '',
					'IdPXML' => '',
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

=item B<getShibbolethUserID>

my $string = $obj->getShibbolethUserID();

Get the value of the shibboleth_user_id field

=cut

sub getShibbolethUserID{
    my ($self) = @_;
    return $self->getFieldValue('shibboleth_user_id');
}

#######################################################

=item B<setShibbolethUserID>

$obj->setShibbolethUserID($value);

Set the value of the shibboleth_user_id field

=cut

sub setShibbolethUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('shibboleth_user_id', $value);
}


#######################################################

=item B<getShibbolethInstitutionName>

my $string = $obj->getShibbolethInstitutionName();

Get the value of the shibboleth_institution_name field

=cut

sub getShibbolethInstitutionName{
    my ($self) = @_;
    return $self->getFieldValue('shibboleth_institution_name');
}

#######################################################

=item B<setShibbolethInstitutionName>

$obj->setShibbolethInstitutionName($value);

Set the value of the shibboleth_institution_name field

=cut

sub setShibbolethInstitutionName{
    my ($self, $value) = @_;
    $self->setFieldValue('shibboleth_institution_name', $value);
}


#######################################################

=item B<getHttpVariable>

my $string = $obj->getHttpVariable();

Get the value of the http_variable field

=cut

sub getHttpVariable{
    my ($self) = @_;
    return $self->getFieldValue('http_variable');
}

#######################################################

=item B<setHttpVariable>

$obj->setHttpVariable($value);

Set the value of the http_variable field

=cut

sub setHttpVariable{
    my ($self, $value) = @_;
    $self->setFieldValue('http_variable', $value);
}


#######################################################

=item B<getHttpValue>

my $string = $obj->getHttpValue();

Get the value of the http_value field

=cut

sub getHttpValue{
    my ($self) = @_;
    return $self->getFieldValue('http_value');
}

#######################################################

=item B<setHttpValue>

$obj->setHttpValue($value);

Set the value of the http_value field

=cut

sub setHttpValue{
    my ($self, $value) = @_;
    $self->setFieldValue('http_value', $value);
}


#######################################################

=item B<getUserGreeting>

my $string = $obj->getUserGreeting();

Get the value of the user_greeting field

=cut

sub getUserGreeting{
    my ($self) = @_;
    return $self->getFieldValue('user_greeting');
}

#######################################################

=item B<setUserGreeting>

$obj->setUserGreeting($value);

Set the value of the user_greeting field

=cut

sub setUserGreeting{
    my ($self, $value) = @_;
    $self->setFieldValue('user_greeting', $value);
}

#######################################################

=item B<ifIsEnabled>

my $string = $obj->ifIsEnabled();

Returns a 0 or 1 depending on wether this IdP is enabled or no

=cut

sub ifIsEnabled{
    my ($self) = @_;
    if($self->getFieldValue('enabled') =~ /yes/i) {return 1;}
    return 0;
}

#######################################################

=item B<isEnabled>

my $string = $obj->isEnabled();

Get the value of the enabled field

=cut

sub isEnabled{
    my ($self) = @_;
    return $self->getFieldValue('enabled');
}

#######################################################

=item B<setEnabled>

$obj->setEnabled($value);

Set the value of the enabled field

=cut

sub setEnabled{
    my ($self, $value) = @_;
    if($self->getFieldValue('enabled') ne $value) {$self->setNeedsRegen('Y');}
    $self->setFieldValue('enabled', $value);
}

#######################################################

=item B<getIdPXML>

my $string = $obj->getIdPXML();

Get the value of the IdPXML field

=cut

sub getIdPXML{
    my ($self) = @_;
    return $self->getFieldValue('IdPXML');
}

#######################################################

=item B<setIdPXML>

$obj->setIdPXML($value);

Set the value of the IdPXML field

=cut

sub setIdPXML{
    my ($self, $value) = @_;
    if($self->getFieldValue('IdPXML') ne $value) {$self->setNeedsRegen('Y');}
    $self->setFieldValue('IdPXML', $value);
}

#######################################################

=item B<needsRegen>

my $string = $obj->needsRegen();

Has there been a change to this IdP that makes the files need to be regenerated

=cut

sub needsRegen{
    my ($self) = @_;
    return $self->getFieldValue('needs_regen');
}

#######################################################

=item B<setNeedsRegen>

$obj->setNeedsRegen($value);

Set the value of the needs_regen field

=cut

sub setNeedsRegen{
    my ($self, $value) = @_;
    $self->setFieldValue('needs_regen', $value);
}

#######################################################

=item B<getUniqueName>

$obj->getUniqueName();

Generate a simple unique name for this shibboleth IdP

=cut

sub getUniqueName{
    my ($self) = @_;
    return "shibEntity" . $self->getShibbolethUserID();
}

#######################################################

=item B<isShibUser>

TUSK::Shibboleth::User->isShibUser($user_id);

Check to see if a user_id is a shibboleth user
Return the shibbolethUserId if they are or 0 if they are not.

You should only use this function if you only have the user id.
If you have a user object check it with the isGhost method.

=cut

sub isShibUser{
	my ($self, $user_id) = @_;
	my $shibUserPrefix = $TUSK::Constants::shibbolethUserID;

	# If we got an object make sure we use the primary_key
	if((ref($user_id) eq 'HSDB4::SQLRow::User') && $user_id->primary_key()) {
		$user_id = $user_id->primary_key();
	}

	if($user_id =~ /^$shibUserPrefix(\d*)$/) {
		return ($1);
	} else {
		return -1;
	}
}

#######################################################

=item B<getLogoutPage>

my $string = $obj->getLogoutPage();

Get the value of the logout_page field

=cut

sub getLogoutPage{
    my ($self) = @_;
    return $self->getFieldValue('logout_page');
}

#######################################################

=item B<setLogoutPage>

$obj->setLogoutPage($value);

Set the value of the logout_page field

=cut

sub setLogoutPage{
    my ($self, $value) = @_;
    $self->setFieldValue('logout_page', $value);
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

