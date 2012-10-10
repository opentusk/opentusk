#! /usr/bin/perl -w
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Std;
use DBI;

use MySQL::Password;
use HSDB4::Constants;
use HSDB45::ClassMeeting;
use TUSK::ClassMeeting::Type;
use TUSK::Core::School;
use TUSK::Core::ServerConfig;


my ($un, $pw) = get_user_pw();
HSDB4::Constants::set_user_pw($un, $pw);
my $dbh;
my $testrun = 1;

# get any args passed in by user
our ($opt_t, $opt_l);
getopts ("tl");

if ($opt_l) {        # if 'l' (live) flag is passed, this is NOT a test run
	$testrun = 0;
}
else { 
	print "You have indicated that you would like to run the script in TEST MODE.\nScript will not perform any real actions, but only indicate what it would have done in LIVE MODE.\n"; 
}



eval {
	my $host = TUSK::Core::ServerConfig::dbWriteHost();
	$dbh = DBI->connect("DBI:mysql:tusk:$host;mysql_socket=/var/run/mysql/mysql.sock", $un, $pw, {RaiseError => 1, PrintError => 0});
};
die "Failure: Could not connect to database: $@" if $@;

my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS `tusk`.`class_meeting_type` (
  `class_meeting_type_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `label` varchar(255) NOT NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`class_meeting_type_id`),
  FOREIGN KEY (`school_id`) REFERENCES school (`school_id`),
  Key (`school_id`, `label`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1");

unless ($testrun) {
	eval {
		$sth->execute();
	};
	die "Failure - could not create class_meeting_type table: $@" if $@;
}
else {
	print "If script really run, would have made table 'tusk.class_meeting_type' here\n";
}

my %seen;
foreach my $s (HSDB4::Constants::schools()) {
	my $school = TUSK::Core::School->new()->lookupReturnOne("school_name='$s'");
	if (!defined $school) {
		print "Error: no school found with name '$s.' Script cannot insert any values for this school into table named tusk.class_meeting_type.\n";
		next;
	}

	my $db = HSDB4::Constants::get_school_db($s);
	if (!defined $db) {
		print "Error: after call to HSDB4::Constants::get_school_db(), script could not find a db for school with name '$s'. Therefore, could not retrieve class meeting types for insertion into new tusk.class_meeting_type table.\n";
		next;
	}

	unless ($seen{$db}++) {
		$sth = $dbh->prepare("describe $db.class_meeting type");
		eval {
			$sth->execute();
		};
		die "Failed to retrieve description of $db.class_meeting type field: $@" if $@;
			
		my $description = $sth->fetchrow_hashref();
		my $type = $description->{Type};
		# let's extract individual values from the string
		$type =~ s/enum\((.*)\)/$1/;
		my @type_arr = split ',', $type;
		foreach my $lbl (@type_arr) {
			$lbl =~ s/'//g;		

			# enum has empty string, we want to skip this one
			next if $lbl =~ /^$/;

			unless ($testrun) {
				my $cm_type = TUSK::ClassMeeting::Type->new()->lookupReturnOne('school_id=' . $school->getPrimaryKeyID() . " and label='$lbl'");

				if (defined $cm_type) {
					print "Error: class meeting of type '" . $cm_type->getLabel() . "' already exists in school '$s.' Cannot create duplicate types in a single school.\n";
					next;
				}

				# insert all relevant values into class_meeting_type
				$cm_type = TUSK::ClassMeeting::Type->new();
				$cm_type->setLabel($lbl);
				$cm_type->setSchoolID($school->getPrimaryKeyID());
				$cm_type->save( {user => $un} );
			}
			else {
				print "Would have just made meeting type with label of '$lbl' for school '$s'\n";
			}
		}
				
		my $stmt1 = qq { alter table $db.class_meeting add column type_id int(10) unsigned after type,
					     add column is_duplicate tinyint(1) unsigned default 0 after location,
					     add column is_mandatory tinyint(1) unsigned default 0 after is_duplicate
					   };
		my $stmt2 = qq { alter table $db.class_meeting add index (type_id),
		                 add index (is_duplicate) };

		unless ($testrun) {
			$sth = $dbh->prepare($stmt1);
			eval {
				$sth->execute();
			};
			die "Problem encountered when trying to add 'type_id', 'is_duplicate', 'is_mandatory' columns to $db.class_meeting: $@" if $@;
				
			$sth = $dbh->prepare($stmt2);
			eval {
				$sth->execute();
			};
			die "Problem encountered when trying to add 'type_id' and 'is_duplicate' as index in $db.class_meeting: $@" if $@;
		}
		else {
			print "would have:\n  $stmt1\n";
			print "would have:\n  $stmt2\n";
		}


		unless ($testrun) {
			my $st = "update $db.class_meeting set type_id=(select class_meeting_type_id from tusk.class_meeting_type cmt where school_id=" . $school->getPrimaryKeyID() . ' and cmt.label=type)';
			$sth = $dbh->prepare($st);
			eval {
				$sth->execute();
			};
			die "Failed to insert type_ids into $db.class_meeting: $@" if $@;
		}
		else {
			print "Would have just tried to insert type_id values into $db.class_meeting\n";
		}


		unless ($testrun) {
			my $confirmation;
			do {
				print "It might be a good idea to compare counts between type and type_id for $db.\nIf it looks good, we can delete the type field. Should we delete the type field (y/n)? ";
				$confirmation = lc(<>);
				chomp $confirmation;
			} while ($confirmation !~ /y|n/);
			if ($confirmation eq 'y') {
				my $st = "alter table $db.class_meeting drop column type";
				$sth = $dbh->prepare($st);
				eval {
					$sth->execute();
				};
				die "Failed to drop column type from $db.class_meeting: $@" if $@;
			}
			elsif ($confirmation eq 'n') {
				print "NOT dropping type field now. You will want to do so in the future\n";
			}
		}
	}
}
