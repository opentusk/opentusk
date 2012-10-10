package TUSK::Core::KeyLookup;

=head1 NAME

B<TUSK::Core::KeyLookup> - Class for manipulating entries in table key_lookup in tusk database

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
					'tablename' => 'key_lookup',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'id' => 'pk',
					'type' => '',
					'tusk_key' => '',
					'other_key' => '',
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

=item B<getType>

my $string = $obj->getType();

Get the value of the type field

=cut

sub getType{
    my ($self) = @_;
    return $self->getFieldValue('type');
}

#######################################################

=item B<setType>

$obj->setType($value);

Set the value of the type field

=cut

sub setType{
    my ($self, $value) = @_;
    $self->setFieldValue('type', $value);
}


#######################################################

=item B<getTuskKey>

my $string = $obj->getTuskKey();

Get the value of the tusk_key field

=cut

sub getTuskKey{
    my ($self) = @_;
    return $self->getFieldValue('tusk_key');
}

#######################################################

=item B<setTuskKey>

$obj->setTuskKey($value);

Set the value of the tusk_key field

=cut

sub setTuskKey{
    my ($self, $value) = @_;
    $self->setFieldValue('tusk_key', $value);
}


#######################################################

=item B<getOtherKey>

my $string = $obj->getOtherKey();

Get the value of the other_key field

=cut

sub getOtherKey{
    my ($self) = @_;
    return $self->getFieldValue('other_key');
}

#######################################################

=item B<setOtherKey>

$obj->setOtherKey($value);

Set the value of the other_key field

=cut

sub setOtherKey{
    my ($self, $value) = @_;
    $self->setFieldValue('other_key', $value);
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

