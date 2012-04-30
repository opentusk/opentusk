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


package TUSK::Search::SearchQuery;

=head1 NAME

B<TUSK::Search::SearchQuery> - Class for manipulating entries in table search_query in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp qw(confess);
use TUSK::Search::SearchQueryField;
use TUSK::Search::SearchQueryFieldType;
use TUSK::Search::LinkSearchQueryContent;
use TUSK::Search::LinkSearchQuerySearchQuery;
use TUSK::Core::HSDB4Tables::Content;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'search_query',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'search_query_id' => 'pk',
					'search_query' => '',
					'user_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
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

=item B<getSearchQuery>

my $string = $obj->getSearchQuery();

Get the value of the search_query field

=cut

sub getSearchQuery{
    my ($self) = @_;
    return $self->getFieldValue('search_query');
}

#######################################################

=item B<setSearchQuery>

$obj->setSearchQuery($value);

Set the value of the search_query field

=cut

sub setSearchQuery{
    my ($self, $value) = @_;
    $self->setFieldValue('search_query', $value);
}


#######################################################

=item B<getUserID>

my $string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}

=back

=cut

### Other Methods


#######################################################

=item B<saveQuery>

$newObject = TUSK::Search::SearchQuery->saveQuery($queryStruct,$user);

Returns a new TUSK::Search::SearchQuery object, already saved with
child records based on the queryStruct and user passed.  A SearchQuery object
is saved as well as child SearchQueryField objects. The user variable passed
is the owner and modifier of these objects.  The queryStruct should be a hashref
of keys corresponding to SearchQueryFieldType records, with the values 
corresponding to the user entry for that field.

=cut

sub saveQuery {
	my $self = shift;
	my $queryStruct = shift;
	my $user = shift;
	if (!ref($queryStruct) eq 'HASH'){
		confess "A hash reference must be passed as the second parameter.";
	}
	my $fieldType;
	my $queryFields = [];
	my $fieldArray;
	foreach my $field (keys %{$queryStruct}){
		if ($field ne 'query'){
			$fieldType = pop @{TUSK::Search::SearchQueryFieldType->lookup(" search_query_field_name = '$field' ")};
			if (!defined($fieldType)){
				confess "Invalid field name passed : $field ";
			}
			if (ref($queryStruct->{$field}) eq 'ARRAY') {
				$fieldArray = $queryStruct->{$field};
			} else {
				$fieldArray = [ $queryStruct->{$field} ];
			}
			foreach my $fieldItem (@{$fieldArray}){
				my $fieldObject = TUSK::Search::SearchQueryField->new();
				$fieldObject->setSearchQueryField($fieldItem);
				$fieldObject->setSearchQueryFieldTypeID($fieldType->getPrimaryKeyID());
				push @{$queryFields},$fieldObject;
			}
		} else {
			$self->setSearchQuery($queryStruct->{$field});
		}
	}

	$self->setUserID($user);

	foreach my $queryField (@{$queryFields}){
		$queryField->setSearchQueryID($self->getPrimaryKeyID());
		$queryField->save({'user'=>$user});
	}
	return $self;
}

#######################################################

=item B<getQueryStruct>

$queryStruct = $obj->getQueryStruct();

A hashref of a user\'s previous query is returned.  The
SearchQuery object is translated from the table structure
into the hashref, for use by Perl. It undoes the conversion
done by saveQuery.

=cut


sub getQueryStruct{
	my $self = shift;
	my $fields = TUSK::Search::SearchQueryField->lookup('search_query_id = '.$self->getPrimaryKeyID());
	my $hashref = {};
	my $fieldName;
	foreach my $field (@{$fields}){
		$fieldName = $field->getSearchQueryFieldTypeObject()->getSearchQueryFieldName();
		if (defined($hashref->{$fieldName})){
			if (!ref($hashref->{$fieldName})){
				$hashref->{$fieldName} = [ $hashref->{$fieldName}, $field->getSearchQueryField ];
			} else {
				push @{$hashref->{$fieldName}}, $field->getSearchQueryField ;
			}
		} else {
			$hashref->{$fieldName} = $field->getSearchQueryField();
		}
	}
	$hashref->{'query'} = $self->getSearchQuery();
	return $hashref;
}

sub hasResults {
	my $self = shift;
	return TUSK::Search::LinkSearchQueryContent->exists("parent_search_query_id = ".$self->getPrimaryKeyID);
}

sub countResults{
        my $self = shift;
        my $id;
#	if (my $refineQuery = $self->getRefineQuery()){
#		$id = $refineQuery->getPrimaryKeyID();
#	} else {
		$id = $self->getPrimaryKeyID();
#	}
        my $stmt = <<EOM;
        SELECT COUNT(*)
        FROM tusk.link_search_query_content
        WHERE parent_search_query_id = $id
EOM
        my $sth = $self->databaseSelect($stmt);
        my ($count) = $sth->fetchrow_array();
        $sth->finish;
        return $count;

}

