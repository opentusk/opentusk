package TUSK::Case::TestSelection;

=head1 NAME

B<TUSK::Case::TestSelection> - Class for manipulating entries in table case_test_selection in tusk database

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

use Carp;
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
					'tablename' => 'case_test_selection',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'test_selection_id' => 'pk',
					'case_report_id' => '',
					'phase_id' => '',
					'phase_visit_id' => '',
					'test_id' => '',
					'test_title' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_join_objects=>[
					TUSK::Core::JoinObject->new("TUSK::Case::Test")] ,
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

=item B<getTestID>

    $string = $obj->getTestID();

    Get the value of the test_id field

=cut

sub getTestID{
    my ($self) = @_;
    return $self->getFieldValue('test_id');
}

#######################################################

=item B<setTestID>

    $string = $obj->setTestID($value);

    Set the value of the test_id field

=cut

sub setTestID{
    my ($self, $value) = @_;
    $self->setFieldValue('test_id', $value);
}


#######################################################

=item B<getTestTitle>

    $string = $obj->getTestTitle();

    Get the value of the test_title field

=cut

sub getTestTitle{
    my ($self) = @_;
    return $self->getFieldValue('test_title');
}

#######################################################

=item B<setTestTitle>

    $string = $obj->setTestTitle($value);

    Set the value of the test_title field

=cut

sub setTestTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('test_title', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getCaseSelections>

    $selectionArrayRef = TUSK::Case::TestSelection->getCaseSelections($case);

    Based on the TUSK::Case::Case object passed, all the exam selections for the 
case are returned.

=cut

sub getCaseSelections{
	my $class = shift;
	my $case = shift or confess "a case needs to be passed getCaseSelections";
	my $report = $case->getReport() or confess "the case report needs to be initiated";
	my $case_report_id = $report->getPrimaryKeyID(); 
	if (!defined($case_report_id)){
		 confess "The case report has not been initiated :".$case_report_id;
	}
	return $class->lookup(" case_report_id = $case_report_id ");
}

#######################################################

=item B<getReportSelections>

    $selectionArrayRef = TUSK::Case::TestSelection->getReportSelections($report,$exam);

Based on the report object and exam passed, all selections for that report and exam
are returned.

=cut

sub getReportSelections{
	my $class = shift;
	my $report = shift or confess "a case report needs to be passed to getReportSelections";
	my $test = shift or confess " a TUSK::Case::Test object needs to be passed to getReportSelections";
	my $phase = shift or confess " a TUSK::Case::Phase object needs to be passed to getReportSelections";

	my $case_report_id = $report->getPrimaryKeyID() || confess "The case report has not been initiated";
	my $test_id = $test->getPrimaryKeyID();
	my $phase_id = $phase->getPrimaryKeyID();

	return $class->lookup(" case_report_id = $case_report_id  and case_test.test_id = $test_id and phase_id = $phase_id");
}

#######################################################

=item B<getPhaseSelections>

    $selectionArrayRef = TUSK::Case::TestSelection->getPhaseSelections($report,$phase);

Based on the report object and phase object passed, all exam selections for that report and phase
are returned.

=cut

sub getPhaseSelections{
	my $class = shift;
	my $report = shift or confess "a case report needs to be passed to getPhaseSelections";
	my $phase = shift or confess " a phase object needs to be passed to getPhaseSelections";
	my $case_report_id = $report->getPrimaryKeyID() || confess "The case report has not been initiated";
	my $phase_id = $phase->getPrimaryKeyID();
	return $class->lookup(" case_report_id = $case_report_id  and phase_id = $phase_id");
}

#######################################################

=item B<getPhaseVisitSelections>

    $selectionArrayRef = TUSK::Case::TestSelection->getPhaseVisitSelections($phase_visit);

Based on the phase visit object passed, all exam selections for that phase visit
are returned.

=cut

sub getPhaseVisitSelections{
	my $class = shift;
	my $phase_visit = shift or confess " a phase_visit object needs to be passed to getPhaseVisitSelections";
	my $phase_visit_id = $phase_visit->getPrimaryKeyID();
	return $class->lookup("phase_visit_id = $phase_visit_id");
}

#######################################################

=item B<getTestObject>

    $test = $exam_selection->getTestObject();

Return the Test object associated with the test selection

=cut

sub getTestObject{
	my $self = shift;
	my $test = $self->getJoinObject("TUSK::Case::Test");

	if (ref($test) eq 'TUSK::Case::Test'){
		return $self->getJoinObject("TUSK::Case::Test");
	} else {
		return TUSK::Case::Test->new();
	}
}

=cut

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

