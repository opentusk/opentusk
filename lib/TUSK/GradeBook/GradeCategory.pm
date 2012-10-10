package TUSK::GradeBook::GradeCategory;

=head1 NAME

B<TUSK::GradeBook::GradeCategory> - Class for manipulating entries in table grade_category in tusk database

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

use TUSK::GradeBook::GradeOffering;
use TUSK::GradeBook::GradeEvent;
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
					'tablename' => 'grade_category',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_category_id' => 'pk',
					'grade_category_name' => '',
					'grade_offering_id' => '',
					'parent_grade_category_id' => '',
					'depth' => '',
					'sort_order' => '',
					'lineage' => '',
					'drop_lowest' => '',
					'drop_highest' => '',
					'multi_site' => '',
					'category_weight' => '',
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

=item B<getGradeCategoryName>

my $string = $obj->getGradeCategoryName();

Get the value of the grade_category_name field

=cut

sub getGradeCategoryName{
    my ($self) = @_;
    return $self->getFieldValue('grade_category_name');
}

#######################################################

=item B<setGradeCategoryName>

$obj->setGradeCategoryName($value);

Set the value of the grade_category_name field

=cut

sub setGradeCategoryName{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_category_name', $value);
}


#######################################################

=item B<getGradeOfferingID>

my $string = $obj->getGradeOfferingID();

Get the value of the grade_offering_id field

=cut

sub getGradeOfferingID{
    my ($self) = @_;
    return $self->getFieldValue('grade_offering_id');
}

#######################################################

=item B<setGradeOfferingID>

$obj->setGradeOfferingID($value);

Set the value of the grade_offering_id field

=cut

sub setGradeOfferingID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_offering_id', $value);
}


#######################################################

=item B<getParentGradeCategoryID>

my $string = $obj->getParentGradeCategoryID();

Get the value of the parent_grade_category_id field

=cut

sub getParentGradeCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('parent_grade_category_id');
}

#######################################################

=item B<setParentGradeCategoryID>

$obj->setParentGradeCategoryID($value);

Set the value of the parent_grade_category_id field

=cut

sub setParentGradeCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_grade_category_id', $value);
}


#######################################################

=item B<getDepth>

my $string = $obj->getDepth();

Get the value of the depth field

=cut

sub getDepth{
    my ($self) = @_;
    return $self->getFieldValue('depth');
}

#######################################################

=item B<setDepth>

$obj->setDepth($value);

Set the value of the depth field

=cut

sub setDepth{
    my ($self, $value) = @_;
    $self->setFieldValue('depth', $value);
}

#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

$obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}


#######################################################

=item B<getLineage>

my $string = $obj->getLineage();

Get the value of the lineage field

=cut

sub getLineage{
    my ($self) = @_;
    return $self->getFieldValue('lineage');
}

#######################################################

=item B<setLineage>

$obj->setLineage($value);

Set the value of the lineage field

=cut

sub setLineage{
    my ($self, $value) = @_;
    $self->setFieldValue('lineage', $value);
}


#######################################################

=item B<getDropLowest>

my $string = $obj->getDropLowest();

Get the value of the drop_lowest field

=cut

sub getDropLowest{
    my ($self) = @_;
    return $self->getFieldValue('drop_lowest');
}

#######################################################

=item B<setDropLowest>

$obj->setDropLowest($value);

Set the value of the drop_lowest field

=cut

sub setDropLowest{
    my ($self, $value) = @_;
    $self->setFieldValue('drop_lowest', $value);
}


#######################################################

=item B<getDropHighest>

my $string = $obj->getDropHighest();

Get the value of the drop_highest field

=cut

sub getDropHighest{
    my ($self) = @_;
    return $self->getFieldValue('drop_highest');
}

#######################################################

=item B<setDropHighest>

$obj->setDropHighest($value);

Set the value of the drop_highest field

=cut

sub setDropHighest{
    my ($self, $value) = @_;
    $self->setFieldValue('drop_highest', $value);
}


#######################################################

=item B<getCategoryWeight>

my $string = $obj->getCategoryWeight();

Get the value of the category_weight field

=cut

sub getCategoryWeight{
    my ($self) = @_;
    return $self->getFieldValue('category_weight');
}

#######################################################

=item B<setCategoryWeight>

$obj->setCategoryWeight($value);

Set the value of the category_weight field

=cut

sub setCategoryWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('category_weight', $value);
}


#######################################################

=item B<getMultiSite>

    $string = $obj->getMultiSite();

    Get the value of the multi_site field

=cut

sub getMultiSite{
    my ($self) = @_;
    return $self->getFieldValue('multi_site');
}

#######################################################

=item B<setMultiSite>

    $string = $obj->setMultiSite($value);

    Set the value of the multi_site field

=cut

sub setMultiSite{
    my ($self, $value) = @_;
    $self->setFieldValue('multi_site', $value);
}


=back

=cut

### Other Methods

sub getGradeOffering {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::GradeBook::GradeOffering");
}

sub getChildren {
    my ($self) = @_;
	return TUSK::GradeBook::GradeCategory->lookup('parent_grade_category_id = ' . $self->getPrimaryKeyID(), ['sort_order']);
}

sub getDescendants {
    my ($self) = @_;
	return TUSK::GradeBook::GradeCategory->lookup("lineage rlike '/" . $self->getPrimaryKeyID() . "/'", ['lineage', 'sort_order']);
}

sub getDescendantsWithParent {
    my ($self) = @_;
	return TUSK::GradeBook::GradeCategory->lookup("grade_category.lineage rlike '/" . $self->getPrimaryKeyID() . "/'", ['grade_category.lineage', 'grade_category.sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeCategory", {alias => 'parent', origkey => 'parent_grade_category_id', joinkey => 'grade_category_id', jointype => 'inner' }) ]);
}

sub getSiblings {
    my ($self, $cond) = @_;
	$cond = ($cond) ? " AND $cond" : '';
	return TUSK::GradeBook::GradeCategory->lookup('parent_grade_category_id = ' . $self->getParentGradeCategoryID() . ' AND grade_category_id != ' . $self->getPrimaryKeyID() . $cond, ['sort_order']);
}

sub getEventChildren {
    my ($self) = @_;
	return TUSK::GradeBook::GradeEvent->lookup('grade_category_id = ' . $self->getPrimaryKeyID());
}

sub isFirstGeneration {
    my ($self) = @_;
	my $offering = TUSK::GradeBook::GradeOffering->lookupReturnOne("grade_offering_id = " . $self->getGradeOfferingID());

	if ($offering && ($offering->getRootGradeCategoryID() == $self->getParentGradeCategoryID())) {
		return 1;
	}
	return 0;
}

=item
	Display sites for any child categories if the first generation parent has multi site flag on
=cut
sub showMultiSite {
    my ($self) = @_;

	if ($self->getDepth() == 1) {  ### top level itself
		return $self->getMultiSite();
	} elsif ($self->getDepth() > 1) {
		my @ids = split('/', $self->getLineage());
		if ($ids[1]) {   ### we expect second id is the top level
			if (my $top_cat = TUSK::GradeBook::GradeCategory->lookupKey($ids[2])) {
				return $top_cat->getMultiSite();
			}
		}
	}
	return 0;
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

