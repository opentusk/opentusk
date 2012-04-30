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


package TUSK::Case::Battery;

=head1 NAME

B<TUSK::Case::Battery> - Class for manipulating entries in table battery in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Case::PhaseTestExclusion;
use TUSK::Case::Phase;
use TUSK::Case::PatientType;
use TUSK::Case::Test;
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
					'tablename' => 'battery',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'battery_id' => 'pk',
					'school_id'=>'',
					'battery_title' => '',
					'battery_desc' => '',
					'battery_type' => '',
					'lab_sheet' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
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

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getBatteryTitle>

    $string = $obj->getBatteryTitle();

    Get the value of the battery_title field

=cut

sub getBatteryTitle{
    my ($self) = @_;
    return $self->getFieldValue('battery_title');
}

#######################################################

=item B<setBatteryTitle>

    $string = $obj->setBatteryTitle($value);

    Set the value of the battery_title field

=cut

sub setBatteryTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('battery_title', $value);
}


#######################################################

=item B<getBatteryDesc>

    $string = $obj->getBatteryDesc();

    Get the value of the battery_desc field

=cut

sub getBatteryDesc{
    my ($self) = @_;
    return $self->getFieldValue('battery_desc');
}

#######################################################

=item B<setBatteryDesc>

    $string = $obj->setBatteryDesc($value);

    Set the value of the battery_desc field

=cut

sub setBatteryDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('battery_desc', $value);
}


#######################################################

=item B<getBatteryType>

    $string = $obj->getBatteryType();

    Get the value of the battery_type field

=cut

sub getBatteryType{
    my ($self) = @_;
    return $self->getFieldValue('battery_type');
}

#######################################################

=item B<setBatteryType>

    $string = $obj->setBatteryType($value);

    Set the value of the battery_type field

=cut

sub setBatteryType{
    my ($self, $value) = @_;
    $self->setFieldValue('battery_type', $value);
}


#######################################################

=item B<getLabSheet>

    $string = $obj->getLabSheet();

    Get the value of the lab_sheet field

=cut

sub getLabSheet{
    my ($self) = @_;
    return $self->getFieldValue('lab_sheet');
}

#######################################################

=item B<setLabSheet>

    $string = $obj->setLabSheet($value);

    Set the value of the lab_sheet field

=cut

