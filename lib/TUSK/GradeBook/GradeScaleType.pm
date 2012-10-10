package TUSK::GradeBook::GradeScaleType;

=head1 NAME

B<TUSK::GradeBook::GradeScaleType> - Class for manipulating entries in table grade_scale_type in tusk database

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
					'tablename' => 'grade_scale_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_scale_type_id' => 'pk',
					'grade_scale_name' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getGradeScaleTypeID>

my $string = $obj->getGradeScaleTypeID();

Get the value of the grade_scale_typeID field

=cut

sub getGradeScaleTypeID{
    my ($self) = @_;
    return $self->getFieldValue('grade_scale_type_id');
}

#######################################################

#######################################################

=item B<getGradeScaleName>

my $string = $obj->getGradeScaleName();

Get the value of the grade_scale_name field

=cut

sub getGradeScaleName{
    my ($self) = @_;
    return $self->getFieldValue('grade_scale_name');
}

#######################################################

=item B<setGradeScaleName>

$obj->setGradeScaleName($value);

Set the value of the grade_scale_name field

=cut

sub setGradeScaleName{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_scale_name', $value);
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

