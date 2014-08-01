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


package TUSK::Session;

use strict;
use HSDB45::Course;

my %courseroles = (
    'DIRECTORNONSTUDENT' => "80",
    'DIRECTOR' => "50",
    'SITEDIRECTOR' => "40",
    'AUTHOR' => "20",
    'STUDENTEDITOR' => "10"
    );

sub get_role{
    my ($role) = @_;
    return $courseroles{$role};
}

sub course_user_role{
    my ($course, $user_id) = @_;

    if ($course->user_has_role($user_id, ['director', 'manager'])) {
	return $courseroles{'DIRECTORNONSTUDENT'};
    } elsif ($course->user_has_role($user_id, ['student_manager'])) {
	return $courseroles{'DIRECTOR'};
    } elsif ($course->user_has_role($user_id, ['site_director'])) {
	return $courseroles{'SITEDIRECTOR'};
    } elsif ($course->user_has_role($user_id, ['author', 'editor'])) {
	return $courseroles{'AUTHOR'};
    } elsif ($course->user_has_role($user_id, ['student_editor'])) {
	return $courseroles{'STUDENTEDITOR'};
    } else {
	return 0;
    }
}

sub check_course_permissions{
    my ($courserole, $minrole) = @_;
    my $key = uc($minrole);

    return 0 unless ($courseroles{$key});
    return ($courserole >= $courseroles{$key});
}

sub is_director{
    my ($course, $user_id) = @_;
    return (course_user_role($course, $user_id) == $courseroles{DIRECTORNONSTUDENT});
}

sub is_admin{
    my ($hash, $user) = @_;

    if ($user){
	unless (defined($hash->{roles}) and scalar keys %{$hash->{roles}->{tusk_session_admin}}){
	    $hash->{roles} = $user->check_admin;
	}
    }    

    return (defined($hash->{roles}->{tusk_session_admin})) ? scalar keys %{$hash->{roles}->{tusk_session_admin}} : 0;

}

sub is_school_admin{
    my ($hash, $school, $user) = @_;

    if ($user){
	unless (defined($hash->{roles}) and scalar keys %{$hash->{roles}->{tusk_session_admin}}){
	    $hash->{roles} = $user->check_admin;
	}
    }

    if (defined($hash->{roles}->{tusk_session_admin}->{$school})) {
	return($hash->{roles}->{tusk_session_admin}->{$school});
    } elsif (defined($hash->{roles}->{tusk_session_admin}->{lc($school)})) {
	return($hash->{roles}->{tusk_session_admin}->{lc($school)});
    } elsif(defined($hash->{roles}->{tusk_session_admin}->{uc($school)})) {
	return($hash->{roles}->{tusk_session_admin}->{uc($school)});
    } else {
	return(0);
    }
}

sub is_author{
    my ($hash, $user) = @_;

    if ($user){
	unless (defined($hash->{roles}) and defined($hash->{roles}->{tusk_session_is_author})){
	    $hash->{roles} = $user->check_author($hash->{roles});
	}
    }

    return ($hash->{roles}->{tusk_session_is_author}) if (defined($hash->{roles}) or defined($hash->{roles}->{tusk_session_is_author}));
}

sub is_eval_admin{
    my ($hash, $user) = @_;

    if ($user){
	unless (defined($hash->{roles}) and scalar keys %{$hash->{roles}->{tusk_session_eval_admin}}){
		$hash->{roles} = $user->check_admin;
	}
    }

    return (defined($hash->{roles}->{tusk_session_eval_admin})) ? scalar keys %{$hash->{roles}->{tusk_session_eval_admin}} : 0;
}

sub is_school_eval_admin {
    my ($hash, $school, $user) = @_;
	
    if ($user) {
	unless (defined($hash->{roles}) and scalar keys %{$hash->{roles}->{tusk_session_eval_admin}}){
	    $hash->{roles} = $user->check_admin;
	}
    }
    
    if (defined($hash->{roles}->{tusk_session_eval_admin}->{$school})) {
	return($hash->{roles}->{tusk_session_eval_admin}->{$school});
    } elsif(defined($hash->{roles}->{tusk_session_eval_admin}->{lc($school)})) {
	return($hash->{roles}->{tusk_session_eval_admin}->{lc($school)});
    } elsif(defined($hash->{roles}->{tusk_session_eval_admin}->{uc($school)})) {
	return($hash->{roles}->{tusk_session_eval_admin}->{uc($school)});
    } else {
	return(0);
    }
}

# Get sorted list of schools for which current session user has admin
sub get_schools {
    my ($session_hashref,) = @_;

    # tusk_session_admin is set in HSDB4::SQLRow::User
    return if ! defined $session_hashref->{roles}{tusk_session_admin};

    my $school_hashref = $session_hashref->{roles}{tusk_session_admin};
    my @admin_schools = sort(grep { $school_hashref->{$_} == 1 } keys %{ $school_hashref });
    return @admin_schools;
}

# Get sorted list ofx schools for which current session user has eval admin
sub get_eval_schools {
    my ($session_hashref,) = @_;

    # tusk_session_eval_admin is set in HSDB4::SQLRow::User
    return if ! defined $session_hashref->{roles}{tusk_session_eval_admin};

    my $school_hashref = $session_hashref->{roles}{tusk_session_eval_admin};
    my @eval_schools = sort(grep { $school_hashref->{$_} == 1 } keys %{ $school_hashref });
    return @eval_schools;
}

sub check_content_key{
    my ($hash, $content_id) = @_;
    if (defined($hash->{content}->{$content_id})){
	return $hash->{content}->{$content_id};
    }else{
	return -1;
    }
}

sub set_content_key{
    my ($hash, $content_id, $value) = @_;

    $hash->{content}->{$content_id} = $value;
}

sub check_content_permissions{
    my ($udat, $course, $content, $courserole, $user) = @_;
    my $grant;

    $udat->{content} = {} unless ($udat->{content});

    my $key = check_content_key($udat, $content->primary_key);
    return $key if ($key != -1);
    $udat->{modified} = localtime;

    my $orig_course = HSDB45::Course->new( _school => $content->field_value('school') )->lookup_key( $content->field_value('course_id') );

    if ((check_course_permissions($courserole, 'DIRECTOR') and $content->field_value('course_id') eq $course->primary_key and $content->field_value('school') eq $course->school) ||
        is_director( $orig_course, $user->user_id ) ) {
	$grant = 1;
    }elsif (&is_school_admin($udat, $content->field_value('school'), $user)){
	$grant = 1;
    }
    
    unless ($grant){
	my @roles = $content->child_user_roles($user->primary_key);
	
	if ($roles[0] and $roles[0] ne "Contact-Person"){
	    $grant = 1;
	}else{
	    $grant = 0;
	  }
    }
    
    set_content_key($udat, $content->primary_key, $grant);
    return $grant;
}

sub is_tusk_admin{
    my $user_id = shift;
    return 0 unless ($user_id);

    foreach (@TUSK::Constants::siteAdmins) { 
	return 1 if ($user_id eq $_);
    }
    return 0;
}

1;
