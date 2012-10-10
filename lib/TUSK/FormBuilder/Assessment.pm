package TUSK::FormBuilder::Assessment;

=head1 NAME

B<TUSK:::FormBuilder::Assessment> - Class for manipulating entries in table form_builder_assessment in tusk database

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
					'tablename' => 'form_builder_assessment',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'assessment_id' => 'pk',
					'form_id' => '',
					'score_display' => '',
					'show_images' => '',
					'show_elective' => '',
					'multi_assessors' => '',
					'show_assigned' => '',
					'student_selection' => '',
					'score_range' => '',
					'frequency' => '',
					'unable_to_assess' => '',
					'show_final_comment' => '',
					'final_comment' => '',
					'total_weight' => '',
					'min_score' => '',
					'show_grade_to_assessor' => '',
					'show_grade_to_subject' => '',					
					'show_grade_to_registrar' => '',
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

=item B<getFormID>

my $string = $obj->getFormID();

Get the value of the form_id field

=cut

sub getFormID{
    my ($self) = @_;
    return $self->getFieldValue('form_id');
}

#######################################################

=item B<setFormID>

$obj->setFormID($value);

Set the value of the form_id field

=cut

sub setFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_id', $value);
}


#######################################################

=item B<getScoreDisplay>

my $string = $obj->getScoreDisplay();

Get the value of the score_display field

=cut

sub getScoreDisplay{
    my ($self) = @_;
    return $self->getFieldValue('score_display');
}

#######################################################

=item B<setScoreDisplay>

$obj->setScoreDisplay($value);

Set the value of the score_display field

=cut

sub setScoreDisplay{
    my ($self, $value) = @_;
    $self->setFieldValue('score_display', $value);
}


#######################################################

=item B<getShowImages>

my $string = $obj->getShowImages();

Get the value of the show_images field

=cut

sub getShowImages{
    my ($self) = @_;
    return $self->getFieldValue('show_images');
}

#######################################################

=item B<setShowImages>

$obj->setShowImages($value);

Set the value of the show_images field

=cut

sub setShowImages{
    my ($self, $value) = @_;
    $self->setFieldValue('show_images', $value);
}


#######################################################

=item B<getShowElective>

my $string = $obj->getShowElective();

Get the value of the show_elective field

=cut

sub getShowElective{
    my ($self) = @_;
    return $self->getFieldValue('show_elective');
}

#######################################################

=item B<setShowElective>

$obj->setShowElective($value);

Set the value of the show_elective field

=cut

sub setShowElective{
    my ($self, $value) = @_;
    $self->setFieldValue('show_elective', $value);
}


#######################################################

=item B<getMultiAssessors>

my $string = $obj->getMultiAssessors();

Get the value of the multi_assessors field

=cut

sub getMultiAssessors{
    my ($self) = @_;
    return $self->getFieldValue('multi_assessors');
}

#######################################################

=item B<setMultiAssessors>

$obj->setMultiAssessors($value);

Set the value of the multi_assessors field

=cut

sub setMultiAssessors{
    my ($self, $value) = @_;
    $self->setFieldValue('multi_assessors', $value);
}


#######################################################

=item B<getShowAssigned>

my $string = $obj->getShowAssigned();

Get the value of the show_assigned field

=cut

sub getShowAssigned{
    my ($self) = @_;
    return $self->getFieldValue('show_assigned');
}

#######################################################

=item B<setShowAssigned>

$obj->setShowAssigned($value);

Set the value of the show_assigned field

=cut

sub setShowAssigned{
    my ($self, $value) = @_;
    $self->setFieldValue('show_assigned', $value);
}


#######################################################

=item B<getStudentSelection>

my $string = $obj->getStudentSelection();

Get the value of the student_selection field

=cut

sub getStudentSelection{
    my ($self) = @_;
    return $self->getFieldValue('student_selection');
}

#######################################################

=item B<setStudentSelection>

$obj->setStudentSelection($value);

Set the value of the student_selection field

=cut

sub setStudentSelection{
    my ($self, $value) = @_;
    $self->setFieldValue('student_selection', $value);
}


#######################################################

=item B<getScoreRange>

my $string = $obj->getScoreRange();

Get the value of the score_range field

=cut

sub getScoreRange{
    my ($self) = @_;
    return $self->getFieldValue('score_range');
}

#######################################################

=item B<setScoreRange>

$obj->setScoreRange($value);

Set the value of the score_range field

=cut

sub setScoreRange{
    my ($self, $value) = @_;
    $self->setFieldValue('score_range', $value);
}


#######################################################

