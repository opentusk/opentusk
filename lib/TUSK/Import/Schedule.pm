package TUSK::Import::Schedule;

use strict;
use warnings;
use base qw(TUSK::Import);
use HSDB45::ClassMeeting;
use HSDB4::DateTime;
use HSDB4::Constants;
use TUSK::Constants;
use Date::Calc;
use Carp;

sub new {
    my ($class) = @_;
    $class = ref $class || $class;
    my $self = $class->SUPER::new();
    $self->set_fields(
		      qw(
			 school_abbrev 
			 oeacode_part1 
			 oeacode_part2 
			 meeting_date 
			 start_time 
			 end_time 
			 title
			 type 
			 location 
			 faculty_list
			 )
		      );
    $self->set_ignore_empty_fields(1);
    return $self;
}

sub read_filehandle {
    my ($self, $fh, $delineator, $clean_regex) = @_;
    
    $delineator = "\t" unless ($delineator);
    $clean_regex = '^[\s\cM]*(.*)[\s\cM]*$' unless ($clean_regex); # regex taken from orignal HSDB45::ClassMeeting::new_schedule_line method

    $self->SUPER::read_filehandle($fh, $delineator, $clean_regex);
    
    return;
}

sub processData {
    my ($self, $args) = @_;
    
    if (!$args->{user_group}->isa('HSDB45::UserGroup') or !$args->{user_group}->primary_key()){
	$self->add_log("error", "Invalid User Group");
	return;
    }

    my $record_hash = {};
    my $course_oeacode = {};
    my $start_date = $args->{start_date} || '9999-99-99';
    my $end_date = $args->{end_date} ||'0000-00-00';
    my $record_count = 0;
    
    if ($args->{mode_flag} eq "live" or $args->{mode_flag} eq "test"){
	my $testing = ($args->{mode_flag} eq "test");
	if (scalar ($self->get_records())){
	    foreach my $record ($self->get_records()){
		
		$record_count++;
		
		if (!$record->get_field_value('oeacode_part1') or !$record->get_field_value('oeacode_part2')){
		    $self->add_log("error", "Record " . $record_count . " is missing all or part of oea code");
		    next;
		}
		
		$course_oeacode->{ $record->get_field_value('oeacode_part1') } = 1;
		my $oea_code = $record->get_field_value('oeacode_part1') . "-" . $record->get_field_value('oeacode_part2');
	    
		
		if ($record_hash->{ $oea_code }){
		    $self->add_log("error", "Record " . $record_count . " uses class meeting oea code " . $oea_code . " that is used by another record in this file.");
		    next;
		}
		
		$record_hash->{ $oea_code } = $record;
		
		unless ($record->get_field_value('meeting_date') =~ /\d\d\d\d\-\d\d-\d\d/){
		    $self->add_log("error", "Record " . $record_count . " uses an invalid date format: " . $record->get_field_value('meeting_date') . "  All dates must be in the following format YYYY-MM-DD.");
			next if $testing;
		    return;
		}
		my @check = $record->get_field_value('meeting_date') =~ /^(\d{4})-(\d{2})-(\d{2})$/;
		unless( Date::Calc::check_date(@check) ) {
		    $self->add_log("error", "Record " . $record_count . " uses an invalid date: " . $record->get_field_value('meeting_date') );
		    next if $testing;
			return;
		}


		my @starttime = split( ":", $record->get_field_value('start_time') );
		unless ( scalar(@starttime) == 2 ) {
		    $self->add_log("error", "Record " . $record_count . " uses an invalid time format: " . $record->get_field_value('start_time') . "  All times must be in the following format HH:MM.");
			next if $testing;
		    return;
		}
		unless ( $starttime[0] >= 0 && $starttime[0] <= 23 && $starttime[1] >= 0 && $starttime[1] <= 60 ) {
		    $self->add_log("error", "Record " . $record_count . " uses an invalid time: " . $record->get_field_value('start_time') );
		    next if $testing;
			return;
		}

		my @endtime   = split( ":", $record->get_field_value('end_time') );
		unless ( scalar(@endtime) == 2 ) {
		    $self->add_log("error", "Record " . $record_count . " uses an invalid time format: " . $record->get_field_value('end_time') . "  All times must be in the following format HH:MM.");
			next if $testing;
		    return;
		}
		unless ( $endtime[0] >= 0 && $endtime[0] <= 23 && $endtime[1] >= 0 && $endtime[1] <= 60 ) {
		    $self->add_log("error", "Record " . $record_count . " uses an invalid time: " . $record->get_field_value('end_time') );
		    next if $testing;
			return;
		}

		# make sure we get the full date range
		$start_date = $record->get_field_value('meeting_date') if $record->get_field_value('meeting_date') lt $start_date;
		$end_date = $record->get_field_value('meeting_date') if $record->get_field_value('meeting_date') gt $end_date;
	    }
	    
	    unless (scalar(keys %$course_oeacode)){
		$self->add_log("error", "No OEA codes were found in file.");
		return;
	    }
	    
	    my $courseids_hash = $self->get_course_ids($args->{user_group}->school(), $course_oeacode);
	    return unless ($courseids_hash);
	    
	    my $class_meetings = $self->get_class_meeting_objects([ values %{$courseids_hash} ], $args->{user_group}->school(), $start_date, $end_date);
	    
	    # look through all linked class meetings, do any updates or deletes
	    foreach my $class_meeting (@$class_meetings){
		if ($record_hash->{ $class_meeting->oea_code() }){
		    $self->update_object($class_meeting, $record_hash->{ $class_meeting->oea_code() }, $args->{mode_flag});
		    delete($record_hash->{ $class_meeting->oea_code() });
		}
		else{
		   	my $del_oeacode = $class_meeting->oea_code();
			if ($testing) {
		    	$self->add_log("info", "Deleted Class Meeting: " . $class_meeting->oea_code() . " (Test Mode)" );
			} else {
		    	$class_meeting->delete($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
		    	$self->add_log("info", "Deleted Class Meeting: " . $class_meeting->oea_code());
			}
		}
	    }
	    
	    # do all the inserts
	    foreach my $oea_code (keys %{$record_hash}){
		my $class_meeting = HSDB45::ClassMeeting->new( _school => $args->{user_group}->school());
		my $course_oea_code = $record_hash->{ $oea_code }->get_field_value('oeacode_part1');
		
		if ($courseids_hash->{ $course_oea_code }){
		    $class_meeting->set_field_values(
						     oea_code => $oea_code,
						     course_id => $courseids_hash->{ $course_oea_code },
						     );
		    
		    $self->update_object($class_meeting, $record_hash->{ $oea_code }, $args->{mode_flag});
		}
		else{
		    $self->add_log("error", "No course found with oea code: " . $course_oea_code);
		}
	    }

	}
	else{
	    $self->add_log("error", "No lines found in file");
	    return;
	}
    }

    if ($args->{mode_flag} eq "reset_flag"){
	my $time  = HSDB4::DateTime->new();
	if ( $args->{flag_time} ) {
		my $check = HSDB4::DateTime->new()->in_mysql_timestamp( $args->{flag_time} );
		$check = HSDB4::DateTime->new()->in_mysql_timestamp( $args->{flag_time} . ":00" ) if (!$check);
		if ( $check->out_mysql_timestamp ne $args->{flag_time}.":00" && $check->out_mysql_timestamp ne $args->{flag_time} ) {
			$self->add_log("error", $args->{flag_time} . " is not a valid date/time.  Format is YYYY-MM-DD HH:MM or YYYY-MM-DD HH:MM:SS." );
			return;
		}
	}
	my $flag_time = $args->{flag_time} || $time->out_mysql_timestamp();
	$args->{user_group}->set_field_values(
					      schedule_flag_time => $flag_time,
					      );
	$args->{user_group}->save();
	$self->add_log("info", "Reset red/green schedule boxes.");
    }
    
    $self->add_log("info", "Finished");

    return;
}

sub test_mode_text{
    my ($mode_flag) = @_;
    if ($mode_flag eq "test"){
	return " (Test Mode)";
    }
    else{
	return "";
    }
}

sub get_course_ids{
    my ($self, $school, $course_oeacode) = @_;

    return {} unless (scalar(keys %{$course_oeacode}));

    my $error_flag = 0;
    my @conds = sprintf ("oea_code IN (%s)", join (', ',  map { "'" . $_ . "'" } keys %{$course_oeacode}));

    my $courseids_hash = {};

    my $blankcourse = HSDB45::Course->new( _school => $school );
    foreach my $course ($blankcourse->lookup_conditions(@conds)) {
	if ($courseids_hash->{ $course->registrar_code() }){
	    $self->add_log("error", "Two courses with oea_code " . $course->registrar_code());
	    $error_flag = 1;
	}
	$courseids_hash->{ $course->registrar_code() } = $course->primary_key();
    }
    
    if ($error_flag){
	return undef;
    }else{
	return $courseids_hash;
    }
       
}

sub get_class_meeting_objects{
    my ($self, $course_ids, $school, $start_date, $end_date) = @_;

    return [] unless (scalar(@$course_ids));

    my @conds = ("meeting_date >= '" . $start_date . "'",
		 "meeting_date <= '" . $end_date . "'",
		 sprintf ("course_id IN (%s)", join (', ', @$course_ids)),  # This may cause problems...  If a class is totally removed, the class meetings won't be retrieved and thus not deleted.  - KIGER 9/30/09
		 );
    
    my $blankmtg = HSDB45::ClassMeeting->new( _school => $school );

    my @class_meetings;

    eval {
	@class_meetings = $blankmtg->lookup_conditions(@conds);
    };
    
    if ($@){
	$self->add_log("error", "Database error");
	confess("Error in TUSK::Import::Schedule: " . $@);
    }

    return \@class_meetings;
}

sub update_object{
    my ($self, $class_meeting, $record, $mode_flag) = @_;

    (my $title = $record->get_field_value('title')) =~ s/\&(amp\;|)/\&amp;/g;
    my $type = HSDB45::ClassMeeting->check_type( $record->get_field_value('type') );

	my $starttime = $record->get_field_value('start_time');
	my $endtime   = $record->get_field_value('end_time');

	$starttime    = "0" . $starttime if ( length($starttime) == 4 );  # These lines prevent times before 10:00 entered as "x:00"
	$endtime      = "0" . $endtime   if ( length($endtime)   == 4 );  # from always appearing as updated
    
    $class_meeting->set_field_values(
				     title => $title,
				     type => $type,
				     meeting_date => $record->get_field_value('meeting_date'),
				     starttime => $starttime . ":00",
				     endtime => $endtime . ":00",
				     location => $record->get_field_value('location'),
				     );
	
    my @changed_fields = grep { $_ ne 'class_meeting_id' } $class_meeting->changed_fields();
    
    my $save_type = ($class_meeting->primary_key()) ? "Updated" : "Inserted";
    # need to do this save so we can get a primary key id for inserting into link_class_meeting_user
    $class_meeting->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword}) if ($mode_flag eq "live");


    my $faculty_change = $self->set_faculty_list($class_meeting, $record->get_field_value('faculty_list'), $mode_flag );
    
    if (scalar(@changed_fields) or $faculty_change){
	$class_meeting->set_flagtime();
	$self->add_log("info", $save_type . " Class Meeting: " . $class_meeting->oea_code() .  &test_mode_text($mode_flag));
	$class_meeting->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword}) if ($mode_flag eq "live");
    }
    
    return;
}

