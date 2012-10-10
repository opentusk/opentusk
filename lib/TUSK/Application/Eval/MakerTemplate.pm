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
	prototype_eval_id => _setPrototypeEvalID($school),
    };

    return bless $self, $class;
}


sub _setPrototypeEvalID {
    my $school = shift;

    my $prototypes = TUSK::Eval::Prototype->new()->lookup("school_id = " . $school->getPrimaryKeyID());
    my %hash = map { $_->getCourseCode() => $_->getEvalID() } @$prototypes;
    return \%hash;
}

sub getPrototypeEvalID {
    my $self = shift;
    my $proto = $self->{prototype_eval_id};

    ## first try
    return $proto->{$self->{course_code}} if ($proto->{$self->{course_code}});
    ## second try
    my $special_case = substr($self->{course_code}, 0, 4);
    return $proto->{$special_case} if ($proto->{$special_case});
    ## finally
    return $proto->{DEFAULT};
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


sub getAllTeachingSites {
    my $self = shift;

    my $codes = TUSK::Core::CourseCode->new()->lookup(
      "code = '" . $self->{course_code} 
      . "' AND school_id = " . $self->{school}->getPrimaryKeyID()
      . " AND teaching_site_id in (select teaching_site_id from " 
      . $self->getSchool()->getSchoolDb() 
      . ".link_course_student where parent_course_id = " 
      . $self->{course}->field_value('course_id')
      . " and time_period_id = " . $self->{time_period}->primary_key() . ')'); 
      

    if (@{$codes} > 1) {
	return undef unless $self->_isSingleCourse($codes);
    } 

    ### 4th year, one teaching site. set to null/undef if more than one teaching site
    ### 3rd year, multiple teaching sites
    if ($self->{course_level} =~ /4\d\d/) {
	return (defined $codes && @{$codes} == 1) 
	    ? [ HSDB45::TeachingSite->new(_school => $self->{school}->getSchoolName())->lookup_key($codes->[0]->getTeachingSiteID()) ] 
	    : undef;
    } elsif ($self->{course_level} =~ /3\d\d/) {
	my @teaching_sites = ();
	if (defined $codes) {
	    foreach (@$codes) {
		my $ts = HSDB45::TeachingSite->new(_school => $self->{school}->getSchoolName())->lookup_key($_->getTeachingSiteID());
		push @teaching_sites, $ts if $ts->primary_key();
	    }
	    return \@teaching_sites;
	}
    } else {
	warn "Unexpected Course Level for: ", $self->{course_code}, " ($self->{course_level})\n";
	return undef;
    } 
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

=head
    my $statement = qq(
		       select code 
		       from tusk.course_code a, $dbname.link_course_student b 
		       where a.course_id = b.parent_course_id 
		       and time_period_id = $time_period_id 
		       and school_id = $school_id and parent_course_id != 370 
		       UNION 
		       select code 
		       from tusk.course_code a, $dbname.link_course_student b 
		       where a.course_id = b.parent_course_id 
		       and a.teaching_site_id = b.teaching_site_id 
		       and time_period_id = $time_period_id 
		       and school_id = $school_id and parent_course_id = 370 
		       );

=cut

	 my $statement = qq(
		       select code 
		       from tusk.course_code a, $dbname.link_course_student b 
		       where a.course_id = b.parent_course_id 
		       and time_period_id = $time_period_id 
		       and school_id = $school_id and parent_course_id != 370 and course_id != 2215
		       UNION
		       select code 
		       from tusk.course_code a, $dbname.link_course_student b 
		       where a.course_id = b.parent_course_id 
		       and a.teaching_site_id = b.teaching_site_id 
		       and time_period_id = $time_period_id 
		       and school_id = $school_id and parent_course_id = 370 
			   UNION
		       select code 
		       from tusk.course_code a, $dbname.link_course_student b 
		       where a.course_id = b.parent_course_id 
		       and a.teaching_site_id = b.teaching_site_id 
		       and time_period_id = $time_period_id 
		       and school_id = $school_id and course_id = 2215
		       ); 
    my $codes = $dbh->selectall_arrayref($statement);
    return $codes;

}


sub getEvalTitle {
    my $self = shift;
    my $eval_title;
    my $site_name = (defined $self->{teaching_site}) ? $self->{teaching_site}->site_name() : undef;
    my $course_title = $self->getCourse()->out_label();
    my $ay = $self->getAcademicYear();
    my $period = $self->getPeriod();

    if ($self->{course_level} =~ /3\d\d/) {
	$eval_title = "$course_title Evaluation Block $period,";
	$eval_title .= (defined $site_name) ? "$site_name," : '';
	$eval_title .= $ay;
    } else {
   	if ($self->{course_code} =~ /FAM4/ && $self->{course_code} !~ /FAM4(87|88|99)/) {
	    $eval_title = "Family Medicine Clerkship Evaluation - AY $ay - Block $period";
	    $site_name =~ s/Family Practice - // if defined $site_name;
	} elsif ($self->{course_code} =~ /NEU4/) {
	    $eval_title = "Neurology Clerkship Evaluation - AY $ay - Block $period - $course_title";

	} else {
	    $eval_title = "Fourth Year Subinternship (Ward) Evaluation - AY $ay - Block $period - $course_title";
	}

	$eval_title .= " - $site_name" if (defined $site_name);

	## add user's names except family medicine courses
	unless ($self->{course_code} =~ /FAM\d{3}/ && $self->{course_code} !~ /FAM4(87|88|99)/) {
	    $eval_title .= " - " . join(", ",map { $_->out_short_name } $self->{course}->child_users()) if ($self->{course}->child_users());
	}
    }
    return $eval_title;
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


## Take care of teaching sites in course_code and link_course_teaching_site. 
## Some courses in link_course_student have teaching site ids but course_code 
## and link_course_teaching_site don't
sub sync_teaching_sites {
    my $self = shift;

    my $username = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};
    my $codes = TUSK::Core::CourseCode->new()->lookup("teaching_site_id = 0 and course_id in (select parent_course_id from " . $self->getSchool()->getSchoolDb() . ".link_course_student where time_period_id = " . $self->{time_period}->primary_key() . ") and school_id = " . $self->getSchool()->getPrimaryKeyID());

    foreach my $code (@{$codes}) {
	my $coursestudent = TUSK::Core::HSDB45Tables::LinkCourseStudent->new();
	$coursestudent->setDatabase($self->getSchool()->getSchoolDb());
	my $links = $coursestudent->lookup("parent_course_id = " . $code->getCourseID() . " and time_period_id = " . $self->{time_period}->primary_key());
	if (scalar @{$links} == 1) {
	    $code->setTeachingSiteID($links->[0]->getFieldValue('teaching_site_id'));
	    $code->save({ user => $username });

	    my $courseteachingsite = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new();
	    $courseteachingsite->setDatabase($self->getSchool()->getSchoolDb());
	    my $ct_link = $courseteachingsite->lookupReturnOne("parent_course_id = " . $code->getCourseID() . " AND child_teaching_site_id = " . $links->[0]->getFieldValue('teaching_site_id'));
	    unless ($ct_link) {
		$courseteachingsite->setFieldValues( {
		    parent_course_id  => $code->getCourseID(),
		    child_teaching_site_id  => $links->[0]->getFieldValue('teaching_site_id'),
		 });
		$courseteachingsite->save({ user => $username });
	    }
	} else {
	    push @{$self->{ts_sync_errors}}, $code->getCode() . ' [' . $code->getCourseID() . ']';
	}
    }
}


sub getTeachingSiteSyncErrors {
    my $self = shift;
    return $self->{ts_sync_errors};
}


1;
