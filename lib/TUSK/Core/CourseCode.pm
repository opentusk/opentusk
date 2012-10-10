package TUSK::Core::CourseCode;

=head1 NAME

B<TUSK::Core::CourseCode> - Class for manipulating entries in table course_code in tusk database

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
					'tablename' => 'course_code',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'course_code_id' => 'pk',
					'school_id' => '',
					'course_id' => '',
					'code' => '',
					'code_type' => '',
					'teaching_site_id' => '',
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

=item B<getSchoolID>

    $string = $obj->getSchoolID();

    Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getCourseID>

    $string = $obj->getCourseID();

    Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

    $string = $obj->setCourseID($value);

    Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getCode>

    $string = $obj->getCode();

    Get the value of the code field

=cut

sub getCode{
    my ($self) = @_;
    return $self->getFieldValue('code');
}

#######################################################

=item B<setCode>

    $string = $obj->setCode($value);

    Set the value of the code field

=cut

sub setCode{
    my ($self, $value) = @_;
    $self->setFieldValue('code', $value);
}


#######################################################

=item B<getCodeType>

    $string = $obj->getCodeType();

    Get the value of the code_type field

=cut

sub getCodeType{
    my ($self) = @_;
    return $self->getFieldValue('code_type');
}

#######################################################

=item B<setCodeType>

    $string = $obj->setCodeType($value);

    Set the value of the code_type field

=cut

sub setCodeType{
    my ($self, $value) = @_;
    $self->setFieldValue('code_type', $value);
}



#######################################################

=item B<getTeachingSiteID>

    $string = $obj->getTeachingSiteID();

    Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    $self->getFieldValue('teaching_site_id');
}


#######################################################

=item B<setTeachingSiteID>

    $string = $obj->setTeachingSiteID($value);

    Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
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

