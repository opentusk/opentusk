# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Case::PhaseOptionSelection;

=head1 NAME

B<TUSK::Case::PhaseOptionSelection> - Class for manipulating entries in table case_phase_option_selection in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

use TUSK::Case::PhaseVisit;


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
					'tablename' => 'case_phase_option_selection',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'phase_option_selection_id' => 'pk',
					'case_report_id' => '',
					'phase_id' => '',
					'phase_visit_id' => '',
					'phase_option_id' => '',
					'short_answer_text' => '',
					'answer_text' => '',
					'option_text' => '',
					'correct' => '',
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

=item B<getCaseReportID>

    $string = $obj->getCaseReportID();

    Get the value of the case_report_id field

=cut

sub getCaseReportID{
    my ($self) = @_;
    return $self->getFieldValue('case_report_id');
}

#######################################################

=item B<setCaseReportID>

    $string = $obj->setCaseReportID($value);

    Set the value of the case_report_id field

=cut

sub setCaseReportID{
    my ($self, $value) = @_;
    $self->setFieldValue('case_report_id', $value);
}


#######################################################

=item B<getPhaseID>

    $string = $obj->getPhaseID();

    Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

    $string = $obj->setPhaseID($value);

    Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getPhaseVisitID>

    $string = $obj->getPhaseVisitID();

    Get the value of the phase_visit_id field

=cut

sub getPhaseVisitID{
    my ($self) = @_;
    return $self->getFieldValue('phase_visit_id');
}

#######################################################

=item B<setPhaseVisitID>

    $string = $obj->setPhaseVisitID($value);

    Set the value of the phase_visit_id field

=cut

sub setPhaseVisitID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_visit_id', $value);
}


#######################################################

=item B<getPhaseOptionID>

    $string = $obj->getPhaseOptionID();

    Get the value of the phase_option_id field

=cut

sub getPhaseOptionID{
    my ($self) = @_;
    return $self->getFieldValue('phase_option_id');
}

#######################################################

=item B<setPhaseOptionID>

    $string = $obj->setPhaseOptionID($value);

    Set the value of the phase_option_id field

=cut

sub setPhaseOptionID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_option_id', $value);
}


#######################################################

=item B<getShortAnswerText>

    $string = $obj->getShortAnswerText();

    Get the value of the short_answer_text field

=cut

sub getShortAnswerText{
    my ($self) = @_;
    return $self->getFieldValue('short_answer_text');
}

#######################################################

=item B<setShortAnswerText>

    $string = $obj->setShortAnswerText($value);

    Set the value of the short_answer_text field

=cut

sub setShortAnswerText{
    my ($self, $value) = @_;
    $self->setFieldValue('short_answer_text', $value);
}

#######################################################

=item B<getAnswerText>

    $string = $obj->getAnswerText();

    Get the value of the answer_text field

=cut

sub getAnswerText{
    my ($self) = @_;
    return $self->getFieldValue('answer_text');
}

#######################################################

=item B<setAnswerText>

    $string = $obj->setAnswerText($value);

    Set the value of the answer_text field

=cut

sub setAnswerText{
    my ($self, $value) = @_;
    $self->setFieldValue('answer_text', $value);
}


#######################################################

=item B<getOptionText>

    $string = $obj->getOptionText();

    Get the value of the option_text field

=cut

sub getOptionText{
    my ($self) = @_;
    return $self->getFieldValue('option_text');
}

#######################################################

=item B<setOptionText>

    $string = $obj->setOptionText($value);

    Set the value of the option_text field

=cut

sub setOptionText{
    my ($self, $value) = @_;
    $self->setFieldValue('option_text', $value);
}


#######################################################

=item B<getCorrect>

    $string = $obj->getCorrect();

    Get the value of the correct field

=cut

sub getCorrect{
    my ($self) = @_;
    return $self->getFieldValue('correct');
}

#######################################################

=item B<setCorrect>

    $string = $obj->setCorrect($value);

    Set the value of the correct field

=cut

sub setCorrect{
    my ($self, $value) = @_;
    $self->setFieldValue('correct', $value);
}



=back

=cut

### Other Methods


#######################################################

=item B<getReportSelection>

    $arrayref = TUSK::Case::PhaseOptionSelection->getReportSelection($case_report,$phase_option);

	Given a TUSK::Case::CaseReport object and a TUSK::Case::PhaseOption object, this sub
will return either a corresponding arrayref of TUSK::Case::PhaseOptionSelection objects. 

=cut

sub getReportSelection {
        my $class = shift;
        my $report = shift or confess "getReportSelection requires a TUSK::Case::CaseReport object";
        if (!$report->isa('TUSK::Case::CaseReport')){
                confess "getReportSelection must have a instantiated TUSK::Case::CaseReport object passed.";
        }
        my $report_id = $report->getPrimaryKeyID()
                or confess "The TUSK::Case::CaseReport object passed must be an actual Report ";
        my $phase_option = shift or confess "getReportSelection requires a TUSK::Case::PhaseOption object";
        if (!$phase_option->isa('TUSK::Case::PhaseOption')){
                confess "The TUSK::Case::PhaseOption object passed must be an actual PhaseOption ";
        }
        my $phase_option_id = $phase_option->getPrimaryKeyID()
                or confess "getReportSelection must have a instantiated TUSK::Case::PhaseOption object passed.";
        return TUSK::Case::PhaseOptionSelection->lookup("phase_option_id = $phase_option_id and case_report_id = $report_id");

}


