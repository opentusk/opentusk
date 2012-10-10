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


package TUSK::Core::AccessLog;

use strict;

use Time::Local;
use FindBin;

# in case we are combining logs, we can figure out the hostname from this hash
# (external partners will have to edit this if they have more than one machine)

my $ips = {
    '130.64.1.96' => 'kato',
    '130.64.1.168' => 'bunter',
    '130.64.1.103' => 'syms',
    '130.64.1.235' => 'littimer',
};

sub parse{
    my %args = @_;

    $args{access_logs} = [ $FindBin::Bin . "/../logs/access_log" ] unless ($args{access_logs});

    if ($args{simple_filter}){
	my ($key, $value) = split '=', $args{simple_filter};

	die "When using simple filter, need to supply in key=value format" if (! $key or ! $value);

	$args{filter} = sub {
	    my $struct = shift;
	    if ($struct->{$key} eq $value){
		return 1;
	    }
	    return 0;
	}
    }

    my @logs = ();
    
    foreach my $access_log (@{$args{access_logs}}){
	open my $fh, $access_log or die "Could not open $access_log: $!";
	
	while (my $line = <$fh>){
	    chomp $line;

	    if ($args{fast_filter}){
		my $fast_filter = $args{fast_filter};
		next if ($line !~ m/$args{fast_filter}/o);
	    }
	    my @split = split "\t", $line;
	    
	    my ($user_agent) = $split[8] =~ m/"(.*)"/;
	    my ($referer) = $split[7] =~ m/"(.*)"/;
	    my ($url_string) = $split[4] =~ m/"(.*)"/;
	    my ($method, $url, $protocol) = split " ", $url_string;
	    my ($date) = $split[3] =~ m/\[(.*)\]/;

	    my ($day, $mon, $year, $hour, $min, $sec) = $date =~ m#(\d+)/(\w+)/(\d+):(\d+):(\d+):(\d+)#;
	    my $months = { 'Jan' => 0, 'Feb' => 1, 'Mar' => 2, 'Apr' => 3, 'May' => 4, 'Jun' => 5, 'Jul' => 6, 'Aug' => 7, 'Sep' => 8, 'Oct' => 9, 'Nov' => 10, 'Dec' => 11 };
	    my $epoch_time = ($args{skip_epoch}) ? 0 : timelocal($sec, $min, $hour, $day, $months->{$mon}, ($year - 1900));
	    my $host = $ips->{ $split[11] } || '';
	    
	    my $struct = {
		remote_host => $split[0],
		remote_logname => $split[1],
		remote_user => $split[2],
		date => $date,
		epoch_time => $epoch_time,
		method => $method,
		url => $url,
		protocol => $protocol,
		http_status => $split[5],
		bytes_sent => $split[6],
		referer => $referer,
		user_agent => $user_agent,
		remote_ip => $split[9],
		connection_status => $split[10],
		local_ip => $split[11],
		process_id => $split[12],
		time => $split[13],
		host => $host,
	    };
	    
	    if (! $args{filter} or $args{filter}->($struct)){
		push @logs, $struct;
	    }
	}
	
	close $fh;
    }

    unless (scalar @logs){
	return;
    }

    my @fields = ($args{fields}) ? split /\s+/, $args{fields} : keys %{$logs[0]};

    if (scalar @{$args{access_logs}} > 1 && ! $args{sort}){
	$args{sort} = sub {
	    my $a = shift; my $b = shift; $a->{epoch_time} <=> $b->{epoch_time};
	}
    }
    
    if ($args{sort} && ! ref $args{sort}){
	my ($first, $second) = ($args{order} && $args{order} eq 'desc') ? ('b', 'a') : ('a', 'b');

	if ($args{sort} =~ /epoch_time|time/){
	    $args{sort} = eval "sub { my \$a = shift; my \$b = shift; \$$first\->{ $args{sort} } <=> \$$second\->{ $args{sort} }; }";
	}
	else {
	    $args{sort} = eval "sub { my \$a = shift; my \$b = shift; \$$first\->{ $args{sort} } cmp \$$second\->{ $args{sort} }; }";
	}
    }

    @logs = (ref $args{sort} eq 'CODE') ? sort { $args{sort}->($a, $b) } @logs : @logs;

    foreach my $log (@logs){
	foreach my $field (@fields){
	    print ucfirst($field), ": ", ($log->{$field} ? $log->{$field} : '') , "\n";
	}
	print "\n";
    }

    return;
}

