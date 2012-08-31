package TUSK::Import::EnrollListing;

use strict;
use base qw(TUSK::Import);
use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::Course;
use HSDB45::Eval;
use HSDB4::DateTime;
use vars qw(%site_map);

# a mapping to help us figure out differences between
# the school's naming of a site an ours
my %site_map = ("MetroWest" => "MetroWest Medical Center",
		"Metro West" => "MetroWest Medical Center",
		"St. Elizabeth's" => "St. Elizabeth's Medical Center",
		"Newton-Wellesley" => "Newton-Wellesley Hospital",
		"NEMC/INPATIENT" => "New England Medical Center Inpt",
		"NEMC/CONSULT" => "New England Medical Center C/L",
		"St. Anne's" => "St. Anne's Hospital",
		"Lemuel Shattuck" => "Lemuel Shattuck Hospital",
		"Cambridge City Hospital" => "Cambridge Hospital",
		"Faulkner" => "Faulkner Hospital",
		"Winchester" => "Winchester Hospital",
		);

sub new {
    my ($class,$school,$period) = @_;
    $class = ref $class || $class;
    my $self = $class->SUPER::new();
    $self->{_school} = $school || die "must specify school";
    $self->{_period} = $period || die "must specify time period";
    $self->set_fields(qw(SocSecNum LastName FirstName MiddleName 
			 AcademicYear SchClassYear CrsPeriod 
			 CrsStartDate CrsEndDate SubjectCode 
			 CourseKey Description CourseDirector Site AddDate UTLN));
    return $self;
}

sub get_period {
    my $self = shift;
    return $self->{_period};
}

sub get_school {
    my $self = shift;
    return $self->{_school};
}

sub process_data {
    my ($self,$un,$pw,$oea_code,$commit) = @_;
    $self->add_log("summary","test run, records will not be created") unless ($commit);
    unless ($self->get_period && $un && $pw) {
	$self->add_log("error","must specify time period(s)");
	return;
    }
    my @periods = split(",",$self->get_period);
    $self->grep_records("CrsPeriod","(".join("|",@periods).")");
    $self->grep_records("SubjectCode",$oea_code) if ($oea_code);
    ## before processing the records, pre-process the data (expanding, replacing etc)
    $self->_preprocess_data;

    $self->add_log("summary","Found ".scalar $self->get_records." records with time period ".join(", ",@periods));

    foreach my $record ($self->get_records) {
	$self->add_log("record",$record->get_field_value("UTLN")." - ".$record->get_field_value("SubjectCode")." - ".$record->get_field_value("Site"));
	my $user_id = $record->get_field_value("UTLN");

	## check for valid UTLN
	unless ($self->_check_user_id($user_id)) {
	    $self->add_log("error","cannot find user -".$user_id."-");
	    next;
	}

	## check for valid course_id
	my $course;
	unless ($course = $self->_check_course($record->get_field_value("SubjectCode"))) {
	    $self->add_log("error","check existence and uniqueness of code ".$record->get_field_value("SubjectCode"));
	    next;
	}

	## get the time period
	my $time_period = $self->_get_time_period($record->get_field_value("CrsPeriod"));

	## get the time period id
	my $time_period_id;
	unless ($time_period_id = $self->_get_time_period_id($time_period,$record->get_field_value("AcademicYear"))) {
	    $self->add_log("error","could not find time_period_id for $time_period in ay ".$record->get_field_value("AcademicYear"));
	    next;
	}

	my $site;
	unless ($site = $self->_get_teaching_site($course,$record->get_field_value("Site"))) {
	    $self->add_log("error","check existence and uniqueness of site ".$record->get_field_value("Site"));
	    next;
	}

	if ($commit) {
	    ## link the course to the user
	    my ($r,$msg) = $self->_link_course_student($un,$pw,$course,$user_id,$time_period_id,$site);
	    if ($r) {
		$self->add_log("message","added $user_id to course: ".$course->out_label);
	    }
	    else {
		$self->add_log("warning",$msg);
	    }
	    ## create the eval
	    my $eval_id;
	    ($eval_id,$msg) = $self->_create_eval($un,$pw,$record,$course,$time_period_id,$site);
	    $self->add_log("error",$msg) unless ($eval_id);
	    $self->add_log("message","eval $eval_id $msg") if ($eval_id);	    
	}
    }
}

sub _check_user_id {
    my $self = shift;
    my $user_id = shift;
    my $user = HSDB4::SQLRow::User->new;
    $user->lookup_key($user_id);
    return $user->primary_key;
}

sub _check_course {
    my $self = shift;
    my $oea_code = shift;
    ## lookup the course_id based on the SubjectCode
    my $course = HSDB45::Course->new(_school => $self->get_school);    
    my @set = $course->lookup_conditions("oea_code='$oea_code'");
    # log and return 0 if no records found or more then one record found
    return if (!@set);
    return if (@set > 1);
    return $set[0];
}

