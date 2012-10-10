package TUSK::Application::FormBuilder::Report::PatientLog::SiteSummary;

use strict;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use TUSK::FormBuilder::FieldItem;


sub new {
    my ($class, $form_id, $course, $site_id, $tp_params) = @_;
	die "Missing form_id, course_id and/or site_id\n" unless ($form_id && $course && $site_id);
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    return $class->SUPER::new( _course => $course, 
							   _form_id => $form_id, 
							   _site_id => $site_id,
							   _tp_params => $tp_params,
							   _report_flags => join(",", @{$TUSK::FormBuilder::Constants::report_flags_by_report_type->{2}}),
							   );
}


sub getReport {
	my ($self) = @_;
	my $sql = qq(
				 SELECT
				 child_user_id,
				 (SELECT CONCAT(lastname, ', ', firstname)
				  FROM hsdb4.user b
				  WHERE a.child_user_id = b.user_id) AS studentname,
				 (SELECT COUNT(*)
				  FROM tusk.form_builder_entry c
				  WHERE time_period_id IN ($self->{_time_period_ids_string})  
				  AND a.child_user_id = c.user_id
				  AND form_id = $self->{_form_id}) AS patients
				 FROM $self->{_db}.link_course_student a 
				 WHERE a.parent_course_id = $self->{_course_id}
				 AND time_period_id in ($self->{_time_period_ids_string})
				 AND teaching_site_id = $self->{_site_id}
				 GROUP BY child_user_id
				 ORDER BY studentname
				 );

	my $sth = $self->{_form}->databaseSelect($sql);
	my @rows = ();
	my $all_students = 0;
	my $report_students = 0;
	my $all_patients = 0;

	while (my ($user_id, $name, $patients) = $sth->fetchrow_array()) {
		$all_students++;
		if ($patients > 0) {
			$report_students++;
			$all_patients += $patients;
		}

		push @rows, [$user_id, $name, $patients];
		
	}

	$sth->finish();
	my $user = HSDB4::SQLRow::User->new()->lookup_key($self->{_user_id});

	return { rows => \@rows, all_students => $all_students, report_students => $report_students, all_patients => $all_patients, fullname => $user->out_full_name()};
}


sub getNumStudents {
	my $self = shift;

	my $sth = $self->{_form}->databaseSelect(qq(
		select count(*)
		from $self->{_db}.link_course_student a 
		where parent_course_id = $self->{_course_id}
		and time_period_id in ($self->{_time_period_ids_string})
		and teaching_site_id = $self->{_site_id}
	));
	
	my $total_cnt = $sth->fetchrow_array;
	$sth->finish();

	$sth = $self->{_form}->databaseSelect(qq(
		select count(distinct user_id), count(*)
		from tusk.form_builder_entry a, $self->{_db}.link_course_student b
		where parent_course_id = $self->{_course_id}
		and teaching_site_id = $self->{_site_id}
		and a.time_period_id in ($self->{_time_period_ids_string})
      	and a.time_period_id = b.time_period_id
		and child_user_id = user_id
		and form_id = $self->{_form_id}
	));
	
	my ($reporting_cnt, $patient_cnt) = $sth->fetchrow_array;
	$sth->finish();


	return ($total_cnt, $reporting_cnt, $patient_cnt);
}


sub getReportByField {
	my ($self, $field_id) = @_;
	return unless defined $field_id;

	my %data = ();
	my ($total_students, $reporting_students, $patients) = $self->getNumStudents();
	my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
	my $sql = qq(
				 select item_id, attribute_item_id, count(item_id) as patients, 
				 count(distinct user_id) as students
				 from tusk.form_builder_response a
				 inner join
				 (select user_id, entry_id
				  from tusk.form_builder_entry b, $self->{_db}.link_course_student c
				  where b.time_period_id = c.time_period_id 
				  and b.time_period_id in ($self->{_time_period_ids_string})
				  and child_user_id = user_id and parent_course_id = $self->{_course_id}
				  and form_id = $self->{_form_id} and teaching_site_id = $self->{_site_id}
				  ) d on (a.entry_id = d.entry_id)
				 left outer join tusk.form_builder_response_attribute e
				 on (a.response_id = e.response_id)
				 where field_id = $field_id
				 and active_flag = 1
				 group by item_id, attribute_item_id);

	my $sth = $self->{_form}->databaseSelect($sql);

	while (my ($item_id, $attr_item_id, $patients, $students) = $sth->fetchrow_array()) {
		my $percent = ($total_students && $students) ? sprintf("%.0f%", $students/$reporting_students*100) : '';
		my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
		$data{$item_id}[0][$i] = $patients;
		$data{$item_id}[1][$i] = $students;
		$data{$item_id}[2][$i] = $percent;

	}
    $sth->finish();

	my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");

	return { 
		rows => $items, 
		total_students => $total_students, 
		reporting_students => $reporting_students,
		percent_reporting_students => ($total_students && $reporting_students) ? sprintf("(%.0f%)", $reporting_students/$total_students*100) : '',
		patients => $patients, 
	    data => \%data, 
	    contains_category => $self->isCategory($items->[0]),
		attribute_items => $attribute_items,
	};
}

