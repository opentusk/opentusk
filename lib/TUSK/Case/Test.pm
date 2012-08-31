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


package TUSK::Case::Test;

=head1 NAME

B<TUSK::Case::Test> - Class for manipulating entries in table case_test in tusk database

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

# Non-exported package globals go here
use vars ();

use TUSK::Case::PhaseTestExclusion;
use TUSK::Case::Phase;
use TUSK::Case::PatientType;
use TUSK::Case::TestValue;
use TUSK::Case::Battery;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'case_test',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'test_id' => 'pk',
					'battery_id' => '',
					'master_test_id' => '',
					'has_sub_test' => '',
					'title' => '',
					'default_cost' => '',
					'units' => '',
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

=item B<getBatteryID>

    $string = $obj->getBatteryID();

    Get the value of the battery_id field

=cut

sub getBatteryID{
    my ($self) = @_;
    return $self->getFieldValue('battery_id');
}

#######################################################

=item B<setBatteryID>

    $string = $obj->setBatteryID($value);

    Set the value of the battery_id field

=cut

sub setBatteryID{
    my ($self, $value) = @_;
    $self->setFieldValue('battery_id', $value);
}

#######################################################

=item B<getTitle>

    $string = $obj->getTitle();

    Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

    $string = $obj->setTitle($value);

    Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}

#######################################################

=item B<getUnits>

    $string = $obj->getUnits();

    Get the value of the units field

=cut

sub getUnits{
    my ($self) = @_;
    return $self->getFieldValue('units');
}

#######################################################

=item B<setUnits>

    $string = $obj->setUnits($value);

    Set the value of the units field

=cut

sub setUnits{
    my ($self, $value) = @_;
    $self->setFieldValue('units', $value);
}

#######################################################

=item B<getMasterTestID>

    $string = $obj->getMasterTestID();

    Get the value of the master_test_id field

=cut

sub getMasterTestID{
    my ($self) = @_;
    return $self->getFieldValue('master_test_id');
}

#######################################################

=item B<setMasterTestID>

    $string = $obj->setMasterTestID($value);

    Set the value of the master_test_id field

=cut

sub setMasterTestID{
    my ($self, $value) = @_;
    $self->setFieldValue('master_test_id', $value);
}


#######################################################

=item B<getHasSubTest>

    $int = $obj->getHasSubTest();

    Get the value of has_sub_test

=cut

sub getHasSubTest {
    my ($self) = @_;
    return $self->getFieldValue('has_sub_test');
}

#######################################################

=item B<setHasSubTest>

    $string = $obj->setHasSubTest(1 | 0);

    Set the value of the has_sub_test field

=cut

sub setHasSubTest{
    my ($self, $value) = @_;
    $self->setFieldValue('has_sub_test', $value);
}


#######################################################

=item B<getDefaultCost>

    $string = $obj->getDefaultCost();

    Get the value of the default_cost field

=cut

sub getDefaultCost{
	my ($self) = @_;
	return $self->getFieldValue('default_cost');
}

#######################################################

=item B<setDefaultCost>

    $string = $obj->setDefaultCost($value);

    Set the value of the default_cost field

=cut

