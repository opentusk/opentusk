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
#

use strict;
use warnings;
use lib qw(/usr/local/tusk/current/lib);
use Carp;
use TUSK::Constants;
use Sys::Hostname;
use HSDB4::Constants qw(get_school_db);
use DBI;
use DBD::mysql;
use Data::Dumper;
use Getopt::Long qw(:config auto_help);
my $opts = {};
Getopt::Long::GetOptions( $opts,"conf=s", "testonly");
# this may need to be exported from shell
$ENV{TUSKRC}	= $opts->{conf} if( defined($opts->{conf}) );
my $hostname 	= Sys::Hostname::hostname;
my $db_host     =  $TUSK::Constants::Servers{$hostname}->{"WriteHost"} or 
		croak("Can't locate WriteHost for ($hostname) tusk.conf\n");
my $content_mgr =  $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername} or
		croak("Can't locate ContentManager user name in tusk.conf\n");
my $content_pwd =  $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword} or
		 croak("Can't locate ContentManager password in tusk.conf\n");
my $defaults 	= {
	testonly		=> defined($opts->{testonly}) ? 1 : 0,
	hostname		=> $hostname,
	db_host			=> $db_host,
	user			=> $content_mgr,
	pwd				=> $content_pwd,
	
};

foreach my $school (keys %TUSK::Constants::Schools) {
	my $display = $TUSK::Constants::Schools{$school}->{DisplayName};
	qlrintf("Got $school [%s]\n",$display);
	my $db = get_school_db($school);
	if($db) {
		my $dbh = db_connect($db,$defaults);
		if($dbh) {
			process_display($dbh,$display,$school);
			$dbh->disconnect;
		}
	} else {
		print "Missing database name for school = ($school)\n";
	}
}


sub process_display {
	my ($dbh,$display_in,$sname) = @_;
	my $sql = sprintf("select school_display from tusk.school where school_name = '%s'",$sname);
	my $r = do_sql($dbh,$sql);
	if($r->{school_display} eq $display_in) {
		print "Display [$display_in] is same skip\n";
	} else {
	    if( $r->{school_display} =~ /\S/ ) {
			print "Display differs changing [$r->{school_display}] to [$display_in]\n";
			unless ($defaults->{testonly}) {
				$sql = sprintf("update tusk.school set school_display = '%s' where school_name = '%s'",
					$display_in,$sname);
				print "sql = $sql\n";
				my $rv = $dbh->do($sql);
			}
		} else {
			print "Empty display for $sname\n";
		}
	}
}
sub do_sql {
	my ($dbh,$sql) = @_;
	my $sth = $dbh->prepare($sql) or die("Can't prepare statement ($sql)\n");
	eval { $sth->execute; };
	if ($@) { croak("Sql error ($@)\n"); }
        my $r = $sth->fetchrow_hashref();
	return($r);
}

sub db_connect {
	my ($db,$defaults) = @_;
	my $dsn = sprintf("DBI:mysql:%s:%s",$db,$defaults->{db_host});
	my $dbh = undef;
	eval {
		$dbh = DBI->connect($dsn, $defaults->{user}, $defaults->{pwd}) or 
		die $DBI::errstr;
	};
	if( $@ )  {
		carp("Warning failed to connect to school $db ($@)\n");
	}
	return($dbh);
}



__END__

=head1 NAME

set_school_display.pl - Synchronizes school display names from tusk.conf with display name columns in the database.

=head1 SYNOPSIS

set_school_display.pl [options]

Options:

--help|-h         : brief help message

--testonly        : show what it would do don't actually change anyhing 

--conf            : localion of tusk.conf default (/usr/local/tusk/conf/tusk.conf)

=head1 OPTIONS

=over 8

=item B<--help>
    Print a brief help message and exits.

=item B<--testonly>

=item B<--conf>
    
=cut

