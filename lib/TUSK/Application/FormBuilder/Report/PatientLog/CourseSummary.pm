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
use TUSK::DB::Util qw(sql_prep_list);

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

sub _report_sql {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  lcs1.teaching_site_id,
  ts.site_name,
  COUNT(DISTINCT lcs1.child_user_id) AS students,
  (SELECT
     CONVERT(CONCAT(COUNT(DISTINCT fbe.user_id), '_', count(*)) USING utf8)
   FROM
     tusk.form_builder_entry fbe
     INNER JOIN $db.link_course_student lcs2
       ON (fbe.user_id = lcs2.child_user_id
           AND
           fbe.time_period_id = lcs2.time_period_id)
   WHERE
     fbe.form_id = ?
     AND
     lcs2.time_period_id IN ($time_period_prep)
     AND
     lcs2.parent_course_id = ?
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
  lcs1.time_period_id IN ($time_period_prep)
GROUP BY ts.teaching_site_id
ORDER BY ts.site_name
END_SQL
}

sub getReport {
    my $self = shift;
    my @results = ();

    my $db = $self->{_db};
    my $tp_prep = sql_prep_list( @{ $self->{_time_period_ids} } );

    my $sql = $self->_report_sql();
    my $sth = $self->{_form}->databaseSelect(
        $sql,
        $self->{_form_id},
        @{ $self->{_time_period_ids} },
        $self->{_course_id},
        $self->{_course_id},
        @{ $self->{_time_period_ids} }
    );
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

sub _report_all_site_attr_sql {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  fbr.item_id AS item_id,
  count(distinct d.user_id) AS either
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
      SELECT fbe.user_id, fbe.entry_id
      FROM
        tusk.form_builder_entry fbe
        INNER JOIN $db.link_course_student lcs
          ON (fbe.user_id = lcs.child_user_id
              AND
              fbe.time_period_id = lcs.time_period_id)
      WHERE
        parent_course_id = ?
        AND
        fbe.time_period_id IN ($time_period_prep)
        AND
        fbe.form_id = ?
  ) d
    ON (fbr.entry_id = d.entry_id)
  LEFT OUTER JOIN tusk.form_builder_response_attribute fbra
    ON (fbr.response_id = fbra.response_id)
WHERE
  fbr.field_id = ?
  AND
  fbr.active_flag = 1
GROUP BY fbr.item_id
ORDER BY fbr.item_id;
END_SQL
}

sub _report_all_site_sql {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  fbr.item_id,
  fbra.attribute_item_id,
  COUNT(*),
  COUNT(DISTINCT d.user_id)
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
    SELECT fbe.user_id, fbe.entry_id
    FROM
      tusk.form_builder_entry fbe
      INNER JOIN $db.link_course_student lcs
        ON (fbe.user_id = lcs.child_user_id
            AND
            fbe.time_period_id = lcs.time_period_id)
    WHERE
      lcs.parent_course_id = ?
      AND
      fbe.time_period_id IN ($time_period_prep)
      AND
      fbe.form_id = ?
  ) d
    ON (fbr.entry_id = d.entry_id)
  LEFT OUTER JOIN tusk.form_builder_response_attribute fbra
    ON (fbr.response_id = fbra.response_id)
WHERE
  fbr.field_id = ?
  AND
  fbr.active_flag = 1
GROUP BY fbr.item_id, fbra.attribute_item_id
END_SQL
}

sub getReportAllSites {
    my ($self, $field_id) = @_;
    my %data = ();
    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my @time_periods = @{ $self->{_time_period_ids} };
    my $tp_prep = sql_prep_list(@time_periods);
    my $total_students = scalar $self->{_course}->get_students(\@time_periods);
    my $db = $self->{_db};
    my ($sql, $sth, $attribute_summary);

    ## if this is a field with attributes, get summary (# of people
    ## who selected any of the attribute items)
    if (scalar (keys %$aids)) {
        $sql = $self->_report_all_site_attr_sql();
        $sth = $self->{_form}->databaseSelect($sql,
                                              $self->{_course_id},
                                              @time_periods,
                                              $self->{_form_id},
                                              $field_id );
        $attribute_summary = $sth->fetchall_hashref('item_id');
    }

    $sql = $self->_report_all_site_sql();
    $sth = $self->{_form}->databaseSelect($sql,
                                          $self->{_course_id},
                                          @time_periods,
                                          $self->{_form_id},
                                          $field_id );

    while (my ($item_id, $attr_item_id, $patients, $students)
               = $sth->fetchrow_array()) {
        my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
        $data{$item_id}[0][$i] = $patients;
        $data{$item_id}[1][$i] = $students;
        $data{$item_id}[2][$i]
            = sprintf("%.0f%%", ratio_pct($students, $total_students));
        if (scalar (keys %$aids)) {
            my $pct = ratio_pct($attribute_summary->{$item_id}{either},
                                $total_students);
            $data{$item_id}[3] = sprintf("%.0f%%", $pct);
        }
    }
    $sth->finish();

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return {
        rows => $items,
        attribute_items => $attribute_items,
        data => \%data,
        contains_category => $self->isCategory($items->[0]),
        total_students => $total_students,
    };
}