sub _get_course_level {
    my $self = shift;
    my $code = shift;
    $code =~ s/.+?(\d\d+)/$1/;
    return $code;
}

sub _get_time_period {
    my $self = shift;
    my $time_period = shift;
    $time_period =~ s/^0(.+)/$1/;
    return unless ($time_period =~ /\d/);
    return $time_period;
}

sub _get_time_period_id {
    my $self = shift;
    my $time_period = shift;
    my $ay = shift;
    my $timeref = HSDB45::TimePeriod->new( _school => $self->get_school );
    my @set = $timeref->lookup_conditions("period='$time_period' AND academic_year='$ay'");
    return unless (@set);
    return if (@set > 1);
    return $set[0]->field_value('time_period_id');
}

sub _get_start_end_dates {
    my $self = shift;
    my $course_level = shift;
    my $end_date = shift;
    $end_date =~ s/\/(\d\d)$/\/20$1/;
    my $days_before = 2;
    my $days_after = 12;
    $days_before = 4 if ($course_level =~ /3\d\d/);
    $days_after = 10 if ($course_level =~ /3\d\d/);	

    my $timeref_start = HSDB4::DateTime->new;
    my $epoch_start = $timeref_start->in_mysql_date($timeref_start->m_d_yyyy_to_yyyy_mm_dd($end_date));
    $timeref_start->subtract_days($days_before);
    $epoch_start = $timeref_start->out_mysql_date();

    my $timeref_end = HSDB4::DateTime->new;
    my $epoch_end = $timeref_end->in_mysql_date($timeref_end->m_d_yyyy_to_yyyy_mm_dd($end_date));
    $timeref_end->add_days($days_after);
    $epoch_end = $timeref_end->out_mysql_date();
	
   return ($epoch_start, $epoch_end);
}

sub _get_teaching_site {
    my $self = shift;
    my $course = shift;
    my $site_name = shift;
    $site_name = $site_map{$site_name} if ($site_map{$site_name});
    my @course_sites = $course->child_teaching_sites;
    return $course_sites[0] if (scalar @course_sites == 1);
    return unless ($site_name);
    @course_sites = grep { $_->field_value("site_name") eq $site_name } @course_sites;
    return $course_sites[0] if (scalar @course_sites == 1);
    my $teaching_site = HSDB45::TeachingSite->new(_school => $self->get_school);
    $site_name =~ s/\'/\'\'/g;
    my @sites = $teaching_site->lookup_conditions("site_name='$site_name'");
    return unless (@sites);
    return if (@sites > 1);
    return $sites[0];
}

sub _link_course_student {
    my $self = shift;
    my ($un,$pw,$course,$user_id,$tpid,$site) = @_;
    ## lets do a lookup first
    return (0,"$user_id is already in course: ".$course->out_label."(".$site->out_label.", time period $tpid)") if ($course->is_user_registered($user_id,$tpid,$site->primary_key));

    my $db = HSDB4::Constants::get_school_db($self->get_school);
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_student"};    
    my ($r,$msg) = $linkref->insert(-user => $un,
				    -password => $pw,
				    -parent_id => $course->primary_key,
				    -child_id => $user_id,
				    time_period_id => $tpid,
				    teaching_site_id => $site->primary_key);
    return ($r,$msg);
}