sub getResults {
	my $self = shift;
	my $start = shift;
	my $limit = shift;

	my $limit_statement = '';

	if (defined($start)){
		$limit_statement = $start;
		if (defined($limit)){
			$limit_statement .= " , $limit ";
		}	
	}

	my $derivedtable = "select child_content_id, computed_score from tusk.link_search_query_content where parent_search_query_id = '" . $self->getPrimaryKeyID() . "' order by computed_score DESC limit $limit_statement";
	my $contentArray = TUSK::Core::HSDB4Tables::Content->new()->lookup(
									   "",
									   [
									    'computed_score DESC',
									    'content.created DESC',
									    'content.modified DESC',
									    ],
									   '',
									   '',
									   [
									    TUSK::Core::JoinObject::DerivedTable->new(
														      {
															  jointype => 'inner', 
															  alias => 'link_search_query_content',
															  joinkey => 'child_content_id',
															  origkey => 'content_id',
															  derivedtable => $derivedtable,
														      }
														      ),
									    ]
									   );

	my @contents = map { $_->getHSDB4ContentObject() } @$contentArray;

	return \@contents;
}

sub getResultsTree {
	my $self = shift;
	my $accumHash = shift || {};
	my $moreResults = TUSK::Search::LinkSearchQuerySearchQuery->lookup(" parent_search_query_id = ".$self->getPrimaryKeyID());
	$accumHash->{'current'} = {'pk'=>$self->getPrimaryKeyID(),
			'search_query'=>$self->prettyPrintUserQuery(),
			'result_count'=>$self->countResults(),
			'date'=>$self->getCreatedOnDate() };
	$accumHash->{'children'} = [];
	my $currentQuery;
	foreach my $result (@{$moreResults}){
		$currentQuery = TUSK::Search::SearchQuery->lookupKey($result->getChildSearchQueryID());
		push @{$accumHash->{'children'}}, $currentQuery->getResultsTree;
	}
	return $accumHash;

}

sub getCreatedOnDate{
    my $self = shift;
    my $datetime = $self->getCreatedOn();
    $datetime =~ s/ .*//;
    return $datetime;
}

sub prettyPrintUserQuery{
	my $self = shift;
	my $recursion_flag = shift;
	my $fields = TUSK::Search::SearchQueryField->lookup(" search_query_id = ".$self->getPrimaryKeyID());
	my $userString = '';
	if (my $searchQuery = $self->getSearchQuery()){
		$userString .= ' Keyword = [' . $searchQuery . ']';
	}

	my $fields_hashref = {};
	foreach my $field (@$fields) {
		my $fieldName = $field->getSearchQueryFieldTypeObject->getDisplayText();
		my $fieldValue = $field->getSearchQueryField;
		if ($fieldName eq 'Concepts'){
		    my $concept = TUSK::Core::Keyword->new()->lookupReturnOne("concept_id = '" . $fieldValue . "'");
		    if (defined $concept && $concept->getPrimaryKeyID()){
			$fieldValue = '"' . $concept->getKeyword() . '"';
		    }
		}
		push (@{$fields_hashref->{$fieldName}}, $fieldValue);
	}	
	
	foreach my $field (keys %$fields_hashref){
	    $userString .= ' ' . $field . ' = [' . join(", ", @{$fields_hashref->{$field}}) . ']';
	}

	if ($recursion_flag){
	    my $link = TUSK::Search::LinkSearchQuerySearchQuery->new()->lookupReturnOne("child_search_query_id = " . $self->getPrimaryKeyID(),
											undef,
											undef,
											undef, 
											[
										       TUSK::Core::JoinObject->new('TUSK::Search::SearchQuery', { 
											   origkey => 'parent_search_query_id', 
											   joinkey => 'search_query_id'})
											 ]
											);
	    if ($link && $link->getPrimaryKeyID()){
		my $parent_query = $link->getJoinObject('TUSK::Search::SearchQuery');
		$userString = $parent_query->prettyPrintUserQuery(1) . "\t" . $userString;
	    }
	}

	return $userString;

}
sub getTopLevelUserQueries {
	my $self = shift;
	my $user_id = shift;
	my $limit = shift;
        my $queryArray = $self->lookup("  user_id = '$user_id' "
		."AND search_query_id NOT IN (SELECT child_search_query_id FROM tusk.link_search_query_search_query) ",
		['created_on DESC'],undef,$limit);
        return $queryArray;
}

sub out_abbrev {
    my ($self) = @_;
    return 'Query';
}

sub out_url {
    my ($self) = @_;
    return '/tusk/search/form/' . $self->getPrimaryKeyID() . '?Search=1';
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

