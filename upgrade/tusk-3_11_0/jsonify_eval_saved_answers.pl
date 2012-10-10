#!/usr/bin/perl

# jsonify_eval_saved_answers.pl:
#     TUSK 3.11.0 saw the introduction of JSON as the backend storage format used in the
#     eval_save_data table in hsdb45 databases, via HSDB45::Eval::SavedAnswers. 
#     This script will use Storable (the old storage format) to thaw binary data stored 
#     in an existing database, convert it to JSON, and write it back to the database.
#     Storable data that was mangled (several records were at Tufts) will not be fixed --
#     THERE IS A POTENTIAL FOR SOME SAVE DATA TO BE RENDERED UNUSABLE THROUGH THIS SCRIPT.
#     You have been warned.

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MySQL::Password;
use DBI;
use Storable qw(thaw);

BEGIN { $ENV{PERL_JSON_BACKEND} = 'JSON::PP' }
use JSON;

my ($sth, $dbh, @hsdb45_dbs);


my $DB_HOST='localhost';
setupDBConnection();
getHSDB45();
jsonifyEvalSaveData();
print "Done!\n";
exit();


sub setupDBConnection {
	my ($DB_USER, $DB_PW) = get_user_pw();	

	eval {
	    $dbh = DBI->connect("DBI:mysql:tusk:$DB_HOST", $DB_USER, $DB_PW, {RaiseError => 0, PrintError => 0});
	};
	die "\nFailure: Could not connect to database: $@\n" if $@;
}


sub getHSDB45 {
	print "Searching for databases that require update...";
	$sth = $dbh->prepare("SHOW DATABASES LIKE '%_admin'");
	$sth->execute;

	while(  my @row = $sth->fetchrow_array()) {
		my $db = $row[0];
		# See if there is the eval_save_data table in this database.
		my $table_sth = $dbh->prepare("SHOW TABLES FROM $db");
		$table_sth->execute();
		while ( my @tableRow = $table_sth->fetchrow_array()) {
			my $tableName = $tableRow[0];
			if($tableName eq 'eval_save_data') {
				push(@hsdb45_dbs, $db);
			}
		}
	}
	print "Done\n";
}


sub jsonifyEvalSaveData {
	my $query;
	foreach my $hsdb45_db (@hsdb45_dbs) {
		print "Processing $hsdb45_db\n";
		#Get all data from the data column. This is where the serialized objects 
		#representing the completed eval responses are saved.
		$sth = $dbh->prepare("SELECT eval_save_data_id, data FROM $hsdb45_db.eval_save_data"); 
		$sth->execute;

		#Thaw the data. If there's an error, this entry was written by the Linux VM 
		#in little-endian byte order -- we can ignore these, since our soon-to-be-ubiquitous
		#Linux vm's will read them fine. 
		while (my ($id, $data) = $sth->fetchrow_array) {
			my $thawed_data;
			eval { $thawed_data = thaw($data) };

			#Continue to the next record if we can't thaw this one, as it fits scenario from above.
			if ($@) {
				#It may be the case that this is already JSON-ified. If so, continue. If not: we failed to thaw!
				if (verifyDecode($hsdb45_db, $id)) {
					next;
				}
				else {
					print "\nProblem with eval_save_data_id $id in $hsdb45_db. Error: $@.\nContinuing...";
					next;
				}
			}

			#If the data from above thawed, we should have a nice answers hash. Since we're migrating
			#to JSON as a serialization format for this feature, JSON-ify the data and write it back into
			#the database.
			my $json_data;
		    eval { $json_data = encode_json($thawed_data) };
			if ($@) {
				print "\nTrouble encoding thawed data in $hsdb45_db with id $id: $@.\nContinuing...";
				next;
			}

			$json_data =~ s/\\r\\n/\\n/g; #Snip out the extra carriage returns introduced by encode_json.

			$dbh->do("UPDATE $hsdb45_db.eval_save_data SET data=? WHERE eval_save_data_id=? ", undef, $json_data, $id);
			verifyDecode($hsdb45_db, $id); #Ensure we can fetch this JSON from the database and turn it back into a hash.
		}
	}
}

sub verifyDecode {
	my ($hsdb45_db, $id) = @_;

	my $sth = $dbh->prepare("SELECT data from $hsdb45_db.eval_save_data where eval_save_data_id = $id");
	$sth->execute;

	my ($json_data) = $sth->fetchrow_array();
	eval { JSON->new->loose->decode($json_data) };
	if ($@) {
		print "Problem unserializing record with eval_save_data_id $id in $hsdb45_db: $@";
		return 0;
	}
	return 1;
}