sub _create_eval {
    my ($self,$un,$pw,$record,$course,$time_period_id,$site) = @_;
    return (0,"Problem creating eval: missing parameters") unless ($un && $pw && $record && $course && $time_period_id && $site);

    ## set course level
    my $course_level = $self->_get_course_level($record->get_field_value("SubjectCode"));
    my $course_title = $course->out_label;
    my $course_code = $record->get_field_value("SubjectCode");
    ## get start and end dates in MySQL format
    my ($start_date,$end_date) = $self->_get_start_end_dates($course_level,$record->get_field_value("CrsEndDate"));

    my $ay = $record->get_field_value("AcademicYear");
    my $time_period = $self->_get_time_period($record->get_field_value("CrsPeriod"));
    my $description = $record->get_field_value("Description");
    my $site_name;
    if ($record->get_field_value("Site") =~ /(Family\ Practice\ Site|Primary\ Care\ Site|Private\ Practice)/) {
	$site_name = $site->site_city_state;
    }
    else {
	$site_name = $site->site_name;
    }
    my $prototype_eval_id;
    my $eval_title;
    if ($course_level =~ /3\d\d/) {
	my %third_year_prototype_eval;
	# put the third year prototype eval id into a hash to be used below
	$third_year_prototype_eval{"PSY300"}=8359; 
	$third_year_prototype_eval{"PED300"}=8358; 
	$third_year_prototype_eval{"OBG300"}=8357; 
        $third_year_prototype_eval{"MED300"}=8360; 
	$third_year_prototype_eval{"SGN300"}=8356; 

	my $block_abbrev = $time_period;
	$block_abbrev =~ s/(.).+/$1/;
	$eval_title = "$course_title Evaluation Block $time_period, $site_name, $ay";
	$prototype_eval_id = $third_year_prototype_eval{$course_code};
    } else {
	# this is a 4th year course
   	# figure out the prototype eval id for a 4th year course
   	if ($course_code =~ /FAM4/ && $description !~ /subinternship/i) {
	    $prototype_eval_id = 8385;
	    $eval_title = "Family Medicine Clerkship Evaluation - AY $ay - Block $time_period - $site_name";
	} elsif ($course_code =~ /NEU4/) {
	    $prototype_eval_id = 6154;
	    $eval_title = "Fourth Year Elective Evaluation - AY $ay - Block $time_period - $course_title - $site_name";
	} else {
	    $prototype_eval_id = 2243;
	    $eval_title = "Fourth Year Elective Evaluation - AY $ay - Block $time_period - $course_title - $site_name";
	}
	## add user's names
	$eval_title .= " - ".join(", ",map { $_->out_short_name } $course->child_users) if ($course->child_users);
    }

    return (0,"Prototype eval not found") unless ($prototype_eval_id);

    ## check existing evals, return if it alread exists
    my $blank_eval = HSDB45::Eval->new(_school => $self->get_school);
    my @cur_evals = $blank_eval->lookup_conditions("course_id = ".$course->primary_key,
						   "time_period_id=".$time_period_id,
						   "teaching_site_id=".$site->primary_key);
    return (0,"More than one eval already exists") if (@cur_evals > 1);
    return ($cur_evals[0]->primary_key,"exists: $eval_title") if (@cur_evals);
		
    ## insert 1 record into eval & link to questions
    my $evalref = HSDB45::Eval->new( _school => $self->get_school );
    $evalref->set_field_values(course_id => $course->primary_key,
			       time_period_id => $time_period_id,
			       teaching_site_id => $site->primary_key,
			       title => $eval_title,
			       available_date => $start_date,
			       due_date => $end_date);
    my ($r,$msg)=$evalref->save($un,$pw);
    my $eval_id = $r;
    
    my $db = HSDB4::Constants::get_school_db($self->get_school);
    HSDB4::Constants::set_user_pw($un,$pw);
    my $dbh = DBI->connect(HSDB4::Constants::db_connect());					
    # insert the correct eval questions
    my $ins = $dbh->prepare ("INSERT INTO $db\.link_eval_eval_question (parent_eval_id,child_eval_question_id,label,sort_order,required,grouping,graphic_stylesheet) VALUES (?, ?, ?, ?, ?, ?, ?)");
    my $sel = $dbh->prepare ("SELECT child_eval_question_id, label, sort_order, required, grouping, graphic_stylesheet FROM $db\.link_eval_eval_question WHERE parent_eval_id=$prototype_eval_id");
    $sel->execute();
    while (my ($qid, $lab, $sort, $req, $group, $style) = $sel->fetchrow_array ) {
	$ins->execute($eval_id, $qid, $lab, $sort, $req, $group, $style);
	if ($@) {
	    $self->add_log("error","Linking of eval questions failed: $@");
	}
    }
    $dbh->disconnect if ($dbh);
    HSDB4::Constants::set_user_pw("","");
    return ($eval_id,"created: $eval_title");
}

sub _preprocess_data {
    my $self = shift;
    # we want to create a new list of records, because we'll be potentially inserting some new records in and want them to follow the original record
    my @reordered_records;
    ## loop over records and find anything with a site of NEMC/*
    foreach my $record ($self->get_records) {
	## foreach NEMC/* create two records, one with site NEMC, the other with site *
	if ($record->get_field_value("Site") =~ /NEMC\/(Faulkner|Winchester)/) {
	    my $second_site = $record->get_field_value("Site");
	    $record->set_field_value("Site","New England Medical Center");
	    push(@reordered_records,$record);
	    $second_site =~ s/NEMC\/(.+?)\ .+/$1/;
	    my $new_record = $record->clone;
	    $new_record->set_field_value("Site",$site_map{$second_site});
	    push(@reordered_records,$new_record);
	} elsif ($record->get_field_value("Site") =~ /St\.\ Elizabeth\'s/ && $record->get_field_value("SubjectCode") =~ /PED300/) {
	    push(@reordered_records,$record);
	    my $new_record = $record->clone;
	    $new_record->set_field_value("Site","Boston Floating Hospital");
	    push(@reordered_records,$new_record);
	} else {
	    push(@reordered_records,$record);
	}
    }
    $self->clear_records;
    $self->push_record(@reordered_records);    
}

1;













