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


package Apache::HSDBHostsOnly;

use strict;
use Apache2::Const qw(:common);
use Apache2::Connection;
use Apache2::Log();
use TUSK::Constants;
use Socket;
use Sys::Hostname;
use Safe();

my $Safe = Safe->new();
my $filetime = 0;

sub handler {
    my $r = shift;
    my $hostfile;
    my $remote_ip = $r->connection()->remote_ip();
    # Use list of PermissibleIPs if available in tusk.conf
    return OK if grep { $_ eq $remote_ip } @TUSK::Constants::PermissibleIPs;
    # Otherwise a simple check if remote IP is same as local IP
    my $local_ip = inet_ntoa(scalar gethostbyname(hostname() || 'localhost'));
    return OK if $remote_ip eq $local_ip;
    $r->log_reason("Access forbidden to client IP: $remote_ip.");
    return FORBIDDEN;
}

1;
