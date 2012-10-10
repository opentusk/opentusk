package TUSK::Case::LinkPhaseQuiz;


=head1 NAME

B<TUSK::Phase::LinkPhaseQuiz> - Class for manipulating entries in table link_phase_quiz in tusk database

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

use TUSK::Quiz::Quiz;
use TUSK::Case::Phase;
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
					'tablename' => 'link_phase_quiz',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_phase_quiz_id' => 'pk',
					'parent_phase_id' => '',
					'child_quiz_id' => '',
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

=item B<getParentPhaseID>

   $string = $obj->getParentPhaseID();

Get the value of the parent_phase_id field

=cut

sub getParentPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_phase_id');
}

#######################################################

=item B<setParentPhaseID>

    $string = $obj->setParentPhaseID($value);

Set the value of the parent_phase_id field

=cut

sub setParentPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_phase_id', $value);
}


#######################################################

=item B<getChildQuizID>

   $string = $obj->getChildQuizID();

Get the value of the child_quiz_id field

=cut

sub getChildQuizID{
    my ($self) = @_;
    return $self->getFieldValue('child_quiz_id');
}

#######################################################

=item B<setChildQuizID>

    $string = $obj->setChildQuizID($value);

Set the value of the child_quiz_id field

=cut

sub setChildQuizID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_quiz_id', $value);
}

######################################################


=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id) = @_;
    return $self->lookup("parent_phase_id = $parent_id ".
        " and child_quiz_id = '$child_id' ");
}

#######################################################

=item B<getQuiz>

    $objective_object = $obj->getQuiz();

Use the link to get the child object of this relation.  Returns a HSDB4::SQLRow::User

=cut

sub getQuiz {
        my $self = shift;
        return TUSK::Quiz::Quiz->new->lookupKey($self->getChildQuizID());
}


#######################################################


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

