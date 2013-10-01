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


use strict;
use Data::Dumper;
use DBD::mysql;
use POSIX;
use IO::Handle;

autoflush STDOUT 1;

sub getUserInput();
sub getConcepts();
sub getStrings();
sub linkConceptsConcepts();
sub linkConceptsToStrings();
sub getConceptDefinition();
sub linkConceptsToSemanticTypes();
sub getSemanticTypes();
sub getDefinitionTypes();



# get database information:
my ($dbh) = getUserInput();


# get all "concepts" and data from MRCONSO
#
# CUI is the concept id
# TS is some sort of indicator of it being the preffered form, though there
#   can be more than one preferred form for a given CUI.  Variations can
#   occur because of spaces and hyphens from what I've seen.
# STR is  the string version of the concept

print "Building index of english concepts...";
my ($bind_eng_cui);
my %mrconso_cui_that_are_eng;
my $distinct_eng_mrconso_cui_sth = $dbh->prepare( qq{SELECT distinct MRCONSO.CUI FROM MRCONSO WHERE LAT='ENG'} ) || die "unable to prepare : ". $dbh->errstr;
unless($distinct_eng_mrconso_cui_sth->execute()) {die "Could not execute sql to get english concepts from the DB!\n";}
my $rc = $distinct_eng_mrconso_cui_sth->bind_columns(\$bind_eng_cui);
while($distinct_eng_mrconso_cui_sth->fetch) {$mrconso_cui_that_are_eng{$bind_eng_cui} = 1;}
print "OK (", scalar(keys %mrconso_cui_that_are_eng), " found)\n";

getConcepts();
getStrings();
linkConceptsConcepts();
linkConceptsToStrings();
getConceptDefinition();
linkConceptsToSemanticTypes();
getSemanticTypes();
getDefinitionTypes();


print "Finishing\n";
close(OUTPUT);
$dbh->disconnect;
exit();






sub getUserInput() {
	print "please enter the mysql database name: ";
	my $mysqlDB = <STDIN>;
	chomp $mysqlDB;

	print "Please enter the mysql username: ";
	my $username = <STDIN>;
	chomp $username;

	print "Please enter the mysql password: ";
	system("stty -echo");
	my $password = <STDIN>;
	system("stty echo");
	chomp $password;
	print "\n";

	#connect to db
	my $dbh = DBI->connect("dbi:mysql:$mysqlDB", $username, $password) || die "unable to connect: $!";

	my $fileName = "tusk_umls_tables.sql";
	print "Please enter the name for the output file (tusk_umls_tables.sql): ";
	my $newFileName = <STDIN>;
	chomp $newFileName;
	if($newFileName) {$fileName = $newFileName;}
	unless(open(OUTPUT, ">$fileName")) {die "Failed to open $fileName : $!\n";}
	return($dbh);
}


sub getConcepts() {
	print "About to find the concepts in the MRCONSO table...";

	my $preferred_form_sth = $dbh->prepare( qq{ SELECT CUI, STR FROM MRCONSO WHERE LAT='ENG' && TS='P' }) || die "unable to prepare: ". $dbh->errstr;
	$preferred_form_sth->execute();
	my ( $bind_cui, $bind_str, %preferred_forms);
	my $rc = $preferred_form_sth->bind_columns( \$bind_cui, \$bind_str );
	
	#
	# since we want only one preferred form, I'm just grabbing the first and
	# using only one.
	while ( $preferred_form_sth->fetch ) {
		if(!$preferred_forms{$bind_cui}) {$preferred_forms{$bind_cui} = $bind_str;}
	}
	
	print "Writing out concepts...";
	print OUTPUT "INSERT INTO tusk.umls_concept (umls_concept_id, preferred_form) VALUES (?,?);\n";
	my $numUsed = 0;
	for my $cui ( keys %preferred_forms ) {
		print OUTPUT "$cui-|-$preferred_forms{$cui}\n";
		$numUsed++;
	}
	
	print "OK\n\n";
	print "Found $numUsed concepts\n";
}

