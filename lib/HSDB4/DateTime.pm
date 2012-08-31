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


package HSDB4::DateTime;

#
# Manipulate dates and times for HSDB4 modules.
#

use POSIX qw(strftime);
use Time::Local;
use HSDB4::Constants;
use Date::Calc;

BEGIN {
    use base qw(Exporter);

    use vars qw($VERSION @EXPORT @EXPORT_OK);

    @EXPORT = qw(@monthNames %months @dayAbbr);
    @EXPORT_OK = qw();
    $VERSION = do { my @r = (q$Revision: 1.24 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}


our @monthNames = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

our %months = ('Jan' => 0, 'Feb' => 1, 'Mar' => 2, 'Apr' => 3, 'May' => 4,
	      'Jun' => 5, 'Jul' => 6, 'Aug' => 7, 'Sep' => 8, 'Oct' => 9,
	      'Nov' => 10, 'Dec' => 11);

our @dayAbbr = ('S', 'M', 'Tu', 'W', 'Th', 'F', 'S');

use overload
  'cmp' => \&compare,
  '<=>' => \&compare,
  '""' => \&out_string;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {-time => time};
    bless $self, $class;
}

sub current_year {
    my @gmtime = gmtime(time());
    my $year  = $gmtime[5] + 1900;
    return $year;
}

sub current_academic_year {
    my @gmtime = gmtime(time());
    my $month = $gmtime[4];
    my $year  = $gmtime[5] + 1900;
    return ($month >= 7) ? $year : $year-1;
}

sub compare {
    my ($a, $b) = @_;
    return $a->{-time} <=> $b->{-time};
}

sub create_date {
    my ($self,$month,$day,$year) = @_;
    return $self->{-time} = timelocal("00", "00", "00", $day, $month-1, $year-1900);
}

sub in_mysql_date {
    #
    # Take in a MySQL date and time
    #

    my $self = shift;
    my $date = shift;
    my $time = shift || '00:00:00';
    return $self->in_mysql_timestamp ("$date $time");
}

sub in_mysql_timestamp {
    #
    # Take in a MySQL timestamp
    #
    
    my $self = shift;
    my $stamp = shift;
    my ($yr, $mn, $dy, $hr, $min, $sec) = 
	$stamp =~ /(\d{4})\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*(\d{2})/;
    if ($dy >= 1 && $dy <= 31 &&
	$mn >= 1 && $mn <= 12 &&
	$yr >= 1900) {
	my $tempTime;
	eval {$tempTime = timelocal($sec, $min, $hr, $dy, $mn-1, $yr-1900)};
	if($@) {$self->{-null} = 1;}
	else   {$self->{-time} = $tempTime;}
    }
    else {
	$self->{-null} = 1;
    }
    return $self;
}


sub has_value {
    my $self = shift;
    return 0 if $self->is_null();
    return 1 if $self->{-time};
    return;
}

sub is_null {
    my $self = shift;
    return $self->{-null};
}

sub is_before{
	my $self = shift;
	my $other_date = shift;

	if($self->compare($other_date) == -1){
		return 1;
	}
	else{
		return 0;
	}
}

sub is_after{
	my $self = shift;
	my $other_date = shift;

	if($self->compare($other_date) == 1){
		return 1;
	}
	else{
		return 0;
	}
}


sub in_unix_timestamp {
    #
    # Take in a funky "Thu Sep 21 15:30:41 EDT 2000" style date
    #

    my $self = shift;
    my $stamp = shift;
    my ($month, $day, $hr, $min, $sec, $tz, $year) = 
	$stamp =~ /\w{3} (\w{3}) (\d{1,2}) (\d\d):(\d\d):(\d\d)( \w{3})? (\d{4})/;
    if ($month && $day && $year) {
	my $tempTime;
	eval {$tempTime = timelocal ($sec, $min, $hr, $day, $months{$month}, $year-1900);};
	if($@) {$self->{-null} = 1;}
	else   {$self->{-time} = $tempTime;}
    }
    else {
	$self->{-null} = 1;
    }
    return $self;
}

sub in_apache_timestamp {
    #
    # Take in a funky "Wed Sep 20 15:29:23 2000" style date
    #

    my $self = shift;
    my $stamp = shift;

    my ($month, $day, $hr, $min, $sec, $year) = 
	$stamp =~ /\w{3} (\w{3}) ( \d|\d\d) (\d\d):(\d\d):(\d\d) (\d{4})/;
    # Im not sure why this was here? 
    # $self->{-time} = timelocal ($sec, $min, $hr, $day, $months{$month}, $year-1900);
    if ($month && $day && $year) {
	my $tempTime;
	eval {$tempTime = timelocal ($sec, $min, $hr, $day, $months{$month}, $year-1900);};
	if($@) {$self->{-null} = 1;}
	else   {$self->{-time} = $tempTime;}
    }
    else {
	$self->{-null} = 1;
    }
    return $self;
}

sub in_unix_time {
    #
    # Take in seconds since the epoch
    #

    my $self = shift;
    my $epoch = shift;
    if ($epoch) {
	$self->{-time} = $epoch;
    }
    else {
	$self->{-null} = 1;
    }
    return $self;
}

sub out_string {
    #
    # Print a nice string representation of the whole thing
    #

    my $self = shift;
    return if $self->is_null();
    return unless $self->{-time};
    return scalar(localtime($self->{-time}));
}

sub out_string_date {
    #
    # Print a nice string representation of just the date
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%A %B %e, %Y", localtime($self->{-time}));
}

sub out_string_date_short {
    #
    # Print a nice string representation of just the date
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%a %b %e", localtime($self->{-time}));
}

sub out_string_date_short_short {
    #
    # Print a short nice string representation of just the date
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%b %e", localtime($self->{-time}));
}

sub out_string_date_short_year {
    #
    # Print a short nice string representation of just the date
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%e %b %Y", localtime($self->{-time}));
}

sub out_string_time {
    #
    # Print a nice string representation of just the time
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%l:%M %p", localtime($self->{-time}));
}

sub out_string_time_hm {
    #
    # Print a nice string representation of just the hour and minutes
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%l:%M", localtime($self->{-time}));
}

sub out_string_full_time {
    #
    # Print a nice string representation of just the time
    #

    my $self = shift;
    return if $self->is_null();
    return strftime ("%l:%M:%S %p", localtime($self->{-time}));
}

sub out_unix_time {
    #
    # Return a Unix time (seconds since epoch)
    #

    my $self = shift;
    return 0 if $self->is_null();
    return $self->{-time};
}

sub out_mysql_date {
    #
    # Return the date in MySQL format
    #

    my $self = shift;
    return unless $self->has_value();
    return strftime ("%Y-%m-%d", localtime($self->{-time}));
}

sub out_mysql_timestamp {
    #
    # Return the date/time in MySQL format
    #

    my $self = shift;
    return if $self->is_null();
    return unless $self->has_value();
    return strftime ("%Y-%m-%d %H:%M:%S", localtime($self->{-time}));
}

sub prev_sunday {
    #
    # Return a HSDB4::DateTime which on Sunday which is or is before the
    # time named
    #

    my $self = shift;
    return unless $self->has_value();
	# Need to get the hour and pull it out, because nothing guarantees we're at midnight.
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($self->{-time});
	# NOTE!  We're adding 7200 here to get it to 2:00 AM instead of 12:00 AM.
	#        Without this, we get in to trouble crossing DST.
    return $self->new ()->in_unix_time ($self->out_unix_time - $wday * 86400 - 3600 * $hour + 7200);
}

sub next_sunday {
    #
    # Return a HSDB4::DateTime which is the next Sunday at midnight
    #

    my $self = shift;
    return unless $self->has_value();
	# Need to get the hour and pull it out, because nothing guarantees we're at midnight.
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($self->{-time});
	# NOTE!  We're adding 7200 here to get it to 2:00 AM instead of 12:00 AM.
	#        Without this, we get in to trouble crossing DST.
    return $self->new ()->in_unix_time ($self->out_unix_time + (7-$wday) * 86400 - 3600 * $hour + 7200);
}

sub out_weekday_number {
    #
    # Return the weekday number (0-6) in question;
    #
    
    my $self = shift;
    return unless $self->has_value();
    return strftime ("%w", localtime($self->{-time}));
}

sub out_days_in_month {
    #
    # Return the number of days in a month (28-31)
    #

    my $self = shift;
    return unless $self->has_value();
    # note the extra place holder here because strftime return 1-12
    return(Date::Calc::Days_in_Month( strftime("%Y", localtime($self->{-time})), strftime("%m", localtime($self->{-time})) ));
}


sub out_monthday {
    #
    # Return the month day (0-31) in question;
    #
    
    my $self = shift;
    return unless $self->has_value();
    return strftime ("%d", localtime($self->{-time}));
}


sub out_weekday {
    #
    # Return the weekday in question;
    #
    
    my $self = shift;
    return unless $self->has_value();
    return strftime ("%A", localtime($self->{-time}));
}

sub out_day_mins {
    #
    # Return the number of minutes since the beginning of the day
    #

    my $self = shift;
    return unless $self->has_value();
    my ($sec, $min, $hour) = localtime ($self->{-time});
    return 60 * $hour + $min;
}

sub out_year {
    #
    # Return the year
    #

    my $self = shift;
    return unless $self->has_value();
    return strftime ("%Y", localtime($self->{-time}));
}


sub subtract_days {
    my $self = shift;
    my $days = shift;
    return unless $self->has_value();
    my $day_secs = $days * 60 * 60 * 24;
    $self->{-time} -= $day_secs;
    return;
}

sub add_days {
    my $self = shift;
    my $days = shift;
    return unless $self->has_value();
    my $day_secs = $days * 60 * 60 * 24;
    $self->{-time} += $day_secs;
    return;
}

sub subtract_hours {
    my $self = shift;
    my $hrs = shift;
    return unless $self->has_value();
    my $hrs_as_secs = $hrs * 60 * 60;
    $self->{-time} -= $hrs_as_secs;
    return;
}

sub m_d_yyyy_to_yyyy_mm_dd {
    my $self = shift;
    my $old_date = shift;
    my ($mo,$sp,$d,$sp2,$yr) = $old_date =~ /(\d{1,2})(\D*)(\d{1,2})(\D*)(\d{4})/;
    foreach ($mo,$d) {
	$_ = "0".$_ if ($_ !~ /\d{2}/);
    }
    return $yr.$sp.$mo.$sp.$d;
}

sub get_prev_date {
	#
	# Takes the date of this and then (roughly) removes x number of months defined in TUSK::Constants::scheduleMonthsDisplayedAtOnce
	#
	my $self = shift;
	my $newDate = HSDB4::DateTime->new()->in_unix_time($self->out_unix_time);
	$newDate->add_days(-($TUSK::Constants::scheduleMonthsDisplayedAtOnce * 30.25));
	return $newDate->out_mysql_date();
}

sub get_next_date {
	#
	# Takes the date of this and then (roughly) adds x number of months defined in TUSK::Constants::scheduleMonthsDisplayedAtOnce
	#
	my $self = shift;
	my $newDate = HSDB4::DateTime->new()->in_unix_time($self->out_unix_time);
	$newDate->add_days(($TUSK::Constants::scheduleMonthsDisplayedAtOnce * 30));
	return $newDate->out_mysql_date();
}

1;

__END__

