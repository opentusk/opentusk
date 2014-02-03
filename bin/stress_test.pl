#!/usr/bin/perl
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


use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use Data::Dumper;
use WWW::Mechanize;
use Time::HiRes qw(time);
use IO::Handle;
use TUSK::Constants;

my ($READER, $WRITER);
pipe($READER, $WRITER);
$WRITER->autoflush(1);

## add TUSK usernames into this array ref for testing
my $users = [
	     ];

my @pids = ();

my $child_count = $ARGV[0] || 10;
my $sleep_variance = $ARGV[1] || 0;

for my $n (1..$child_count){
    my $pid = fork();
    if (not defined $pid){
	die "resources not available";
    }
    elsif ($pid == 0){
	close $READER;
	my $sleep_time = int(rand($sleep_variance));
	sleep($sleep_time);
	my $username = $users->[int(rand( scalar @$users ))];
	print $WRITER $username . "," . $n . "," . $sleep_time . "," . &login($username) . "\n";
	close $WRITER;

	exit;
    }
    else {
	push @pids, $pid;
    }
}

foreach my $pid (@pids){
    waitpid($pid, 0);
}

my $count = 0;

my @data = ();

while (my $line = <$READER>){
    chomp $line;
    push @data, [ split(',', $line) ];
    $count++;
    last if ($count == $child_count);
}

close $READER;

my $total_time = 0;
my ($fast_time, $slow_time);

printf "%-20s %-10s %-10s %s\n", "username", "child", "sleep", "time";

foreach my $record (@data){
    printf "%-20s %-10s %-10s %0.3f sec\n", @$record;
    
    $total_time += $record->[3];
    $fast_time = $record->[3] if (! $fast_time or $record->[3] < $fast_time);
    $slow_time = $record->[3] if (! $slow_time or $record->[3] > $slow_time);
}

printf "\nAverage time: %0.3f sec (%d requests)\n", $total_time / $child_count, $child_count;
printf "Range: %0.3f - %0.3f\n\n", $fast_time, $slow_time;

sub login{
    my $username = shift;

    my $start = time;
    my $mech = WWW::Mechanize->new();

    my $url = "http://$TUSK::Constants::Domain";

    $mech->get( $url );

    $mech->submit_form(
                       form_name => 'login',
                       fields      => {
                           user    => $username,
                           password    => 'xx',
                       }
		       );
    return (time - $start);
}