sub set_faculty_list {
    #
    # Make sure the faculty list agrees with the incoming string
    #

    my ($self, $class_meeting, $fac_list, $mode_flag) = @_;
    
    $fac_list =~ s/(?:^\s+|\s+$)//g;
    $fac_list =~ s/\W+/ /g;
		   
    # Get the lists of user_ids
    my @future_user_ids = split(/ /, $fac_list);
    my %future_user_ids_hash = map { lc($_) => 1 } @future_user_ids;		    
		    
    my @current_users = $class_meeting->child_users();
    my %current_users_hash = map { lc($_->primary_key()) => 1 } @current_users;
		    
    my $change_flag = 0;
    my %future_user_ids_check;

    # Add users from list
    foreach my $user_id (keys %future_user_ids_hash) {
	if ($current_users_hash{$user_id}){
	    delete($current_users_hash{$user_id});
	}
	else{
	    my $user = HSDB4::SQLRow::User->new()->lookup_key($user_id);
	    next unless ($user->primary_key()); # check to make sure this is a valid user_id
	
	    $class_meeting->user_link()->insert(-user=> $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},
				   -password=>$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword},
				   -child_id => $user_id,
				   -parent_id => $class_meeting->primary_key() ) if ($mode_flag eq "live");
	    $change_flag = 1;
	    
	    $self->add_log("info", "User " .$user_id . " added: " . $class_meeting->oea_code() .  &test_mode_text($mode_flag));
	}
    }

    foreach my $user_id (keys %current_users_hash){
	$class_meeting->user_link()->delete(-user=> $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},
					    -password=>$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword},
					    -child_id => $user_id,
					    -parent_id => $class_meeting->primary_key() ) if ($mode_flag eq "live");
	$change_flag = 1;
	$self->add_log("info", "User " . $user_id . " deleted: " .  $class_meeting->oea_code() . &test_mode_text($mode_flag));
    }
		   
    return $change_flag;
}
1;
