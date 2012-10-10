package TUSK::Case::Case;

=head1 NAME

B<TUSK::Case::Case> - Class for manipulating entries in table case_header in tusk database

=head1 DESCRIPTION

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

use TUSK::Case::CaseReport;
use TUSK::Case::LinkCaseGradeEvent;
use TUSK::Case::LinkCaseObjective;
use TUSK::Case::LinkCasePhase;
use TUSK::Case::LinkCaseContent;
use TUSK::Case::PatientType;
use TUSK::Case::Phase;
use TUSK::Core::School;
use TUSK::GradeBook::LinkUserGradeEvent;
use TUSK::GradeBook::GradeEvent;
use TUSK::Permission::UserRole;
use HSDB4::SQLRow::User;

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
					'tablename' => 'case_header',
					'usertoken' => 'ContentManager'
					},
				    _field_names => {
					'case_header_id' => 'pk',
		'case_title' => '',
		'navigation_type' => '',
		'case_user_desc' => '',
		'case_author_desc' => '',
		'duration_text' => '',
		'duration' => '',
		'case_type' => '',
		'patient_type_id' => '',
		'publish_flag' => '',
		'share_case' => '',
		'restricted_access' => '',
		'feedback_email' => '',
		'billing_total' => '',
		'references_section' => '',
		'source' => '',
		'copyright' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'logfile',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getCaseTitle>

   $string = $obj->getCaseTitle();

Get the value of the case_title field

=cut

sub getCaseTitle{
    my ($self) = @_;
    return $self->getFieldValue('case_title');
}

#######################################################

=item B<setCaseTitle>

    $string = $obj->setCaseTitle($value);

Set the value of the case_title field

=cut

sub setCaseTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('case_title', $value);
}


#######################################################

=item B<getNavigationType>

   $int = $obj->getNavigationType();

Get the value of the navigation_type field

=cut

sub getNavigationType{
    my ($self) = @_;
    return $self->getFieldValue('navigation_type');
}

#######################################################

=item B<setNavigationType>

    $int = $obj->setNavigationType($value);

Set the value of the navigation_type field

=cut

sub setNavigationType{
    my ($self, $value) = @_;
    $self->setFieldValue('navigation_type', $value);
}


#######################################################

=item B<getCaseUserDesc>

   $string = $obj->getCaseUserDesc();

Get the value of the case_user_desc field

=cut

sub getCaseUserDesc{
    my ($self) = @_;
    return $self->getFieldValue('case_user_desc');
}

#######################################################

=item B<setCaseUserDesc>

    $string = $obj->setCaseUserDesc($value);

Set the value of the case_user_desc field

=cut

sub setCaseUserDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('case_user_desc', $value);
}


#######################################################

=item B<getCaseAuthorDesc>

   $string = $obj->getCaseAuthorDesc();

Get the value of the case_author_desc field

=cut

sub getCaseAuthorDesc{
    my ($self) = @_;
    return $self->getFieldValue('case_author_desc');
}

#######################################################

=item B<setCaseAuthorDesc>

    $string = $obj->setCaseAuthorDesc($value);

Set the value of the case_author_desc field

=cut

sub setCaseAuthorDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('case_author_desc', $value);
}


#######################################################

=item B<getDurationText>

   $string = $obj->getDurationText();

Get the value of the duration_text field

=cut

sub getDurationText{
    my ($self) = @_;
    return $self->getFieldValue('duration_text');
}

#######################################################

=item B<setDurationText>

    $string = $obj->setDurationText($value);

Set the value of the duration_text field

=cut

sub setDurationText{
    my ($self, $value) = @_;
    $self->setFieldValue('duration_text', $value);
}


#######################################################

=item B<getDuration>

   $string = $obj->getDuration();

Get the value of the duration field

=cut

sub getDuration{
    my ($self) = @_;
    return $self->getFieldValue('duration');
}

#######################################################

=item B<setDuration>

    $string = $obj->setDuration($value);

Set the value of the duration field

=cut

sub setDuration{
    my ($self, $value) = @_;
    $self->setFieldValue('duration', $value);
}


#######################################################

=item B<getCaseType>

   $string = $obj->getCaseType();

Get the value of the case_type field

=cut

sub getCaseType{
    my ($self) = @_;
    return $self->getFieldValue('case_type');
}

#######################################################

=item B<setCaseType>

    $string = $obj->setCaseType($value);

Set the value of the case_type field

=cut