sub getFieldReportByStudent {
	my ($self, $field_id) = @_;
	return unless defined $field_id;

	my %data = ();
	my %total_seen = ();
	my %total_reporting = ();
	my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
	my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
	my ($total_students, $reporting_students, $patients) = $self->getNumStudents();
	my @time_periods = split(",", $self->{_time_period_ids_string});
	my @students = $self->{_course}->get_students(\@time_periods, $self->{_site_id});
    
	# grab data for hash
	my $sql = qq(
				 select user_id, item_id, attribute_item_id, count(item_id) as patients
				 from tusk.form_builder_response a
				 inner join
				 (select user_id, entry_id
				  from tusk.form_builder_entry b, $self->{_db}.link_course_student c
				  where b.time_period_id = c.time_period_id 
				  and b.time_period_id in ($self->{_time_period_ids_string})
				  and child_user_id = user_id and parent_course_id = $self->{_course_id}
				  and form_id = $self->{_form_id} and teaching_site_id = $self->{_site_id}
				  ) d on (a.entry_id = d.entry_id)
				 left outer join tusk.form_builder_response_attribute e
				 on (a.response_id = e.response_id)
				 where field_id = $field_id
				 and active_flag = 1
				 group by user_id, item_id, attribute_item_id
				);
	my $sth = $self->{_form}->databaseSelect($sql);

	# popuplate data hash with data
	while (my ($user_id, $item_id, $attribute_item_id, $patients) = $sth->fetchrow_array()) {
		if (defined $attribute_items && scalar @$attribute_items) {
				$data{$user_id}->{$item_id}->{$attribute_item_id} = $patients;
				$total_seen{$item_id}->{$attribute_item_id} += $patients;
				$total_reporting{$item_id}->{$attribute_item_id} += 1;
		}
		else {
			$data{$user_id}->{$item_id} = $patients;
			$total_seen{$item_id} += $patients;
			$total_reporting{$item_id} += 1;
		}
	}
    $sth->finish();
    
	# create categorized item array, with the following structure:
	# @categorized = 
	#	[
	#		{ category_name => 'Category name',
	#		  items => [
	#			{ item_id => 1,
	#			  item_name => 'Item Name'
	#			},
	#			.
	#			.
	#		},
	#		.
	#		.
	#	];
	#
	my (@categorized, $currentcategory, $currentitems);

	foreach my $item (@$items) {
		# field without categories
		if (!$self->isCategory($items->[0])) {
			push(@$currentitems, {item_id => $item->getPrimaryKeyID(), item_name => $item->getItemName()});
		}
		# field with categories
		else {
			if ($item->isCatStart()) {
				if ($currentcategory) {
					push(@categorized, {category_name => $currentcategory, category_items => $currentitems});
				}
				$currentitems = [];
				$currentcategory = $item->getItemName();
			}
			elsif ($item->isItemType()) {
				push(@$currentitems, {item_id => $item->getPrimaryKeyID(), item_name => $item->getItemName()});
			}
		}
	}
	# push the last category hash into the categorized array
	if ($self->isCategory($items->[0])) {
		push(@categorized, {category_name => $currentcategory, category_items => $currentitems});
	}
	else {
		push(@categorized, {category_items => $currentitems});
	}

	return {
		reporting_students => $reporting_students,
		total_students => $total_students,
	    contains_category => $self->isCategory($items->[0]),
		categorized_items => \@categorized,
		attribute_items => $attribute_items,
		rows => \@students, 
	    data => \%data,
		total_seen => \%total_seen,
		total_reporting => \%total_reporting,
	};
}


sub getCommentSummary  {
	my ($self, $fields_condition) = @_;

	return $self->SUPER::getCommentSummary($fields_condition, " AND user_id in (select child_user_id from $self->{_db}.link_course_student where time_period_id in ($self->{_time_period_ids_string}) and teaching_site_id = $self->{_site_id})");
}

1;
