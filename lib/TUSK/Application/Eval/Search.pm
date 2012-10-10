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


package TUSK::Application::Eval::Search;


use HSDB4::Constants;
use HSDB45::Eval::MergedResults;

## Input: takes a school ($school) and an array reference of eval_ids ($eval_list)
## Output: returns array ref of MergedResult objects that contain one or many of the evals in $eval_list in the primary_eval_id or secondary_eval_ids field
##
## NOTE: dynamic SQL would not be necessary if the link between a merged_eval_id and various eval_ids was done in a normalized way in the DB 
##
sub getMergedEvalsThatContain {
    my $school = shift;
	my $eval_list = shift;
    my $db = HSDB4::Constants::get_school_db($school);
    my $dbh = HSDB4::Constants::def_db_handle();
	my $sql;
	my @conditions = ("primary_eval_id IN(" . (join ",", @$eval_list) . ")");
	 
	foreach my $eval_id (@$eval_list) {
		push @conditions, ("FIND_IN_SET(" . $eval_id . ", secondary_eval_ids)");
	}
	$sql .= join " OR ", @conditions;

	my @merged = HSDB45::Eval::MergedResults->new(_school => $school)->lookup_conditions($sql);

	return \@merged;
}

## Input: takes a school ($school) and an array reference of eval_ids ($eval_list)
## Output: returns array ref that is a subset of $eval_list, containing only eval_ids that are not referenced in any merged_eval_results primary_eval_id or secondary_eval_ids fields
sub getNonmergedEvalIdsSubset {
    my $school = shift;
	my $eval_list = shift;
    my $db = HSDB4::Constants::get_school_db($school);
    my $dbh = HSDB4::Constants::def_db_handle();
 	my $sql = "SELECT eval_id FROM $db.eval 
 	WHERE eval_id NOT IN (
 		SELECT eval_id FROM $db.eval, $db.merged_eval_results WHERE eval_id = primary_eval_id OR FIND_IN_SET(eval_id, secondary_eval_ids)
 	) AND eval_id IN (" . (join ",", @$eval_list) . ")";   

	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my @results = map { $_->[0] } @{$sth->fetchall_arrayref()};

	return \@results;
}


1;
__END__