sub setDefaultCost{
    my ($self, $value) = @_;
    $self->setFieldValue('default_cost', $value);
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

=item B<getTestValues>

    $arrayref = $obj->getTestValues();

    Get an arrayref of TestValue objects

=cut

sub getTestValues{
    my ($self) = @_;

	unless($self->{'-test_values'}){
		$self->{'-test_values'} = TUSK::Case::TestValue->new()->lookup('test_id=' . $self->getPrimaryKeyID());
	}

	return $self->{'-test_values'};
}

#######################################################

=item B<getUnassignedPatients>

    $arrayref = $obj->getUnassignedPatients();

    Get an arrayref of Patient objects not assigned to this test

=cut

sub getUnassignedPatients{
	my $self = shift;
	my $battery = TUSK::Case::Battery->lookupKey($self->getBatteryID());
	my $school_id = $battery->getSchoolID();
	my $test_id = $self->getPrimaryKeyID();

	my $patients;

	$patients = TUSK::Case::PatientType->new()->lookup("school_id=$school_id AND test_id is null", undef, undef, undef, [ TUSK::Core::JoinObject->new('TUSK::Case::TestValue', { joinkey => 'patient_type_id', joincond => "test_id = $test_id" })]);

	return $patients;

}

#######################################################

=item B<isSubTest>

    $int = $obj->isSubTest();

    If obj has a master_test_id, then return 1, otherwise 0

=cut

sub isSubTest{
	my $self = shift;
	my $master_id = $self->getMasterTestID();

	return 1 if defined($master_id);
	return 0;
}

#######################################################

=item B<isMasterTest>

    $int = $obj->isMasterTest();

    call getHasSubTest to determine if we are master test

=cut

sub isMasterTest{
	my $self = shift;
	return $self->getHasSubTest();
}

#######################################################

=item B<getMasterTest>

    $obj = $obj->getMasterTest();

    If obj has a master_test, return it

=cut

sub getMasterTest{
    my $self = shift;

	return unless $self->isSubTest();

	unless ($self->{'-master_test'}){
		$self->{'-master_test'} = TUSK::Case::Test->lookupKey($self->getMasterTestID());
	}
	return $self->{'-master_test'};

}

#######################################################

=item B<getSubTests>

    $sub_tests = $test->getSubTests($value);

    Get an array ref of sub tests for the test

=cut

sub getChildTests{
	#deprecated
	getSubTests(@_);
}

sub getSubTests {
	my $self = shift;
	my $test_id = $self->getPrimaryKeyID();
	return [] if (!defined($test_id));
	$self->{-subtests} = TUSK::Case::Test->lookup(" master_test_id = $test_id ");
	if ($self->{-phase}){
		map { $_->setCurrentPhase($self->{-phase}); } @{$self->{-subtests}};
	}
	return $self->{-subtests};

}

#######################################################

=item B<getDefaultValue>

    $string = $TUSK::Case::Test->getDefaultValue(patient_type_id);

    Get the value of the default_value field for the patient with the supplied patient_type_id.
	If no patient_type_id is passed, die. 

=cut

sub getDefaultValue{
    my ($self, $patient_type_id) = @_;

	unless(defined($patient_type_id)){
		croak "getDefaultValue() requires a patient_type_id to be passed to it\n";
	}

	unless (exists($self->{-patient_test_values}->{$patient_type_id})){
		my $test_value = TUSK::Case::TestValue->lookup("patient_type_id = $patient_type_id AND test_id = " . $self->getPrimaryKeyID());
		if (!scalar(@$test_value)){
			croak "no TUSK::Case::TestValue obj found with supplied patient_type_id and test_id: $@";
		}
		elsif (scalar(@$test_value) > 1){
			croak "multiple TUSK::Case::TestValue objs found with supplied patient_type_id ($patient_type_id) and test_id (" . $self->getPrimaryKeyID() . "): $@";
		}
		$self->{-patient_test_values}->{$patient_type_id} = $test_value->[0];
	}
    return $self->{-patient_test_values}->{$patient_type_id}->getDefaultValue();
}

#######################################################

=item B<setDefaultValue>

    $string = $TUSK::Case::Test->setDefaultValue($patient_type_id, $value);

    Set the value of the default_value field for the patient with the supplied patient_type_id.
	If no patient_type_id is passed, die. 

=cut

sub setDefaultValue{
    my ($self, $patient_type_id, $value) = @_;
    	
	unless(defined($patient_type_id)){
		croak "TUSK::Case::Test->setDefaultValue() requires a patient_type_id to be passed to it\n";
	}

	unless (exists($self->{-patient_test_values}->{$patient_type_id})){
		my $test_value = TUSK::Case::TestValue->lookup("patient_type_id = $patient_type_id AND test_id = " . $self->getPrimaryKeyID());
		if (!scalar(@$test_value)){
			croak "no TUSK::Case::TestValue obj found with supplied patient_type_id and test_id: $@";
		}
		elsif(scalar(@$test_value) > 1){
			croak "multiple TUSK::Case::TestValue objs found with supplied patient_type_id and test_id: $@";
		}
		$self->{-patient_test_values}->{$patient_type_id} = $test_value->[0];
	}

	$self->{-patient_test_values}->{$patient_type_id}->setDefaultValue($value);
}

#######################################################

=item B<getDefaultContentID>

	$string = $TUSK::Case::Test->getDefaultContentID(patient_type_id);

    Get the value of the default_content_id field for the patient with the supplied patient_type_id.
	If no patient_type_id is passed, die. 

=cut


sub getDefaultContentID{
    my ($self, $patient_type_id) = @_;

	unless(defined($patient_type_id)){
		croak "getDefaultContentID() requires a patient_type_id to be passed to it\n";
	}

	unless (exists($self->{-patient_test_values}->{$patient_type_id})){
		my $test_value = TUSK::Case::TestValue->lookup("patient_type_id = $patient_type_id AND test_id = " . $self->getPrimaryKeyID());
		if (!scalar(@$test_value)){
			croak "no TUSK::Case::TestValue obj found with supplied patient_type_id and test_id: $@";
		}
		elsif(scalar(@$test_value) > 1){
			croak "multiple TUSK::Case::TestValue objs found with supplied patient_type_id and test_id: $@";
		}
		$self->{-patient_test_values}->{$patient_type_id} = $test_value->[0];
	}
    return $self->{-patient_test_values}->{$patient_type_id}->getDefaultContentID();
}

#######################################################

=item B<setDefaultContentID>

    $string = $TUSK::Case::Test->setDefaultContentID($patient_type_id, $value);

    Set the value of the default_content_id field for the patient with the supplied patient_type_id.
	If no patient_type_id is passed, die. 

=cut

sub setDefaultContentID{
	my ($self, $patient_type_id, $value) = @_;
	if ($value eq ''){
		$value = undef;
	}
	    	
	unless(defined($patient_type_id)){
		croak "setDefaultContentID() requires a patient_type_id to be passed to it\n";
	}

	unless (exists($self->{-patient_test_values}->{$patient_type_id})){
		my $test_value = TUSK::Case::TestValue->lookupReturnOne("patient_type_id = $patient_type_id AND test_id = " . $self->getPrimaryKeyID());
		if (!scalar(@$test_value)){
			croak "no TUSK::Case::TestValue obj found with supplied patient_type_id and test_id: $@";
		}
		elsif(scalar(@$test_value) > 1){
			croak "multiple TUSK::Case::TestValue objs found with supplied patient_type_id and test_id: $@";
		}
		$self->{-patient_test_values}->{$patient_type_id} = $test_value->[0];
	}

	$self->{-patient_test_values}->{$patient_type_id}->setDefaultContentID($value);

}

#######################################################

=item B<getCorrect>

    $correct = $obj->getCorrect([$phase]);

This method returns whether the exam is correct forthe given phase if there is no phase passed
then the method looks to see if there is a phase associated with the exam, which is added by
setCurrentPhase.  If a phase is not found either way, then the method dies.  

=cut


sub getCorrect {
	my $self = shift;
	my $phase = shift || $self->{-phase};
	if (!$phase->isa('TUSK::Case::Phase')){
		confess "You need to pass a TUSK::Case::Phase object or use the setCurrentPhase method";
	}
	my $exclusion = $self->getTestExclusion($phase);
	if (!$exclusion->getPrimaryKeyID()){
		# if there is no exclusion then the exam is not correct
		return 0;
	}
	return $exclusion->getCorrect();
}

#######################################################

=item B<getDisplayValue>

    $string = $obj->getDisplayValue([$phase]);

This method returns what string an exam should show for a given phase. 
If there is no phase passed then the method looks to see if there is a 
phase associated with the exam.  If a phase is not found either way, 
then the method dies.  
If there is a TestExclusion obj for this test/phase, and this obj has
an alternate value, return it, otherwise return "within normal limits".

=cut

sub getDisplayValue{
	my $self = shift;
	my $phase = shift || $self->{-phase};
	my $author_view_flag = shift;

	if (!$phase->isa('TUSK::Case::Phase')){
		confess "You need to pass a TUSK::Case::Phase object or use the setCurrentPhase method";
	}
	my $exclusion = $self->getTestExclusion($phase);
	if($exclusion->getPrimaryKeyID() && $exclusion->getAlternateValue()){
		return $exclusion->getAlternateValue();
	} elsif (!$author_view_flag) {
		if($self->getBatteryType eq 'History'){
			return "Non-Contributory";
		} else {
			return "Within Normal Limits";
		}
	}
	 
}

#######################################################

=item B<getDisplayContentID>

    $content_id = $obj->getDisplayContentID([$phase]);

This method returns what content_id an exam should show for a given phase.
If there is no phase passed then the method looks to see if there is a 
phase associated with the exam.  If a phase is not found either way, then 
the method dies.  Otherwise,
it returns the display content id for this given phase.

=cut

sub getDisplayContentID{
        my $self = shift;
        my $phase = shift || $self->{-phase};
        if (!$phase->isa('TUSK::Case::Phase')){
                confess "You need to pass a TUSK::Case::Phase object or use the setCurrentPhase method";
        }
        my $exclusion = $self->getTestExclusion($phase);
        unless($exclusion->getPrimaryKeyID() && $exclusion->getAlternateContentID()){
                return $self->getDefaultContentID($phase->getPatientTypeID());
        }
        return $exclusion->getAlternateContentID();
}

#######################################################

=item B<getTestExclusion>

     $obj->getTestExclusion($phase);

    Returns the test exclusion TUSK::Case::PhaseTestExclusion object for the 
relevant phase associated by setCurrentPhase or optionally uses the 
TUSK::Case::Phase object passed in.  If there is no exclusion associated it returns an empty
TUSK::Case::PhaseTestExclusion object, but the phase_id and the battery_exam_id are set. 

=cut

sub getTestExclusion{
	my $self = shift;
	my $phase = shift || $self->{-phase};
	if (!defined($phase)){
		confess "No phase has been set for getTestExclusion()";
	}
	if (!$phase->isa('TUSK::Case::Phase')){
		confess "You need to pass a TUSK::Case::Phase object or use the setCurrentPhase method";
	}
	my $phase_id = $phase->getPrimaryKeyID();
	my $test_id = $self->getPrimaryKeyID();
	my $exclusions =  [];
	if ($test_id && $phase_id){
		$exclusions = TUSK::Case::PhaseTestExclusion->lookup("phase_id = $phase_id and test_id = $test_id");
	}
	if (scalar(@{$exclusions}) > 1){
		confess "There are more than one exclusions for one exam.";
	} elsif (!scalar(@{$exclusions})){
		my $exclusion =  TUSK::Case::PhaseTestExclusion->new();
		$exclusion->setPhaseID($phase_id);
		$exclusion->setTestID($test_id);
		return $exclusion;
	}
	return pop @{$exclusions};
}

#######################################################

=item B<setCurrentPhase>

     $obj->setCurrentPhase($phase);

    Sets the phase that the exam should refer to when figuring out exclusions.

=cut

sub setCurrentPhase{
	my $self = shift;
	my $phase = shift;
	unless ($phase->isa('TUSK::Case::Phase')){
		confess "You need to pass a TUSK::Case::Phase object";
	}
	if ((ref $self eq '') || !$self->getPrimaryKeyID()){
		confess " You need to pass an initialized phase object";
	}
	$self->{-phase} = $phase;
}

#######################################################

=item B<getFormattedUnits>

     $string = $obj->getFormattedUnits();

     Return test units in parens if there are units. if not, return nothing.

=cut

sub getFormattedUnits{
	my $self = shift;

	my $units = $self->getUnits;

	if($units){
		return "($units)";
	}

}

#######################################################

=item B<delete>

    $retval = $obj->delete();

    This deletes test and all subtests as well as all affiliated test values

=cut

sub delete {
	my $self = shift;

	foreach my $test (@{$self->getSubTests}){
		$test->delete();
	}

	$self->deleteTestValues();
	return $self->SUPER::delete();	

}

#######################################################

=item B<save>

    $retval = $obj->save();

    Make sure that when we save a subtest, we tie a TestValue object to it for all patients already tied to master test

=cut

sub save {
	my ($self, $params) = @_;

	my $id = $self->getPrimaryKeyID(); #used in conditional below. 

	my $retval = $self->SUPER::save($params);

	if($self->isSubTest() && !$id){
	# if self's a subtest and has never been saved...

		my $master = $self->getMasterTest();
		my $test_values = $master->getTestValues();

		foreach my $tv (@$test_values){
			my $patient_type_id = $tv->getPatientTypeID();
			my $sub_test_value = TUSK::Case::TestValue->new();
			$sub_test_value->setTestID($self->getPrimaryKeyID());
			$sub_test_value->setPatientTypeID($patient_type_id);

			$sub_test_value->save($params);
		}
	}
	return $retval;
}

#######################################################

=item B<deleteTestValues>

    $retval = $obj->deleteTestValues();

    This deletes a test's affiliated test values

=cut

sub deleteTestValues {
	my $self = shift;

	foreach my $test_value (@{$self->getTestValues()}){
		$test_value->SUPER::delete();
	}
	
}

#######################################################

=item B<updateSortOrders>

    $arrayref = $obj->updateSortOrders($batter_id, $change_order_string, $arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  $index is array index of the object that changed,
$newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateSortOrders{
    my ($self, $battery_id, $change_order_string, $arrayref) = @_;

    my $cond = "battery_id = " . $battery_id;
    my ($index, $newindex) = split ("-", $change_order_string);

    return $self->SUPER::updateSortOrders($index, $newindex, $cond, $arrayref);
}

#######################################################

=item B<getBatteryObj>

    $string = $Test->getBatteryObj();

    return the battery obj that is the 'parent' of this test

=cut

sub getBatteryObj{
	my ($self) = @_;
	return TUSK::Case::Battery->lookupKey($self->getBatteryID());
}

#######################################################

=item B<getBatteryType>

    $string = $Test->getBatteryType();

    return the battery_type field from test's battery obj

=cut

sub getBatteryType{
	my ($self) = @_;

	my $battery = $self->getBatteryObj();
	return $battery->getBatteryType();
}

#######################################################

=item B<getFormattedCost>

    $string = $obj->getFormattedCost();

    Get the value of the default_cost field formatted as $xxx.xx

=cut

sub getFormattedCost{
    my ($self) = @_;
    return sprintf("%.2f", $self->getFieldValue('default_cost'));
}


1;

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2006.

=cut

1;

