package TUSK::Import::CourseRole;

use strict;
use base qw(TUSK::Import);
use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::Course;
use HSDB45::LDAP;

sub new {
    my ($class,$school) = @_;
    $class = ref $class || $class;
    my $self = $class->SUPER::new();
    $self->{_school} = $school || die "must specify school";
    $self->set_fields(qw(CourseNum CourseKey FirstName MiddleName LastName ContactKey
			 SortOrder Site SiteCode SiteCity SiteState));
    return $self;
}

sub get_school {
    my $self = shift;
    return $self->{_school};
}

sub process_data {
    my ($self,$auth_user,$auth_passwd,$code,$commit) = @_;
    $self->grep_records("CourseNum","(".join("|",split(",",$code)).")",1) if ($code);
    $self->add_log("summary","test run, records will not be created") unless ($commit);
    ## before processing the records, pre-process the data (expanding, replacing etc)
    $self->_preprocess_data;
    my $ok = 0;
    my $bad = 0;
    my (%course_id_list,%course_user_id_list);
    foreach my $record ($self->get_records) {
	next if ($record->get_field_value("CourseNum") =~ /CourseNum/);
next if ($record->get_field_value("CourseNum") =~ /MPH/);
next if ($record->get_field_value("CourseNum") =~ /MBA/);
	$self->add_log("record",$record->get_field_value("CourseNum")." - ".$record->get_field_value("FirstName")." ".$record->get_field_value("LastName"));
	my $user_id = $self->_get_user_id($record->get_field_value("ContactKey"),$record->get_field_value("FirstName"),$record->get_field_value("LastName"));
	if (!$user_id) {
	    $bad++;
	    next;
	}
	$self->add_log("message","user_id is $user_id");
	my ($oea_code,$loc) = split("-",$record->get_field_value("CourseNum"));
	my $course = $self->_get_course($oea_code);
	if (!$course) {
	    $self->add_log("error","can't find course based on oea_code: ".$oea_code);
	    $bad++;
	    next;
	}
	$self->add_log("message","course_id is ".$course->primary_key);
	my @course_users = $course->child_users;
	$self->add_log("message",scalar @course_users ? scalar @course_users." existing course user(s) ".join(", ", map { $_->primary_key } @course_users) : "no existing course users");
	unless ($course_id_list{$course->primary_key}) {
	    ## unless this course has been in the list before we need to delete the relationships
	    $self->add_log("message","delete course users") if ($commit);
	    $course->delete_all_users($auth_user,$auth_passwd) if ($commit);
	}

	## add course users
	$self->add_log("message","$user_id added as course director") if ($commit);
	$course->add_child_user($auth_user,$auth_passwd,$user_id,"",0,"Director") if (($commit) && !$course_user_id_list{$course->primary_key.$user_id});	
	$course_id_list{$course->primary_key}++;
	$course_user_id_list{$course->primary_key.$user_id}++;
	$ok++;
    }
    $self->add_log("summary","$ok records complete, $bad records failed");
}

sub _get_user_id {
    my ($self,$contact_key,$first,$last) = @_;
    my $dbh = HSDB4::Constants::def_db_handle;
    my $sql = "select user_id,contact_key_id from link_user_contact_key where contact_key_id = $contact_key and school = '".$self->get_school."'";
    my ($user_id,$key) = $dbh->selectrow_array($sql);
    unless ($user_id) {
	my $msg = "user_id not found for ContactKey $contact_key ($first $last)";
	if (!$key) {
	    my @users = HSDB4::SQLRow::User->new->lookup_conditions("firstname='"._dbh_quote($first)."'","lastname='"._dbh_quote($last)."'");
	    my ($sth,$uid);
	    if (scalar @users == 1) {
		$uid = $users[0]->primary_key;
		$sth = $dbh->prepare("insert into link_user_contact_key set contact_key_id=?,fullname=?,school=?,user_id=?");
		$sth->execute($contact_key,$first." ".$last,$self->get_school,$uid);
		$msg .= " - $uid seems to match, will use";
		$self->add_log("warning",$msg);
		$user_id = $uid;
	    }
	    else {
		$sth = $dbh->prepare("insert into link_user_contact_key set contact_key_id=?,fullname=?,school=?");
		$sth->execute($contact_key,$first." ".$last,$self->get_school);
		$self->add_log("error",$msg);
	    }
	}
    }
    my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);
    return $user->primary_key if ($user->primary_key);
}

sub _get_course {
    my ($self,$code) = @_;
    return unless $code;
    my $course = HSDB45::Course->new(_school => $self->get_school);
    my @courses = $course->lookup_conditions("oea_code = '$code'");
    return $courses[0] if scalar @courses == 1;
}

sub _preprocess_data {
    my $self = shift;
}

sub _dbh_quote {
    my $field = shift;
    $field =~ s/'/''/g;
    return $field;
}

1;