sub setLabSheet{
    my ($self, $value) = @_;
    $self->setFieldValue('lab_sheet', $value);
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

sub getBatteries{
	my $class = shift;
	my $phase = shift;
	my $school = shift;
	return unless ($school);
	my $cond = ' 1 = 1 ';
	if (defined($phase) && ($phase->isa('TUSK::Case::Phase'))){
		$cond = " battery_type = '".$phase->getBatteryType()."' " ;
	}
	return TUSK::Case::Battery->lookup($cond . "and lower(school_name) = lower('" . $school . "')", undef, undef, undef, [ TUSK::Core::JoinObject->new('TUSK::Core::School')]);
}

sub getSchoolBatteries {
	my $class = shift;
	my $school = shift;
	my $cond = " school_id = " . $school->getPrimaryKeyID();
	return TUSK::Case::Battery->lookup($cond);
}

#######################################################

=item B<getChildExamStruct>

    $struct = $battery->getChildExamStruct($phase, $patient_type, $author_view_flag);

    This sub returns a complicated structure that represents the relevant battery
information for the relevant phase and patient type.  The battery for a phase is represented 
by taking the exams in the battery and subtracting the tests specified in the phase
but in some cases replaces values from the battery.  These replaced values are specified per
phase and patient type. 

The struct returned has the following structure :

$VAR1 = {
          'current' => {
                         'pk' => '1',
                         'title' => 'Vital signs' <--- Battery
                       },
          'children' => [ <--- Represents Exams
                          {
                            'current' => {
                                           'pk' => '6',
                                           'exam_title' => 'Oxygen Saturation',
                                           'include' => '1',
                                           'exam_correct' => 'Yes',
                                           'exam_def_value' => '',
                                           'display_value' => 'my value',
                                           'exam_alt_value' => 'my value',
                                           'phase_exam_exclusion_id' => '20'
                                         },
                            'children' => [] <--- Represents Tests
                          }]
	};

=cut

sub getChildExamStruct {
	my $self = shift;
	my $phase = shift;
	my $patient_type = shift;
	my $author_view_flag = shift;

	# get battery_id
	if (!defined($self) || !$self->isa('TUSK::Case::Battery')){
		confess "A Battery needs to be passed";
	} 
	if (!defined($self->getPrimaryKeyID())){
		confess "The battery object needs to be initialized"; 
	}
	my $battery_id = $self->getPrimaryKeyID();

	# get phase_id
	if (!defined($phase) || !$phase->isa('TUSK::Case::Phase')){
		confess "A Phase needs to be passed";
	} 
	if (!defined($phase->getPrimaryKeyID())){
		confess "The phase object needs to be initialized"; 
	}
	my $phase_id = $phase->getPrimaryKeyID();

	# now get patient_type_id... if no patient_type passed in, create one and set id to 0
	my $patient_type_id;
	if (!defined($patient_type) || !$patient_type->isa('TUSK::Case::PatientType')){
		$patient_type = TUSK::Case::PatientType->new(); #new
	} 
	if (!defined($patient_type->getPrimaryKeyID())){
		$patient_type_id=0; 
	} else { 
		$patient_type_id = $patient_type->getPrimaryKeyID(); 
	}

	my $tests_struct = TUSK::Case::Test->lookup("case_test.battery_id = $battery_id AND case_test.master_test_id is null and case_test_value.patient_type_id=$patient_type_id",
	  ['case_test.sort_order', 'subTest.sort_order'],
	  undef, undef,
	  [TUSK::Core::JoinObject->new('TUSK::Case::Test',
	      {alias=>'subTest', joinkey=>'master_test_id', origkey=>'case_test.test_id'}),
	  TUSK::Core::JoinObject->new('TUSK::Case::PhaseTestExclusion',
	      {alias=>'tx', joinkey => 'test_id', origkey => 'case_test.test_id', 
	      joincond => "tx.phase_id = $phase_id"}),
	  TUSK::Core::JoinObject->new('TUSK::Case::PhaseTestExclusion',
	      {alias=>'stx', joinkey => 'test_id', origkey => 'subTest.test_id', 
	      joincond => "stx.phase_id = $phase_id", objtree=>['subTest'] }),
	  TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
	      {joinkey => 'test_id', origkey => 'case_test.test_id' }),
	  TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
	      {alias=>'subTestValue', joinkey => 'test_id', 
	      origkey => 'subTest.test_id', objtree=> ['subTest'],
	      joincond => "subTestValue.patient_type_id = $patient_type_id"})
	  ]);

	my $battery_struct = {};