sub _report_by_site_sql {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  tse.teaching_site_id,
  fbr.item_id,
  fbra.attribute_item_id,
  COUNT(*)
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
    SELECT lcs.teaching_site_id, fbe.entry_id
    FROM
      tusk.form_builder_entry fbe
      INNER JOIN $db.link_course_student lcs
        ON (fbe.time_period_id = lcs.time_period_id
            AND
            fbe.user_id = lcs.child_user_id)
    WHERE
      fbe.time_period_id IN ($time_period_prep)
      AND
      lcs.parent_course_id = ?
      AND
      fbe.form_id = ?
  ) tse
    ON (fbr.entry_id = tse.entry_id)
  LEFT OUTER JOIN tusk.form_builder_response_attribute fbra
    ON (fbr.response_id = fbra.response_id)
WHERE
  field_id = ?
  AND
  active_flag = 1
GROUP BY tse.teaching_site_id, fbr.item_id, fbra.attribute_item_id
END_SQL
}

sub getReportBySite {
    my ($self, $field_id) = @_;
    return unless defined $field_id;

    my $sql = $self->_report_by_site_sql();

    my ($reported_data, $items, $attribute_items, $isCategory)
        = $self->getData($field_id, $sql, 'hoh',
                         @{ $self->{_time_period_ids} },
                         $self->{_course_id},
                         $self->{_form_id},
                         $field_id, );
    my %site_hash;
    foreach my $tp_id ( @{ $self->{_time_period_ids} } ) {
        my $sites = $self->{_course}->get_teaching_sites_for_enrolled_time_period($tp_id);
        foreach my $site (@$sites) {
            my $site_id = $site->site_id();
            $site_hash{$site_id} = $site unless $site_hash{$site_id};
        }
    }
    my @teaching_sites;
    push(@teaching_sites, values(%site_hash));

    return {
        rows => \@teaching_sites,
        items => $items,
        attribute_items => $attribute_items,
        data => $reported_data,
        bysite => 1,
        contains_category => $isCategory,
    };
}

sub _report_by_student_sql {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  ue.user_id,
  fbr.item_id,
  fbra.attribute_item_id,
  COUNT(*)
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
    SELECT fbe.user_id, fbe.entry_id
    FROM
      tusk.form_builder_entry fbe
      INNER JOIN $db.link_course_student lcs
        ON (fbe.time_period_id = lcs.time_period_id
            AND
            fbe.user_id = lcs.child_user_id)
    WHERE
      fbe.time_period_id IN ($time_period_prep)
      AND
      lcs.parent_course_id = ?
      AND
      fbe.form_id = ?
    ) ue
      ON (fbr.entry_id = ue.entry_id)
    LEFT OUTER JOIN tusk.form_builder_response_attribute as fbra
      ON (fbr.response_id = fbra.response_id)
WHERE
  fbr.field_id = ?
  AND
  fbr.active_flag = 1
GROUP BY ue.user_id, fbr.item_id, fbra.attribute_item_id
END_SQL
}

sub getReportByStudent {
    my ($self, $field_id) = @_;
    return unless defined $field_id;

    my $sql = $self->_report_by_student_sql();

    my ($reported_data, $items, $attribute_items, $isCategory)
        = $self->getData($field_id, $sql, 'hoh',
                         @{ $self->{_time_period_ids} },
                         $self->{_course_id},
                         $self->{_form_id},
                         $field_id );
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

    return {
        rows => \@students,
        items => $items,
        attribute_items => $attribute_items,
        data => $reported_data,
        bystudent => 1,
        contains_category => $isCategory,
    };
}


sub getData {
    my ($self, $field_id, $sql, $flag, @sql_values) = @_;

    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my $sth = $self->{_form}->databaseSelect($sql, @sql_values);
    my $reported_data = ();

    if ($flag eq 'hash') {      ### store only key and val
        while (my ($item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
            my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
            $reported_data->{$item_id}[$i] = $count;
        }
    }
    elsif ($flag eq 'hoh') {    ### store hash of hash
        while (my ($id, $item_id, $attr_item_id, $count)
                   = $sth->fetchrow_array()) {
            my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
            $reported_data->{$id}{$item_id}[$i] = $count;
        }
    }

    $sth->finish;

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return ($reported_data, $items, $attribute_items,
            $self->isCategory($items->[0]));
}

sub _pct_by_site_sql1 {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT tsue.teaching_site_id, fbr.item_id, COUNT(DISTINCT user_id)
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
    SELECT teaching_site_id, user_id, entry_id
    FROM
      tusk.form_builder_entry fbe
      INNER JOIN $db.link_course_student lcs
        ON (fbe.time_period_id = lcs.time_period_id
            AND
            fbe.user_id = lcs.child_user_id)
    WHERE
      fbe.time_period_id IN ($time_period_prep)
      AND
      lcs.parent_course_id = ?
      AND
      fbe.form_id = ?
  ) tsue
    ON (fbr.entry_id = tsue.entry_id)
  LEFT OUTER JOIN tusk.form_builder_response_attribute fbra
    ON (fbr.response_id = fbra.response_id)
WHERE
  fbr.field_id = ?
  AND
  fbr.active_flag = 1
GROUP BY tsue.teaching_site_id, fbr.item_id
END_SQL
}