=item B<getFrequency>

my $string = $obj->getFrequency();

Get the value of the frequency field

=cut

sub getFrequency{
    my ($self) = @_;
    return $self->getFieldValue('frequency');
}

#######################################################

=item B<setFrequency>

$obj->setFrequency($value);

Set the value of the frequency field

=cut

sub setFrequency{
    my ($self, $value) = @_;
    $self->setFieldValue('frequency', $value);
}


#######################################################

=item B<getShowFinalComment>

my $string = $obj->getShowFinalComment();

Get the value of the show_final_comment field

=cut

sub getShowFinalComment{
    my ($self) = @_;
    return $self->getFieldValue('show_final_comment');
}

#######################################################

=item B<setShowFinalComment>

$obj->setShowFinalComment($value);

Set the value of the show_final_comment field

=cut

sub setShowFinalComment{
    my ($self, $value) = @_;
    $self->setFieldValue('show_final_comment', $value);
}



#######################################################

=item B<getFinalComment>

my $string = $obj->getFinalComment();

Get the value of the final_comment field

=cut

sub getFinalComment{
    my ($self) = @_;
    return $self->getFieldValue('final_comment');
}

#######################################################

=item B<setFinalComment>

$obj->setFinalComment($value);

Set the value of the final_comment field

=cut

sub setFinalComment{
    my ($self, $value) = @_;
    $self->setFieldValue('final_comment', $value);
}


#######################################################

=item B<getUnableToAssess>

my $string = $obj->getUnableToAssess();

Get the value of the unable_to_assess field

=cut

sub getUnableToAssess{
    my ($self) = @_;
    return $self->getFieldValue('unable_to_assess');
}

#######################################################

=item B<setUnableToAssess>

$obj->setUnableToAssess($value);

Set the value of the unable_to_assess field

=cut

sub setUnableToAssess{
    my ($self, $value) = @_;
    $self->setFieldValue('unable_to_assess', $value);
}


#######################################################

=item B<getTotalWeight>

my $string = $obj->getTotalWeight();

Get the value of the total_weight field

=cut

sub getTotalWeight{
    my ($self) = @_;
    return $self->getFieldValue('total_weight');
}

#######################################################

=item B<setTotalWeight>

$obj->setTotalWeight($value);

Set the value of the total_weight field

=cut

sub setTotalWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('total_weight', $value);
}


#######################################################

=item B<getMinScore>

my $string = $obj->getMinScore();

Get the value of the min_score field

=cut

sub getMinScore{
    my ($self) = @_;
    return $self->getFieldValue('min_score');
}

#######################################################

=item B<setMinScore>

$obj->setMinScore($value);

Set the value of the min_score field

=cut

sub setMinScore{
    my ($self, $value) = @_;
    $self->setFieldValue('min_score', $value);
}



#######################################################

=item B<getShowGradeToAssessor>

my $string = $obj->getShowGradeToAssessor();

Get the value of the show_grade_to_assessor field

=cut

sub getShowGradeToAssessor{
    my ($self) = @_;
    return $self->getFieldValue('show_grade_to_assessor');
}

#######################################################

=item B<setShowGradeToAssessor>

$obj->setShowGradeToAssessor($value);

Set the value of the show_grade_to_assessor field

=cut

sub setShowGradeToAssessor{
    my ($self, $value) = @_;
    $self->setFieldValue('show_grade_to_assessor', $value);
}



#######################################################

=item B<getShowGradeToSubject>

my $string = $obj->getShowGradeToSubject();

Get the value of the show_grade_to_subject field

=cut

sub getShowGradeToSubject{
    my ($self) = @_;
    return $self->getFieldValue('show_grade_to_subject');
}

#######################################################

=item B<setShowGradeToSubject>

$obj->setShowGradeToSubject($value);

Set the value of the show_grade_to_subject field

=cut

sub setShowGradeToSubject{
    my ($self, $value) = @_;
    $self->setFieldValue('show_grade_to_subject', $value);
}



#######################################################

=item B<getShowGradeToRegistrar>

my $string = $obj->getShowGradeToRegistrar();

Get the value of the show_grade_to_registrar field

=cut

sub getShowGradeToRegistrar{
    my ($self) = @_;
    return $self->getFieldValue('show_grade_to_registrar');
}

#######################################################

=item B<setShowGradeToRegistrar>

$obj->setShowGradeToRegistrar($value);

Set the value of the show_grade_to_registrar field

=cut

sub setShowGradeToRegistrar{
    my ($self, $value) = @_;
    $self->setFieldValue('show_grade_to_registrar', $value);
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

