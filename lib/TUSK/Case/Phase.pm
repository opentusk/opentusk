package TUSK::Case::Phase;

=head1 NAME

B<TUSK::Case::Phase> - Class for manipulating entries in table phase in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4
	confess "Invalid phase type id :".$self->getPhaseTypeID() if (!$self->{-phase_type});

=cut

use strict;
use TUSK::Case::PhaseType;
use TUSK::Case::LinkPhaseBattery;
use TUSK::Case::PhaseOption;
use TUSK::Case::PhaseOptionSelection;
use TUSK::Case::PhaseVisit;
use TUSK::Case::LinkPhaseContent;
use TUSK::Case::LinkPhaseQuiz;
use TUSK::Case::TestSelection;
use TUSK::Case::Rule;

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
use Carp;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'phase',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'phase_id' => 'pk',
					'phase_title' => '',
					'phase_desc' => '',
					'main_text' => '',
					'instructions' => '',
					'phase_type_id' => '',
					'shared' => '',
					'phase_option_type' => '',
					'source' => '',
					'copyright' => '',
					'encounter' => '',
					'is_generic' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_join_objects => [
							      TUSK::Core::JoinObject->new("TUSK::Case::PhaseType"),
							      ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getPhaseTitle>

   $string = $obj->getPhaseTitle();

Get the value of the phase_title field

=cut

sub getPhaseTitle{
    my ($self) = @_;
    return $self->getFieldValue('phase_title');
}

#######################################################

=item B<setPhaseTitle>

    $string = $obj->setPhaseTitle($value);

Set the value of the phase_title field

=cut

sub setPhaseTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_title', $value);
}


#######################################################

=item B<getPhaseDesc>

   $string = $obj->getPhaseDesc();

Get the value of the phase_desc field

=cut

sub getPhaseDesc{
    my ($self) = @_;
    return $self->getFieldValue('phase_desc');
}

#######################################################

=item B<setPhaseDesc>

    $string = $obj->setPhaseDesc($value);

Set the value of the phase_desc field

=cut

sub setPhaseDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_desc', $value);
}


#######################################################

=item B<getMainText>

   $string = $obj->getMainText();

Get the value of the main_text field

=cut

sub getMainText{
    my ($self) = @_;
    return $self->getFieldValue('main_text');
}

#######################################################

=item B<setMainText>

    $string = $obj->setMainText($value);

Set the value of the main_text field

=cut

sub setMainText{
    my ($self, $value) = @_;
    $self->setFieldValue('main_text', $value);
}


#######################################################

=item B<getInstructions>

   $string = $obj->getInstructions();

Get the value of the instructions field

=cut

sub getInstructions{
    my ($self) = @_;
    return $self->getFieldValue('instructions');
}

#######################################################

=item B<setInstructions>

    $string = $obj->setInstructions($value);

Set the value of the instructions field

=cut

sub setInstructions{
    my ($self, $value) = @_;
    $self->setFieldValue('instructions', $value);
}


#######################################################

=item B<getPhaseTypeID>

   $string = $obj->getPhaseTypeID();

Get the value of the phase_type_id field

=cut

sub getPhaseTypeID{
    my ($self) = @_;
    return $self->getFieldValue('phase_type_id');
}

#######################################################

=item B<setPhaseTypeID>

    $string = $obj->setPhaseTypeId($value);

Set the value of the phase_type_id field

=cut

sub setPhaseTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_type_id', $value);
}


#######################################################

=item B<getShared>

   $string = $obj->getShared();

Get the value of the shared field

=cut

sub getShared{
    my ($self) = @_;
    return $self->getFieldValue('shared');
}

#######################################################

=item B<setShared>

    $string = $obj->setShared($value);

Set the value of the shared field

=cut

sub setShared{
    my ($self, $value) = @_;
    $self->setFieldValue('shared', $value);
}


#######################################################

=item B<getPhaseOptionType>

   $string = $obj->getPhaseOptionType();

Get the value of the phase_option_type field

=cut

sub getPhaseOptionType{
    my ($self) = @_;
    return $self->getFieldValue('phase_option_type');
}

