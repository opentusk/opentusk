package TUSK::Application::FormBuilder::Report::PatientLog::CourseSummary;

use strict;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use TUSK::FormBuilder::FieldItem;
use TUSK::FormBuilder::AttributeItem;

sub new {
    my ($class, $form_id, $course, $tp_params) = @_;
	die "Missing form_id, and/or course_id\n" unless ($form_id && $course);
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    return $class->SUPER::new( 
							   _course => $course, 
							   _form_id => $form_id,
							   _tp_params => $tp_params,
							   _report_flags => join(",", @{$TUSK::FormBuilder::Constants::report_flags_by_report_type->{1}}),

							   );
}

sub getReport {
	my ($self) = @_;
	my @results = ();

	my $sql = qq(
				 select
				 teaching_site_id,
				 (select site_name
				  from $self->{_db}.teaching_site as b
				  where a.teaching_site_id = b.teaching_site_id) as site_name,
				 count(child_user_id),
				 (select concat(count(distinct c.user_id), '_', count(*))
				  from tusk.form_builder_entry as c
				  where a.time_period_id = c.time_period_id  
				  and form_id = $self->{_form_id}
				  and c.user_id in (select d.child_user_id 
									from $self->{_db}.link_course_student as d 
									where d.time_period_id = a.time_period_id 
									and d.parent_course_id = a.parent_course_id 
									and d.teaching_site_id = a.teaching_site_id)
				  ) as patients
				 from $self->{_db}.link_course_student as a 
				 where a.parent_course_id = $self->{_course_id}
				 and time_period_id in ($self->{_time_period_ids_string})
				 group by teaching_site_id
				 order by site_name
				 );

	my $sth = $self->{_form}->databaseSelect($sql);
	my ($total_num_students, $total_report_students, $total_patients);
	while (my ($site_id, $site_name, $num_students, $count) = $sth->fetchrow_array()) {
		my ($report_students, $patients) = split(/_/, $count);
		my $ratio = ($num_students > 0) ? $report_students / $num_students * 100 : 0;
		push @results, [$site_id, $site_name, $num_students, $report_students, sprintf("%.0f", $ratio), $patients];
		$total_num_students += $num_students;
		$total_report_students += $report_students;
		$total_patients += $patients;
	}

	my $total_ratio = ($total_num_students > 0) ? $total_report_students / $total_num_students * 100 : 0;
	my $total = [$total_num_students, $total_report_students, sprintf("%.0f", $total_ratio), $total_patients];
	return { rows => \@results, total => $total };
}


sub getReportAllSites {
	my ($self, $field_id) = @_;

	my $sql = qq(
		 select item_id, attribute_item_id, count(*)
		 from tusk.form_builder_response as a
		 inner join tusk.form_builder_entry as b on (a.entry_id = b.entry_id)
		 left outer join tusk.form_builder_response_attribute as c on (a.response_id = c.response_id)
		 where time_period_id in ($self->{_time_period_ids_string})
		 and form_id = $self->{_form_id} and field_id = $field_id 
		 group by item_id, attribute_item_id 
	);
	my ($reported_data, $items, $attribute_items, $isCategory) = $self->getData($field_id, $sql, 'hash');

	return { rows => $items, attribute_items => $attribute_items, data => $reported_data, contains_category => $isCategory };
}


sub getReportBySite {
	my ($self, $field_id) = @_;
	return unless defined $field_id;

	my $sql =  qq(
				  select teaching_site_id, item_id, attribute_item_id, count(*)
				  from tusk.form_builder_response as a
				  inner join
				  (select teaching_site_id, entry_id
				   from tusk.form_builder_entry as b, $self->{_db}\.link_course_student as c
				   where b.time_period_id in ($self->{_time_period_ids_string})
				   and b.time_period_id = c.time_period_id
				   and child_user_id = user_id and parent_course_id = $self->{_course_id} 
				   and form_id = $self->{_form_id}) as d
				  on (a.entry_id = d.entry_id) 
				  left outer join tusk.form_builder_response_attribute as e
				  on (a.response_id = e.response_id)
				  where field_id = $field_id
				  group by teaching_site_id, item_id, attribute_item_id
				  );

	my ($reported_data, $items, $attribute_items, $isCategory) = $self->getData($field_id, $sql, 'hoh');
	my $teaching_sites = $self->{_course}->get_teaching_sites_for_enrolled_time_period($self->{_time_period_ids}[0]);
	return {rows => $teaching_sites, items => $items, attribute_items => $attribute_items, data => $reported_data, bysite => 1, contains_category => $isCategory};
}



sub getReportByStudent {
	my ($self, $field_id) = @_;
	return unless defined $field_id;

	my $sql =  qq(
				  select user_id, item_id, attribute_item_id, count(*)
				  from tusk.form_builder_response as a
				  inner join
				  (select user_id, entry_id
				   from tusk.form_builder_entry as b, $self->{_db}\.link_course_student as c
				   where b.time_period_id in ($self->{_time_period_ids_string})
				   and b.time_period_id = c.time_period_id
				   and child_user_id = user_id and parent_course_id = $self->{_course_id} 
				   and form_id = $self->{_form_id}) as d
				  on (a.entry_id = d.entry_id) 
				  left outer join tusk.form_builder_response_attribute as e
				  on (a.response_id = e.response_id)
				  where field_id = $field_id
				  group by user_id, item_id, attribute_item_id
				  );

	my ($reported_data, $items, $attribute_items, $isCategory) = $self->getData($field_id, $sql, 'hoh');
	## possibly one student are in more than one teaching site
	my %seen_students = (); my @students = ();
	foreach my $student ($self->{_course}->get_students($self->{_time_period_ids}[0])) {
		unless (exists $seen_students{$student->primary_key()}) {
			push @students, $student;
			$seen_students{$student->primary_key()} = 1;
		}
	}

	return {rows => \@students, items => $items, attribute_items => $attribute_items, data => $reported_data, bystudent => 1, contains_category => $isCategory};
}


sub getData {
	my ($self, $field_id, $sql, $flag) = @_;

	my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
	my $sth = $self->{_form}->databaseSelect($sql);
	my $reported_data = ();

	if ($flag eq 'hash') {  ### store only key and val
		while (my ($item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
			my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
			$reported_data->{$item_id}[$i] = $count;
		}
	} elsif ($flag eq 'hoh') {  ### store hash of hash 
		while (my ($id, $item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
			my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
			$reported_data->{$id}{$item_id}[$i] = $count;
		}
	}

    $sth->finish;

	my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
	return ($reported_data, $items, $attribute_items, $self->isCategory($items->[0]));
}


1;
