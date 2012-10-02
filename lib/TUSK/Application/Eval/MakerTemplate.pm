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


package TUSK::Application::Eval::MakerTemplate;


use TUSK::Core::CourseCode;
use TUSK::Core::School;
use TUSK::Eval::Prototype;
use TUSK::Constants;
use TUSK::Core::HSDB45Tables::LinkCourseStudent;
use TUSK::Core::HSDB45Tables::LinkCourseTeachingSite;
use HSDB4::DateTime;
use HSDB45::TeachingSite;
use HSDB45::Eval;
use HSDB45::Course;
use HSDB45::TimePeriod;


sub new {
    my ($class, $args) = @_;
    my $tp;

    eval {
	$tp = HSDB45::TimePeriod->new( _school => $args->{school})->lookup_key($args->{time_period_id});
    };

    unless (defined $tp) {
	die "Invalid Input: time_period id=$args->{time_period_id}, School=$args->{school}\n";
    }

    my $school = TUSK::Core::School->new()->lookupReturnOne("school_name = '" . $args->{school} . "'");
    my $self = { 
		school            => $school,
		period            => $tp->field_value('period'),
		academic_year     => $tp->field_value('academic_year'),
		time_period       => $tp,
		prototype_evals   => _setPrototypeEvals($school),
    };

    return bless $self, $class;
}

sub _setPrototypeEvals {
    my $school = shift;
    my $prototypes = TUSK::Eval::Prototype->lookup("school_id = " . $school->getPrimaryKeyID());
    
    my %hash = map { $_->getCourseCode() => $_ } @$prototypes;
    return \%hash;
}

sub getPrototypeEvalID {
    my ($self, $course_code) = @_;

    ## first try, an exact match
    return $self->{prototype_evals}->{$course_code}->getEvalID() if ($self->{prototype_evals}->{$course_code});

	## second try, see if there's a non-exact match
	while (my ($code => $proto) = each(%{$self->{prototype_evals}})) {
		if ($proto->getExactMatch() == "N" && $course_code =~ $code) {
			return $proto->getEvalID();
		}
	}

    ## otherwise return empty string
    return "";
}

sub getSchool {
    my $self = shift;
    return $self->{school};
}

sub getTimePeriod {
    my $self = shift;
    return $self->{time_period};
}

sub getPeriod {
    my $self = shift;
    return $self->{period};
}

sub getAcademicYear {
    my $self = shift;
    return $self->{academic_year};
}

sub getCourse {
    my $self = shift;
    return $self->{course};
}

sub getCourseCode {
    my $self = shift;
    return $self->{course_code};
}

### retrieve list of records by course_id, teaching_site_id and time_period_id
sub getCoursesInfoBySite {
    my $self = shift;
    my $dbname = $self->{school}->getSchoolDb();
    my $school_id = $self->{school}->getPrimaryKeyID();
	my $tp_id = $self->{time_period}->primary_key();
	my @courses;

	my $sql = qq(
		SELECT a.parent_course_id, title, code, a.teaching_site_id, site_name,
			(SELECT group_concat(concat(firstname, ' ', lastname) SEPARATOR '; ') 
			FROM $dbname.link_course_user cs, hsdb4.user u
			WHERE cs.child_user_id = u.user_id and a.parent_course_id = cs.parent_course_id and roles in ('Director')
			GROUP BY parent_course_id)
		as faculty_name, 
			(SELECT count(*) 
			FROM $dbname.eval e 
			WHERE parent_course_id = e.course_id AND e.time_period_id = $tp_id AND a.teaching_site_id = e.teaching_site_id) 
		as evalcount
		FROM $dbname.link_course_student a 
		LEFT OUTER JOIN tusk.course_code as b
		on (b.course_id = a.parent_course_id and a.teaching_site_id = b.teaching_site_id and school_id = $school_id) 
		INNER JOIN $dbname.course as c on (c.course_id = a.parent_course_id)
		LEFT OUTER JOIN $dbname.teaching_site as d on (d.teaching_site_id = a.teaching_site_id)
		WHERE time_period_id = $tp_id
		GROUP BY a.parent_course_id, a.teaching_site_id ORDER BY evalcount ASC
	);

	my $sth = $self->{school}->databaseSelect($sql);
	my $results = $sth->fetchall_arrayref();
	$sth->execute();

    while (my ($course_id, $title, $code, $site_id, $site_name, $faculty_name, $eval_exists) = $sth->fetchrow_array) {
		my $codes = TUSK::Core::CourseCode->new()->lookup("code = '" . $code . "' and school_id = " . $school_id);
		if (scalar @{$codes} && $self->_isSingleCourse($codes) && $site_id) {
			push(@courses, {'course_id' => $course_id, 'course_title' => $title, 'course_code' => $code, 'teaching_site_id' => $site_id, 'teaching_site_name' => $site_name, 'faculty_names' => $faculty_name, 'eval_exists' => $eval_exists});
		}
	}
	
	return \@courses;
}