sub setCaseType{
    my ($self, $value) = @_;
    $self->setFieldValue('case_type', $value);
}


#######################################################

=item B<getPatientTypeID>

   $string = $obj->getPatientTypeID();

Get the value of the patient_type_id field

=cut

sub getPatientTypeID{
    my ($self) = @_;
    return $self->getFieldValue('patient_type_id');
}

#######################################################

=item B<setPatientTypeID>

    $string = $obj->setPatientTypeID($value);

Set the value of the patient_type_id field

=cut

sub setPatientTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('patient_type_id', $value);
}


#######################################################

=item B<getPublishFlag>

   $string = $obj->getPublishFlag();

Get the value of the posted field

=cut

sub getPublishFlag{
    my ($self) = @_;
    return $self->getFieldValue('publish_flag');
}

#######################################################

=item B<setPublishFlag>

    $string = $obj->setPublishFlag($value);

Set the value of the posted field

=cut

sub setPublishFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('publish_flag', $value);
}


#######################################################

=item B<getShareCase>

   $string = $obj->getShareCase();

Get the value of the share_case field

=cut

sub getShareCase{
    my ($self) = @_;
    return $self->getFieldValue('share_case');
}

#######################################################

=item B<setShareCase>

    $string = $obj->setShareCase($value);

Set the value of the share_case field

=cut

sub setShareCase{
    my ($self, $value) = @_;
    $self->setFieldValue('share_case', $value);
}


#######################################################

=item B<getRestrictedAccess>

   $string = $obj->getRestrictedAccess();

Get the value of the restricted_access field

=cut

sub getRestrictedAccess{
    my ($self) = @_;
    return $self->getFieldValue('restricted_access');
}

#######################################################

=item B<setRestrictedAccess>

    $string = $obj->setRestrictedAccess($value);

Set the value of the restricted_access field

=cut

sub setRestrictedAccess{
    my ($self, $value) = @_;
    $self->setFieldValue('restricted_access', $value);
}


#######################################################

=item B<getFeedbackEmail>

   $string = $obj->getFeedbackEmail();

Get the value of the feedback_email field

=cut

sub getFeedbackEmail{
    my ($self) = @_;
    return $self->getFieldValue('feedback_email');
}

#######################################################

=item B<setFeedbackEmail>

    $string = $obj->setFeedbackEmail($value);

Set the value of the feedback_email field

=cut

sub setFeedbackEmail{
    my ($self, $value) = @_;
    $self->setFieldValue('feedback_email', $value);
}


#######################################################

=item B<getBillingTotal>

   $string = $obj->getBillingTotal();

Get the value of the billing_total field

=cut

sub getBillingTotal{
    my ($self) = @_;
    return $self->getFieldValue('billing_total');
}

#######################################################

=item B<setBillingTotal>

    $string = $obj->setBillingTotal($value);

Set the value of the billing_total field

=cut

sub setBillingTotal{
    my ($self, $value) = @_;
    $self->setFieldValue('billing_total', $value);
}


#######################################################

=item B<getReferencesSection>

   $string = $obj->getReferencesSection();

Get the value of the references_section field

=cut

sub getReferencesSection{
    my ($self) = @_;
    return $self->getFieldValue('references_section');
}

#######################################################

=item B<setReferencesSection>

    $string = $obj->setReferencesSection($value);

Set the value of the references_section field

=cut

sub setReferencesSection{
    my ($self, $value) = @_;
    $self->setFieldValue('references_section', $value);
}

#######################################################

=item B<getSource>

   $string = $obj->getSource();

Get the value of the source field

=cut

sub getSource{
    my ($self) = @_;
    return $self->getFieldValue('source');
}

#######################################################

=item B<setSource>

    $string = $obj->setSource($value);

Set the value of the source field

=cut

sub setSource{
    my ($self, $value) = @_;
    $self->setFieldValue('source', $value);
}
#######################################################

=item B<getCopyright>

   $string = $obj->getCopyright();

Get the value of the copyright field

=cut

sub getCopyright{
    my ($self) = @_;
    return $self->getFieldValue('copyright');
}

#######################################################

=item B<setCopyright>

    $string = $obj->setCopyright($value);

Set the value of the copyright field

=cut

sub setCopyright{
    my ($self, $value) = @_;
    $self->setFieldValue('copyright', $value);
}


=back

=cut

### Other Methods


#######################################################

=item B<isAvailable>

   $bool = $case->isAvailable($user_obj);