=head1 NAME

B<TUSK::Core::AccessLog> - A class for parsing the apache access log

=head1 USAGE

Lets say I want to find all requests from remote_user psilev01 and sort them by the server process time:

&TUSK::Core::AccessLog::parse(
    fields => qq{date url time method},
    simple_sort => "time",
    simple_filter => "remote_user=psilev01",
    order => "desc",
);

Lets say I want to find all requests that took longer than 30 seconds to process and sort by remote_user and then url:

my $filter = sub {
    my $struct = shift;

    if ($struct->{time} > 30){
        return 1;
    }

    return 0;
};

my $sort = sub { 
    my $a = shift; 
    my $b = shift; 
    $a->{remote_user} . $a->{url} cmp $b->{remote_user} . $b->{url}; 
};

&TUSK::Core::AccessLog::parse(
    fields => qq{date url time method remote_user},
    sort => $sort,
    filter => $filter,
);

Lets say I want to combine two logs and find all requests from remote_user psilev01 and sort by date:

&TUSK::Core::AccessLog::parse(
    simple_filter => "remote_user=psilev01",
    access_logs => ['/path/to/log/1', '/path/to/log/2'],
);

=head1 ARGS

=item * fields

A string that contains each of the fields you want to output followed by a space.  If you do not include this argument then all fields will be outputed.  List of fields is provided at the end.

=item * simple_sort

Allow you to sort by a field.  List of fields is provided at the end.  You can supply either a sort or a simple_sort.  If no sort is provided it will sort by date.

=item * sort

A code reference to a sort sub.  Use perldoc -f sort to find more info about these subs.

=item * order

Used with simple_sort to reverse the results.  With the sort option you can have your sort sub return the results in whichever order you want.

=item * simple_filter

A string in the form of "field=value".  Will quickly filter the logs matching exactly any records that contain that value for that field.  You can supply either a simple_filter or a filter.  If no filter is provided, all records will be returned.

=item * filter

A code reference to a filter sub.  Gives you complete flexibility for filtering the record.

=item * fast_filter

For very large access_logs, you might to do a fast_filter to speed up your script.  A fast_filter will do a regular expression on the access_line before doing any processing.  For example if you use "31/Oct/2007" as your fast_filter, it will quickly process only records that have a match in the line to this string.  Use this feature with care :)

=item * access_logs

An array reference of strings that contain the path to apache access logs (that use the tusk customlog format).  If this is not supplied, the package will assume you are in the bin directory of an install and look for the access_log that is located ../logs from where the bin dir is.

=item * skip_epoch

Calculating the epoch time is very time consuming.  If you have a very large access_log you might want to skip this (just pass a true value).

=head1 FIELDS

=item * remote_host

=item * remote_logname

=item * remote_user

=item * date

=item * epoch_time 

number of secs since the epoch (use this when doing date compares).  This will be zero if skip_epoch argument was used.

=item * method - get/post/head etc

=item * url

=item * protocol

=item * http_status

http status code

=item * bytes_sent

=item * referer

=item * user_agent

=item * remote_ip

=item * connection_status

'X' means that the connection was closed by the client

=item * local_ip

=item * process_id

apache child process id that handled this request

=item * time

amount of time the server took to process the request (in secs)

=item * host

hostname of the server (useful when parsing multiple logs at the same time).  There is an array in this package that maps ip address to hostnames.  This will probably need to be updated as time goes on

1;