# this code reformats the data from the query into a tree structure

	$battery_struct->{'current'}->{'pk'} = $battery_id;
	$battery_struct->{'current'}->{'title'} = $self->getBatteryTitle();

	$battery_struct->{'children'} = [];
	
	foreach my $test (@$tests_struct){
		my $tmpHash = {};
		
		$tmpHash->{'current'}->{'title'} = $tmpHash->{'current'}->{'title_with_units'} = $test->getTitle();
		$tmpHash->{'current'}->{'units'} .= $test->getUnits();
		$tmpHash->{'current'}->{'title_with_units'} .= ' (' . $test->getUnits() . ')' if $test->getUnits() ne '';
		
		$tmpHash->{'children'} = [];

		my $subtests = $test->getJoinObjects('subTest');
		my $value = $test->getJoinObject('TUSK::Case::TestValue');
		my $exclusion = $test->getJoinObject('tx');

		if(ref($exclusion) ne 'TUSK::Case::PhaseTestExclusion'){
			# if test doesnt have exclusion, make a blank obj here to avoid breaking code below
			$exclusion = TUSK::Case::PhaseTestExclusion->new();
		}

		unless (@$subtests > 0){
			$tmpHash->{'current'}->{'alt_value'} = $exclusion->getAlternateValue();
			$tmpHash->{'current'}->{'feedback'} = $exclusion->getFeedback();
			$tmpHash->{'current'}->{'def_value'} = $value->getDefaultValue();
			$tmpHash->{'current'}->{'correct'} = $exclusion->getCorrect();
			$tmpHash->{'current'}->{'content_id'} = $value->getDefaultContentID();
			$tmpHash->{'current'}->{'alt_content_id'} = $exclusion->getAlternateContentID();
			$tmpHash->{'current'}->{'phase_exam_exclusion_id'} = $exclusion->getPrimaryKeyID();
			$tmpHash->{'current'}->{'priority'} = $exclusion->getPriority();
			$tmpHash->{'current'}->{'display_value'} = $test->getDisplayValue($phase, $author_view_flag);
		}

		$tmpHash->{'current'}->{'pk'} = $test->getPrimaryKeyID();
		$tmpHash->{'current'}->{'include'} = defined($exclusion->getInclude())? $exclusion->getInclude() : 0;
		$tmpHash->{'current'}->{'priority'} = $exclusion->getPriority();
			
		push (@{$battery_struct->{'children'}}, $tmpHash);
 

		foreach my $subtest (@$subtests){

			my $subvalues = $subtest->getJoinObject('subTestValue');
			my $st_exclusion = $subtest->getJoinObject('stx');
			if(ref($st_exclusion) ne 'TUSK::Case::PhaseTestExclusion'){
				# if test doesnt have exclusion, make a blank obj here to avoid breaking code below
				$st_exclusion = TUSK::Case::PhaseTestExclusion->new();
			}
		    my $tmpHash = {};

			$tmpHash->{'current'}->{'title'} = $tmpHash->{'current'}->{'title_with_units'} = $subtest->getTitle();
			$tmpHash->{'current'}->{'units'} .= $subtest->getUnits();
			$tmpHash->{'current'}->{'title_with_units'} .= ' (' . $subtest->getUnits() . ')' if $subtest->getUnits() ne '';
			$tmpHash->{'current'}->{'alt_value'} = $st_exclusion->getAlternateValue();
			$tmpHash->{'current'}->{'feedback'} = $st_exclusion->getFeedback();
			$tmpHash->{'current'}->{'def_value'} = $subvalues->getDefaultValue();
			$tmpHash->{'current'}->{'correct'} = $st_exclusion->getCorrect();
			$tmpHash->{'current'}->{'content_id'} = $subvalues->getDefaultContentID();
			$tmpHash->{'current'}->{'alt_content_id'} = $st_exclusion->getAlternateContentID();
			$tmpHash->{'current'}->{'phase_exam_exclusion_id'} = $st_exclusion->getPrimaryKeyID();
			$tmpHash->{'current'}->{'priority'} = $st_exclusion->getPriority();

		    if (defined($st_exclusion->getAlternateValue())){
				$tmpHash->{'current'}->{'display_value'} = $st_exclusion->getAlternateValue();
			} elsif(!$author_view_flag) {
				if($self->getBatteryType() eq 'History'){
					$tmpHash->{'current'}->{'display_value'} = 'Non-Contributory';
				} else {
					$tmpHash->{'current'}->{'display_value'} = 'Within Normal Limits';
				}
			}

			$tmpHash->{'current'}->{'pk'} = $subtest->getPrimaryKeyID();
			$tmpHash->{'current'}->{'include'} = defined($st_exclusion->getInclude())? $st_exclusion->getInclude() : 0;

		    my $last_index = scalar(@{$battery_struct->{'children'}}) - 1;
			push (@{$battery_struct->{'children'}->[$last_index]->{'children'}}, $tmpHash);
			
			if($tmpHash->{'current'}->{'include'} && $tmpHash->{'current'}->{'priority'} ne 'Low'){
				$battery_struct->{'children'}->[$last_index]->{'current'}->{'has_expert_subtest'} = 1;
			}
		}
	}
	
	return $battery_struct;

}

