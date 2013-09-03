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


package TUSK::Application::FormBuilder::Report::PatientLog::CourseSummary;

use strict;
use utf8;
use warnings;
use Carp;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use TUSK::FormBuilder::FieldItem;
use TUSK::FormBuilder::AttributeItem;

sub new {
    my ($class, $form_id, $course, $tp_params) = @_;
    confess "Missing form_id" unless ($form_id);
    confess "Missing course_id" unless ($course);
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $flags_ref
        = $TUSK::FormBuilder::Constants::report_flags_by_report_type->{1};
    return $class->SUPER::new(
        _course => $course,
        _form_id => $form_id,
        _tp_params => $tp_params,
        _report_flags => join(q{,}, @{$flags_ref}),
    );
}

sub ratio_pct {
    my ($num, $denom) = @_;
    return $denom > 0 ? $num / $denom * 100 : 0;
}

sub getReport {
    my $self = shift;
    my @results = ();

    my $db = $self->{_db};
    my $tp_prep = join(q{,},
                       ('?') x scalar( @{ $self->{_time_period_ids} } ));
    my $sql = <<"END_SQL";
SELECT
  lcs1.teaching_site_id,
  ts.site_name,
  count(lcs1.child_user_id) AS students,
  (SELECT
     CONCAT(COUNT(DISTINCT fbe.user_id), "_", count(*))
   FROM
     tusk.form_builder_entry fbe
     INNER JOIN $db.link_course_student lcs2
       ON (fbe.time_period_id = lcs2.time_period_id
           AND
           fbe.user_id = lcs2.child_user_id)
   WHERE
     fbe.form_id = ?
     AND
     lcs2.parent_course_id = ?
     AND
     lcs2.time_period_id = lcs1.time_period_id
     AND
     lcs2.teaching_site_id = lcs1.teaching_site_id
    ) AS patients
FROM
  $db.link_course_student lcs1
  INNER JOIN $db.teaching_site ts
    ON lcs1.teaching_site_id = ts.teaching_site_id
WHERE
  lcs1.parent_course_id = ?
  AND
  lcs1.time_period_id IN ($tp_prep)
GROUP BY ts.teaching_site_id
ORDER BY ts.site_name
END_SQL

    my $sth = $self->{_form}->databaseSelect($sql,
                                             $self->{_form_id},
                                             $self->{_course_id},
                                             $self->{_course_id},
                                             @{ $self->{_time_period_ids} });
    my ($total_num_students, $total_report_students, $total_patients);
    while (my ($site_id, $site_name, $num_students, $count)
               = $sth->fetchrow_array()) {
        my ($report_students, $patients) = split(/_/, $count);
        my $ratio = ratio_pct($report_students, $num_students);
        push @results, [ $site_id, $site_name, $num_students,
                         $report_students, sprintf("%.0f", $ratio),
                         $patients, ];
        $total_num_students += $num_students;
        $total_report_students += $report_students;
        $total_patients += $patients;
    }

    my $total_ratio = ratio_pct($total_report_students, $total_num_students);
    my $total = [ $total_num_students, $total_report_students,
                  sprintf("%.0f", $total_ratio), $total_patients ];
    return { rows => \@results, total => $total };
}


