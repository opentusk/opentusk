package TUSK::Course::CourseSharing;

=head1 NAME

B<TUSK::Course::CourseSharing> - Class for manipulating entries in table course_sharing in tusk database

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
use HSDB4::DateTime;
use TUSK::Course;
use TUSK::ShibbolethUser;

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
					'tablename' => 'course_sharing',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'course_sharing_id' => 'pk',
					'token' => '',
					'course_id' => '',
					'shared_with' => '',
					'avaliable_from' => '',
					'avaliable_to' => '',
					'authorizing_note' => '',
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

=item B<getCourseSharingID>

my $string = $obj->getCourseSharingID();

Get the value of the course_sharing_id field

=cut

sub getCourseSharingID{
    my ($self) = @_;
    return $self->getFieldValue('course_sharing_id');
}

#######################################################

=item B<setCourseSharingID>

$obj->setCourseSharingID($value);

Set the value of the course_sharing_id field

=cut

sub setCourseSharingID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_sharing_id', $value);
}


#######################################################

=item B<getCourseID>

my $string = $obj->getCourseID();

Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

$obj->setCourseID($value);

Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getSharedWith>

my $string = $obj->getSharedWith();

Get the value of the shared_with field

=cut

sub getSharedWith{
    my ($self) = @_;
    return $self->getFieldValue('shared_with');
}

#######################################################

=item B<setSharedWith>

$obj->setSharedWith($value);

Set the value of the shared_with field

=cut

sub setSharedWith{
    my ($self, $value) = @_;
    $self->setFieldValue('shared_with', $value);
}

#######################################################

=item B<getSharedWithName>

my $string = $obj->getSharedWithName();

Get the expanded value of the shared_with field (the name behind the number)

=cut

sub getSharedWithName{
    my ($self) = @_;
    return TUSK::ShibbolethUser->new()->lookupKey( $self->getFieldValue('shared_with') )->getShibbolethInstitutionName();
}



#######################################################

=item B<getAvaliableFrom>

my $string = $obj->getAvaliableFrom();

Get the value of the avaliable_from field

=cut

sub getAvaliableFrom{
    my ($self) = @_;
    return $self->getFieldValue('avaliable_from');
}

#######################################################

=item B<setAvaliableFrom>

$obj->setAvaliableFrom($value);

Set the value of the avaliable_from field

=cut

sub setAvaliableFrom{
    my ($self, $value) = @_;
    $self->setFieldValue('avaliable_from', $value);
}


#######################################################

=item B<getAvaliableTo>

my $string = $obj->getAvaliableTo();

Get the value of the avaliable_to field

=cut

sub getAvaliableTo{
    my ($self) = @_;
    return $self->getFieldValue('avaliable_to');
}

#######################################################

=item B<setAvaliableTo>

$obj->setAvaliableTo($value);

Set the value of the avaliable_to field

=cut

sub setAvaliableTo{
    my ($self, $value) = @_;
    $self->setFieldValue('avaliable_to', $value);
}


#######################################################

=item B<getAuthorizingNote>

my $string = $obj->getAuthorizingNote();

Get the value of the authorizing_note field

=cut

sub getAuthorizingNote{
    my ($self) = @_;
    return $self->getFieldValue('authorizing_note');
}

#######################################################

=item B<setAuthorizingNote>

$obj->setAuthorizingNote($value);

Set the value of the authorizing_note field

=cut

sub setAuthorizingNote{
    my ($self, $value) = @_;
    $self->setFieldValue('authorizing_note', $value);
}



#######################################################

=item B<getCurrentSharedCourses>

$obj->getCurrentSharedCourses($value);

Using the value of a school, get the courses that are current shared

=cut

sub getCurrentSharedCourses{
    my ($self, $value) = @_;
    my @return;
    unless($self->{-current_courses}) {
      foreach my $courseShare ( @{TUSK::Course::CourseSharing->lookup("shared_with=$value AND avaliable_from <= NOW() AND avaliable_to >= NOW()")} ) {
      	  my $course = TUSK::Course->new()->lookupKey($courseShare->getCourseID())->getHSDB45CourseFromTuskID();
          push @return, $course;
      }
      $self->{-current_courses} = \@return;
    }
    return $self->{-current_courses};
}


#######################################################

=item B<isCurrent>

$obj->isCurrent();

Take a share and checks to see if it is current being shared (date is between start and end time)

=cut

sub isCurrent {
    my ($self, $value) = @_;
    my $nowTime = HSDB4::DateTime->new();
    my $startDate = HSDB4::DateTime->new()->in_mysql_date( $self->getAvaliableFrom() );
    my $endDate = HSDB4::DateTime->new()->in_mysql_date( $self->getAvaliableTo() );

    if(($startDate->out_unix_time() <= $nowTime->out_unix_time()) && ($nowTime->out_unix_time() <= $endDate->out_unix_time())) {return 1;}
    return 0;
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