### retrieve list of records by course_id and time_period_id
sub getCoursesInfoByCourse {
    my $self = shift;
    my $dbname = $self->{school}->getSchoolDb();
    my $school_id = $self->{school}->getPrimaryKeyID();
	my $tp_id = $self->{time_period}->primary_key();
	my @courses;

	my $sql = qq(
		SELECT courses.course_id, title, code, evalcount FROM (SELECT course_id, title, (SELECT count(*)
					FROM $dbname.eval e
					WHERE c.course_id = e.course_id AND e.time_period_id = $tp_id)
				as evalcount
			FROM $dbname.link_course_student, $dbname.course c 
			WHERE time_period_id = $tp_id AND parent_course_id = course_id GROUP BY course_id) as courses
		LEFT OUTER JOIN tusk.course_code ON courses.course_id = tusk.course_code.course_id AND school_id = $school_id
		GROUP BY course_id ORDER BY evalcount ASC
	);

	my $sth = $self->{school}->databaseSelect($sql);
	my $results = $sth->fetchall_arrayref();
	$sth->execute();

    while (my ($course_id, $title, $code, $eval_exists) = $sth->fetchrow_array) {
		push(@courses, {'course_id' => $course_id, 'course_title' => $title, 'eval_exists' => $eval_exists, 'course_code' => $code});
	}
	
	return \@courses;
}

sub setCourse {
    my ($self,$course_code) = @_;

    ## lookup the course_id based on the SubjectCode
    my ($course, $codes);
    my $school = $self->{school}->getSchoolName();
    if ($school eq 'Medical' && $course_code =~ /^FAM\d{3}$/ && $course_code !~ /FAM4(87|88|99)/) {
		$course = HSDB45::Course->new(_school => "Medical")->lookup_key(370);    
    } 
	elsif ($school eq 'Medical' && $course_code =~ /^NEU\d{3}$/){
		$course = HSDB45::Course->new(_school => "Medical")->lookup_key(2215);
	}
	else {
		$codes = TUSK::Core::CourseCode->new()->lookup("code = '$course_code' and school_id = " . $self->{school}->getPrimaryKeyID());
		if (@{$codes} > 1) {
		    unless ($self->_isSingleCourse($codes)) {
				return undef;
			}
		}
		$course = HSDB45::Course->new(_school => $school)->lookup_key($codes->[0]->getCourseID());    
    }
    
    $self->{course} = (defined $course->field_value('course_id')) ? $course : undef;
    $self->{course_code} = $course_code; 
    $course_code =~ s/.+?(\d\d+)/$1/;
    $self->{course_level} = $course_code;
}

sub _isSingleCourse {
    my ($self, $codes) = @_;
    my %saw = ();
    my @uniqs = grep(!$saw{$_}++, map {$_->getCourseID()} @{$codes});

    return (scalar @uniqs == 1) ? 1 : 0;
}

sub getCourseLevel {
    my ($self, $code) = @_;
    return $self->{course_level};
}

sub setTeachingSite {
    my ($self, $teaching_site) = @_;
    $self->{teaching_site} = $teaching_site;
}

sub getTeachingSite {
    my $self = shift;
    return $self->{teaching_site};
}

sub getCourseCodes {
    my $self = shift;
    my $dbname = $self->{school}->getSchoolDb();
    my $school_id = $self->{school}->getPrimaryKeyID();
    my $time_period_id = $self->{time_period}->primary_key();
    my $dbh = HSDB4::Constants::def_db_handle();
	my $codes;

	my $statement = qq(
			select distinct code 
			from tusk.course_code a, $dbname.link_course_student b 
			where a.course_id = b.parent_course_id 
			and time_period_id = $time_period_id
			and school_id = $school_id
		   );
	$codes = $dbh->selectall_arrayref($statement);

	return $codes;
}

sub evalExists {
    my $self = shift;
    my $blank_eval = HSDB45::Eval->new(_school => $self->getSchool()->getSchoolName());
    my @cur_evals = ();

    return 0 unless (defined $self->{course} && defined $self->{time_period});

    my $statement = (ref $self->{teaching_site} eq 'HSDB45::TeachingSite' && $self->{teaching_site}->primary_key()) ? " teaching_site_id = " . $self->{teaching_site}->primary_key() : " (teaching_site_id is NULL or teaching_site_id = 0)";

    @cur_evals = $blank_eval->lookup_conditions(
		"course_id = " . $self->{course}->primary_key()
		. " AND time_period_id = " . $self->{time_period}->primary_key() 
		. " AND  $statement");

    return @cur_evals;
}


1;
