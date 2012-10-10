package TUSK::Core::RegistrationUser;

=head1 NAME

B<TUSK::Core::RegistrationUser> - Class for manipulating entries in table registration_user in tusk database

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
					'tablename' => 'registration_user',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'registration_user_id' => 'pk',
					'school_id' => '',
					'school_user_id' => '',
					'user_id' => '',
					'firstname' => '',
					'midname' => '',
					'lastname' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getSchoolUserID>

my $string = $obj->getSchoolUserID();

Get the value of the school_user_id field

=cut

sub getSchoolUserID{
    my ($self) = @_;
    return $self->getFieldValue('school_user_id');
}

#######################################################

=item B<setSchoolUserID>

$obj->setSchoolUserID($value);

Set the value of the school_user_id field

=cut

sub setSchoolUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_user_id', $value);
}


#######################################################

=item B<getUserID>

my $string = $obj->getUserID();

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