Return whether the specified case is available to this user

=cut

sub isAvailable {
    my $self = shift;
    my $user = shift;
    my $case_id = $self->getPrimaryKeyID();
    my @user_group_courses = map { $_->current_courses } $user->parent_user_groups();
    my @linked_courses = $user->current_courses();
    my @all_courses = ( @user_group_courses,@linked_courses);
    my ($st,$case,$school_id,$course_id) ;
    foreach my $course (@all_courses){
            $course_id = $course->course_id;
            $school_id = $course->get_school()->get_school_id();
            $st = <<EOM;
                SELECT case_header_id
                FROM case_header c,
                link_course_case lcc
                WHERE (available_date < now() OR available_date IS NULL)
                AND (due_date > now() OR due_date IS NULL)
                AND publish_flag
                AND child_case_id = case_header_id
                AND case_header_id = $case_id
                AND school_id =  $school_id
                AND parent_course_id =  $course_id
EOM
            $case = TUSK::Case::select_object($self,$st);
            if (defined($case->getPrimaryKeyID())){
                return 1;
            }
    }
    return 0;

}

#######################################################

=item B<getAvailableUserCases>

   $arrayref = $obj->getAvailableUserCases($user_obj);

Return an arrayref of the cases available to a particular user

=cut

sub getAvailableUserCases{
    my ($self, $user, $course) = @_;

    my @all_courses;

    if (!$course) {
	@all_courses = $user->current_courses();
    } else {
	push (@all_courses, $course);
    }

    my $cases =  [] ;
    my $cond ="     (available_date < now() OR available_date IS NULL)
                AND (due_date > now() OR due_date IS NULL)
                AND publish_flag
		AND case_type != 'Self-Assessment'";
    
    my @course_cond;

    foreach my $course (@all_courses){
 	my $course_id = $course->course_id();
	next unless ($course_id);
	my $school_id = $course->get_school()->getPrimaryKeyID();
	
	push (@course_cond,  "(parent_course_id = $course_id AND school_id = $school_id )");
    }

    if (scalar(@course_cond)){
	$cond .= "AND (" . join(' OR ', @course_cond) . ")";
	$cases =  $self->lookup($cond, 
				['school_id', 'parent_course_id', 'sort_order'],
				undef,
				undef,
				[ 
				  TUSK::Core::JoinObject->new('TUSK::Case::LinkCourseCase', { origkey => 'case_header_id', joinkey => 'child_case_id' }) 
				  ]); 
    }
    return $cases;
}

#######################################################

=item B<getAvailableCourseCases>

   $arrayref = $obj->getAvailableCourseCases($course);

Returns all cases available for this person and this course.

=cut

sub getAvailableCourseCases{
    my ($self, $course) = @_;
    my $course_id = $course->course_id() or confess "Unable to get course_id";
    my $school_id = $course->get_school()->getPrimaryKeyID();
    my $cond = <<EOM;
            parent_course_id = $course_id
	AND school_id = $school_id 
	AND case_type = 'Self-Assessment' 
	AND publish_flag 
        AND (available_date < now() OR available_date IS NULL)
        AND (due_date > now() OR due_date IS NULL)
EOM
        return $self->lookup($cond,
			     ['sort_order'],
			     undef,
			     undef,
			     [
			      TUSK::Core::JoinObject->new('TUSK::Case::LinkCourseCase', { origkey => 'case_header_id', joinkey => 'child_case_id' })
			      ]);
}

#######################################################

=item B<availablePhases>

   $arrayref = $obj->availablePhases();

Return phases available to be taken, in a given case.

=cut

sub availablePhases{
        my $self = shift;
        if ((ref $self) ne 'TUSK::Case::Case'){
                confess "Invalid Object Passed";
        }
        my $case_id = $self->getPrimaryKeyID();
        if (!defined($case_id)){
                return [];
        }
	return TUSK::Case::LinkCasePhase->getPhases($self);
}


#######################################################

