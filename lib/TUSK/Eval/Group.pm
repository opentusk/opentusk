package TUSK::Eval::Group;

=head1 NAME

B<TUSK::Eval::Group> - Class for manipulating entries in table eval_group in tusk database

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
use HSDB4::DateTime;
use HSDB45::Course;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'eval_group',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_group_id' => 'pk',
					'school_id' => '',
					'course_id' => '',
					'title' => '',
					'time_period_id' => '',
					'instructions' => '',
					'available_date' => '',
					'due_date' => '',
					'template_eval_id' => '',
					'show_name_flag' => '',
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

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<getSchoolName>

my $string = $obj->getSchoolName();

Get the value of the school name

=cut

sub getSchoolName {
    my ($self) = @_;
    my $school = TUSK::Core::School->lookupKey($self->getSchoolID());
    return $school->getSchoolName();
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

=item B<getTimePeriodID>

my $string = $obj->getTimePeriodID();

Get the value of the time_period_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

$obj->setTimePeriodID($value);

Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}


#######################################################

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getInstructions>

my $string = $obj->getInstructions();

Get the value of the instructions field

=cut

sub getInstructions{
    my ($self) = @_;
    return $self->getFieldValue('instructions');
}

#######################################################

=item B<setInstructions>

$obj->setInstructions($value);

Set the value of the instructions field

=cut

sub setInstructions{
    my ($self, $value) = @_;
    $self->setFieldValue('instructions', $value);
}


#######################################################

sub getFormattedDueDate{
    my ($self) = @_;
    my $due_date = $self->getDueDate();
    $due_date =~ s/\d{2}:\d{2}:\d{2}$//;
    return $due_date;
}



#######################################################

=item B<getDueDate>

my $string = $obj->getDueDate();

Get the value of the due_date field

=cut

sub getDueDate{
    my ($self) = @_;
    return $self->getFieldValue('due_date');
}

#######################################################

=item B<getDueDateObject>

my $string = $obj->getDueDateObject();

Get the value of the due_date as a HSDB4::DateTime Object

=cut

sub getDueDateObject {
    my ($self) = @_;
    return ($self->getDueDate()) ? HSDB4::DateTime->new()->in_mysql_date($self->getDueDate()) : undef;
}


#######################################################

=item B<setDueDate>

$obj->setDueDate($value);

Set the value of the due_date field

=cut

sub setDueDate{
    my ($self, $value) = @_;
    $self->setFieldValue('due_date', $value);
}


#######################################################

sub getFormattedAvailableDate{
    my ($self) = @_;
    my $avail_date = $self->getAvailableDate();
    $avail_date =~ s/\d{2}:\d{2}:\d{2}$//;
    return $avail_date;
}


#######################################################

=item B<getAvailableDate>

my $string = $obj->getAvailableDate();

Get the value of the available_date field

=cut

sub getAvailableDate{
    my ($self) = @_;
    return $self->getFieldValue('available_date');
}

#######################################################

=item B<setAvailableDate>

$obj->setAvailableDate($value);

Set the value of the available_date field

=cut

sub setAvailableDate{
    my ($self, $value) = @_;
    $self->setFieldValue('available_date', $value);
}


#######################################################

=item B<getTemplateEvalID>

my $string = $obj->getTemplateEvalID();

Get the value of the template_eval_id field

=cut

sub getTemplateEvalID {
    my ($self) = @_;
    return $self->getFieldValue('template_eval_id');
}

#######################################################

=item B<setTemplateEvalID>

$obj->setTemplateEvalID($value);

Set the value of the template_eval_id field

=cut

sub setTemplateEvalID {
    my ($self, $value) = @_;
    $self->setFieldValue('template_eval_id', $value);
}



#######################################################

=item B<getShowNameFlag>

my $string = $obj->getShowNameFlag();

Get the value of the show_name_flag field

=cut

sub getShowNameFlag {
    my ($self) = @_;
    return $self->getFieldValue('show_name_flag');
}

#######################################################

=item B<setShowNameFlag>

$obj->setShowNameFlag($value);

Set the value of the show_name_flag field

=cut

sub setShowNameFlag {
    my ($self, $value) = @_;
    $self->setFieldValue('show_name_flag', $value);
}



=back

=cut

### Other Methods


sub isUserAllowed {
    my ($self, $user) = @_;

    unless ($self->isAvailable()) {
	return (0, 'Form is not yet available.');
    }

    if ($self->isOverdue()) {
	return (0, 'Form is overdue.');
    }

##    my $course = HSDB45::Course->new(_school => $self->school,
##				     _id => $self->getCourseID());

##    if ($course->is_user_registerd

    return (1, '');
}


sub isAvailable {
    my $self = shift;
    my $now = HSDB4::DateTime->new();

    return 0 unless ($self->getAvailableDate());

    my $available = HSDB4::DateTime->new()->in_mysql_date($self->getAvailableDate());

    if ($now->out_unix_time < $available->out_unix_time()) {
	return 0;
    }
    return 1;
}


sub isOverdue {
    my $self = shift;
    my $now = HSDB4::DateTime->new();

    return 0 unless($self->getDueDate());

    if ($now->out_unix_time > ($self->getDueDateObject()->out_unix_time() + 86400)) {
	return 1;
    }
    return 0;
}


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

