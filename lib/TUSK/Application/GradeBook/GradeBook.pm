package TUSK::Application::GradeBook::GradeBook;

use strict;
use TUSK::GradeBook::GradeScale;
use TUSK::GradeBook::GradeScaleBounds;
use TUSK::GradeBook::GradeEventGradeScale;
use TUSK::GradeBook::GradeCategory;
use TUSK::GradeBook::GradeEvent;
use TUSK::GradeBook::GradeOffering;
use TUSK::Application::GradeBook::FinalGrade::ByEvent;
use TUSK::Functions;


sub new {
    my ($class, $args) = @_;

	die "Missing/Invalid Course Object" unless (defined $args->{course} && ref $args->{course} eq 'HSDB45::Course');
	die "Missing Time Period" unless ($args->{time_period_id});

    my $self = { 
		course      => $args->{course},
		time_period_id  => $args->{time_period_id},
		user_id      => $args->{user_id},
	};

    bless($self, $class);
	$self->{grade_offering} = TUSK::GradeBook::GradeOffering->lookupReturnOne("course_id = " . $self->{course}->getTuskCourseID() . " AND time_period_id = $self->{time_period_id}");
    return $self;
}

#######################################################

=item B<getAllButFinalEvents>
	Return All events but final grade event
=cut

sub getAllButFinalEvents {
	my ($self, $extra_cond) = @_;

	my $cond = ($self->{grade_offering} && $self->{grade_offering}->getFinalGradeEventID()) ? " AND grade_event_id != " . $self->{grade_offering}->getFinalGradeEventID() : '';
	$cond = " AND $extra_cond" if ($extra_cond);

	return TUSK::GradeBook::GradeEvent->lookup("course_id = " . $self->{course}->primary_key() . " AND school_id = " . $self->{course}->get_school()->getPrimaryKeyID() . " AND time_period_id = $self->{time_period_id}" . $cond, ['grade_category_id', 'sort_order']);
}


#######################################################

=item B<getAllEventsByCategory>

	Return a hash (category_id) of array of elements

=cut

sub getAllEventsByCategory {
	my ($self) = @_;

	my $events = $self->getAllButFinalEvents();
	my %categories = map { $_->getPrimaryKeyID() => $_ } @{$self->getAllCategories()};
	my $categorized_events = {};   ### in flat structure
	foreach my $event (@$events) {
		push @{$categorized_events->{$event->getGradeCategoryID()}}, $event;
	}
	return ($categorized_events, \%categories);
}


#######################################################

=item B<getAllDescendantEvents>

	Givent a category id, return a list of child events including those from child categories

=cut