sub getStrings() {
	my $sql_loop_counter = 0;
	print "About to find the strings in the MRCONSO table...";
	print OUTPUT "INSERT INTO tusk.umls_string (string_id, string_text) VALUES (?,?);\n";
	my $strings_sth = $dbh->prepare( qq{SELECT distinct MRCONSO.SUI, MRCONSO.STR FROM MRCONSO WHERE LAT='ENG'} ) || die "unable to prepare: ". $dbh->errstr;
	$strings_sth->execute();
	my ($bind_sui, $bind_str);
	my $rc = $strings_sth->bind_columns(\$bind_sui, \$bind_str);
	while($strings_sth->fetch) {
		print OUTPUT "$bind_sui-|-$bind_str\n";
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " strings\n";
}



sub linkConceptsConcepts() {
	my $sql_loop_counter = 0;
	print "About to link concepts to one another...";
	print OUTPUT "INSERT INTO link_keyword_keyword (parent_keyword_id, child_keyword_id, concept_relationship) VALUES ((SELECT keyword_id FROM tusk.keyword WHERE concept_id=?), (SELECT keyword_id FROM tusk.keyword WHERE concept_id=?),?);\n";
#	print OUTPUT "INSERT INTO link_umls_concept_umls_concept (umls_concept_id, umls_concept_id2, concept_relationship) VALUES (?,?,?);\n";
	my $link_concept_concept_sth = $dbh->prepare( qq{SELECT DISTINCT MRREL.CUI1, MRREL.CUI2, MRREL.REL FROM MRREL} ) || die "unable to prepare: ". $dbh->errstr;
	$link_concept_concept_sth->execute();
	my ($bind_cui1, $bind_cui2, $bind_relation);
	my $rc = $link_concept_concept_sth->bind_columns( \$bind_cui1, \$bind_cui2, \$bind_relation );
	while($link_concept_concept_sth->fetch) {
		if(exists($mrconso_cui_that_are_eng{$bind_cui1}) && exists($mrconso_cui_that_are_eng{$bind_cui2})) {
			print OUTPUT "$bind_cui1-|-$bind_cui2-|-$bind_relation\n";
			$sql_loop_counter++;
		}
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " relations\n";
}




sub linkConceptsToStrings() {
	my $sql_loop_counter = 0;
	print "About to link concepts to strings...";
	print OUTPUT "INSERT INTO link_keyword_umls_string (parent_keyword_id, child_umls_string_id, term_status) VALUES ((SELECT keyword_id FROM tusk.keyword WHERE concept_id=?),(SELECT umls_string_id FROM tusk.umls_string WHERE string_id=?),?);\n";
	my $link_concept_string_sth = $dbh->prepare( qq{SELECT DISTINCT MRCONSO.CUI, MRCONSO.SUI, MRCONSO.TS FROM MRCONSO WHERE LAT = 'ENG'} ) || die "unable to prepare: ". $dbh->errstr;
	$link_concept_string_sth->execute();
	my ($bind_cui, $bind_sui, $bind_ts);
	my $rc = $link_concept_string_sth->bind_columns(\$bind_cui, \$bind_sui, \$bind_ts);
	while($link_concept_string_sth->fetch) {
		print OUTPUT "$bind_cui-|-$bind_sui-|-$bind_ts\n";
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " relations\n";
}




sub getConceptDefinition() {
	my $sql_loop_counter = 0;
	print "About to get concepts definitions...";
	print OUTPUT "INSERT INTO umls_definition (umls_definition_type_id, keyword_id, definition) VALUES ((SELECT umls_definition_type_id FROM tusk.umls_definition_type WHERE definition_type_code=? ORDER BY umls_definition_type_id DESC limit 1), (SELECT keyword_id FROM tusk.keyword WHERE concept_id=?),?);\n";
	my $umls_definition_sth = $dbh->prepare( qq{SELECT MRDEF.SAB, MRDEF.CUI, MRDEF.DEF FROM MRDEF} ) || die "unable to prepare: ". $dbh->errstr;
	$umls_definition_sth->execute();
	my ($bind_cui, $bind_def, $bind_sab);
	my $rc = $umls_definition_sth->bind_columns(\$bind_cui, \$bind_def, \$bind_sab);
	while($umls_definition_sth->fetch) {
		print OUTPUT "$bind_cui-|-$bind_def-|-$bind_sab\n";
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " definitions\n";
}







sub linkConceptsToSemanticTypes() {
	my $sql_loop_counter = 0;
	my $english_cuis = 0;
	print "About to link concepts to semantic types...";
	print OUTPUT "INSERT INTO link_keyword_umls_semantic_type (parent_keyword_id, child_umls_semantic_type_id) VALUES ((select keyword_id from tusk.keyword where concept_id=?), (select umls_semantic_type_id from umls_semantic_type where semantic_type_id=?));\n";
#	print OUTPUT "INSERT INTO link_keyword_umls_semantic_type (parent_keyword_id, child_umls_semantic_type_id) VALUES (?,?);\n";
	my $umls_link_concept_semantic_type_sth = $dbh->prepare( qq{SELECT MRSTY.CUI, MRSTY.TUI FROM MRSTY} ) || die "unable to prepare: ". $dbh->errstr;
	#I tried this and the query takes way to long (> days) so we made the hash mrconso_cui_that_are_eng (since we get MRCONSO.LAT='ENG' up above and we will use perl to merge the lists
	#my $umls_link_concept_semantic_type_sth = $dbh->prepare( qq{SELECT MRSTY.CUI, MRSTY.TUI FROM MRSTY, MRCONSO WHERE MRCONSO.CUI=MRSTY.CUI AND MRCONSO.LAT='ENG'} ) || die "unable to prepare: ". $dbh->errstr;
	$umls_link_concept_semantic_type_sth->execute();
	my ($bind_tui, $bind_cui);
	my $rc = $umls_link_concept_semantic_type_sth->bind_columns(\$bind_cui, \$bind_tui);
	while($umls_link_concept_semantic_type_sth->fetch) {
		if(exists($mrconso_cui_that_are_eng{$bind_cui})) {
			print OUTPUT "$bind_cui-|-$bind_tui\n";
			$english_cuis++;
		}
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $english_cuis . " links out of " . $sql_loop_counter . " strings\n";
}





sub getSemanticTypes() {
	my $sql_loop_counter = 0;
	print "About to get semantic types...";
	print OUTPUT "INSERT INTO umls_semantic_type (semantic_type_id, semantic_type) VALUES (?,?);\n";
	my $umls_scmantic_type_sth = $dbh->prepare( qq{SELECT DISTINCT(MRSTY.TUI), MRSTY.STY FROM MRSTY ORDER BY MRSTY.TUI} ) || die "unable to prepare: ". $dbh->errstr;
	$umls_scmantic_type_sth->execute();
	my ($bind_tui, $bind_sty);
	my $rc = $umls_scmantic_type_sth->bind_columns(\$bind_tui, \$bind_sty);
	while($umls_scmantic_type_sth->fetch) {
		print OUTPUT "$bind_tui-|-$bind_sty\n";
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " semantic types\n";
}

sub getDefinitionTypes() {
	my $sql_loop_counter = 0;
	print "About to get definition types...";
	print OUTPUT "INSERT INTO tusk.umls_definition_type (definition_type_name, definition_type_code) VALUES (?,?);\n";
	my $umls_scmantic_type_sth = $dbh->prepare( qq{SELECT MRSAB.SON, MRSAB.RSAB FROM MRSAB ORDER BY MRSAB.SON} ) || die "unable to prepare: ". $dbh->errstr;
	$umls_scmantic_type_sth->execute();
	my ($bind_son, $bind_rsab);
	my $rc = $umls_scmantic_type_sth->bind_columns(\$bind_son, \$bind_rsab);
	while($umls_scmantic_type_sth->fetch) {
		print OUTPUT "$bind_son-|-$bind_rsab\n";
		$sql_loop_counter++;
	}
	print "OK\n\n";
	print "Found " . $sql_loop_counter . " definition types\n";
}