=item B<memberPhase>

    if($case->memberPhase($phase)){

Returns boolean that indicates whether the specified phase is 
part of the case.


=cut

sub memberPhase{
        my $self = shift;
	my $phase = shift;
        my $phase_id = $phase->getPrimaryKeyID();
        my $case_id = $self->getPrimaryKeyID();
	return TUSK::Case::LinkCasePhase->exists(" NOT phase_hidden AND parent_case_id = $case_id AND child_phase_id = $phase_id ");
}

#######################################################

=item B<getReferences>

   $arrayref = $case->getReferences();

Returns associated content that are references for the case.

=cut

sub getReferences {
        my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
        my $references = TUSK::Case::LinkCaseContent->lookup("parent_case_id = $case_id "
                .' and link_type = "Reference"',['sort_order'] );
        my @content = map { $_->getContent() } @{$references};
        return \@content;
}

#######################################################

=item B<getObjectives>

   $arrayref = $case->getObjectives();

Returns the associated objectives for the case.

=cut

sub getObjectives{
	my $self = shift; 
	my $case_id = $self->getPrimaryKeyID or confess "Case has not been initialized";
	my $links = TUSK::Case::LinkCaseObjective->lookup("parent_case_id = $case_id");
	my $objectives = [];
	foreach my $link (@{$links}){
		push @{$objectives},$link->getObjective();
	}
	return $objectives;


}
#######################################################

=item B<getPatientType>

   $patient_type = $case->getPatientType();

Returns a patient type object for the relevant patient type of 
the case

=cut

sub getPatientType{
	my $self = shift;
	return TUSK::Case::PatientType->lookupKey($self->getPatientTypeID());
}

#######################################################

=item B<hasObjectives>

   if($case->hasObjectives()){

Returns a boolean value indicating whether this case has 
any child objectives.

=cut

sub hasObjectives {
	my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
	return 0 if (!$case_id);
	return TUSK::Case::LinkCaseObjective->exists(" parent_case_id = $case_id ");
}

#######################################################

=item B<hasPhases>

   if($case->hasPhases()){

Returns a boolean value indicating whether this case has 
any child phases.

=cut

sub hasPhases {
	my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
	return 0 if (!$case_id);
	return TUSK::Case::LinkCasePhase->exists(" parent_case_id = $case_id ");
}

#######################################################

=item B<hasReferences>

   if($case->hasReferences()){

Returns a boolean value indicating whether this case has 
any child references.

=cut

sub hasReferences {
	my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
	return 0 if (!$case_id);
	return TUSK::Case::LinkCaseContent->exists(" link_type = 'Reference' and parent_case_id = $case_id ");
}

#######################################################

=item B<isTest>

   if($case->isTest()){

Returns boolean indicating whether this case is a test (exam).

=cut

sub isTest{
	my $self = shift;
	if ($self->getCaseType eq 'Test'){
		return 1;
	}
	return 0;
}

#######################################################

=item B<isSelfAssessment>

   if($case->isSelfAssessment()){

Returns boolean indicating whether this case is a test (exam).

=cut

sub isSelfAssessment{
        my $self = shift;
        if ($self->getCaseType eq 'Self-Assessment'){
                return 1;
        }
        return 0;
}

#######################################################


=item B<getDurationDisplay>

   $string = $case->getDurationDisplay();

Return the relevant duration text depending on the type of case.

=cut

sub getDurationDisplay {
    my $self = shift;
    if ($self->isTest()){
	return $self->getDuration();
    } 
    return $self->getDurationText();
}

#######################################################

=item B<setReport>

   $case->setReport($report);

Associates a case report object with the case object

=cut

sub setReport {
    my $self = shift;
    my $report = shift;
    if (!defined($report) || !$report->isa('TUSK::Case::CaseReport')){
	confess "setReport requires a TUSK::Case::CaseReport object";
    }
    if (!$report->getPrimaryKeyID()){
	confess "setReport requires an initialized TUSK::Case::CaseReport object";
    }
    $self->{-report} = $report;
}

#######################################################

=item B<getReport>

   $report = $case->getReport([$user_id]);

Returns the report associated with this case. The user id is optional if
the report needs to be initialized.

=cut

sub getReport{
	my $self = shift;
	my $user_id = shift;
	unless ($self->{-report}){
		$self->initiateReport($user_id);
		if (!defined($self->{-report}) || !$self->{-report}->getPrimaryKeyID()){
			confess "Could not initiate report";
		}
	}
	return $self->{-report};
}


#######################################################

=item B<getVisitedPhases>

   $arrayref = $case->getVisitedPhases();

Returns the visited phases for a given case.  It
assumes that the case report has been initialized.

=cut


sub getVisitedPhases{
    my $self = shift;
    my $case_id = $self->getPrimaryKeyID();
    my $report = $self->getReport();
    my $report_id = $report->getPrimaryKeyID() || confess "Couldn't get report id";

	my $links = TUSK::Case::LinkCasePhase->lookup(undef,['sort_order ASC', 'phase.phase_id ASC'],undef,undef,
		[
		 TUSK::Core::JoinObject->new('TUSK::Case::PhaseVisit',{'origkey'=>'child_phase_id', 'joinkey'=>'phase_id', 'cond' => " case_report_id = $report_id "}),
		 TUSK::Core::JoinObject->new('TUSK::Case::Phase', {'origkey'=>'child_phase_id','joinkey'=>'phase_id'}),
		 ]);
	my @phases = map { $_->getPhaseObject() } @{$links};
	return \@phases;			
}

#######################################################

=item B<visitPhase>

   $case->visitPhase($phase, $user_id);

Given a phase, this method records a visit of it.

=cut

sub visitPhase{
	my $self = shift;
	my $phase = shift ;
	my $user_id = shift;

	if (defined($phase) && defined($phase->getPrimaryKeyID())){
		$phase->visit($self->getReport($user_id));
	}
}

#######################################################
=item B<prevPhaseVisited>

   $case->prevPhaseVisited($phase, $user_id);

Given a phase, the method determines if the previous phase
was visited. If no previous phase defined, we must be
first phase, and we return true since there is no necessary
phase to visit.

=cut

sub prevPhaseVisited{
    my $self = shift;
    my $phase = shift;
    my $user_id = shift;

	my $prev_phase = $self->getPrevPhase($phase);
	
	if(defined($prev_phase)){
		if($prev_phase->visited($self->getReport($user_id))){
			return 1;
		}
		else{
			return 0;
		}
	}
	#if we got here, $prev_phase not defined and we must be first phase, so return true.
	return 1; 
}

#######################################################

=item B<getFirstPhase>

   $phase = $case->getFirstPhase();

Returns the first visible phase in a case

=cut

sub getFirstPhase{
	my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
	my $cond = <<EOM;
	NOT phase_hidden
	AND parent_case_id = $case_id
EOM

        my $phases = TUSK::Case::LinkCasePhase->lookup($cond,['sort_order ASC','child_phase_id ASC'],undef,1,
		[TUSK::Core::JoinObject->new('TUSK::Case::Phase',{origkey=>'child_phase_id','joinkey'=>'phase_id'})]);
	if (@{$phases}){
		return $phases->[0]->getPhaseObject;
	} 
	return undef;
}

#######################################################

=item B<getLastPhase>

   $phase = $case->getLastPhase();

Returns the last visible phase in a case. 

=cut

sub getLastPhase {
	my $self = shift;
	my $case_id = $self->getPrimaryKeyID();
	my $cond = <<EOM;
	           NOT phase_hidden
	           AND parent_case_id = $case_id
EOM
    
	my $phases = TUSK::Case::LinkCasePhase->lookup($cond,['sort_order DESC', 'child_phase_id DESC'],undef,1,
	    [TUSK::Core::JoinObject->new('TUSK::Case::Phase',{origkey=>'child_phase_id','joinkey'=>'phase_id'})]);

	if (scalar @$phases) {
		return $phases->[0]->getPhaseObject();
	}
	return undef;
}

#######################################################

=item B<getNextPhase>

   $next_phase = $case->getNextPhase($phase);

Given a certain phase for a case, the method returns the 
next phase in the case.

=cut

sub getNextPhase{
    my $self = shift;
    my $phase = shift;
    if (!defined($phase) || !$phase->isa('TUSK::Case::Phase')){
	confess "Phase object needs to be passed.";
    }
    
    my $case_id = $self->getPrimaryKeyID();
    my $phase_id = $phase->getPrimaryKeyID();

    my $link = TUSK::Case::LinkCasePhase->new()->lookupReturnOne("parent_case_id=$case_id AND child_phase_id=$phase_id");
    my $sort_order = $link->getSortOrder();

    my $st = <<EOM;
    SELECT 
        (sort_order + 1e-10 * child_phase_id) as phase_sort,
        child_phase_id
    FROM tusk.link_case_phase 
    WHERE NOT phase_hidden
    AND parent_case_id=$case_id
    AND (sort_order + 1e-10 * child_phase_id) > ($sort_order + 1e-10 * $phase_id)
        ORDER BY phase_sort ASC
        LIMIT 1;
EOM

	my $phaseSth = $self->databaseSelect($st);
	my @next_phase_id = $phaseSth->fetchrow_array();
	$phaseSth->finish;
	if (defined($next_phase_id[1])){
		return TUSK::Case::Phase->lookupKey($next_phase_id[1]);
	}
	return undef;

}

#######################################################

=item B<getPrevPhase>

   $prev_phase = $case->getPrevPhase($phase);

Given a certain phase for a case, the method returns the 
previous phase in the case.

=cut

sub getPrevPhase{
        my $self = shift;
        my $phase = shift;
        if (!defined($phase) || !$phase->isa('TUSK::Case::Phase')){
                confess "Phase object needs to be passed.";
        }
        my $case_id = $self->getPrimaryKeyID();
        my $phase_id = $phase->getPrimaryKeyID();
        
        my $link = TUSK::Case::LinkCasePhase->new()->lookupReturnOne("parent_case_id=$case_id AND child_phase_id=$phase_id");
        my $sort_order = $link->getSortOrder();

        my $st = <<EOM;
        SELECT 
            (sort_order + 1e-10 * child_phase_id) as phase_sort,
            child_phase_id
        FROM tusk.link_case_phase 
        WHERE NOT phase_hidden
        AND parent_case_id=$case_id
        AND (sort_order + 1e-10 * child_phase_id) < ($sort_order + 1e-10 * $phase_id)
            ORDER BY phase_sort DESC
            LIMIT 1;
EOM

        my $phaseSth = $self->databaseSelect($st);
        my @prev_phase_id = $phaseSth->fetchrow_array();
        $phaseSth->finish;
        if (defined($prev_phase_id[1])){
                return TUSK::Case::Phase->lookupKey($prev_phase_id[1]);
        }
        return undef;

}


#######################################################

=item B<initiateReport>

    $case->initiateReport([$user_id]);


When a user starts a case this function is called to start
the reporting portion of their simulation.  Optionally the user id
of the owner of the report can be passed, if it is not then it checks 
the User of the object, if neither are defined this is an error.

=cut


sub initiateReport{
	my $self = shift;
	my $user_id = shift || $self->getUser();
	if (!defined($user_id)){
		confess "User ID needs to be defined for initiateReport to work";
	}
	my $case_id = $self->getPrimaryKeyID();
	my $cond = sprintf (" end_date is null AND user_id = '%s' AND case_id = '%s' ",	$user_id, $case_id);
	my $reports = TUSK::Case::CaseReport->lookup($cond);
	my $report;
	if (!scalar(@{$reports})){
		$report = TUSK::Case::CaseReport->new();
		$report->setUserID($user_id);
		$report->setCaseID($case_id);
		$report->setStartDate(HSDB4::DateTime->new()->out_mysql_timestamp());
		$report->save({'user'=>$user_id});
		$self->setReport($report);
	} elsif (scalar(@{$reports}) > 1){
		confess "Couldn't find appropriate report to attach to case, (duplicate)";
	} else {
		$self->setReport($reports->[0]);
	}

}

#######################################################

=item B<completeReport>

   $case->completeReport($user_id);

The method finalizes the report associated with the case.  It should
be the final step in dealing with the report. It makes sure that the
report is no longer considered open for editing. The parameter is the 
user id associated with the owner of the case report.

=cut

sub completeReport{
    my $self = shift;
    my $user_id = shift || confess "User id is a required parameter";
    my $report = $self->getReport($user_id);
    if (!defined($report)){
	confess "Could not retrieve user report";
    }
    $report->setEndDate(HSDB4::DateTime->new()->out_mysql_timestamp());
    $report->save({'user'=>$user_id});
}

#######################################################

=item B<getScore>

   $score = $case->getScore();

This method returns the total score for a given case and case report.
If the case report is not initialized, it returns an error. The 
score is made up of the total scores of all completed phases for
the case.

=cut

sub getScore {
	my $self = shift;
	my $report = shift;
	if (!defined($report)){
		$report = $self->getReport || confess "The report must be initialized to get the score";
	}
	if ($report->getCaseID != $self->getPrimaryKeyID()){
		confess "That is not a valid report for this case, it is for case id: ".$report->getCaseID;

	}
	$self->setReport($report);
	my $completed_phases = $self->getCompletedPhases();	
	my $score = 0;
	foreach my $phase (@{$completed_phases}){
		$score += $phase->getScore($report);
	}
	return $score;


}

#######################################################

=item B<getLinkCourseCaseObject>

   $link_course_case = $self->getLinkCourseCaseObject();

Returns the associated TUSK::Case::LinkCourseCase object if it has been joined

=cut

sub getLinkCourseCaseObject{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Case::LinkCourseCase');
}

#######################################################

=item B<getCourseID>

   $int = $self->getCourseID();

Returns the course_id from the associated TUSK::Case::LinkCourseCase object.

=cut

sub getCourseID{
    my ($self) = @_;
    my $link_course_case = $self->getLinkCourseCaseObject();
    return $link_course_case->getParentCourseID();
}

#######################################################

=item B<getSchoolID>

   $int = $self->getSchoolID();

Returns the school_id from the associated TUSK::Case::LinkCourseCase object.

=cut

sub getSchoolID{
    my ($self) = @_;
    my $link_course_case = $self->getLinkCourseCaseObject();
    return $link_course_case->getSchoolID();
}

#######################################################

=item B<saveGradeEvent>

    $self->saveGradeEvent();

    If this case has a grade event, and a grade has not been recorded for this user and case, generate one. Otherwise, do nothing.

=cut

sub saveGradeEvent{
	my ($self, $grade_event_id, $user_id) = @_;

	my $grade = TUSK::GradeBook::LinkUserGradeEvent->lookupReturnOne("parent_user_id = '$user_id' AND child_grade_event_id = $grade_event_id");

	if(ref($grade) ne 'TUSK::GradeBook::LinkUserGradeEvent'){
		my $event = TUSK::GradeBook::GradeEvent->lookupKey($grade_event_id);
		if (defined($event)){
			my $timeperiod_id = $event->getTimePeriodID();
			my $course = $event->getCourseObject();
			my @students = $course->get_students($timeperiod_id);
			# if student is in course...
			if(scalar(map { $_->user_id() =~ /$user_id/ } @students)){
				$grade = TUSK::GradeBook::LinkUserGradeEvent->new();
				$grade->setParentUserID($user_id);
				$grade->setChildGradeEventID($grade_event_id);
				$grade->setGrade('Complete');
				$grade->save({ user => $user_id });
			}
		}
	}
}

#######################################################

=item B<getGradeDate>

   $int = $self->getGradeDate();

Returns the date that the LinkUserGradeEvent obj was created, if there is one, for this user and GradeEvent.

=cut

sub getGradeDate{
	my ($self, $user_id, $grade_event_id) = @_;

	my $grade = TUSK::GradeBook::LinkUserGradeEvent->lookupReturnOne("parent_user_id = '$user_id' AND child_grade_event_id = $grade_event_id");

	if(ref($grade) eq 'TUSK::GradeBook::LinkUserGradeEvent'){
		return $grade->getCreatedOn();
	}
	return "No Grade Recorded";
}

#######################################################

=item B<getGradeEventID>

   $int = $self->getGradeEventID();

Returns the LinkCaseGradeEvent grade_event_id if there is one, for this case.

=cut

sub getGradeEventID{
	my ($self) = @_;

	if(defined($self->getPrimaryKeyID())){
		my $grade_event = TUSK::Case::LinkCaseGradeEvent->lookup("parent_case_id = " . $self->getPrimaryKeyID());

		if (@$grade_event > 0){
			if (@$grade_event > 1){
				croak "More than one LinkCaseGradeEvent for provided case: " . $self->getPrimaryKeyID();
			}
			return $grade_event->[0]->getChildGradeEventID();
		}
	}
	return '';
}

#######################################################

=item B<setGradeEventID>

   $self->setGradeEventID([int]);

Sets the LinkCaseGradeEvent grade_event_id if an int is passed.

=cut

sub setGradeEventID{
	my ($self, $grade_event_id, $user) = @_;

	my $link = TUSK::Case::LinkCaseGradeEvent->lookupReturnOne("parent_case_id = " . $self->getPrimaryKeyID());

	if(ref($link) ne 'TUSK::Case::LinkCaseGradeEvent'){
	# there is no existing LinkCaseGradeEvent obj, so create one
		if(!$grade_event_id){
		# unless we weren't passed an event_id, in which case, do nothing 
			return;
		}
		$link = TUSK::Case::LinkCaseGradeEvent->new();
		$link->setParentCaseID($self->getPrimaryKeyID());
		$link->setChildGradeEventID($grade_event_id);
		$link->save({user => $user});
	}
	else {
		if(!$grade_event_id){
		# if we have pre-existing LinkCaseGradeEvent obj, but were not passed an id, we should delete obj
			$link->delete();
		}
		else {
		# we just want to change the GradeEvent linked to this case
			$link->setChildGradeEventID($grade_event_id);
			$link->save({user => $user});
		}
	}
}

#######################################################

=item B<getCaseAuthors>

   $self->getCaseAuthors();

Return string containing semi-colon-separated listing of all Case Authors.
Credentials can be optionally included.

=cut

sub getCaseAuthors{
	my ($self, $params) = @_;

	my $user_roles = TUSK::Permission::UserRole->new()->getFeatureUserByRole('case',$self->getPrimaryKeyID(),'author');

	my $ur_string;
	if($params->{credentials}){
		$ur_string = join '; ', map { $_->getNameFirstLastDegree() } @$user_roles;
	}
	else{
		$ur_string = join '; ', map { $_->getUserNameFirstLast() } @$user_roles;
	}

	return $ur_string;
}

#######################################################

=item B<getTestsWithCosts>

   $self->getTestsWithCosts();

Return an arrayref of tests that the user ordered and that have a 
default cost associated with them

=cut

sub getTestsWithCosts{
	my ($self, $user) = @_;

	$self->setUser($user);
	my $selections = TUSK::Case::TestSelection->getCaseSelections($self);
	my @test_ids = map { $_->getTestID() } @{$selections};
	my $tests = [];

	if (scalar(@test_ids)){
		$tests= TUSK::Case::Test->lookup ('test_id in (' . join(',',@test_ids) . ') and default_cost != 0');
	} 
	return $tests;
}

#######################################################

=item B<isLinearNav>

   $int = $self->isLinearNav();

Return 1 if case has a navigation_type of "Linear"; 0 otherwise.

=cut

sub isLinearNav{
	my ($self) = @_;

	if($self->getNavigationType() eq 'Linear'){
		return 1;
	}
	return 0;
}

#######################################################

=item B<isGlobalNav>

   $int = $self->isGlobalNav();

Return 1 if case has a navigation_type of "Global"; 0 otherwise.

=cut

sub isGlobalNav{
	my ($self) = @_;

	if($self->getNavigationType() eq 'Global'){
		return 1;
	}
	return 0;
}

#######################################################

=item B<emailReceipt>

   $self->emailReceipt($user);

Send the $user an email that they have completed the case.

=cut

sub emailReceipt{
	my $self = shift;
	my $user_id = shift || confess "User id is a required parameter";
	my $course  = shift || confess "Course is a required parameter";
	my $report  = shift || confess "Report is a required parameter";

	return if $self->isSelfAssessment();

	my $user = HSDB4::SQLRow::User->new()->lookup_key($user_id);

	my $coursetitle = $course->title();
	my $casetitle = $self->getCaseTitle();
	my $enddate = $report->getEndDate();
	my $subject = "Case Completion Receipt: $casetitle";
	my $message = <<EOM;
This is a message automatically sent by TUSK to confirm your completion of a case.

User ID: $user_id
Course: $coursetitle
Case: $casetitle
Case Completed: $enddate 

EOM
	my ($success, $retmsg) = $user->send_email($subject, $message);
	if(!$success){
		confess $retmsg;
	}
}

#######################################################

=item B<isReportComplete>

   $int = $self->isReportComplete();

Return 1 if case report is complete; 0 otherwise.

=cut

sub isReportComplete{
	my $self = shift;
	my $report = shift || confess "Report is a required parameter";

	if($report->getEndDate()){
		return 1;
	}
	return 0;
}

#######################################################

=item B<hasPopQuiz>

   $int = $self->hasPopQuiz();

Return 1 if case has a phase that is not of type 'quiz' with 
a linked quiz; 0 otherwise.

=cut

sub hasPopQuiz{
	my $self = shift;

	my $phases = $self->availablePhases();

	my $haspopquiz = 0;
	my $quiz;
	foreach my $p (@$phases) {
		$quiz = $p->getQuiz();
		if (defined $quiz && ref($p) !~ /Quiz$/) {
			$haspopquiz = 1;
			last;
		}
	}	
	return $haspopquiz;
}

#######################################################

=item B<hasRule>

   $int = $self->hasRule();

Return 1 if case has a phase with a rule, 0 otherwise

=cut

sub hasRule{
	my $self = shift;

	my $phases = $self->availablePhases();

	foreach my $p (@$phases) {
		my $rule = $p->getRules();
		if (scalar @$rule) {
			return 1;
		}
	}	
	return 0;
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