sub getChildExamIDStruct {
        my $self = shift;
        my $phase = shift;
        my $patient_type = shift;
        if (!defined($self) || !$self->isa('TUSK::Case::Battery')){
                confess "A Battery needs to be passed";
        }
        if (!defined($self->getPrimaryKeyID())){
                confess "The battery object needs to be initialized";
        }
        if (!defined($phase) || !$phase->isa('TUSK::Case::Phase')){
                confess "A Phase needs to be passed";
        }
        if (!defined($phase->getPrimaryKeyID())){
                confess "The phase object needs to be initialized";
        }
        if (!defined($patient_type) || !$patient_type->isa('TUSK::Case::PatientType')){
                confess "A PatientType needs to be passed";
        }
        if (!defined($patient_type->getPrimaryKeyID())){
                confess "The patient type object needs to be initialized";
        }
        my $battery_id = $self->getPrimaryKeyID();
        my $phase_id = $phase->getPrimaryKeyID();
        my $patient_type_id = $patient_type->getPrimaryKeyID();

		my $tests_struct = TUSK::Case::Test->lookup("case_test.battery_id = $battery_id AND case_test.master_test_id is null and case_test_value.patient_type_id=$patient_type_id",
		    ['case_test.sort_order', 'subTest.sort_order'],
		    undef, undef,
		    [TUSK::Core::JoinObject->new('TUSK::Case::Test',
		        {alias=>'subTest', joinkey=>'master_test_id', origkey=>'case_test.test_id'}),
		     TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
		        {joinkey => 'test_id', origkey => 'case_test.test_id' }),
		     TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
		        {alias=>'subTestValue', joinkey => 'test_id', 
		        origkey => 'subTest.test_id', objtree=> ['subTest'],
		        joincond => "subTestValue.patient_type_id = $patient_type_id"})
		    ]);


		my $id_struct = { exam=>{}, test=>{}};

		foreach my $test (@$tests_struct){
			$id_struct->{exam}->{$test->getPrimaryKeyID()} = 1;
			
			my $subtests = $test->getJoinObjects('subTest');
			foreach my $st (@$subtests){
				$id_struct->{test}->{$st->getPrimaryKeyID()} = 1;
			}
		}

	return $id_struct;
}


sub getChildExams {
	#deprecated
	getChildTests(@_);
}

#######################################################

=item B<getChildTests>

    $arrayref = $obj->getChildTests();

    returns all tests within a battery (excluding subtests). 

=cut

sub getChildTests {
	my $self = shift;
	my $battery_id = $self->getPrimaryKeyID(); 

	unless ($self->{-tests}){
		$self->{-tests} = TUSK::Case::Test->lookup(" battery_id = $battery_id and master_test_id is null");
	}
	return $self->{-tests};
}

#######################################################

=item B<getTestsForPatientType>

    $arrayref = $obj->getTestsForPatientType($patient_type[_id]);

    this method, when supplied either a PatientType obj or patient_type_id,
    will return arrayref of all tests (and TestValue objs) that are 
    children of Battery. This does not return subtests.

=cut

sub getTestsForPatientType {
	my $self = shift;
	my $patient_type = shift;

	my $battery_id = $self->getPrimaryKeyID(); 
	my $patient_type_id;

	if (defined($patient_type)){
		if (ref($patient_type) and $patient_type->isa('TUSK::Case::PatientType')){
			$patient_type_id = $patient_type->getPrimaryKeyID();	
		} elsif ($patient_type =~ m/^\d+/){
			$patient_type_id = $patient_type;	
		}
	}

	my $tests_struct = TUSK::Case::Test->lookup("case_test.battery_id = $battery_id AND case_test.master_test_id is null and case_test_value.patient_type_id=$patient_type_id",
		    ['case_test.sort_order'],
		    undef, undef,
		    [TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
		        {joinkey => 'test_id', origkey => 'case_test.test_id' }) ]);

	return $tests_struct;
}

#######################################################

=item B<updateSortOrders>

    $arrayref = $obj->updateSortOrders($school_id, $change_order_string, $arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  $index is array index of the object that changed,
$newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateSortOrders{
    my ($self, $school_id, $change_order_string, $arrayref) = @_;

    my $cond = "school_id = " . $school_id;
    my ($index, $newindex) = split ("-", $change_order_string);

    return $self->SUPER::updateSortOrders($index, $newindex, $cond, $arrayref);
}

#######################################################

=item B<delete>

    $retval = $obj->delete();

    Before deleting Battery obj, be sure to delete all child tests.
    The Test obj will be sure to delete all subtests, test values, and subtest values.

=cut

sub delete {
	my $self = shift;
	my $params = shift;
	foreach my $test (@{$self->getChildTests}){
		$test->delete($params);
	}
	return $self->SUPER::delete($params);
}


1;

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

