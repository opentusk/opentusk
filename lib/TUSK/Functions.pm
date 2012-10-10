package TUSK::Functions;

use strict;
use HSDB45::TimePeriod;
use FindBin;


#############################################
# return any given string in text only 
# upto number of chars (default= 50), remove html tags
#############################################
sub truncateTextWithoutTags {

    my ($text, $maxCharSize) = @_;
    $maxCharSize ||= 50;

    $text =~ s/<\s*\/?[?A-z][^>]*>//g;

    return substr($text, 0, $maxCharSize) . ' ...';
}


sub truncate_string {
    my $stringToWorkOn = shift();

    my $maxNumberOfCharacters = shift();
    $maxNumberOfCharacters ||= 50;

    my @stringElements = ();
    my @elementsInStringToReturn = ();
    my $shortBodyToReturn = '';
    my $totalCharactersSoFar = 0;
    my $elipsis = "";

    #Split the string into html elemtents and string elements.
    while($stringToWorkOn =~ /(.*)(<[^ ][^>]*>)(.*)/) {
	push @stringElements, $3, $2;
	$stringToWorkOn = $1;
    }

    push @stringElements, $stringToWorkOn;

    my $haveEnoughtStringElements = 0;
    foreach my $tempElement (reverse @stringElements)
    {
      if($tempElement =~ /^<[^ ]/) {
	$_ = $tempElement;
	if( /<\/?b>/i || /<\/?u>/i || /<\/?i>/i || /<\/a>/i || /<a href[^>]*>/i ) {
          #If we are an html tag then push us into the elements to return
	  push @elementsInStringToReturn, $tempElement;
        }
      }
      elsif(!$haveEnoughtStringElements)
      {
        my @charsInSection = split //, $tempElement;
	if((($#charsInSection) + $totalCharactersSoFar) >= $maxNumberOfCharacters) {
		#This is the last element we will be using.

		#First lets pull out only the max number of chars that we will be using.
		$tempElement = substr($tempElement, 0, ($maxNumberOfCharacters-$totalCharactersSoFar-3));

                if($tempElement =~ / /)
		{
			$tempElement =~ s/\w*$//;
			$tempElement =~ s/[^A-Za-z0-9]*$//;
		}
		push @elementsInStringToReturn, $tempElement;
		$haveEnoughtStringElements = 1;
                $elipsis = "...";
	}
	else {
		#If not then push the temp element onto the elements to return
		push @elementsInStringToReturn, $tempElement;
		$totalCharactersSoFar += $#charsInSection;
	}
      }
    }

    foreach (@elementsInStringToReturn) {$shortBodyToReturn .= $_;}
    return($shortBodyToReturn . $elipsis);
}


sub processfdat{
    my ($fdat) = @_;

    my $struct = {};

    foreach my $key (keys %{$fdat}){
	if ($key =~/^(.*?)__(.*?)__(.*?)__(.*?)$/){
	    my @split = split("__", $key);
	    $split[0]=~s/div//;
	    $struct->{$split[0]}[$split[3]]->{pk} = $split[1];
	    $struct->{$split[0]}[$split[3]]->{$split[2]} = $fdat->{$key};
	}
    }

    return $struct;
}

sub get_data{
    my ($fdat, $name) = @_;

    my $struct = TUSK::Functions::processfdat($fdat);
    if ($struct->{$name}){
	return @{$struct->{$name}}
    }else{
	return ();
    }
}

sub get_users{
    my ($fdat) = @_;

    return get_data($fdat, "users");
}

#this sub added to satisfy Forums modules still calling embperl 
sub course_time_periods_emb{

    my ($req, $timeperiod, $udat) = @_;

    my ($periods);

    check_session_timeperiod_emb($req, $udat);

    $periods = $req->{course}->get_time_periods();
	unless ($periods){
		$udat->{timeperiod} = -1;
		return -1;
    }
	if ($timeperiod){
		$udat->{timeperiod} = $timeperiod;
		delete($udat->{selected_timeperiod_display});
    }
	elsif ($udat->{timeperiod}){
		$timeperiod = $udat->{timeperiod};
    }
	else{
		$timeperiod = get_time_period($req, $udat);
		if ($timeperiod==-1){
			$udat->{timeperiod} = $timeperiod = @$periods[length(@$periods) -1]->primary_key;
		}
		delete($udat->{selected_timeperiod_display});
	}

	if (scalar(@$periods)){
		$req->{extratext}->[0]->{name} = "Time Period";
		$req->{extratext}->[0]->{text} = TUSK::Functions::get_selected_timeperiod_display($req->{course}->school,$udat);

		$req->{extratext}->[1]->{name}  = "Change Time Period";
		$req->{extratext}->[1]->{text}  = "<iframe src=\"about:blank\" style=\"height:0; width:0; border:0; visibility:hidden;\">this prevents back forward cache in safari. info: http://developer.apple.com/internet/safari/faq.html#anchor5</iframe>";
		$req->{extratext}->[1]->{text} .= "<input type=\"hidden\" name=\"timeperiod\" />";
		$req->{extratext}->[1]->{text} .= "<select name=\"timeperiod_dd\" onchange=\"updateTPAndSubmit(this);\" class=\"navsm\">\n";
		$req->{extratext}->[1]->{text} .= "<option class=\"navsm\" value=\"\" selected=\"selected\">Select</option>\n";

		foreach my $period (@$periods){
			$req->{extratext}->[1]->{text} .= "<option class=\"navsm\" value=\"" . $period->primary_key . "\" ";
			$req->{extratext}->[1]->{text} .= ">" . $period->out_display . "</option>\n";
		}
		$req->{extratext}->[1]->{text} .= "</select>";

		$req->{no_cache} = 1;
    }
    
    return ($timeperiod);
}

# gets time period info for course objects if the user is a school admin
sub course_time_periods{
    my ($req, $timeperiod, $udat) = @_;

    my ($periods);

    check_session_timeperiod($req, $udat);

    $periods = $req->{course}->get_time_periods();
	unless ($periods){
		$udat->{timeperiod} = -1;
		return -1;
    }
	if ($timeperiod){
		$udat->{timeperiod} = $timeperiod;
		delete($udat->{selected_timeperiod_display});
    }
	elsif ($udat->{timeperiod}){
		$timeperiod = $udat->{timeperiod};
    }
	else{
		$timeperiod = get_time_period($req, $udat);
		if ($timeperiod==-1){
			$udat->{timeperiod} = $timeperiod = @$periods[length(@$periods) -1]->primary_key;
		}
		delete($udat->{selected_timeperiod_display});
	}

	if (scalar(@$periods)){
		$req->{extratext}->[0]->{name} = "Time Period";
		$req->{extratext}->[0]->{text} = TUSK::Functions::get_selected_timeperiod_display($req->{course}->school,$udat);

		$req->{extratext}->[1]->{name}  = "Change Time Period";
		$req->{extratext}->[1]->{text}  = "<iframe src=\"about:blank\" style=\"height:0; width:0; border:0; visibility:hidden;\">this prevents back forward cache in safari. info: http://developer.apple.com/internet/safari/faq.html#anchor5</iframe>";
		$req->{extratext}->[1]->{text} .= "<input type=\"hidden\" name=\"timeperiod\" />";
		$req->{extratext}->[1]->{text} .= "<select name=\"timeperiod_dd\" onchange=\"updateTPAndSubmit(this);\" class=\"navsm\">\n";
		$req->{extratext}->[1]->{text} .= "<option class=\"navsm\" value=\"\" selected=\"selected\">Select</option>\n";

		foreach my $period (@$periods){
			$req->{extratext}->[1]->{text} .= "<option class=\"navsm\" value=\"" . $period->primary_key . "\" ";
			$req->{extratext}->[1]->{text} .= ">" . $period->out_display . "</option>\n";
		}
		$req->{extratext}->[1]->{text} .= "</select>";

		$req->{no_cache} = 1;
    }
    
    return ($timeperiod);
}

sub get_selected_timeperiod_display{
    my ($school, $udat) = @_;

    unless ($udat->{selected_timeperiod_display}){
	my $timeperiod = HSDB45::TimePeriod->new(_school=>$school)->lookup_key($udat->{timeperiod});
	return unless ($timeperiod->primary_key);
	$udat->{selected_timeperiod_display} = $timeperiod->out_display;
    }
    return ($udat->{selected_timeperiod_display});
}

sub get_time_period{
    my ($req, $udat) = @_;

    #following line changed to call _emb to satisfy Announcements,Forums,Groups,Tracking modules
    check_session_timeperiod_emb($req, $udat);
    unless ($udat->{timeperiod}){
	my $timeperiod = $req->{course}->get_current_timeperiod();
	delete($udat->{selected_timeperiod_display});
	if ($timeperiod){
	    $udat->{timeperiod} = $timeperiod->primary_key;
	}else{
	    $udat->{timeperiod} = -1;
	}
    }

    return ($udat->{timeperiod});
}


sub check_session_timeperiod_emb{
    my ($req, $udat) = @_;
    $udat->{timeperiod_course} = "" unless (defined($udat->{timeperiod_course}));
    if ($udat->{timeperiod_course} ne $req->{school} . "-" . $req->{course_id}){
        delete($udat->{timeperiod});
        delete($udat->{selected_timeperiod_display});
        $udat->{timeperiod_course} = $req->{school} . "-" . $req->{course_id}
    }
}

sub set_eternity_timeperiod_emb{
    my ($req, $udat) = @_;

        check_session_timeperiod_emb($req, $udat);

        my $tp = HSDB45::TimePeriod->new(_school => $req->{course}->school())->get_eternity_period();

        if(defined($tp)){

                unless($udat->{timeperiod} == $tp->primary_key()){
                        delete($udat->{selected_timeperiod_display});
                        $udat->{timeperiod} = $tp->primary_key();
                }
                return 1;
        }
        else{
                return 0;
        }
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


sub set_eternity_timeperiod {
  my ($course, $session) = @_;

	check_session_timeperiod($course, $session);
  	my $tp = HSDB45::TimePeriod->new(_school => $course->school())->get_eternity_period();
    if(defined($tp)){

		unless( $session->{timeperiod} == $tp->primary_key() ){
			delete($session->{selected_timeperiod_display});
			$session->{timeperiod} = $tp->primary_key();
		}
		return 1;
	}
	else{
		return 0;
	}	
}


sub get_tusk_version {
	my $release = 'Unknown';
	my $temp_release = $FindBin::Bin;
	if($temp_release =~ /^.*\/tusk\/([^\/]*)\//) {$release = $1;}
	$release =~ s/_/./g;
	$release =~ s/^tusk-//g;
	return $release;
}


sub unique {
	my ($list) = @_;
	return [] unless @$list;
	my %seen = ();
	$seen{$_}++ foreach (@$list);
    return [ keys %seen ];
}


sub isValidNumber {
	my ($str) = @_;

	### taken from perl cookbook
	return (0, "has nondigits")	if ($str =~ /\D/);
	return (0, "not a natural number") unless ($str =~ /^\d+$/);  # rejects -3
	return (0, "not an integer") unless ($str =~ /^-?\d+$/); # rejects +3
	return (0, "not an integer") unless ($str =~ /^[+-]?\d+$/);
	return (0, "not a decimal number") unless ($str =~ /^-?\d+\.?\d*$/);  # rejects .2
	return (0, "not a decimal number") unless ($str =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/);
	return (0, "not a C float") unless ($str =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/);

	return 1;
}
1;

