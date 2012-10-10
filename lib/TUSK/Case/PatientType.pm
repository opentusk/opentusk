package TUSK::Case::PatientType;

=head1 NAME

B<TUSK::Case::PatientType> - Class for manipulating entries in table patient_type in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::School;
use TUSK::Case::Battery;

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
					'tablename' => 'patient_type',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'patient_type_id' => 'pk',
					'school_id'=>'',
					'type_name' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
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

=item B<getTypeName>

   $string = $obj->getTypeName();

Get the value of the type_name field

=cut

sub getTypeName{
    my ($self) = @_;
    return $self->getFieldValue('type_name');
}

#######################################################

=item B<setTypeName>

    $string = $obj->setTypeName($value);

Set the value of the type_name field

=cut

sub setTypeName{
    my ($self, $value) = @_;
    $self->setFieldValue('type_name', $value);
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


#######################################################


### Other Methods

sub getPatientTypes{
        return TUSK::Case::PatientType->lookup("1 = 1");
}

sub getSchoolPatientTypes {
	my $class = shift;
	my $school = shift;
	return TUSK::Case::PatientType->lookup('school_id = '.$school->getPrimaryKeyID());
}

#######################################################
=item B<getTestsAndValues>

    $structure = $obj->getTestsAndValues();

This method returns a somewhat complicated set of objects containing all tests affiliated with a particular patient type.

Each Test has (potentially) 2 JoinObjects: TestValue (always) and subtests(if present). Subtests will then have 1 JoinObject: TestValue. Tests are returned sorted by battery id, test sort order, subtest sort order.

=cut

sub getTestsAndValues {
    my ($self, $phase_type) = @_;
    my $id = $self->getPrimaryKeyID();

    my $struct = TUSK::Case::Battery->lookup("battery.battery_type='$phase_type' AND case_test_value.patient_type_id=$id AND case_test.master_test_id is null",
      ['battery.sort_order', 'battery.battery_id', 'case_test.sort_order', 'case_test.test_id', 'subTest.sort_order', 'subTest.test_id'],
      undef, undef,
      [TUSK::Core::JoinObject->new('TUSK::Case::Test',
          {joinkey => 'battery_id', origkey => 'battery_id' }),
      TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
          {joinkey => 'test_id', origkey => 'case_test.test_id', objtree=>['TUSK::Case::Test'] }),
      TUSK::Core::JoinObject->new('TUSK::Case::Test',
          {alias=>'subTest', joinkey=>'master_test_id', origkey=>'case_test.test_id', 
		   objtree=>['TUSK::Case::Test']}),
      TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
          {alias=>'subTestValue', joinkey => 'test_id', 
          origkey => 'subTest.test_id', objtree=> ['TUSK::Case::Test', 'subTest'], 
          joincond => "subTestValue.patient_type_id=$id"})
	  ]);

    return $struct;
}


#######################################################
=item B<getUnassignedTests>

    $structure = $obj->getUnassignedTests();

This method returns a somewhat complicated set of objects containing all tests in a PatientType's school that do not have TestValue objects for a particular student.

=cut

sub getUnassignedTests {
    my $self = shift;
	my $battery_type = shift;

    my $id = $self->getPrimaryKeyID();
	my $school = TUSK::Core::School->lookupKey($self->getSchoolID());

	my $batteries = TUSK::Case::Battery->getSchoolBatteries($school);

	unless(scalar(@$batteries)){
		return [];
	} 

	my $battery_ids = [];

	foreach my $battery (@$batteries){
		push @$battery_ids, $battery->getPrimaryKeyID();
	}
	my $battery_list = join(',', @$battery_ids);

    my $struct = TUSK::Case::Battery->lookup("case_test.master_test_id is null and case_test.test_id is not null and case_test_value.patient_type_id is null and battery.battery_type = '$battery_type' and battery.battery_id in ($battery_list)",
      ['battery.battery_id ASC','case_test.sort_order','subTest.sort_order'],
      undef, undef,
      [TUSK::Core::JoinObject->new('TUSK::Case::Test',
          {joinkey => 'battery_id', origkey => 'battery_id' }),
      TUSK::Core::JoinObject->new('TUSK::Case::TestValue',
          {joinkey => 'test_id', origkey => 'case_test.test_id', objtree=>['TUSK::Case::Test'], joincond=>"case_test_value.patient_type_id=$id" }),
      TUSK::Core::JoinObject->new('TUSK::Case::Test',
          {alias=>'subTest', joinkey=>'master_test_id', origkey=>'case_test.test_id', objtree=>['TUSK::Case::Test']}) ]);

    return $struct;
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


=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

