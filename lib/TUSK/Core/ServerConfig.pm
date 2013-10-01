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


package TUSK::Core::ServerConfig;

use strict;
use TUSK::Constants;
use Sys::Hostname;

sub dbReadUser {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers{$token}{'readusername'};
}

sub dbWriteUser {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers{$token}{'writeusername'};
}

sub dbReadPassword {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers{$token}{'readpassword'};
}

sub dbWritePassword {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers{$token}{'writepassword'};
}

sub dbReadDefaultDB {
    return $TUSK::Constants::Default{DB};
}

sub dbWriteDefaultDB {
    return $TUSK::Constants::Default{DB};
}

sub dbReadHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"ReadHost"};
}

sub dbWriteHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"WriteHost"};
}

sub dbSearchHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"SearchHost"};
}

sub dbVideoHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"VideoHost"};
}

sub dbAudioHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"AudioHost"};
}

sub dbFlashPixHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::Servers{$hostname}->{"FlashPixHost"};
}

1;
