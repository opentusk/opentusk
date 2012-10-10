package TUSK::Case::PhaseType;

=head1 NAME

B<TUSK::PhaseType::PhaseType> - Class for manipulating entries in table phase_type in tusk database

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
					'database' => 'tusk',
					'tablename' => 'phase_type',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'phase_type_id' => 'pk',
					'title' => '',
					'hide_phase_type' => '',
					'phase_type_object_name' => '',
					'default_sort_order'=>'' 
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
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

=item B<getTitle>

   $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

    $string = $obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getHidePhaseType>

   $string = $obj->getHidePhaseType();

Get the value of the hide_phase_type field

=cut

sub getHidePhaseType{
    my ($self) = @_;
    return $self->getFieldValue('hide_phase_type');
}

#######################################################

=item B<setHidePhaseType>

    $string = $obj->setHidePhaseType($value);

Set the value of the hide_phase_type field

=cut

sub setHidePhaseType{
    my ($self, $value) = @_;
    $self->setFieldValue('hide_phase_type', $value);
}


#######################################################

=item B<getPhaseTypeObjectName>

   $string = $obj->getPhaseTypeObjectName();

Get the value of the phase_type_object_name field

=cut

sub getPhaseTypeObjectName{
    my ($self) = @_;
    return $self->getFieldValue('phase_type_object_name');
}

#######################################################

=item B<setPhaseTypeObjectName>

    $string = $obj->setPhaseTypeObjectName($value);

Set the value of the phase_type_object_name field

=cut

sub setPhaseTypeObjectName{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_type_object_name', $value);
}

#######################################################

=item B<getDefaultSortOrder>

   $string = $obj->getDefaultSortOrder();

Get the value of the default_sort_order field

=cut

sub getDefaultSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('default_sort_order');
}

#######################################################

=item B<setDefaultSortOrder>

    $string = $obj->setDefaultSortOrder($value);

Set the value of the default_sort_order field

=cut

sub setDefaultSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('default_sort_order', $value);
}


=back

=cut

### Other Methods

sub getPhaseTypes{
	my $self = shift;
	my $param = shift;
	if ($param eq 'ALL'){
		return $self->lookup(' 1 = 1 ',['default_sort_order'] );
	} else {
		return $self->lookup(' not hide_phase_type ',['default_sort_order'] );
	}
}


=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