#######################################################

=item B<getVisitSelection>

    $arrayref = TUSK::Case::PhaseOptionSelection->getVisitSelection($phase_visit, $phase_option);

	Given a TUSK::Case::PhaseVisit object and a TUSK::Case::PhaseOption object, this sub
will return the corresponding arrayref containing the TUSK::Case::PhaseOptionSelection object. 

=cut

sub getVisitSelection {
	my $class = shift;
	my $visit = shift or confess "getVisitSelection requires a TUSK::Case::PhaseVisit object";
	if (!$visit->isa('TUSK::Case::PhaseVisit')){
		confess "getVisitSelection must have a instantiated TUSK::Case::PhaseVisit object passed.";
	}
	my $visit_id = $visit->getPrimaryKeyID()
		or confess "The TUSK::Case::PhaseVisit object passed must be an actual Visit.";
	my $phase_option = shift or confess "getVisitSelection requires a TUSK::Case::PhaseOption object";
	if (!$phase_option->isa('TUSK::Case::PhaseOption')){
		confess "The TUSK::Case::PhaseOption object passed must be an actual PhaseOption ";
	}
	my $phase_option_id = $phase_option->getPrimaryKeyID()
		or confess "getVisitSelection must have a instantiated TUSK::Case::PhaseOption object passed.";

	return TUSK::Case::PhaseOptionSelection->lookup("phase_option_id = $phase_option_id and phase_visit_id = $visit_id");
}

#######################################################

=item B<getPhaseSelections>

    $arrayref = TUSK::Case::PhaseOptionSelection->getPhaseSelections($phase,$case_report);

    Given a phase object the function returns an array ref of PhaseOptionSelection
objects for the given phase.   

=cut

sub getPhaseSelections {
	my $class = shift;
	my $phase = shift or confess "getPhaseSelections requires a phase object";
	if (!$phase->isa('TUSK::Case::Phase')){
		confess "getPhaseSelections must have a instantiated phase object passed.";
	}
	my $phase_id = $phase->getPrimaryKeyID() 
		or confess "The phase object passed must be a real phase";
	my $case_report = shift or confess "getPhaseSelections requires a case_report object";
	if (!$case_report->isa('TUSK::Case::CaseReport')){
		confess "getPhaseSelections must have a instantiated case_report object passed.";
	}
	my $case_report_id = $case_report->getPrimaryKeyID() 
		or confess "The case_report object passed must be a real case_report";
	return TUSK::Case::PhaseOptionSelection->lookup("case_phase_option_selection.phase_id = $phase_id and case_report_id = $case_report_id", ['sort_order'], 
							undef, 
							undef, 
							[ 
							  TUSK::Core::JoinObject->new('TUSK::Case::PhaseOption'),
							  ],
							);

}

#######################################################

=item B<getLatestPhaseSelections>

    $arrayref = TUSK::Case::PhaseOptionSelection->getLatestPhaseSelections($phase,$case_report);

    Given a phase object the function returns an array ref of PhaseOptionSelection
objects from the last visit for the given phase.   

=cut

sub getLatestPhaseSelections {
	my $class = shift;
	my $phase = shift or confess "getLatestPhaseSelections requires a phase object";
	if (!$phase->isa('TUSK::Case::Phase')){
		confess "getLatestPhaseSelections must have a instantiated phase object passed.";
	}
	my $phase_id = $phase->getPrimaryKeyID() 
		or confess "The phase object passed must be a real phase";

	my $case_report = shift or confess "getLatestPhaseSelections requires a case_report object";
	if (!$case_report->isa('TUSK::Case::CaseReport')){
		confess "getLatestPhaseSelections must have a instantiated case_report object passed.";
	}
	my $case_report_id = $case_report->getPrimaryKeyID() 
		or confess "The case_report object passed must be a real case_report";


	my $selection = TUSK::Case::PhaseOptionSelection->lookupReturnOne("case_report_id = $case_report_id and phase_id = $phase_id", ['phase_visit_id DESC']);

	if(defined $selection){
		my $visit = TUSK::Case::PhaseVisit->lookupKey($selection->getPhaseVisitID());
		return TUSK::Case::PhaseOptionSelection->getPhaseVisitSelections($visit);
	}
	else {
		return [];
	}
}

#######################################################

=item B<getPhaseVisitSelections>

    $arrayref = TUSK::Case::PhaseOptionSelection->getPhaseVisitSelections($phase_visit);

    Given a phase_visit object the function returns an array ref of PhaseOptionSelection
objects from that visit.

=cut

sub getPhaseVisitSelections {
	my $class = shift;
	my $phase_visit = shift or confess "getPhaseVisitSelections requires a phase_visit object";
	if (!$phase_visit->isa('TUSK::Case::PhaseVisit')){
		confess "getPhaseVisitSelections must have a instantiated phase_visit object passed.";
	}
	my $phase_visit_id = $phase_visit->getPrimaryKeyID() 
		or confess "The phase_visit object passed must be a real phase_visit";

	return TUSK::Case::PhaseOptionSelection->lookup("case_phase_option_selection.phase_visit_id = $phase_visit_id", ['sort_order'], 
							undef, 
							undef, 
							[ 
							  TUSK::Core::JoinObject->new('TUSK::Case::PhaseOption'),
							  ],
							);

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

