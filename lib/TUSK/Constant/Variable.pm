package TUSK::Constant::Variable;

=head1 NAME

B<TUSK::Constant::Variable> - Class for manipulating entries in table constant_variable in tusk database

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
					'tablename' => 'constant_variable',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'constant_variable_id' => 'pk',
					'constant_name' => '',
					'constant_value' => '',
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

=item B<getConstantName>

my $string = $obj->getConstantName();

Get the value of the constant_name field

=cut

sub getConstantName{
    my ($self) = @_;
    return $self->getFieldValue('constant_name');
}

#######################################################

=item B<setConstantName>

$obj->setConstantName($value);

Set the value of the constant_name field

=cut

sub setConstantName{
    my ($self, $value) = @_;
    $self->setFieldValue('constant_name', $value);
}


#######################################################

=item B<getConstantValue>

my $string = $obj->getConstantValue();

Get the value of the constant_value field

=cut

sub getConstantValue{
    my ($self) = @_;
    return $self->getFieldValue('constant_value');
}

#######################################################

=item B<setConstantValue>

$obj->setConstantValue($value);

Set the value of the constant_value field

=cut

sub setConstantValue{
    my ($self, $value) = @_;
    $self->setFieldValue('constant_value', $value);
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