sub getAllDescendantEvents {
	my ($self, $category_id) = @_;
	return [] unless defined $category_id;

	my $cond = '';
	if (my $final_event_id = $self->{grade_offering}->getFinalGradeEventID()) {
		$cond = "grade_event_id != " . $final_event_id;
	}

	return TUSK::GradeBook::GradeEvent->lookup($cond, ['lineage', 'sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeCategory", {joinkey => 'grade_category_id', jointype => 'inner', joincond => "(lineage rlike '/$category_id/' OR grade_category.grade_category_id = $category_id)" })]);

}


#######################################################

=item B<getAllCategories>

	All categories except the root category with no heirarchy

=cut

sub getAllCategories {
	my ($self, $condition) = @_;
	$condition = '' unless defined $condition;

	return TUSK::GradeBook::GradeCategory->new()->lookup($condition, ['lineage', 'sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeOffering", {joinkey => 'grade_offering_id', jointype => 'inner', joincond => "course_id = " . $self->{course}->getTuskCourseID() . " AND time_period_id = $self->{time_period_id} AND root_grade_category_id != grade_category_id"})]);
}


#######################################################

=item B<getSortedCategories>
	the grade_category table 'almost' stores records in sequence so we need to sort them
    We avoid recursion as we want to make fewer db calls 
=cut

sub getSortedCategories {
	my ($self, $cond) = @_;
	my $cats= $self->getAllCategories($cond);
	my %sorts = map { $_->getPrimaryKeyID() => $_->getSortOrder()} @$cats;

	my (%hash, @sorted) = ((), ());
	foreach my $cat (@$cats) {
		my $key = join('/', map { $sorts{$_} }  split('/', $cat->getLineage() . $cat->getPrimaryKeyID()));
		$hash{$key} = $cat;
	}
	push @sorted, $hash{$_} foreach (sort keys %hash);
	return \@sorted;
}



sub getEventsWithCategories {
	my ($self) = @_;
	my $root_catogory = $self->getRootCategory();
	
}


##########################################################################

=item B<getRootCategory>

	root category should be created only once for the course. so we try to
	grab it first. if not there, then create one.

=cut

sub getRootCategory {
	my ($self) = @_;

	unless ($self->{root_category}) {
		$self->{root_category} = TUSK::GradeBook::GradeCategory->new()->lookupReturnOne("",  undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeOffering", {joinkey => 'grade_offering_id', jointype => 'inner', joincond => "course_id = " . $self->{course}->getTuskCourseID() . " AND time_period_id = $self->{time_period_id} AND root_grade_category_id = grade_category_id"})]);

		unless ($self->{root_category}) {
			### not there yet, then let's creat one
			my $offering = TUSK::GradeBook::GradeOffering->new();
			$offering->setCourseID($self->{course}->getTuskCourseID());
			$offering->setTimePeriodID($self->{time_period_id});
			$offering->save({'user' => $self->{user_id}});

			my $root_category_name = 'Offering Category';
			my $category = TUSK::GradeBook::GradeCategory->new();
			$category->setGradeCategoryName($root_category_name);
			$category->setGradeOfferingID($offering->getPrimaryKeyID());
			$category->setLineage('/');
			$category->save({'user' => $self->{user_id}});		

			$offering->setRootGradeCategoryID($category->setPrimaryKeyID());
			$offering->save({'user' => $self->{user_id}});

			$self->{root_category} = TUSK::GradeBook::GradeCategory->new()->lookupReturnOne("",  undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeOffering", {joinkey => 'grade_offering_id', jointype => 'inner', joincond => "course_id = " . $self->{course}->getTuskCourseID() . " AND time_period_id = $self->{time_period_id} AND root_grade_category_id = grade_category_id"})]);
		}
	}

	return $self->{root_category};
}


##########################################################################

=item B<hasCategory>

	return if this gradebook has category or not

=cut

sub hasCategory {
	my $self = shift;
	return (scalar @{$self->getAllCategories()}) ? 1 : 0;
}



##########################################################################

=item B<getFirstGenerationCategories>

	Return all categories at top most level

=cut

sub getFirstGenerationCategories {
	my $self = shift;
	my $root_category = $self->getRootCategory();
	if ($root_category) {
		return TUSK::GradeBook::GradeCategory->lookup("parent_grade_category_id = " . $root_category->getPrimaryKeyID(), ['sort_order']);
	}
	return [];
}



#######################################################

=item B<getStudentGradeRecords>

    ($saved_grades, $categorized_events) = $obj->getStudentGradeRecords($student);

Given a student, return $saved_grades only includes records for students with grades and events keyed by category

=cut

sub getStudentGradeRecords {
    my ($self, $student) = @_;

	return unless (ref $student eq 'HSDB4::SQLRow::User');

	my (%saved_grades, %categorized_events);
	my $events = $self->getAllButFinalEvents();

	if (@$events) {	
		my $links = TUSK::GradeBook::LinkUserGradeEvent->new->lookup("parent_user_id = '" . $student->primary_key() . "' AND child_grade_event_id in (" . join(', ', map { $_->getPrimaryKeyID() } @$events) . ')');

		push @{$categorized_events{$_->getGradeCategoryID()}}, $_ foreach (@$events);
		%saved_grades = map { $_->getChildGradeEventID() => $_ } @$links;
	}
	return (\%saved_grades, \%categorized_events);
}


#######################################################

=item B<getAllGradeRecords>

    $grades_data = $obj->getAllGradeRecords();

    Given event objects, return all grade records, excluding those waived grade events, sorted by user_id, category_id and grade
=cut

sub getAllGradeRecords {
	my ($self, $events)= @_;

	return [] unless ($events);

	return TUSK::GradeBook::LinkUserGradeEvent->lookup("child_grade_event_id in (" . join(', ', map { $_->getPrimaryKeyID() } @$events) . ')', ['parent_user_id', 'grade_category_id'], undef, undef, [TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeEvent", { origkey => 'child_grade_event_id', joinkey => 'grade_event_id', jointype => 'inner', joincond => "course_id = " . $self->{course}->getPrimaryKeyID() . " AND time_period_id = $self->{time_period_id} AND school_id = " . $self->{course}->get_school()->getPrimaryKeyID() . ' AND (waive_grade = 0 or waive_grade is NULL)'})]);
}


#######################################################

=item B<getAllGradeRecordsByCategoryStudent>

    $records_by_category_student = $obj->getAllGradeRecordsByStudent();

=cut

sub getAllGradeRecordsByCategoryStudent {
    my ($self, $events) = @_;
	my %records_by_category_student;

	if (@$events) {	
		my $links = $self->getAllGradeRecords($events);
		foreach my $link (@$links) {
			push @{$records_by_category_student{$link->getGradeEventObject()->getGradeCategoryID()}{$link->getParentUserID()}}, $link;
		}
	}

	return \%records_by_category_student;
}


#######################################################

=item B<getAllGradeRecordsByStudent>

    $records_by_student = $obj->getAllGradeRecordsByStudent($events);

=cut

sub getAllGradeRecordsByStudent {
    my ($self, $events) = @_;
	my %records_by_student;

	if (@$events) {	
		my $links = $self->getAllGradeRecords($events);
		foreach my $link (@$links) {
			push @{$records_by_student{$link->getParentUserID()}}, $link;
		}
	}

	return \%records_by_student;
}


#######################################################

=item B<updateCategorySortOrders>

    $arrayref = $obj->updateCategorySortOrders($change_order_string, $arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  $index is array index of the object that changed, $newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateCategorySortOrders {
    my ($self, $change_order_string, $arrayref) = @_;
	if ($self->{grade_offering}) {
		my ($index, $newindex) = split('-', $change_order_string);
		return $self->{grade_offering}->updateSortOrders($index, $newindex, 'grade_offering_id = ' . $self->{grade_offering}->getPrimaryKeyID(), $arrayref, 1);
	}
	return [];

}

sub calculateFinalGradeByEvent {
	my ($self) = @_;
	my $events = $self->getAllButFinalEvents();
	my $grade_records = $self->getAllGradeRecordsByStudent($events);

	unless ($self->{final_grade}) {
		$self->setFinalGradeEvent() unless ($self->{final_grade_event});
		$self->{final_grade} = TUSK::Application::GradeBook::FinalGrade::ByEvent->new( { user_id => $self->{user_id}, final_grade_event => $self->{final_grade_event}, course => $self->{course} });
	}

	$self->{final_grade}->process($grade_records);
}


sub createGradeEvent {
	my $self = shift;
	my $event_name = shift || '';
	my $event_description = shift || undef;

	my $event = TUSK::GradeBook::GradeEvent->new();
	$event->setEventName($event_name);
	$event->setEventDescription($event_name);
	$event->setSchoolID($self->{course}->get_school()->getPrimaryKeyID());
	$event->setCourseID($self->{course}->primary_key());
	$event->setTimePeriodID($self->{time_period_id});
	$event->setGradeCategoryID($self->getRootCategory()->getPrimaryKeyID());
	$event->save({user => $self->{user_id}});
	return $event;
}


sub setFinalGradeEvent {
	my ($self, $event) = @_;

	if (!defined $event && ref $event ne 'TUSK::GradeBook::GradeEvent') {
		$event = $self->createGradeEvent('Final Grade');
	} 

	$self->{grade_offering}->setFinalGradeEventID($event->getPrimaryKeyID());
	$self->{grade_offering}->save({user => $self->{user_id}});
	$self->{final_grade_event} = $event;
}

sub getFinalGradeEvent {
	my ($self, $event_id) = @_;

	if ($event_id) {
		$self->{final_grade_event} = TUSK::GradeBook::GradeEvent->lookupKey($event_id);
	} else {
		if ($event_id = $self->{grade_offering}->getFinalGradeEventID()) {
			$self->{final_grade_event} = TUSK::GradeBook::GradeEvent->lookupKey($event_id);
		}
	}
	return $self->{final_grade_event};
}

#########################################################################################

sub getScaledGrade {
	my ($self,$calculated_grade,$grade_event_id) = @_;
	my $scaled_grade;
	my $grade_event_scale = TUSK::GradeBook::GradeEventGradeScale->lookupReturnOne("grade_event_id = " . $grade_event_id);
	my $scale_id = $grade_event_scale->{_field_values}->{'grade_scale_id'};

	if (defined($scale_id)) {
		my $scales = TUSK::GradeBook::GradeScaleBounds->lookup("grade_scale_id = $scale_id order by lower_bound desc");
		my $j=0;
		while( defined(@$scales[$j]) && !defined($scaled_grade) ) {
			my $lower_bound = @$scales[$j]->getLowerBound();
			if ($calculated_grade >= $lower_bound ) {
				$scaled_grade = @$scales[$j]->getGradeSymbol();
			}
			$j++;
		}
	}

	if( !defined($scaled_grade) ) {
		$scaled_grade = "N/A";
	}

	return $scaled_grade;
}



1;




