#!/usr/local/bin/perl

# do-db-conversion.pl :
#     Converts an existing TUSK database to use UTF-8 as the character encoding on text fields.
#     This is done by querying MySQL's information schema for all text columns, grouping them
#     by table, and applying an ALTER TABLE on each table containing text columns to redefine
#     their encoding. Any tables that need this conversion and also have an index will have
#     their index dropped before converting, and rebuilt after converting. This is a big part
#     of where time is spent in the conversion process.
#
#     Log information and errors will be dumped to a file, alter-columns-log.txt, in the directory
#     from which the script is run.

use strict;
use warnings;
use Data::Dumper;
use MySQL::Password;
use DBI;
use POSIX ":sys_wait_h";

my ($user_name, $password, $script_user, $logfile, $DB_HOST);
my ($dbh, $sth, $sql, $retval);
my @tusk_dbs;
my $skip_tables = {
					'tusk.link_search_query_content' => 0,
					'hsdb4.content_history'          => 0,
				  };


if (my $pid = fork()) {
	print "Started master to check child pid $pid\n";
	my $keepLooping = 1;
	do {
		print "Child still running at ". localtime(time) ."\n";
		sleep 60;
		$keepLooping = waitpid($pid, WNOHANG);
	} while($keepLooping != -1);
} elsif(defined $pid) {
	main();
	exit(0);
} else {
	die "Can't fork to monitor\n";
}
exit;

sub main {
	open($logfile, '> ./alter-columns-log.txt') or die "Trouble opening logfile: $!\n"; 
	setupDBConnection();
	findTuskDBs();
	my $queries = buildQueries(); 
	my $indexed_tables = identifyIndexedTables($queries);

	print "Going to modify all TUSK databases. Are you sure you want to continue? (y/n): "; 
	my $resp = <>;
	chomp($resp);
	die "Exiting\n." unless lc($resp) eq 'y'; 
	print "\nModifying TUSK databases...\n";

	alterTables($queries, $indexed_tables);
	alterIndexedTables($indexed_tables);
	cleanup();
}


sub setupDBConnection {
	#########
	# All the below DB connection code was lifted from the create_school.pl utility.
	#########
	print "\nPlease enter the hostname MYSQL is running on: ";
	$DB_HOST = <>;
	chomp $DB_HOST;

	print "Please enter username of a MYSQL account with ALTER permissions. Hint: the default is often 'root'.\n\nUser name: ";
	$user_name = <>;
	chomp $user_name;
	
	print "Please enter password for $user_name: ";
	system("stty -echo");
	$password = <>;
	print "\n";
	system("stty echo");
	chomp $password;

	eval {
	    $dbh = DBI->connect("DBI:mysql:information_schema:$DB_HOST", $user_name, $password, {RaiseError => 0, PrintError => 0}) or warn "\nProblem connecting: ". $DBI::errstr;
	};
	die "\nFailure: Could not connect to database: $@\n" if $@;

	checkPermissions();
	print "Working on host $DB_HOST\n";
}


sub checkPermissions {
	#Make sure user has all the permissions specified.
	$sql = "select Alter_priv from mysql.user where User='$user_name'";
	$sth = $dbh->prepare($sql);
	eval { $sth->execute; };
	die "Failure: $@ - sql: $sql" if ($@);
	
	my @privileges = $sth->fetchrow_array();
	map { die "User $user_name does not have sufficient permissions.\n" if ($_ ne 'Y') } @privileges;
	$sth->finish;
}


sub findTuskDBs {
	@tusk_dbs = ('tusk', 'hsdb4');
	my $sql = "SHOW DATABASES LIKE '%_admin'"; 
	$sth = $dbh->prepare($sql);
	eval { $sth->execute() };
	die "Failure: $@ - sql: $sql" if ($@);
	while (my $hsdb45_dbs = $sth->fetchrow_array()) {
		push(@tusk_dbs, $hsdb45_dbs);
	}
}


