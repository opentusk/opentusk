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


package TUSK::ScriptLog;

=head1 NAME

B<TUSK::ScriptLog> - Class used for console script logging

=head1 DESCRIPTION

Thought it would be nice to have a generic way for our cron scripts to log

=head1 SUBROUTINES

=cut

use strict;
use Carp qw(confess);
use FindBin;

my $handle;

my $logdir = "$FindBin::Bin/../logs";

#######################################################

=item B<openlog>

    TUSK::ScriptLog::openlog($filename, $message, $path);

Opens up $filename for appending and logs a startup $message.  The default path for logs is /usr/local/tusk/current/log and can be overridden by $path.
    Autoflushing is turned on by default. If no $message then logs "Starting".  If no filename, will use the script name;

=cut

sub openlog{
    my ($filename, $message, $path) = @_;
    ($filename) = ($0 =~ m/[\/\\]([^\/\\]*?)$/) unless($filename);
    $path = $logdir unless $path;
    if (! -d $logdir ){
	confess "The log directory $logdir does not exist";
    }
    if (! -w $logdir ) {
	confess "The log directory $logdir is not writable for this user";
    }
    $message = "Starting" unless $message;
    open($handle, ">>$path/$filename") or confess("Log file failed: $!");
    my $oldfh = select $handle; 
    $| = 1;  
    select $oldfh;
    &log($message);
}

#######################################################

=item B<closelog>

    TUSK::ScriptLog::closelog($message);

Closes $filename and logs $message. If no $message then logs "Finished".

=cut

sub closelog{
    my ($message) = @_;
    $message = "Finished" unless ($message);
    if ($handle){
        &log($message) ;
        close($handle);
    }
}

#######################################################

=item B<log>

    TUSK::ScriptLog::log($message);

Take a message and log it to a file.  $message will be chomped and then given a timestamp and a line return.

=cut

sub log{
    my ($message) = @_;
    chomp($message);
    if (!$handle){
  	confess "The log file is not opened"; 
    }
    print $handle localtime() . ": " . $message . "\n";
}

#######################################################

=item B<printandlog>

    TUSK::ScriptLog::printandlog($message);

Take a message print it to the console and call TUSK::ScriptLog::log.  $message will be chomped and then given a timestamp and a line return.

=cut

sub printandlog{
    my ($message) = @_;
    chomp($message);
    print localtime() . ": " . $message . "\n"; 
    &log ($message);
}

#######################################################

=item B<loganddie>

    TUSK::ScriptLog::loganddie($message);

Calls TUSK::ScriptLog::log, TUSK::ScriptLog::closelog("I was told to die") and then dies 

=cut

sub loganddie{
    my ($message) = @_;
    &log($message);
    closelog("I was told to die");
    die $message;
}

#######################################################

END {
    close($handle) if ($handle);
}
1;
