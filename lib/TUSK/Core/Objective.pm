package TUSK::Core::Objective;

=head1 NAME

B<TUSK::Core::Objective> - Class for manipulating entries in table objective in hsdb4 database

=head1 DESCRIPTION

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
					'tablename' => 'objective',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'objective_id' => 'pk',
		'modified' => '',
		'body' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getModified>

   $string = $obj->getModified();

Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
}

#######################################################

=item B<setModified>

    $string = $obj->setModified($value);

Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
}


#######################################################

=item B<getBody>

   $string = $obj->getBody();

Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

    $string = $obj->setBody($value);

Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}



=back

=cut

### Other Methods

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