#######################################################

=item B<setPhaseOptionType>

    $string = $obj->setPhaseOptionType($value);

Set the value of the phase_option_type field

=cut

sub setPhaseOptionType{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_option_type', $value);
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

#######################################################

=item B<getEncounter>

   $string = $obj->getEncounter();

Get the value of the encounter field

=cut

sub getEncounter{
    my ($self) = @_;
    return $self->getFieldValue('encounter');
}

#######################################################

=item B<setEncounter>

    $string = $obj->setEncounter($value);

Set the value of the encounter field

=cut

sub setEncounter{
    my ($self, $value) = @_;
    $self->setFieldValue('encounter', $value);
}


#######################################################

=item B<getIsGeneric>

   $string = $obj->getIsGeneric();

Get the value of the is_generic field

=cut

sub getIsGeneric{
    my ($self) = @_;
    return $self->getFieldValue('is_generic');
}

#######################################################

=item B<setIsGeneric>

    $string = $obj->setIsGeneric($value);

Set the value of the is_generic field

=cut

sub setIsGeneric{
    my ($self, $value) = @_;
    $self->setFieldValue('is_generic', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<rebless>

This examines the phase passed and returns the properly blessed version
of the subclass.

=cut


sub rebless{
	my $self = shift;
	my $phase_type_id = shift;
	my $phase_type;
	
	return $self if ($self->getIsGeneric()); # don't rebless if this is generic

	if (!defined($phase_type_id)){
		$phase_type = $self->getPhaseType();
	} else {
		$phase_type = TUSK::Case::PhaseType->lookupKey($phase_type_id);
	}
	if (!$phase_type){
		confess "Could not find a phase type for this phase id: $phase_type_id";
	}
	my $class = $phase_type->getPhaseTypeObjectName();
	if ($class){
		# class is tainted
		$class =~ m/^(\w+)$/;
		eval "require TUSK::Case::Phase::$1";
		if ($@){
			confess "Couldn't load package TUSK::Case::Phase::$class : $@";
		}
		bless $self, "TUSK::Case::Phase::$class";
		if ($class->can('init')){
			$self->init();
		}
	} 
	
	return $self;
}

#######################################################

=item B<lookupKey>

    $phase = $obj->lookupKey($key);

This is an override of the base class to allow new phases to be
blessed into the proper subclass.

=cut

sub lookupKey {
    my $self = shift;
    $self = $self->new() if (ref $self eq '');
    $self->SUPER::lookupKey (@_);
    return $self->rebless;
}

#######################################################

=item B<setPrimaryKeyID>

    $obj->setPrimaryKeyID($key);

This is an override of the base class to allow new phases to be
blessed into the proper subclass.

=cut


sub setPrimaryKeyID {
    my $self = shift;
    $self->SUPER::setPrimaryKeyID(@_);
    return $self->rebless;

}

#######################################################

=item B<lookupPhaseType>

    $phase = $obj->lookupPhaseType($phase_type_id);

Given a phase type id, a phase of the proper subclass is returned.

=cut

sub lookupPhaseType {
	my $self = shift;
	my $type_id = shift;
	$self = $self->new() if (ref $self eq '');
	$self =  $self->rebless($type_id);
	$self->setPhaseTypeID($type_id);
	return $self;
}

#######################################################

=item B<getPhaseType>

    $phase_type = $obj->getPhaseType();

For the specific phase, it returns the phase type object associated to it.

=cut

sub getPhaseType {
    my $self = shift();
    die "invalid invocant of object method" unless $self->isa('TUSK::Case::Phase');
    unless ($self->{-phase_type}){
	$self->{-phase_type} = TUSK::Case::PhaseType->lookupKey($self->getPhaseTypeID());
	confess "Invalid phase type id :".$self->getPhaseTypeID() if (!$self->{-phase_type});
    }
    return  $self->{-phase_type};
}

#######################################################

=item B<getIncludeFile>

    $string = $obj->getIncludeFile();

This method returns the file that handles the UI for the particular phase.  
It is how the presentation layer knows what page should display for a particular
phase type.

=cut

sub getIncludeFile {
	return "generic_phase";
}


#######################################################

=item B<getScore>

    $score = $phase->getScore($report);

This method should be overridden in phases that can have
scores.  The report must be passed for any 
scoring to take place.

=cut

sub getScore {
	return 0;
}


#######################################################

=item B<getBatteries>

    $batteries  = $obj->getBatteries();

Returns all battery objects associated to this phase.

=cut

sub getBatteries {
    my $self = shift();
    return TUSK::Case::LinkPhaseBattery->getBatteries($self);
	
}

#######################################################

=item B<getPatientTypeID>

    $patient_type_id  = $obj->getPatientTypeID();

Returns patient_type_id associated with this phase's case.

=cut

sub getPatientTypeID {
    my $self = shift();
	my $id = $self->getPrimaryKeyID();
	my $link = TUSK::Case::LinkCasePhase->lookup("child_phase_id = $id");
	unless (scalar @$link){
		confess "No TUSK::Case::LinkCasePhase objects for supplied phase (id: $id)";
	}
	unless (@$link == 1){
		confess "Ambiguous TUSK::Case::LinkCasePhase objects returned for supplied phase (id: $id)";
	}
	my $case = TUSK::Case::Case->lookupKey($link->[0]->getParentCaseID());
	
    return $case->getPatientTypeID();
}

#######################################################

=item B<getBatteryType>

    $string = $obj->getBatteryType();

Base method that can be overridden for phases that need to have 
a different battery type associated.  By default the string is ''.  
Phases like PhysicalExam will need to override this to provide
the correct BatteryType.

=cut

sub getBatteryType {
	return '';
}


#######################################################

=item B<getPhaseOptions>

    $phase_options = $obj->getPhaseOptions([$case_report]);

Returns the phase options for a given phase.  If the optional case_report is passed,
then the phase option selections for the case_report are joined in to the select.
 

=cut

sub getPhaseOptions {
	my $self = shift;
	my $phase_id = $self->getPrimaryKeyID() or return [];
	my $case_report = shift ;
	my ($case_report_cond,$joinObject);
	if (defined($case_report) && ($case_report->isa('TUSK::Case::CaseReport'))){
		if (!$case_report->isa('TUSK::Case::CaseReport')){
			confess "The parameter must be a TUSK::Case::CaseReport";
		}
		if (!defined($case_report->getPrimaryKeyID())){
			confess "The case report must be initialized for getPhaseOptions to work";
		}
		$case_report_cond = " AND case_phase_option_selection.case_report_id = ".$case_report->getPrimaryKeyID();

		my $visit = $self->getLastVisitWithSelections($case_report);
		if(defined $visit){
			$case_report_cond .= " AND case_phase_option_selection.phase_visit_id = " . $visit->getPrimaryKeyID();
		}

		$joinObject = [TUSK::Core::JoinObject->new("TUSK::Case::PhaseOptionSelection",
							{'joinkey'=>'phase_option_id',
							 'origkey'=>'phase_option_id',
							 'cond' => "case_phase_option_selection.phase_id = $phase_id ".$case_report_cond} )];
	} 
	else {
		$case_report_cond = '';
	}
	return TUSK::Case::PhaseOption->lookup("phase_option.phase_id = $phase_id",["sort_order"],
		undef,undef,$joinObject);
}


#######################################################

=item B<getReferences>

    $content = $obj->getReferences();

Returns all content that is 'Reference' content for the given phase.


=cut

sub getReferences {
	my $self = shift;
	return $self->getContent("Reference");
}

#######################################################

=item B<getNarrativeContent>

    $content = $obj->getNarrativeContent();

Returns all content that is 'Narrative' content for the given phase.

=cut

sub getNarrativeContent {
	my $self = shift;
	return $self->getContent("Narrative");
}

#######################################################

=item B<getContent>

    $content = $obj->getContent($type);

Returns the content associated to the phase with the given type.

=cut

sub getContent {
	my $self = shift;
	my $content_type = shift;
	my $phase_id = $self->getPrimaryKeyID();
	my $references = TUSK::Case::LinkPhaseContent->lookup("parent_phase_id = $phase_id "
														  ." and link_type = '$content_type'",['sort_order'] );
	my @content = map { $_->getContent() } @{$references};
	return \@content;
}

#######################################################

=item B<visit>

    $phase->visit($case_report);

For a given phase and case report, create a phase visit record.

=cut

sub visit{
    my $self = shift;
    my $report = shift || confess "Report object needed to continue";
    my $phase_id = $self->getPrimaryKeyID() || confess "Phase Id not found";
    my $report_id = $report->getPrimaryKeyID();

	my $visit =  TUSK::Case::PhaseVisit->new();
	$visit->setCaseReportID($report_id);
	$visit->setPhaseID($phase_id);
	$visit->setVisitDate(HSDB4::DateTime->new()->out_mysql_timestamp());
	$visit->save({ user => $report->getUserID() });
	return $visit;
}

#######################################################

=item B<visited>

    $phase->visited($case_report);

For a given phase and case report, check if there is a phase visit record

=cut

sub visited{
	my $self = shift;
	my $report = shift || confess "Report object needed to continue";
	my $phase_id = $self->getPrimaryKeyID() || confess "Phase Id not found";
	my $report_id = $report->getPrimaryKeyID();
	my $cond = sprintf(" phase.phase_id = %s and case_report_id = %s ",
	           $phase_id,$report_id);
	my $visits = TUSK::Case::PhaseVisit->lookup($cond);
	if (scalar(@{$visits})){
		return 1;
	}
	else{
		return 0;
	}
}

#######################################################

=item B<getQuizLink>

    $link = $phase->getQuizLink();

Return the LinkPhaseQuiz record corresponding to this phase, there should be zero or one.

=cut

sub getQuizLink{
	my $self = shift;
	my $phase_id = $self->getPrimaryKeyID();
	my $links = TUSK::Case::LinkPhaseQuiz->lookup(" parent_phase_id = " .$phase_id, 
		undef,undef,undef,
		[TUSK::Core::JoinObject->new("TUSK::Quiz::Quiz",{'joinkey'=>'quiz_id','origkey'=>'child_quiz_id'})]);
	# there should be only one quiz
	if (scalar(@{$links}) > 1){
		confess "The phase with id $phase_id has more than one quiz";
	}
	my $quizLink = pop @{$links};
	return $quizLink;

}

#######################################################

=item B<getQuiz>

    $quiz =$phase->getQuiz($case_report);

Returns the quiz object associated with this phase. 

=cut

sub getQuiz {
	my $self = shift;
	my $link = $self->getQuizLink();
	if ($link){
		return $link->getQuiz();
	}
	return undef;

}

#######################################################

=item B<getPhaseTestSelections>

    $arrayref = $obj->getPhaseTestSelections($report);

Given a TUSK::Case:CaseReport object this method will return an arrayref
of TUSK::Case::TestSelection Objects that have been previously selected in the 
phase for the given CaseReport.

=cut

sub getPhaseTestSelections{
	my $self = shift;
	my $report = shift or confess "A report object is required for getPhaseTestSelections";
	if (!$report->isa('TUSK::Case::CaseReport')){
		confess "The report object TUSK::Case::CaseReport should be the second parameter passed."
	}
	my $report_id = $report->getPrimaryKeyID();
	my $phase_id = $self->getPrimaryKeyID();
	return TUSK::Case::TestSelection->lookup("case_report_id = $report_id and phase_id = $phase_id");
}

#######################################################

=item B<setVisit>

    $arrayref = $obj->setVisit($phase_visit);

Associates a TUSK::Case:PhaseVisit with a phase

=cut

sub setVisit{
	my $self = shift;
	my $visit = shift;
	if (!defined($visit) || !$visit->isa('TUSK::Case::PhaseVisit')){
		confess "setVisit requires a TUSK::Case::PhaseVisit object";
	}
	if (!$visit->getPrimaryKeyID()){
		confess "setPhase requires an initialized TUSK::Case::PhaseVisit object";
	}
	$self->{-visit} = $visit;
}

#######################################################

=item B<getVisit>

   $visit = $phase->getVisit();

Returns the phase visit associated with this phase.

=cut

sub getVisit{
	my $self = shift;
	unless ($self->{-visit}){
		confess "No affiliated Phase Visit";
	}
	return $self->{-visit};
}

#######################################################

=item B<getLastVisitWithSelections>

   $visit = $phase->getLastVisitWithSelections();

Returns the most recent phase visit associated with this phase that has PhaseOptionSelection
records associated with it.

=cut

sub getLastVisitWithSelections{
	my $self = shift;
	my $case_report = shift;
	if (defined($case_report) && !($case_report->isa('TUSK::Case::CaseReport'))){
		confess "The parameter must be a TUSK::Case::CaseReport";
	}
	if (!defined($case_report->getPrimaryKeyID())){
		confess "The case report must be initialized for getPhaseOptions to work";
	}

	my $selection = TUSK::Case::PhaseOptionSelection->lookupReturnOne('case_report_id = ' . $case_report->getPrimaryKeyID() . ' and phase_id = ' . $self->getPrimaryKeyID(), ['phase_visit_id DESC']);

	if (defined $selection) {
		return TUSK::Case::PhaseVisit->lookupKey($selection->getPhaseVisitID());
	}
	else {
		warn 'no last visit with selections: ' . $self->getPhaseTitle();
	}
	return undef;
}

#######################################################

=item B<getMostRecentVisit>

   $visit = $phase->getMostRecentVisit();

Returns the most recent phase visit associated with this phase.

=cut

sub getMostRecentVisit{
	my $self = shift;
	my $case_report = shift;

	if (defined($case_report) && !($case_report->isa('TUSK::Case::CaseReport'))){
		confess "The parameter must be a TUSK::Case::CaseReport";
	}
	if (!defined($case_report->getPrimaryKeyID())){
		confess "The case report must be initialized for getMostRecentVisit to work";
	}

	my $visit = TUSK::Case::PhaseVisit->lookupReturnOne('case_report_id = ' . $case_report->getPrimaryKeyID() . ' and case_phase_visit.phase_id = ' . $self->getPrimaryKeyID(), ['phase_visit_id DESC']);

	if (defined $visit) {
		return $visit;
	}

	return undef;
}

#######################################################

=item B<isLastPhaseVisted>

   $visit = $phase->isLastPhaseVisited();

returns boolean whether the calling phase was the last phase visited for given report

=cut

sub isLastPhaseVisited{
	my $self = shift;
	my $case_report = shift;

	if (defined($case_report) && !($case_report->isa('TUSK::Case::CaseReport'))){
		confess "The parameter must be a TUSK::Case::CaseReport";
	}
	if (!defined($case_report->getPrimaryKeyID())){
		confess "The case report must be initialized for isLastPhaseVisited to work";
	}

	my $last_visit = TUSK::Case::PhaseVisit->lookupReturnOne('case_report_id = ' . $case_report->getPrimaryKeyID(), ['phase_visit_id DESC']);

	if (defined $last_visit) {
		if ($self->getPrimaryKeyID() == $last_visit->getPhaseObject()->getPrimaryKeyID()) {
			return 1;
		}
	}
	return 0;
}

#######################################################

=item B<getRules>

   $rules = $phase->getRules();

Returns an arrayref of rules that need to be satisfied in order
to enter this phase.

=cut

sub getRules{
	my $self = shift;

	return TUSK::Case::Rule->new()->lookup('phase_id=' . $self->getPrimaryKeyID());
}


#######################################################

=item B<evaluateRules>

    @msgs = $obj->evaluateRules($arrayref, $casereport);

Provided an arrayref of rule objects and a case report obj, 
evaluate rules one at a time. Return an array containing a 
message for each violated rule. If no rules violated, 
array will be empty.

=cut

sub evaluateRules {
	my ($self, $rules, $report) = @_;
	
	my @msgs;
	foreach my $r (@$rules) {
		if (!$r->isSatisfied($report)) {
			push @msgs, $r->getMessage();
		}
	}

	return @msgs;
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

