package TUSK::Case::CaseReport;

=head1 NAME

B<TUSK::Case::CaseReport> - Class for manipulating entries in table case_report in tusk database

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
use TUSK::Case::LinkCaseReportQuizResult;
use TUSK::Case::LinkPhaseBattery;
use TUSK::Case::PhaseTestExclusion;
use TUSK::Case::TestSelection;
use TUSK::Case::Test;
use TUSK::Case::Case;
use TUSK::Quiz::Result;
use HSDB4::DateTime;
use Carp;

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
					'tablename' => 'case_report',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'case_report_id' => 'pk',
					'case_id' => '',
					'user_id' => '',
					'start_date' => '',
					'end_date' => '',
					'notes'=>'' ,
					'preview_flag' => '',
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

=item B<getCaseID>

    $string = $obj->getCaseID();

    Get the value of the case_id field

=cut

sub getCaseID{
    my ($self) = @_;
    return $self->getFieldValue('case_id');
}

#######################################################

=item B<setCaseID>

    $string = $obj->setCaseID($value);

    Set the value of the case_id field

=cut

sub setCaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('case_id', $value);
}


#######################################################

=item B<getUserID>

    $string = $obj->getUserID();

    Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

    $string = $obj->setUserID($value);

    Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}


#######################################################

=item B<getStartDate>

    $string = $obj->getStartDate();

    Get the value of the start_date field

=cut