sub _pct_by_site_sql2 {
    my $self = shift;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    return <<"END_SQL";
SELECT
  utse.teaching_site_id,
  fbr.item_id,
  fbra.attribute_item_id,
  COUNT(DISTINCT utse.user_id)
FROM
  tusk.form_builder_response fbr
  INNER JOIN (
    SELECT fbe.user_id, lcs.teaching_site_id, fbe.entry_id
    FROM
      tusk.form_builder_entry fbe
      INNER JOIN $db.link_course_student lcs
      ON (fbe.time_period_id = lcs.time_period_id
          AND
          fbe.user_id = lcs.child_user_id)
    WHERE
      fbe.time_period_id IN ($time_period_prep)
      AND
      lcs.parent_course_id = ?
      AND fbe.form_id = ?
  ) utse
    ON (fbr.entry_id = utse.entry_id)
  LEFT OUTER JOIN tusk.form_builder_response_attribute fbra
    ON (fbr.response_id = fbra.response_id)
WHERE
  fbr.field_id = ?
  AND
  fbr.active_flag = 1
GROUP BY utse.teaching_site_id, fbr.item_id, fbra.attribute_item_id
END_SQL
}

sub getPercentagesBySite {
    my ($self, $field_id) = @_;
    return unless defined $field_id;

    my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
    my @time_periods = @{ $self->{_time_period_ids} };
    my ($sql, $sth);
    my $reported_data;
    my (%ts_hash, @ts_array);

    foreach my $tp_id (@time_periods) {
        my $sites = $self->{_course}->get_teaching_sites_for_enrolled_time_period($tp_id);
        foreach my $site (@$sites) {
            my $site_id = $site->site_id();
            $ts_hash{$site_id} = $site unless $ts_hash{$site_id};
        }
    }
    @ts_array = map { $ts_hash{$_} }
                sort { $ts_hash{$a} cmp $ts_hash{$b} }
                keys %ts_hash;
    my @ts_ids = keys (%ts_hash);
    my $total_students = $self->getNumStudentsBySite(\@ts_ids);

    $sql = $self->_pct_by_site_sql1();

    $sth = $self->{_form}->databaseSelect( $sql,
                                           @{ $self->{_time_period_ids} },
                                           $self->{_course_id},
                                           $self->{_form_id},
                                           $field_id );

    while (my ($teaching_site_id, $item_id, $responses)
               = $sth->fetchrow_array()) {
        my $pct = ratio_pct( $responses,
                             $total_students->{$teaching_site_id}->{total} );
        $reported_data->{$teaching_site_id}->{$item_id}->{either}
            = sprintf("%.0f%%", $pct);
    }

    $sql = $self->_pct_by_site_sql2();

    $sth = $self->{_form}->databaseSelect( $sql,
                                           @{ $self->{_time_period_ids} },
                                           $self->{_course_id},
                                           $self->{_form_id},
                                           $field_id );

    while (my ($teaching_site_id, $item_id, $attribute_item_id, $responses)
               = $sth->fetchrow_array()) {
        my $pct = ratio_pct($responses,
                            $total_students->{$teaching_site_id}->{total});
        $reported_data->{$teaching_site_id}->{$item_id}->{$attribute_item_id}
            = sprintf("%.0f%%", $pct);
    }

    my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
    return {
        rows => \@ts_array,
        items => $items,
        attribute_items => $attribute_items,
        data => $reported_data,
        bysite => 1,
        teaching_sites => \%ts_hash,
    };
}


sub _students_by_site_sql {
    my $self = shift;
    my @teaching_sites = @_;
    my $db = $self->{_db};
    my $time_period_prep = sql_prep_list( @{ $self->{_time_period_ids} } );
    my $teaching_sites_prep = sql_prep_list(@teaching_sites);
    return <<"END_SQL";
SELECT lcs.teaching_site_id, COUNT(*) AS total
FROM $db.link_course_student lcs
WHERE
  lcs.parent_course_id = ?
  AND
  lcs.time_period_id IN ($time_period_prep)
  AND
  lcs.teaching_site_id IN ($teaching_sites_prep)
GROUP BY lcs.teaching_site_id
END_SQL
}

sub getNumStudentsBySite {
    my $self = shift;
    my $teaching_sites = shift;
    my @sites;

    if (ref($teaching_sites) eq 'ARRAY') {
        @sites = @{ $teaching_sites };
    }
    else {
        push @sites, $teaching_sites;
    }

    my $sth = $self->{_form}->databaseSelect(
        $self->_students_by_site_sql(@sites),
        $self->{_course_id},
        @{ $self->{_time_period_ids} },
        @sites,
    );

    my $teaching_site_totals = $sth->fetchall_hashref('teaching_site_id');
    $sth->finish();

    return $teaching_site_totals;
}

1;