sub buildQueries {
	my (%queries, @text_columns);	

	####First, we have to find every text-like column in every TUSK database.
	my $db_list = join(',', map { $_ = "'$_'" } @tusk_dbs);
	my $sql = "select cols.TABLE_SCHEMA, cols.TABLE_NAME, cols.COLUMN_NAME, cols.COLUMN_TYPE, cols.IS_NULLABLE, cols.COLUMN_DEFAULT, cols.COLLATION_NAME FROM columns cols JOIN tables tbls ON cols.TABLE_NAME = tbls.TABLE_NAME AND cols.TABLE_SCHEMA = tbls.TABLE_SCHEMA WHERE cols.TABLE_SCHEMA in ($db_list) AND (DATA_TYPE LIKE '%char%' OR DATA_TYPE like '%text%') ORDER BY tbls.UPDATE_TIME desc";

	my $text_columns;
	eval { $text_columns = $dbh->selectall_arrayref($sql, { Slice => {} }) };
	die "Failure: $@ - sql: $sql" if ($@);

	#Add two queries to the list to be executed -- one to cast the column to its corresponding
	#blob type, and another to cast it back to the original type, with the proper charset and
	#collation.
	foreach my $column (@$text_columns) {
		my $db_name = $column->{TABLE_SCHEMA};
		my $table_name = $column->{TABLE_NAME};
		my $column_name = $column->{COLUMN_NAME};
		my $column_type = $column->{COLUMN_TYPE};
		my $column_nullable = $column->{IS_NULLABLE};
		my $column_default = $column->{COLUMN_DEFAULT};
		my $column_collation = $column->{COLLATION_NAME};

		my $query_key = "$db_name.$table_name";
		my $to_utf8_query = $queries{$query_key} ? $queries{$query_key}->{utf8} : undef;
		my $new_table = 0; #Whether this table's query already existed in the query hash.

		unless($to_utf8_query) {
			$to_utf8_query = "ALTER TABLE $db_name.$table_name";
			$new_table = 1;
		}

		#Need to append a comma if we're adding an additional MODIFY statement to this table's query.
		$to_utf8_query .= $new_table ? " " : ", ";
		$to_utf8_query .= "MODIFY $column_name $column_type CHARACTER SET utf8"; 
		
		#Include nullability and the default value for the field.
		$to_utf8_query .= " NOT NULL" if $column_nullable eq 'NO'; 
		if (defined($column_default) and length($column_default) == 0) {
			$to_utf8_query .= ' DEFAULT ""';
		}
		elsif (defined($column_default) and length($column_default)) {
			$to_utf8_query .= " DEFAULT \"$column_default\""
		}

		my $column_info = $queries{$query_key};
		if ($column_info) {
			$column_info->{utf8} = $to_utf8_query;
		}
		else {
			$column_info = { utf8 => $to_utf8_query, table_name => $table_name, db => $db_name };
		}
		$queries{"$db_name.$table_name"} = $column_info; 
	}

	return \%queries;
}


sub alterTables {
	my ($queries, $indexed_tables) = @_; 
	my %indexed_tables; #This hash keeps track of the tables having PK fields as described above.
	my @errors;
	my $query_res;


	foreach my $table (keys(%$queries)) {
		#If this table has a FULLTEXT index on it, skip it and convert it later
		next if $indexed_tables->{$table};

		#In some conversions, we may want to skip certain tables. Check the 
		#skip hash to see whether we should skip this iteration. 
		if ($skip_tables->{$table}) {
			print $logfile "Table $table is listed as a table to skip. Continuing...\n";
			print "Table $table is listed as a table to skip. Continuing...\n";
			next;
		}

		my $to_utf8_query = $queries->{$table}->{utf8};
		my $table_name = $queries->{$table}->{table_name};
		my $table_parent_db = $queries->{$table}->{db};

		print $logfile sprintf("\nWorking on table %s.%s\n", $table_parent_db, $table_name);
		print sprintf("\nWorking on table %s.%s\n", $table_parent_db, $table_name);
		my $starttime = time;

		print $logfile sprintf("Running query %s\n", $to_utf8_query);
		$query_res = $dbh->do($to_utf8_query);
		unless (defined($query_res)) {
			print "Trouble with converting table $table_parent_db.$table_name. Continuing.\n";
			push(@errors, "$table_parent_db.$table_name Error: $dbh->errstr \n");
			next;
		}
		print sprintf("Total conversion time: %u seconds\n", (time - $starttime));
	}	

}


sub identifyIndexedTables {
	my $queries = shift;
	my %indexed_tables;
	
	foreach my $table (keys(%$queries)) {
		my $table_parent_db = $queries->{$table}->{db};
		my $table_name = $queries->{$table}->{table_name};
		$sth = $dbh->prepare("SELECT * FROM STATISTICS WHERE TABLE_SCHEMA = '$table_parent_db' AND TABLE_NAME = '$table_name' AND INDEX_TYPE = 'FULLTEXT'");
		$sth->execute();
		if ($sth->fetchrow_hashref()) {
			$indexed_tables{$table} = $queries->{$table};
		}
	}

	return \%indexed_tables;
}


