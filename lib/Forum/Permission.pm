package Forum::Permission;

=head1 NAME

B<Forum::Permission> - Class for manipulating entries in table permissions in mwforum database

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
					'database' => 'mwforum',
					'tablename' => 'permissions',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'id' => 'pk',
					'userName' => '',
					'boardId' => '',
					'permissions' => '',
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

=item B<getUserName>

my $string = $obj->getUserName();

Get the value of the userName field

=cut

sub getUserName{
    my ($self) = @_;
    return $self->getFieldValue('userName');
}

#######################################################

=item B<setUserName>

$obj->setUserName($value);

Set the value of the userName field

=cut

sub setUserName{
    my ($self, $value) = @_;
    $self->setFieldValue('userName', $value);
}


#######################################################

=item B<getBoardID>

my $string = $obj->getBoardID();

Get the value of the boardId field

=cut

sub getBoardID{
    my ($self) = @_;
    return $self->getFieldValue('boardId');
}

#######################################################

=item B<setBoardID>

$obj->setBoardID($value);

Set the value of the boardId field

=cut

sub setBoardID{
    my ($self, $value) = @_;
    $self->setFieldValue('boardId', $value);
}


#######################################################

=item B<getPermissions>

my $string = $obj->getPermissions();

Get the value of the permissions field

=cut

sub getPermissions{
    my ($self) = @_;
    return $self->getFieldValue('permissions');
}

#######################################################

=item B<setPermissions>

$obj->setPermissions($value);

Set the value of the permissions field

=cut

sub setPermissions{
    my ($self, $value) = @_;
    $self->setFieldValue('permissions', $value);
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

