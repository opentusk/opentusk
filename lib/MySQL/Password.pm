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


package MySQL::Password;

use strict;
use Term::ReadKey;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw (get_user_pw);
@EXPORT_OK = qw (get_cnf_file_pw get_prompt_pw);

sub get_cnf_file_pw {
    my $cnf_file = "$ENV{HOME}/.my.cnf";
    return unless -r $cnf_file;
    open CNF_FILE, "$cnf_file" or return;
    my ($user, $pw);
    while (<CNF_FILE>) { 
	next unless /\S/ and /^[^\#]/;
	($user) = /^user\s*=\s*(\S+)/ unless defined $user;
	($pw) = /^password\s*=\s*(\S*)$/ unless defined $pw;
	last if defined $user and defined $pw;
    }
    close CNF_FILE;
    $user ||= (getpwuid($>))[0];
    if($user =~ /^['"](.*)['"]$/) {$user = $1;}
    if($pw =~ /^['"](.*)['"]$/) {$pw = $1;}
    return unless defined $pw;
    return ($user, $pw);
}

sub get_prompt_pw {
    my ($username, $password);
    # Get the username for connecting to the database
    print "Database username: ";
    chomp ($username = ReadLine (0));
    # Get the password, but use noecho to prevent it being shown as the
    # user types it
    print "Database password: ";
    ReadMode ('noecho');
    chomp ($password = ReadLine (0));
    ReadMode ('normal');
    print "\n";
    return ($username, $password);
}

sub get_user_pw {
    my ($user, $pw);
    ($user, $pw) = get_cnf_file_pw();
    return ($user, $pw) if defined $user && defined $pw;
    return get_prompt_pw();
}

1;

__END__