sub getReportAllSites {
    my ($self, $field_id) = @_;
    my %data = ();
    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my @time_periods = split(",", $self->{_time_period_ids_string});
    my $total_students = scalar $self->{_course}->get_students(\@time_periods);
    my ($sql, $sth, $attribute_summary);

    ## if this is a field with attributes, get summary (# of people who selected any of the attribute items)
    if (scalar (keys %$aids)) {
        $sql = qq(
                                        select item_id, count(distinct user_id) as either
                                        from tusk.form_builder_response as a
                                        inner join
                                        (select user_id, entry_id
                                                from tusk.form_builder_entry b, $self->{_db}.link_course_student c
                                                where b.user_id = c.child_user_id
                                                and b.time_period_id = c.time_period_id
                                                and parent_course_id = $self->{_course_id}
                                                and b.time_period_id in ($self->{_time_period_ids_string})
                                                and form_id = $self->{_form_id}) as d
                                        on (a.entry_id = d.entry_id)
                                        left outer join tusk.form_builder_response_attribute as c on (a.response_id = c.response_id)
                                        where a.field_id = $field_id and
                                        active_flag = 1 group by item_id order by item_id;
                                );

        $sth = $self->{_form}->databaseSelect($sql);
        $attribute_summary = $sth->fetchall_hashref('item_id');
    }

    $sql = qq(
                                 select item_id, attribute_item_id, count(*), count(distinct user_id)
                                 from tusk.form_builder_response as a
                                 inner join
                                 (select user_id, entry_id
                                  from tusk.form_builder_entry b, $self->{_db}.link_course_student c
                                  where b.user_id = c.child_user_id
                                  and b.time_period_id = c.time_period_id
                                  and parent_course_id = $self->{_course_id}
                                  and b.time_period_id in ($self->{_time_period_ids_string})
                                  and form_id = $self->{_form_id}) as d
                                 on (a.entry_id = d.entry_id)
                                 left outer join tusk.form_builder_response_attribute as c on (a.response_id = c.response_id)
                                 where field_id = $field_id
                                 and active_flag = 1
                                 group by item_id, attribute_item_id
                                 );

    $sth = $self->{_form}->databaseSelect($sql);

    while (my ($item_id, $attr_item_id, $patients, $students) = $sth->fetchrow_array()) {
        my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
        $data{$item_id}[0][$i] = $patients;
        $data{$item_id}[1][$i] = $students;
        $data{$item_id}[2][$i] = sprintf("%.0f%", $students/$total_students*100);
        if (scalar (keys %$aids)) {
            $data{$item_id}[3] = sprintf("%.0f%", ($attribute_summary->{$item_id}{'either'}/$total_students)*100);
        }
    }
    $sth->finish();

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return { rows => $items, attribute_items => $attribute_items, data => \%data, contains_category => $self->isCategory($items->[0]), total_students => $total_students };
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
                                  and active_flag = 1
                                  group by teaching_site_id, item_id, attribute_item_id
                                  );

    my ($reported_data, $items, $attribute_items, $isCategory) = $self->getData($field_id, $sql, 'hoh');
    my %site_hash;
    foreach my $tp_id (@{$self->{_time_period_ids}}) {
        my $sites = $self->{_course}->get_teaching_sites_for_enrolled_time_period($tp_id);
        foreach my $site (@$sites) {
            my $site_id = $site->site_id();
            $site_hash{$site_id} = $site unless $site_hash{$site_id};
        }
    }
    my @teaching_sites;
    push(@teaching_sites, values(%site_hash));

    return {rows => \@teaching_sites, items => $items, attribute_items => $attribute_items, data => $reported_data, bysite => 1, contains_category => $isCategory};
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
                                  and active_flag = 1
                                  group by user_id, item_id, attribute_item_id
                                  );

    my ($reported_data, $items, $attribute_items, $isCategory) = $self->getData($field_id, $sql, 'hoh');
    ## possibly one student are in more than one teaching site
    my %seen_students = (); my @students = ();
    foreach my $tp_id ($self->{_time_period_ids}) {
        foreach my $student ($self->{_course}->get_students($tp_id)) {
            unless (exists $seen_students{$student->primary_key()}) {
                push @students, $student;
                $seen_students{$student->primary_key()} = 1;
            }
        }
    }

    return {rows => \@students, items => $items, attribute_items => $attribute_items, data => $reported_data, bystudent => 1, contains_category => $isCategory};
}


