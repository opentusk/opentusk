# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

package TUSK::Application::FormBuilder::Assessment;

use TUSK::FormBuilder::Entry;
use TUSK::FormBuilder::SubjectAssessor;
use HSDB45::Course;
use HSDB4::Constants qw(:school);
use Carp qw(confess);

sub new {
	my ($class, $arg_ref) = @_;

	my $self = {
		user_id => $arg_ref->{user_id},
		current_time_period => $arg_ref->{current_time_period},
		requested_time_period => $arg_ref->{requested_time_period},
		session_user_id => $arg_ref->{session_user_id},
		course_id => $arg_ref->{course_id},
        school_id => $arg_ref->{school_id}
	};

	bless($self, $class);

	return $self;
}

sub moveAssessment {
	my ($self, $args) = @_;

	my $user = HSDB4::SQLRow::User->new()->lookup_key($self->{user_id});

	$self->{current_time_period} =~ s{\A \s* | \s* \z}{}gxm;

    my $assessor_ids = $self->getAssessors();
    my $entries;
    if (scalar @$assessor_ids) {
        for my $assessor_id (@$assessor_ids) {
            $self->copyAssessorTimePeriod({assessor_id => 
                $assessor_id});
        }
        $entries = $self->getEntries({
            assessors => $assessor_ids
        });
    }

    for my $entry (@$entries) {
        $self->updateEntry({
            entry_id => $entry->{entry_id}
        });
    }
}

sub getAssessors {
    my ($self, $args) = @_;
	my $assessors_sql = qq(
        select sa.assessor_id, parent_course_id as course_id,
            f.form_id as form_id
        from tusk.form_builder_subject_assessor sa
            inner join tusk.link_course_form as cf on (sa.form_id = cf.child_form_id)
            inner join tusk.form_builder_form as f on (sa.form_id = f.form_id)
            inner join tusk.form_builder_form_type as ft on (f.form_type_id = ft.form_type_id)
            inner join tusk.school as s on (cf.school_id = s.school_id)
        where f.publish_flag = 1
            and ft.token = 'Assessment' and status in (1,2)
            and sa.subject_id  = ?
            and sa.time_period_id = ?
            and cf.parent_course_id = ?
            and cf.school_id = ?
    );

    my $dbh = HSDB4::Constants::def_db_handle ();
	my $assessments = [];
    warn "Using user id $self->{user_id}, current time period $self->{current_time_period},
    course id $self->{course_id} and school id $self->{school_id}.";
    eval {
		my $sth = $dbh->prepare($assessors_sql);
		$sth->execute($self->{user_id}, $self->{current_time_period}, 
            $self->{course_id}, $self->{school_id});
		$assessments = $sth->fetchall_arrayref({});
    };

	confess "$@" if ($@);

    my @assessors = map {"'" . $_->{assessor_id} . "'"} (@$assessments);

    return \@assessors;
}

sub getEntries {
    my ($self, $args) = @_;
    my @assessors = @{$args->{assessors}};
    my $sub_condition = '(' . join(q{,}, @assessors) . ')';
    warn "Sub condition is " . $sub_condition;
    my $entries_sql = qq(
        select form_id, e.entry_id
        from tusk.form_builder_entry e inner join 
            tusk.form_builder_entry_association ea on e.entry_id = ea.entry_id 
        where ea.user_id = ? and e.time_period_id = ? and e.user_id in $sub_condition
    );

    my $entries = [];

    my $dbh = HSDB4::Constants::def_db_handle ();
    eval {
        my $sth = $dbh->prepare($entries_sql);
        $sth->execute($self->{user_id}, $self->{current_time_period});
        $entries = $sth->fetchall_arrayref({});
    };

    confess "$@" if ($@);

    for my $row (@$entries) 
    {
        warn "Entry is " . $row->{entry_id};
    }
    
    return $entries;
}

sub updateEntry() {
	my ($self, $args) = @_;
	warn "Entry id is " . $args->{entry_id};
	my $entry = TUSK::FormBuilder::Entry->lookupReturnOne("entry_id = $args->{entry_id}");
	$entry->setFieldValue('time_period_id', $self->{requested_time_period});
	warn "User id is " . $self->{session_user_id};
	$entry->save({user => 
		$self->{session_user_id}});
}

sub copyAssessorTimePeriod() {
    my ($self, $args) = @_;
	$course = HSDB45::Course->new(_school => $self->{school_id})->lookup_key(
        $self->{course_id});
    my $users = $course->users($self->{current_time_period}, "course_user.course_user_id = $args->{assessor_id}");
    warn "Users related information is " . scalar @$users;
    warn "Course id is " . $course->getTuskCourseID();
}

1;