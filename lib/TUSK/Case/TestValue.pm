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


package TUSK::Case::TestValue;

=head1 NAME

B<TUSK::Case::TestValue> - Class for manipulating entries in table case_test_value in tusk database

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

use TUSK::Case::PatientType;
use TUSK::Case::Test;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'case_test_value',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'test_value_id' => 'pk',
					'test_id' => '',
					'patient_type_id' => '',
					'default_value' => '',
					'default_content_id' => '',
					'source' => '',
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
    # remove cached object 
    delete $self->{-patient_type};
    $self->setFieldValue('patient_type_id', $value);
}


#######################################################

=item B<getDefaultValue>

    $string = $obj->getDefaultValue();

    Get the value of the default_value field

=cut

sub getDefaultValue{
    my ($self) = @_;
    return $self->getFieldValue('default_value');
}

#######################################################

=item B<setDefaultValue>

    $string = $obj->setDefaultValue($value);

    Set the value of the default_value field

=cut

sub setDefaultValue{
    my ($self, $value) = @_;
    $self->setFieldValue('default_value', $value);
}

#######################################################

=item B<getDefaultContentID>

    $string = $obj->getDefaultContentID();

    Get the value of the default_content_id field

=cut

sub getDefaultContentID{
    my ($self) = @_;
    return $self->getFieldValue('default_content_id');
}

#######################################################

=item B<setDefaultContentID>

    $string = $obj->setDefaultContentID($value);

    Set the value of the default_content_id field

=cut

sub setDefaultContentID{
    my ($self, $value) = @_;
    if ($value eq ''){
	$value = undef;
    }
    $self->setFieldValue('default_content_id', $value);
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



=back

=cut

### Other Methods

#######################################################

=item B<getTitle>

    $string = $obj->getTitle();

    Get the value of the TUSK::Case::Test Obj's title field

=cut

sub getTitle{
	my ($self) = @_;

	my $test = $self->getTest();

	return $test->getTitle();
}

#######################################################

=item B<getTest>

    $testObj = $TUSK::Case::TestValue->getTest();

This returns the Test object associated with the TestValue

=cut

sub getTest{
	my $self = shift or confess "Object must be instantiated";
	if (!ref ($self)){
		confess "Object must have been instantiated";
	}
	unless ($self->{'-test'}){
		$self->{'-test'} = TUSK::Case::Test->lookupKey($self->getTestID());
	}
	return $self->{'-test'};

}


#######################################################

=item B<getPatientType>

    $patientTypeObj = $obj->getPatientType();

This returns the PatientType object associated with the TestValue

=cut

sub getPatientType{
	my $self = shift or confess "Object must be instantiated";
	if (!ref ($self)){
		confess "Object must have been instantiated";
	}
	unless ($self->{'-patient_type'}){
		$self->{'-patient_type'} = TUSK::Case::PatientType->lookupKey($self->getPatientTypeID());
	}
	return $self->{'-patient_type'};
}

#######################################################

=item B<getRelatedValues>

    $arrayref = $obj->getRelatedValues();

Given a TestValue, return TestValue objects of parent test and all children, if relevant. Otherwise, just return arrayref of calling TestValue.

=cut

sub getRelatedValues{
	my $self = shift;
	my $test = $self->getTest();

	my $master_test = ($test->isSubTest)? $test->getMasterTest() : $test;
	my $master_id = $master_test->getPrimaryKeyID();

	my $test_family = TUSK::Case::Test->lookup("master_test_id = $master_id OR test_id = $master_id");

	my $query_ids = join(', ', map { $_->getPrimaryKeyID()  } @$test_family);

	my $patient_type_id = $self->getPatientTypeID();
	
	my $family_values = TUSK::Case::TestValue->lookup("patient_type_id = $patient_type_id and test_id in ($query_ids)");

	return $family_values;

}

#######################################################

=item B<getPatientTypeName>

    $string = $obj->getPatientTypeName();

This returns the TypeName field of the PatientType object associated with the Test

=cut

sub getPatientTypeName{
	my $self = shift or confess "Object must be instantiated";
	if (!ref ($self)){
		confess "Object must have been instantiated"; 
	}
	my $patientType = $self->getPatientType();
	if (defined($patientType) && $patientType->isa('TUSK::Case::PatientType')){
		return $patientType->getTypeName();
	}
	return "";
}


## start subclass

package TUSK::Case::MasterTestTestValue;

=head1 NAME

B<TUSK::Case::MasterTestTestValue> - Class for manipulating entries in table case_test_value in tusk database. in case shell administrative tool (tusk/case/administrator/examaddedit), web interface limits access to TestValue (TV) objects. user cannot delete a TV for a subtest, but must delete the TV for the master test, which will insure that all subtest values are also deleted. these TV objects for master tests are called MasterTestTestValue objects.

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
    
    @ISA = qw(TUSK::Case::TestValue Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();


#######################################################

=item B<delete>

    $retval = $obj->delete();
    If the MasterTestTestValue obj is tied to a regular old test, only that test is deleted. If it is tied to a master test, the master test's TestValue obj and any children TestValue obj's are deleted in order to keep data clean in the db.

=cut

sub delete {
	my $self = shift;

	my $family_values = $self->getRelatedValues();

	foreach my $tv (@$family_values){
	print $tv->getPrimaryKeyID . "\n";
		$tv->SUPER::delete();
	}

}


#######################################################

=item B<save>

    $retval = $obj->delete();
    If the MasterTestTestValue obj is tied to a regular old test, only the calling TestValue is saved. If it is tied to a master test, the calling TestValue is saved, and TestValue obj's are created and saved for all subtests of master test.


=cut

sub save {
	my ($self, $params) = @_;

	my $test = TUSK::Case::Test->lookupKey($self->getTestID());
	if($test->getHasSubTest()){
		my $subtests = $test->getSubTests();

		foreach my $st (@$subtests){
			my $test_id = $st->getPrimaryKeyID();
			my $patient_type_id = $self->getPatientTypeID();
			my $test_value = TUSK::Case::TestValue->new();
			my $exists = $test_value->lookupReturnOne("test_id=$test_id AND patient_type_id=$patient_type_id");
			unless(defined($exists)){
				$test_value->setTestID($test_id);
				$test_value->setPatientTypeID($patient_type_id);

				$test_value->save($params);
			}
		}
	}

	$self->SUPER::save($params);
}




## end subclass

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

