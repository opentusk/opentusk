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


package TUSK::Application::FormBuilder::Report::Course;

use strict;
use base qw(TUSK::Application::FormBuilder::ReportBuilder);
use TUSK::Core::School;

sub new {
    my ($class, $form_id, $course) = @_;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    return $class->SUPER::new( _course => $course, _form_id => $form_id );
}

sub getSchoolDB{
    my ($self) = @_;
    return $self->{_course}->school_db();
}

sub getCourseID{
    my ($self) = @_;
    return $self->{_course}->primary_key;
}

sub FieldperPerson{
    my ($self, $args, $extra_field) = @_;
    
    my $schooldb = $self->getSchoolDB();
    my $course_id = $self->getCourseID();
    my $user_id = $self->getUserID();
    my $fullname = $self->getPersonalFlag() ? "'&nbsp;' as Fullname" : "concat(u.lastname, ', ', u.firstname) as Fullname";
	my $time_period_ids = (ref $args->{time_period_id} eq 'ARRAY') ? join(',', @{$args->{time_period_id}}) : $args->{time_period_id};
	my $teaching_site_ids = (ref $args->{teaching_site_id} eq 'ARRAY') ? join(',', @{$args->{teaching_site_id}}) : $args->{teaching_site_id};

    my @wheres1 = ("s.parent_course_id = $course_id",
		  "s.time_period_id in ($time_period_ids)",
		  "r.active_flag",
                  "(s.child_user_id = u.user_id)",
                  "(s.child_user_id = e.user_id and s.time_period_id = e.time_period_id and e.form_id = ".$self->getFormID().")",
                  "(i.item_id = r.item_id)",
		  "(i.item_type_id = it.item_type_id)");


    my @wheres2 = ("s.parent_course_id = $course_id",
		   "s.time_period_id in ($time_period_ids)",
		   "(s.child_user_id = u.user_id)",
		   "(s.parent_course_id = l.parent_course_id)",
		   "(l.child_form_id = lff.parent_form_id)",
		   "(f.field_id = lff.child_field_id)",
		   "(i.field_id = f.field_id)",
		   "(i.item_type_id = it.item_type_id)");

    unless ($args->{nosite}) {
		push @wheres1, "s.teaching_site_id in ($teaching_site_ids)";
		push @wheres2, "s.teaching_site_id in ($teaching_site_ids)";
    }

    my $sql_builder = {
	statements => [
		       { 
			   fields => [ 
				       "s.child_user_id as user_id", 
				       $fullname, 
				      "i.item_id as item_id", 
				      "i.content_id as content_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      ],
			       tables => [ 
					   "hsdb4.user u",
					   "$schooldb\.link_course_student s",
					   "tusk.form_builder_entry e",
					   "tusk.form_builder_field_item i",
					   "tusk.form_builder_item_type it",
					  
					  ], 
			       wheres => [ @wheres1 ], 
					  
			   },
		       {
			   fields => [ 
				       "s.child_user_id as user_id", 
				       $fullname, 
				      "i.item_id as item_id",
				      "i.content_id as content_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      ],
			       tables => [
					  "hsdb4.user u",
					  "$schooldb\.link_course_student s",
					  "tusk.link_course_form l",
					  "tusk.link_form_field lff",
					  "tusk.form_builder_field f",
					  "tusk.form_builder_field_item i",
					  "tusk.form_builder_item_type it",
					  ], 
			       wheres => [ @wheres2 ], 
			   }
		       ],
	groupbys => [
		     "user_id",
		     "item_id",
		     ], 
	    
	    orderbys => [
			 "Fullname",
			 "sort_order",
			 "item_id",
			 ],
	};

    if ($user_id){
		for my $int (0..1){
			push (@{$sql_builder->{statements}->[$int]->{'wheres'}}, "s.child_user_id = '" . $user_id . "'");
		}
    }
    return $self->SUPER::query($self->processExtras($sql_builder, $args, $extra_field));
}

sub OtherperPerson{
    my ($self, $args) = @_;

    return $self->FieldperPerson($args, "text");
}

sub FieldperTeachingSite{
    my ($self, $args, $extra_field) = @_;
    
    my $schooldb = $self->getSchoolDB();
    my $course_id = $self->getCourseID();

    my $sql_builder = {
	statements => [
		       { 
			   fields => [
				      "s.teaching_site_id as teaching_site_id", 
				      "t.site_name as Sitename",
				      "i.item_id as item_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      ],
			       tables => [
					  "$schooldb\.teaching_site t",
					  "$schooldb\.link_course_student s",
					  "tusk.form_builder_entry e",
					  "tusk.form_builder_field_item i",
					  "tusk.form_builder_item_type it",
					  
					  ], 
			       wheres => [
					  "s.parent_course_id = $course_id",
					  "s.time_period_id = " . $args->{time_period_id},
					  "r.active_flag",
                      "(s.teaching_site_id = t.teaching_site_id)",
                      "(s.child_user_id = e.user_id and s.time_period_id = e.time_period_id and e.form_id = ".$self->getFormID().")",
                      "(i.item_id = r.item_id)",
                      "(i.item_type_id = it.item_type_id)",
					  ], 
			   },
		       {
			   fields => [
				      "s.teaching_site_id as teaching_site_id", 
				      "t.site_name as Sitename",
				      "i.item_id as item_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      ],
			       tables => [
					  "$schooldb\.teaching_site t",
					  "$schooldb\.link_course_student s",
					  "tusk.link_course_form l",
					  "tusk.link_form_field lff",
					  "tusk.form_builder_field f",
					  "tusk.form_builder_field_item i",
					  "tusk.form_builder_item_type it",
					  ], 
			       wheres => [
					  "s.parent_course_id = $course_id",
 					  "s.time_period_id = " . $args->{time_period_id},
                      "(s.teaching_site_id = t.teaching_site_id)",
                      "(s.parent_course_id = l.parent_course_id)",
                      "(l.child_form_id = lff.parent_form_id)",
                      "(f.field_id = lff.child_field_id)",
                      "(i.field_id = f.field_id)",
                      "(i.item_type_id = it.item_type_id)",
					  ], 
			   }
		       ],
	groupbys => [
		     "teaching_site_id",
		     "item_id",
		     ], 
	    
	    orderbys => [
			 "Sitename",
			 "teaching_site_id",
			 "sort_order",
			 "item_id",
			 ],
	};

    return $self->SUPER::query($self->processExtras($sql_builder, $args, $extra_field));
}

sub OtherperTeachingSite{
    my ($self, $args) = @_;

    return $self->FieldperTeachingSite($args, "text");
}

sub FieldperTimePeriod{
    my ($self, $args, $extra_field) = @_;

    my $schooldb = $self->getSchoolDB();
    my $course_id = $self->getCourseID();

    my $sql_builder = {
	statements => [
		       { 
			   fields => [
				      "s.time_period_id as time_period_id", 
				      "concat(t.period, ' (', t.academic_year, ')') as 'Time Period'",
				      "i.item_id as item_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      "t.start_date as start_date",
				      ],
			       tables => [
					  "$schooldb\.time_period t",
					  "$schooldb\.link_course_student s",
					  "tusk.form_builder_entry e",
					  "tusk.form_builder_field_item i",
					  "tusk.form_builder_item_type it",
					  ], 
			       wheres => [
					  "s.parent_course_id = $course_id",
					  "r.active_flag",
					  "(s.time_period_id = t.time_period_id)",
					  "(s.child_user_id = e.user_id and s.time_period_id = e.time_period_id and e.form_id = " . $self->getFormID() . ")",
					  "(i.item_id = r.item_id)",
					  "(i.item_type_id = it.item_type_id)",
					  ], 
			   },
		       {
			   fields => [
				      "s.time_period_id as time_period_id", 
				      "concat(t.period, ' (', t.academic_year, ')') as 'Time Period'",
				      "i.item_id as item_id",
				      "i.sort_order as sort_order",
				      "i.item_name as item_name",
				      "i.abbreviation as abbreviation",
				      "allow_user_defined_value as allow_other",
				      "it.token as token",
				      "t.start_date as start_date",
				      ],
			       tables => [
					  "$schooldb\.time_period t",
					  "$schooldb\.link_course_student s",
					  "tusk.link_course_form l",
					  "tusk.link_form_field lff",
					  "tusk.form_builder_field f",
					  "tusk.form_builder_field_item i",
					  "tusk.form_builder_item_type it",
					  ], 
			       wheres => [
					  "s.parent_course_id = $course_id",
					  "(s.time_period_id = t.time_period_id)",
					  "(s.parent_course_id = l.parent_course_id)",
					  "(l.child_form_id = lff.parent_form_id)",
					  "(f.field_id = lff.child_field_id)",
					  "(i.field_id = f.field_id)",
					  "(i.item_type_id = it.item_type_id)",
					 ], 
			   }
		       ],
	groupbys => [
		     "time_period_id",
		     "item_id",
		     ], 
	    
	    orderbys => [
			 "start_date desc",
			 "'Time Period'",
			 "sort_order",
			 "item_id",
			 ],
	};

    if ($args->{teaching_site_id}){
	for my $int (0..1){
	    push (@{$sql_builder->{statements}->[$int]->{'wheres'}}, "s.teaching_site_id = " . $args->{teaching_site_id});
	}
    }

    if ($args->{start_date}){
	for my $int (0..1){
	    push (@{$sql_builder->{statements}->[$int]->{'wheres'}}, "t.start_date >= '" . $args->{start_date} . "'");
	}
    }

 	## narrow results down by time period, if one(s) were passed
   if ($args->{tpid}){
	for my $int (0..1){
		if (ref($args->{tpid}) eq "ARRAY") {
		    push (@{$sql_builder->{statements}->[$int]->{'wheres'}}, "s.time_period_id IN(" . join("," , @{$args->{tpid}}) . ")");
		}
		else {
		    push (@{$sql_builder->{statements}->[$int]->{'wheres'}}, "s.time_period_id = '" . $args->{tpid} . "'");
		}
	}
   }
    
    return $self->SUPER::query($self->processExtras($sql_builder, $args, $extra_field));
}

sub OtherperTimePeriod{
    my ($self, $args) = @_;

    return $self->FieldperTimePeriod($args, "text");
}

sub HistoryperPerson{
    my ($self, $time_period_id, $teaching_site_id) = @_;

    my $schooldb = $self->getSchoolDB();
    my $course_id = $self->getCourseID();
    my $user_id = $self->getUserID();
	my $form_id = $self->getFormID();

    my $wheres = [ "s.child_user_id = '$user_id'",
                   "s.parent_course_id = $course_id",
                   "s.time_period_id = $time_period_id" ];

    push @$wheres, "s.teaching_site_id = $teaching_site_id" if defined ($teaching_site_id);

    my $sql_builder = { 
		statements => [
			{
               'fields' => [
							"s.child_user_id as user_id",
                            "e.entry_id",
                            "date_format(e.date, '%c/%e/%y') as date",
                            "f.field_id as field_id",
                            "f.field_name as field_name",
                            "i.item_id as item_id",
                            "i.item_name as item_name",
                            "i.abbreviation as item_abbreviation",
                            "a.item_id as attribute_id",
                            "a.item_name as attribute_name",
                            "r1.text as text",
                            "f.default_report as default_report",
                            "f.private as private",
                            "r1.active_flag",
							"lf.csort_order",
             ],
             'tables' => [
						  "$schooldb\.link_course_student s",
                          "left join tusk.form_builder_entry e on (s.child_user_id = e.user_id and s.time_period_id = e.time_period_id and e.form_id = $form_id)",
                          "left join tusk.form_builder_response r1 on (r1.entry_id = e.entry_id)",
                          "left join tusk.form_builder_field f on (f.field_id = r1.field_id)",
                          "left join tusk.form_builder_field_item i on (i.item_id = r1.item_id)",
                          "left join tusk.form_builder_response_attribute ra on (r1.response_id = ra.response_id)",
                          "left join tusk.form_builder_attribute_item a on (a.item_id = ra.attribute_item_id)",
						  "left join (select * from (select l1.child_field_id, l2.sort_order*1000 + l1.depth_level*100 + l1.sort_order as csort_order from tusk.form_builder_link_field_field l1, tusk.link_form_field l2 where l1.root_field_id = l2.child_field_id and parent_form_id = $form_id UNION select child_field_id, sort_order*1000 as csort_order from tusk.link_form_field where parent_form_id = $form_id) as SortFields) lf on (f.field_id = lf.child_field_id)",
            ],
            'wheres' => $wheres,
            'groupbys' => [],
            'orderbys' => [
						   "e.date desc",
						   "e.entry_id desc",
						   "lf.csort_order",
						   'r1.active_flag desc',
						   "lf.child_field_id",
						   "i.sort_order",
						   ]
		    }
	    ],
		orderbys => [],
		groupbys => [],
	};
    push (@{$sql_builder->{statements}->[0]->{'wheres'}}, "f.private = 0") unless ($self->getPersonalFlag());
    return $self->SUPER::query($sql_builder);
}

sub processExtras{
    my ($self, $sql_builder, $args, $extra_field) = @_;

    my ($attribute_id, $advanced_items, $item_id, $field_id) = ($args->{attribute_id}, $args->{advanced_item_id}, $args->{item_id}, $args->{field_id});

    if ($advanced_items){
	$advanced_items = [ $advanced_items ] unless (ref($advanced_items) eq "ARRAY");
    }else{
	$advanced_items = [];
    }

    $sql_builder = $self->addAdvanced($sql_builder, $advanced_items);

    $sql_builder = $self->addAttribute($sql_builder, $attribute_id) if ($attribute_id);

    if ($extra_field){
	push(@{$sql_builder->{statements}->[0]->{fields}}, "if(r.$extra_field <> '', r.$extra_field,'[ <i>empty</i> ]') as $extra_field");
	push(@{$sql_builder->{statements}->[0]->{wheres}}, "i.item_id = $item_id");
	push(@{$sql_builder->{orderbys}}, $extra_field);
	$sql_builder->{type} = "other";
    }else{
	push(@{$sql_builder->{statements}->[0]->{fields}}, "1 as inner_count");
	push(@{$sql_builder->{statements}->[1]->{fields}}, "0 as inner_count");
	push(@{$sql_builder->{statements}->[0]->{wheres}}, "i.field_id = $field_id");
	push(@{$sql_builder->{statements}->[1]->{wheres}}, "i.field_id = $field_id");
	$sql_builder->{type} = "field";
    }

    return $sql_builder;
}

sub addAdvanced{
    my ($self, $sql_builder, $advanced_items) = @_;
    
    my $count = 1;
    my $table_link = "e";

    foreach my $item_id (@{$advanced_items}){
	next unless $item_id;
	push (@{$sql_builder->{statements}->[0]->{tables}}, "tusk.form_builder_response r$count");
        push (@{$sql_builder->{statements}->[0]->{wheres}}, "(r" . $count . ".entry_id = " . $table_link . ".entry_id and r" . $count .
                                                            ".item_id = " . $item_id  .")"
             );
	$table_link = "r" . $count;
	$count++;
    }

    push (@{$sql_builder->{statements}->[0]->{tables}}, "tusk.form_builder_response r");
    push (@{$sql_builder->{statements}->[0]->{wheres}}, "(r.entry_id = " . $table_link . ".entry_id)");
    return ($sql_builder);
}

sub addAttribute{
    my ($self, $sql_builder, $attribute_id) = @_;
    
    for my $int (0..1){

	if ($int == 0){
	push (@{$sql_builder->{statements}->[$int]->{fields}}, 'a.item_id as attribute_id', 'a.item_name as attribute_name', 'a.abbreviation as attribute_abbreviation', 'a.sort_order as attribute_sort_order');
	    push (@{$sql_builder->{statements}->[$int]->{tables}}, "tusk.form_builder_response_attribute ra", 'tusk.form_builder_attribute_item a',);
	    push (@{$sql_builder->{statements}->[$int]->{wheres}}, "(r.response_id = ra.response_id)", '(a.item_id = ra.attribute_item_id)');
	}else{
	push (@{$sql_builder->{statements}->[$int]->{fields}}, 'a.item_id as attribute_id', 'a.item_name as attribute_name', 'a.abbreviation as attribute_abbreviation', 'a.sort_order as attribute_sort_order');
	    push (@{$sql_builder->{statements}->[$int]->{tables}}, "tusk.form_builder_attribute at", "tusk.form_builder_attribute_item a",);
	    push (@{$sql_builder->{statements}->[$int]->{wheres}}, "(at.field_id = f.field_id)", "(at.attribute_id = a.attribute_id)",);
	}
	push (@{$sql_builder->{statements}->[$int]->{wheres}}, "a.attribute_id = $attribute_id");
    }
    push (@{$sql_builder->{'orderbys'}}, "attribute_sort_order", "attribute_id");
    push (@{$sql_builder->{groupbys}}, "attribute_id");
    
    return ($sql_builder);
}

1;
