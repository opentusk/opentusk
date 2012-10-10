package TUSK::Schedule::ClassMeetingObjective;

=head1 NAME

B<TUSK::Schedule::ClassMeetingObjective> - Class for manipulating entries in table class_meeting_objective in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Objective;

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
					'tablename' => 'class_meeting_objective',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'class_meeting_objective_id' => 'pk',
					'class_meeting_id' => '',
					'objective_id' => '',
					'school_id' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getClassMeetingID>

   $string = $obj->getClassMeetingID();

Get the value of the class_meeting_id field

=cut

sub getClassMeetingID{
    my ($self) = @_;
    return $self->getFieldValue('class_meeting_id');
}

#######################################################

=item B<setClassMeetingID>

    $string = $obj->setClassMeetingID($value);

Set the value of the class_meeting_id field

=cut

sub setClassMeetingID{
    my ($self, $value) = @_;
    $self->setFieldValue('class_meeting_id', $value);
}


#######################################################

=item B<getObjectiveID>

   $string = $obj->getObjectiveID();

Get the value of the objective_id field

=cut

sub getObjectiveID{
    my ($self) = @_;
    return $self->getFieldValue('objective_id');
}

#######################################################

=item B<setObjectiveID>

    $string = $obj->setObjectiveID($value);

Set the value of the objective_id field

=cut

sub setObjectiveID{
    my ($self, $value) = @_;
    $self->setFieldValue('objective_id', $value);
}


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

    $obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getSortOrder>

   $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

    $string = $obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($school_id, $class_meeting_id,$objective_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self,$school_id, $class_meeting_id, $objective_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id and objective_id = $objective_id");
}

#######################################################

=item B<getObjective>

    $objective_object = $obj->getObjective();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Objective

=cut

sub getObjective {
	my $self = shift;
	return TUSK::Core::Objective->new->lookupKey($self->getObjectiveID());
}

#######################################################

=item B<getObjectivesByClassMeeting>

    $new_object = $obj->getObjectivesByClassMeeting($school_id, $class_meeting_id);

=cut

sub getObjectivesByClassMeeting{
    my ($self, $school_id, $class_meeting_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id");
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