sub alterIndexedTables {
	my $indexed_tables = shift;
	print $logfile "\n\nAltering Indexed Tables...\n";
	print "\n\nAltering Indexed Tables...\n";

	TABLE_LOOP: foreach my $table (keys(%$indexed_tables)) {
		my $db_name = $indexed_tables->{$table}->{db};
		my $table_name = $indexed_tables->{$table}->{table_name};
		my $utf8_query = $indexed_tables->{$table}->{utf8};
		my $index_queries = buildIndexQueries($db_name, $table_name);

		#Begin by disabling keys on the table. This will explicity tell MySQL to not update
		#the FULLTEXT indices on this table until we're done messing with it.
		$dbh->do("ALTER TABLE $table DISABLE KEYS") or die "Error running 'DISABLE KEYS' on $table: " . $dbh->errstr . "\n";
	
		#Next, drop this table's indexes, so column conversion can happen.
		foreach my $index (keys(%$index_queries)) {
			my $drop_query = $index_queries->{$index}->{drop};
			print $logfile "Working on index $index\n";
			print $logfile "RUnning drop query: $drop_query\n";
			print "Working on index $index\n";
			unless ($dbh->do($drop_query)) {
				print $logfile sprintf("Error dropping FULLTEXT index on $table: %s\n", $dbh->errstr);
				print $logfile "WARNING: You will have to recreate missing FULLTEXT indices on this table!\n";
				print $logfile "Skipping to next indexed table...\n";
				print sprintf("Error dropping FULLTEXT index on $table: %s\n", $dbh->errstr);
				print "WARNING: You will have to recreate missing FULLTEXT indices on this table!\n";
				print "Skipping to next indexed table...\n";
				next TABLE_LOOP;
			}
		}

		#Now that all indices on this table are dropped, run it through the conversion process.
		my %table_conversion_query;
		$table_conversion_query{"$db_name.$table_name"} = $indexed_tables->{$table};
		alterTables(\%table_conversion_query);
			
		#Recreate the index as it was prior to the conversion.
		foreach my $index (keys(%$index_queries)) {
			my $recreate_query = $index_queries->{$index}->{recreate};
			print $logfile "Running index recreate query: $recreate_query\n";
			unless ($dbh->do($recreate_query)) {
				die sprintf("Error recreating FULLTEXT index on table $db_name.$table_name: %s", $dbh->errstr); 
			}
		}

		#Finally, re-enable keys to rebuild the indices.
		$dbh->do("ALTER TABLE $table ENABLE KEYS");
	}
	print $logfile "Finished altering indexed tables.\n";
	print "Finished altering indexed tables.\n";
}


sub buildIndexQueries {
	my ($db, $table) = @_;
	my (%index_queries, $sth);
	
	#Fetch the names of the indexes we'll have to drop from this table, and create a drop query.
	$sth = $dbh->prepare("SELECT INDEX_NAME FROM STATISTICS WHERE TABLE_SCHEMA = '$db' AND TABLE_NAME = '$table' AND INDEX_TYPE = 'FULLTEXT' GROUP BY INDEX_NAME");
	$sth->execute();
	while (my $row = $sth->fetchrow_hashref()) {
		my $index_name =  $row->{INDEX_NAME};
		$index_queries{$index_name}->{drop} = "ALTER TABLE $db.$table DROP INDEX $index_name";
	}

	#For each index found above, figure out which columns go in the index definition, and create
	#a query to rebuild the index.
	foreach my $index_name (keys(%index_queries)) {
		my @indexed_columns;
		$sth = $dbh->prepare("SELECT COLUMN_NAME FROM STATISTICS WHERE TABLE_SCHEMA = '$db' AND TABLE_NAME = '$table' AND INDEX_NAME = '$index_name'");
		$sth->execute();
		while (my $row = $sth->fetchrow_hashref()) {
			push(@indexed_columns, $row->{COLUMN_NAME}); 
		}

		my $create_query = "ALTER TABLE $db.$table ADD FULLTEXT `$index_name`("; 
		$create_query .= join(',', map { "`$_`" } @indexed_columns);
		$create_query .= ")";
		$index_queries{$index_name}->{recreate} = $create_query;
	}

	return \%index_queries;
}


sub cleanup {
	print $logfile "\n\nFinished altering TUSK tables.\n";
	print "\n\nFinished altering TUSK tables.\n";
	return 1;
}
