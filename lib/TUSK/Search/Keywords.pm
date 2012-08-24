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


package TUSK::Search::Keywords;

=head1 NAME

B<TUSK::Search::Keywords> - Class for searching through UMLS Concepts and keywords in the tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;
	require TUSK::Application::HTML::Strip;


    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();
use TUSK::Search::FTSFunctions;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => '',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
#					'umls_string_id' => 'pk',
#					'string_id' => '',
#					'string_text' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=back

=cut

### Other Methods

#######################################################

=item B<search>

$obj->search($query_hashref);

Method that searches and returns a sorted list of keyword objects (based on reliance)

=cut

sub search{
	my ($self, $searchTerm, $numberToReturn) = @_;

	# This was the initial sequence that we tried
	#    my $sql = "SELECT keyword.keyword, keyword.keyword_id, keyword.concept_id, keyword.definition,
	#                      SUM(IF(STRCMP(term_status,'P'), (match(string_text) against ($escapedSearchTerm)), (match(string_text) against ($escapedSearchTerm)) * 10) +
	#                          IF(STRCMP(string_text, $escapedSearchTerm), 0, 10000)
	#                       ) AS computed_score
	#  		 FROM tusk.umls_string, tusk.link_keyword_umls_string, tusk.keyword
	# 		WHERE match (string_text) against ($escapedSearchTerm)
	#   		  AND keyword_id=parent_keyword_id
	#   		  AND umls_string_id=child_umls_string_id
	#	     GROUP BY keyword
	#	     ORDER BY computed_score DESC
	#    ";
	#    if($numberToReturn =~ /^\d+$/) {$sql .= "LIMIT $numberToReturn";}


	#This function generates a SQL statement like this on using the logic located under the sql statement:
	# SELECT keyword.keyword, keyword.keyword_id, keyword.concept_id, keyword.definition,
	#        SUM(	(match(string_text) against ("+high +blood +pressure")) * IF(string_text='high blood pressure', (IF(term_status='P', 1000, 100)), 1) + 
	#		(match(string_text) against ("+high +blood +pressure")) * IF(string_text RLIKE 'high', 10, 1) +
	#		(match(string_text) against ("+high +blood +pressure")) * IF(string_text RLIKE 'blood', 10, 1) +
	#		(match(string_text) against ("+high +blood +pressure")) * IF(string_text RLIKE 'pressure', 10, 1) +
	#		0
	#	 ) AS computed_score
	#    FROM tusk.umls_string, tusk.link_keyword_umls_string, tusk.keyword
	#   WHERE match (string_text) against ("+high +blood +pressure" in boolean mode)
	#     AND keyword_id=parent_keyword_id
	#     AND umls_string_id=child_umls_string_id
	#GROUP BY keyword
	#ORDER BY computed_score DESC
	#   LIMIT 25;
	#
	#
	#if(string_text eq $searchTerm) {
	#	if(term_status eq 'P') {SUM += 1000 * value;}
	#	else                   {SUM += 100 * value;}
	#else {
	#	foreach (@pieces of term) {
	#		if(term_status eq 'P')  {SUM += 10 * value;}
	#		else 			{SUM += value;}
	#	}
	#}

	# take out HTML tags before search
	my $stripObj = TUSK::Application::HTML::Strip->new();
	$searchTerm = TUSK::Core::SQLRow::sql_escape($stripObj->removeHTML($searchTerm));

	my $whereSearchTerm = &TUSK::Search::FTSFunctions::add_plusses_to_search_string($searchTerm);

	my $escapedSearchTerm = TUSK::Core::SQLRow::sql_escape($searchTerm);

	my $sql = "SELECT keyword.keyword, keyword.keyword_id, keyword.concept_id, group_concat(distinct umls_definition.definition order by umls_definition.umls_definition_type_id separator '\t') as definitions, group_concat(distinct definition_type_name order by umls_definition.umls_definition_type_id separator '\t') as definition_types, group_concat(distinct umls_string.string_text order by string_text separator '\t') as synonyms,
				SUM(
					(match(string_text) against (\"$whereSearchTerm\")) * IF(string_text=$escapedSearchTerm, (IF(term_status='P', 1000, 100)), 1) + 
	";
	foreach my $subTerm (split / /, $searchTerm) {
		$subTerm = TUSK::Core::SQLRow::sql_escape($subTerm);
		$sql .= "					(match(string_text) against (\"$whereSearchTerm\")) * IF(string_text RLIKE $subTerm, 10, 1) +\n";
	}
	$sql .= "					0
				) AS computed_score
		      FROM tusk.umls_string, tusk.link_keyword_umls_string, tusk.keyword
                           left join tusk.umls_definition on keyword.keyword_id = umls_definition.keyword_id
                           left join tusk.umls_definition_type on umls_definition_type.umls_definition_type_id = umls_definition.umls_definition_type_id
 		     WHERE match (string_text) against (\"$whereSearchTerm\" in boolean mode)
   		       AND keyword.keyword_id=parent_keyword_id
   		       AND umls_string_id=child_umls_string_id 
	          GROUP BY keyword
	          ORDER BY computed_score DESC
	";
	if($numberToReturn =~ /^\d+$/) {$sql .= "LIMIT $numberToReturn";}

	my $results;
	my $sth = $self->databaseSelect($sql);
	while(my $row_hashref = $sth->fetchrow_hashref) {
        	$row_hashref->{'keyword'} =~ s/\b(.)/uc($1)/eg;
		$row_hashref->{'synonyms'} =~ s/\b(.)/uc($1)/eg;
		my $keyword = $row_hashref->{'keyword'};
		$row_hashref->{'synonyms'} =~ s/(\A\Q$keyword\E\t|\t\Q$keyword\E)//g;
		push @{$results}, $row_hashref;
	}

    $sth->finish();
    return $results;
}


=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