sub getStartDate{
    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

#######################################################

=item B<setStartDate>

    $string = $obj->setStartDate($value);

    Set the value of the start_date field

=cut

sub setStartDate{
    my ($self, $value) = @_;
    $self->setFieldValue('start_date', $value);
}


#######################################################

=item B<getEndDate>

    $string = $obj->getEndDate();

    Get the value of the end_date field

=cut

sub getEndDate{
    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

#######################################################

=item B<setEndDate>

    $string = $obj->setEndDate($value);

    Set the value of the end_date field

=cut

sub setEndDate{
    my ($self, $value) = @_;
    $self->setFieldValue('end_date', $value);
}



#######################################################

=item B<getNotes>

    $string = $obj->getNotes();

    Get the value of the notes field

=cut

sub getNotes{
    my ($self) = @_;
    return $self->getFieldValue('notes');
}

#######################################################

=item B<setNotes>

    $string = $obj->setNotes($value);

    Set the value of the notes field

=cut

sub setNotes{
    my ($self, $value) = @_;
    $self->setFieldValue('notes', $value);
}

#######################################################

=item B<getPreviewFlag>

    $string = $obj->getPreviewFlag();

    Get the value of the preview_flag field

=cut

sub getPreviewFlag{
    my ($self) = @_;
    return $self->getFieldValue('preview_flag');
}

#######################################################

=item B<setPreviewFlag>

    $string = $obj->setPreviewFlag($value);

    Set the value of the preview_flag field

=cut

sub setPreviewFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('preview_flag', $value);
}

=back

=cut

### Other Methods

#######################################################

=item B<getUserObject>

    $user = $obj->getUserObject();

Get the user object associated to the case report

=cut

sub getUserObject {
	my $self = shift;
	return HSDB4::SQLRow::User->new->lookup_key($self->getUserID());
}

#######################################################

=item B<getCaseObject>

    $case = $obj->getCaseObject($value);

Get the case object associated to the case report

=cut

sub getCaseObject {
	my $self = shift;
	return TUSK::Case::Case->lookupKey($self->getCaseID());
}

#######################################################

=item B<getQuizResults>

    $quiz_results = $obj->getQuizResults();

Return all associated Quiz Results for a given Case Report

=cut

sub getQuizResults {
	my $self = shift;
	my $caseReportId = $self->getPrimaryKeyID() or confess "Case Report is not initialized";
	my @links = map { $_->getQuizResultObject } 
		@{TUSK::Case::LinkCaseReportQuizResult->lookup("parent_case_report_id = $caseReportId", ["created_on ASC"])};
	return \@links;	
}

#######################################################

=item B<getQuizResultLinks>

    $quiz_results = $obj->getQuizResultLinks();

Return all associated Quiz Result Links for a given Case Report

=cut

sub getQuizResultLinks {
	my $self = shift;
	my $caseReportId = $self->getPrimaryKeyID() or confess "Case Report is not initialized";
	my $links =  TUSK::Case::LinkCaseReportQuizResult->lookup("parent_case_report_id = $caseReportId", ["created_on ASC"]);
	return $links;
}

#######################################################

=item B<getExpertSelections>

    $obj->getExpertSelections($phase_id);

    Returns all tests/subtests that author set as having 'high' priority but were not selected by user.

=cut

sub getExpertSelections{
	my ($self, $phase_id) = @_;

	my $report_id = $self->getPrimaryKeyID();

	my $tests = TUSK::Case::Test->lookup("cts.test_id is null and lpb.child_battery_id is not null and case_test.has_sub_test=0 and pte.include=1 and (pte.priority='high' or pte.priority='medium')", 
	['case_test.sort_order'], undef, undef,
	[TUSK::Core::JoinObject->new('TUSK::Case::TestSelection',
		{alias => 'cts', joinkey => 'test_id', origkey => 'case_test.test_id',
		joincond => "cts.case_report_id=$report_id AND cts.phase_id=$phase_id"} ),
	TUSK::Core::JoinObject->new('TUSK::Case::LinkPhaseBattery',
		{alias => 'lpb', joinkey => 'child_battery_id', origkey => 'case_test.battery_id',
		joincond => "lpb.parent_phase_id=$phase_id"} ),
	TUSK::Core::JoinObject->new('TUSK::Case::PhaseTestExclusion',
		{alias => 'pte', joinkey => 'test_id', origkey => 'case_test.test_id',
		joincond => "pte.phase_id=$phase_id"} )
	]);

	return $tests;

}

#######################################################

=item B<getOpenQuiz>

    $scalar = $obj->getOpenQuiz();

Return the most recently opened quiz for this particular Case Report, or undef if its end date is NOT null

=cut

sub getOpenQuiz {
	my $self = shift;
	my $quiz_id = shift;
	
	my $user_id = $self->getUserID();
	my $case_start_date = $self->getStartDate();

	my $quiz_result = TUSK::Quiz::Result->lookupReturnOne("user_id='$user_id' and quiz_id=$quiz_id and start_date >= '$case_start_date' order by start_date DESC");

	if (defined $quiz_result && $quiz_result->getEndDate()) {
		return undef;
	}

	return $quiz_result;
}

#######################################################

=item B<getCompletedQuiz>

    $scalar = $obj->getCompletedQuiz();

Return the most recently completed quiz for this particular Case Report, or undef if its end date is null

=cut

sub getCompletedQuiz {
	my $self = shift;
	my $quiz_id = shift;
	
	my $user_id = $self->getUserID();
	my $case_start_date = $self->getStartDate();

	# we are introducing new behavior whereas once a user has completed a quiz for a given case_report
	# they will not be able to take the quiz again. instead, they will see their results.
	# however, if they complete the case, then start it again, thus generating a new report, they should
	# be able to take quiz again. therefore, each quiz should only have one result record for each case report.
	# however, we used to allow multiple quiz results for self-assessments and reviewed cases. therefore,
	# we need to get all results for the case report b/c there could be multiple completed quiz results and 
	# still one uncompleted. essentially, this is grandfathering in old quiz results/case reports.
	my $quiz_results = TUSK::Quiz::Result->lookup("user_id='$user_id' and quiz_id=$quiz_id and start_date > '$case_start_date' order by start_date DESC");

	foreach my $result(@$quiz_results){
		unless($result->getEndDate()){
			return undef;
		}
	}
	return $quiz_results->[0];
}

#######################################################

=item B<hasCompletedQuiz>

    $scalar = $obj->hasCompletedQuiz();

Return 1 if user has completed quiz for this particular Case Report, 0 otherwise

=cut

sub hasCompletedQuiz {
	my $self = shift;
	my $quiz_id = shift;
	
	my $user_id = $self->getUserID();
	my $case_start_date = $self->getStartDate();

	my $quiz_results = TUSK::Quiz::Result->lookup("user_id='$user_id' and quiz_id=$quiz_id and start_date > '$case_start_date' order by start_date ASC");

	foreach my $result(@$quiz_results){
		if($result->getEndDate()){
			return 1;
		}
	}
	return 0;
}

#######################################################

=item B<hasPathway>

    $scalar = $obj->hasPathway();

Determine whether this report was initiated before 3.6.1. If so, this report
has a pathway report, and return 1. Otherwise, 0.

=cut

sub hasPathway {
	my $self = shift;

	my $rep_start = HSDB4::DateTime->new()->in_mysql_timestamp($self->getStartDate());
	my $release_start = HSDB4::DateTime->new()->in_mysql_timestamp($TUSK::Constants::release_stamp_3_6_1);
	if ($rep_start->is_after($release_start)) {
		return 1;
	}
	else {
		return 0;
	}
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

