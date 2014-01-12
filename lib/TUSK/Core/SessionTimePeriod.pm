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


package TUSK::Core::SessionTimePeriod;

use strict;
use HSDB45::TimePeriod;
use HSDB45::Course;

# gets time period info for course objects if the user is a school admin
sub course_time_periods{
    my ($course, $timeperiod, $session) = @_;

    my ($periods, $extratext);

    check_session_timeperiod($course, $session);

    $periods = $course->get_universal_time_periods();
	unless ($periods){
		$session->{timeperiod} = -1;
		return -1;
    }

	if ($timeperiod){
		$session->{timeperiod} = $timeperiod;
		delete $session->{selected_timeperiod_display};
    }
	elsif ($session->{timeperiod}){
		$timeperiod = $session->{timeperiod};
    }
	else{
		$timeperiod = get_time_period($course, $session);
		if ($timeperiod == -1){
			$session->{timeperiod} = $timeperiod = @$periods[length(@$periods) -1]->primary_key;
		}
		delete $session->{selected_timeperiod_display};
    }

	if (scalar(@$periods)){
		$extratext->[0]->{name} = "Time Period";
		$extratext->[0]->{text} = get_selected_timeperiod_display($course->school, $session);

		$extratext->[1]->{name}  = "Change Time Period";
		$extratext->[1]->{text}  = "<iframe src=\"about:blank\" style=\"height:0; width:0; border:0; visibility:hidden;\">this prevents back forward cache in safari. info: http://developer.apple.com/internet/safari/faq.html#anchor5</iframe>";
		$extratext->[1]->{text} .= "<input type=\"hidden\" name=\"timeperiod\" />";
		$extratext->[1]->{text} .= "<select name=\"timeperiod_dd\" onchange=\"updateTPAndSubmit(this);\" class=\"navsm\">\n";
		$extratext->[1]->{text} .= "<option class=\"navsm\" value=\"\" selected=\"selected\">Select</option>\n";

		foreach my $period (@$periods){
			$extratext->[1]->{text} .= "<option class=\"navsm\" value=\"" . $period->primary_key . "\" ";
##			$extratext->[1]->{text} .= ">" . $period->out_display . "</option>\n";
			$extratext->[1]->{text} .= ">" . $period->out_display . ' &nbsp;&nbsp; (' . $period->out_date_range() . ")</option>\n";
		}
		$extratext->[1]->{text} .= "</select>";
    }
    
    return ($extratext);
}

sub show_dropdown_without_course{
	my ($periods, $school, $timeperiod, $session) = @_;
	my $extratext;

	if (scalar(@$periods)){	
		if ($timeperiod){
			$session->{timeperiod} = $timeperiod;
			delete $session->{selected_timeperiod_display};
		}
		elsif ($session->{timeperiod}){
			$timeperiod = $session->{timeperiod};
		}
		else{
			$session->{timeperiod} = $timeperiod = @$periods[length(@$periods) -1]->primary_key;
			delete $session->{selected_timeperiod_display};
		}

		$extratext->[0]->{name} = "Time Period";
		$extratext->[0]->{text} = get_selected_timeperiod_display($school, $session);

		$extratext->[1]->{name}  = "Change Time Period";
		$extratext->[1]->{text}  = "<iframe src=\"about:blank\" style=\"height:0; width:0; border:0; visibility:hidden;\">this prevents back forward cache in safari. info: http://developer.apple.com/internet/safari/faq.html#anchor5</iframe>";
		$extratext->[1]->{text} .= "<input type=\"hidden\" name=\"timeperiod\" />";
		$extratext->[1]->{text} .= "<select name=\"timeperiod_dd\" onchange=\"updateTPAndSubmit(this);\" class=\"navsm\">\n";
		$extratext->[1]->{text} .= "<option class=\"navsm\" value=\"\" selected=\"selected\">Select</option>\n";

		foreach my $period (@$periods){
			$extratext->[1]->{text} .= "<option class=\"navsm\" value=\"" . $period->primary_key . "\" ";
			$extratext->[1]->{text} .= ">" . $period->out_display . "</option>\n";
		}
		$extratext->[1]->{text} .= "</select>";
	}
    
	return ($extratext);
}

sub get_selected_timeperiod_display{
    my ($school, $session) = @_;

    unless ($session->{selected_timeperiod_display}){
	my $timeperiod = HSDB45::TimePeriod->new(_school=>$school)->lookup_key($session->{timeperiod});
	return unless ($timeperiod->primary_key);
	$session->{selected_timeperiod_display} = $timeperiod->out_display;
    }
    return ($session->{selected_timeperiod_display});
}

sub get_time_period{
    my ($course, $session) = @_;

    check_session_timeperiod($course, $session);
    
    unless ($session->{timeperiod}){
	my $timeperiod = $course->get_current_timeperiod();
	delete($session->{selected_timeperiod_display});
	if ($timeperiod){
	    $session->{timeperiod} = $timeperiod->primary_key;
	}else{
	    $session->{timeperiod} = -1;
	}
    }

    return ($session->{timeperiod});
}

sub check_session_timeperiod{
    my ($course, $session) = @_;
    $session->{timeperiod_course} = "" unless (defined($session->{timeperiod_course}));
    if ($session->{timeperiod_course} ne $course->school . "-" . $course->course_id){
	delete($session->{timeperiod});
	delete($session->{selected_timeperiod_display});
	$session->{timeperiod_course} = $course->school . "-" . $course->course_id
    }
}

1;