sub getData {
    my ($self, $field_id, $sql, $flag) = @_;

    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my $sth = $self->{_form}->databaseSelect($sql);
    my $reported_data = ();

    if ($flag eq 'hash') {      ### store only key and val
        while (my ($item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
            my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
            $reported_data->{$item_id}[$i] = $count;
        }
    }
    elsif ($flag eq 'hoh') {    ### store hash of hash
        while (my ($id, $item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
            my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
            $reported_data->{$id}{$item_id}[$i] = $count;
        }
    }

    $sth->finish;

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return ($reported_data, $items, $attribute_items, $self->isCategory($items->[0]));
}


sub getPercentagesBySite {
    my ($self, $field_id) = @_;
    return unless defined $field_id;

    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my @time_periods = split(",", $self->{_time_period_ids_string});
    my ($sql, $sth);
    my $reported_data;
    my (%ts_hash, @ts_array);

    foreach my $tp_id (@{$self->{_time_period_ids}}) {
        my $sites = $self->{_course}->get_teaching_sites_for_enrolled_time_period($tp_id);
        foreach my $site (@$sites) {
            my $site_id = $site->site_id();
            $ts_hash{$site_id} = $site unless $ts_hash{$site_id};
        }
    }
    @ts_array = map { $ts_hash{$_} } sort { $ts_hash{$a} cmp $ts_hash{$b} } keys %ts_hash;
    my @ts_ids = keys (%ts_hash);
    my $total_students = $self->getNumStudentsBySite(\@ts_ids);

    $sql = qq(
                                select teaching_site_id, item_id, count(distinct user_id)
                                from tusk.form_builder_response as a
                                inner join
                                (select teaching_site_id, user_id, entry_id
                                        from tusk.form_builder_entry as b, $self->{_db}.link_course_student as c
                                        where b.time_period_id in ($self->{_time_period_ids_string})
                                        and b.time_period_id = c.time_period_id
                                        and child_user_id = user_id and parent_course_id = $self->{_course_id}
                                        and form_id = $self->{_form_id}) as d
                                on (a.entry_id = d.entry_id)
                                left outer join tusk.form_builder_response_attribute as e
                                on (a.response_id = e.response_id)
                                where field_id = $field_id
                                and active_flag = 1
                                group by teaching_site_id, item_id
                        );

    $sth = $self->{_form}->databaseSelect($sql);
    while (my ($teaching_site_id, $item_id, $responses) = $sth->fetchrow_array()) {
        $reported_data->{$teaching_site_id}->{$item_id}->{'either'} = sprintf("%.0f%", ($responses/$total_students->{$teaching_site_id}->{total})*100);;
    }

    $sql =  qq(
                                select teaching_site_id, item_id, attribute_item_id, count(distinct user_id)
                                from tusk.form_builder_response as a
                                inner join
                                (select user_id, teaching_site_id, entry_id
                                        from tusk.form_builder_entry as b, $self->{_db}\.link_course_student as c
                                        where b.time_period_id in ($self->{_time_period_ids_string})
                                        and b.time_period_id = c.time_period_id
                                        and child_user_id = user_id and parent_course_id = $self->{_course_id}
                                        and form_id = $self->{_form_id}) as d
                                on (a.entry_id = d.entry_id)
                                left outer join tusk.form_builder_response_attribute as e
                                on (a.response_id = e.response_id)
                                where field_id = $field_id
                                and active_flag = 1
                                group by teaching_site_id, item_id, attribute_item_id
                                );

    $sth = $self->{_form}->databaseSelect($sql);

    while (my ($teaching_site_id, $item_id, $attribute_item_id, $responses) = $sth->fetchrow_array()) {
        $reported_data->{$teaching_site_id}->{$item_id}->{$attribute_item_id} = sprintf("%.0f%", ($responses/$total_students->{$teaching_site_id}->{total})*100);;
    }

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return {rows => \@ts_array, items => $items, attribute_items => $attribute_items, data => $reported_data, bysite => 1, teaching_sites => \%ts_hash };
}


sub getNumStudentsBySite {
    my $self = shift;
    my $teaching_sites = shift;
    my $ts_string;

    if (ref($teaching_sites) eq 'ARRAY') {
        $ts_string = " teaching_site_id IN(" . join(",", @$teaching_sites) . ")";
    }
    else {
        $ts_string = " teaching_site_id = $teaching_sites";
    }

    my $sth = $self->{_form}->databaseSelect(qq(
                select teaching_site_id, count(*) as total
                from $self->{_db}.link_course_student a
                where parent_course_id = $self->{_course_id}
                and time_period_id in ($self->{_time_period_ids_string})
                and $ts_string
                group by teaching_site_id
        ));

    my $teaching_site_totals = $sth->fetchall_hashref('teaching_site_id');
    $sth->finish();

    return $teaching_site_totals;
}


1;
