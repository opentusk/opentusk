package TUSK::Search::UserSearch;

use strict;
use Carp qw(confess); 


use TUSK::Search::SearchTerm;
use TUSK::Search::SearchResult;
use TUSK::Search::SearchQuery;
use DBIx::FullTextSearch;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);
use HSDB4::Constants;

# this hash is a lookup between query field name and 
# the relevant FTS Index to search
my %FTSFieldNameLookup =  ( 'query' => 'fts_body',
				'author'=> 'fts_author',
				'title'=>'fts_title',
				'media_type'=>'fts_type',
				'school'=>'fts_school',
				'content_id'=>'fts_title',
				'course'=>'fts_course' ,
				'user'=>'fts_user',
				'non_user'=>'fts_non_user',
				'copyright'=>'fts_body' ) ;


my %validField = map { ( $_ => 1 ) } keys %FTSFieldNameLookup;

=head1 NAME

B<TUSK::Search::UserSearch>

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE

=over

##################################################

=item B<new>

TUSK::Search::UserSearch->new();

Returns a new instance of the object

=cut

sub new{
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

##################################################

=item B<findPredefinedSearchResults>

($searchResults, $cleanSearchString) = $obj->findPredefinedSearchResults($userEntry);

This method examines the Predefined Search Results tables
to determine whether the string passed matches a search string
that matches a predefined URL.  For example, a string of 'evals' 
will return the URL to the Evaluation system.

It returns an arrayref of TUSK::Search::SearchResult objects as 
well as the search string that the method looked for in the database.

=cut

sub findPredefinedSearchResults{
	my $self = shift;
	my $userEntry = shift;
	my $searchString = sprintf " lower(search_term) = lower('%s') ", cleanUserEntry($userEntry, 1);
	my $terms = TUSK::Search::SearchTerm->lookup($searchString);
	my @results = map { $_->getSearchResultObject() } @{$terms}; 
	return (\@results ,$searchString);
}

##################################################

=item B<findPossibleUMLSConcepts>

$concepts = obj->findPossibleUMLSConcepts($userEntry);

The userEntry string is used to search UMLS Strings. The string
has wildcards attached to the beginning and end in order to widen
the search. An arrayref of matching TUSK::Core::Keyword objects is returned.

=cut

sub findPossibleUMLSConcepts {
	my $self = shift;
	my $userEntry = shift;
	return $self->findSimilarUMLSConcepts($userEntry,'wildcard search');
}

##################################################

=item B<findSimilarUMLSConcepts>

$concepts = obj->findSimilarUMLSConcepts($userEntry,[$wildCardSearch]);

The method has one required parameter and one optional parameter. The required 
parameter is a string to be used to search UMLS Strings. All matching concepts 
(TUSK::Core::Keyword) associated with that exact string will be returned. The optional
parameter will change this behavior and cause the method to return any UMLS String that 
is partially matched with the user entry.
 
=cut

sub findSimilarUMLSConcepts{
	my $self = shift;
	my $userEntry = shift;
	my $wildCardSearch = shift || 0;
	my $userPhrases =  $self->getPossibleUserPhrases($userEntry);
	my $searchString;
	if ($wildCardSearch){
		$searchString = 'string_text like lower("%%%s%%")';
	} else {
		$searchString = 'string_text = lower("%s")';
	}
	my @UMLSStrings = map { @{TUSK::UMLS::UmlsString->lookup(sprintf($searchString,$_))}}
		@{$userPhrases};
	my $UMLSConcept = {} ;
	foreach my $string (@UMLSStrings){
		my $keywords = $string->getKeywords();
		foreach my $keyword (@{$keywords}){
			$UMLSConcept->{$keyword->getPrimaryKeyID} = $keyword;
		}
	}
	return [values(%{$UMLSConcept})];
}

##################################################

=item findRelatedUMLSConcepts

$concepts = $obj->findRelatedUMLSConcepts($userEntry,$relationType);

This method returns an arrayref of TUSK::Core::Keyword objects.  The parameters
are a string that should be used to search the UMLS Strings and an arrayref of strings
that correspond to relation types in the LinkKeywordKeyword object.  Any keyword that 
has a relationship to any keyword with a matching UMLS string is returned.  

=cut

sub findRelatedUMLSConcepts{
        my $self = shift;
        my $userEntry = shift;
	my $relationType = shift;
        my $userPhrases = $self->getPossibleUserPhrases($userEntry);
        my @UMLSStrings = map { @{TUSK::UMLS::UmlsString->lookup("string_text  = lower('$_')")}}
                @{$userPhrases};
        my $UMLSConcept = {} ;
        foreach my $string (@UMLSStrings){
                my $keywords = $string->getKeywords();
                foreach my $keyword (@{$keywords}){
			my $related = $keyword->getRelatedKeywords($relationType);
			foreach my $relatedKeyword (@{$related}){
				$UMLSConcept->{$relatedKeyword->getPrimaryKeyID} = $relatedKeyword;
			}
                }
        }
	# print tv_interval($t0)."\n";
        return [values(%{$UMLSConcept})];
}

##################################################

=item B<getPossibleUserPhrases>

$userPhrases = $obj->getPossibleUserPhrases($userEntry);

The method returns an arrayref of strings that could be interpreted
as phrases based on the passed string. It interprets a grouping
of words as a phrase based on quotes or position in the original 
string. 

=cut

sub getPossibleUserPhrases {
	my $self = shift;
	my $userEntry = shift;
        my (@userPhrases);
        @userPhrases = $userEntry =~ m/"(.+?)"/g;
	$userEntry =~ s/"(.+?)"//g;
	my @userRemainingWords = $userEntry =~ m/(\w+)/g;
	my $accumString;
	for (my $i = 0; $i < @userRemainingWords; $i++){
		$accumString = '';
		for (my $j = 0; $j <= $i; $j++){
			$accumString .= $userRemainingWords[$j].' ';
		}
		chop $accumString;
		push @userPhrases, $accumString; 
	}
        @userPhrases = map { $_ =~ s/\s+|"/ /g; $_;} grep { $_ ne '' } (@userPhrases,@userRemainingWords);
	return \@userPhrases;
}


##################################################

=item B<getPhrases>

This method takes a user entry for a field and returns an array. Each
entry includes either a string of words that was double quoted by the user
or a single word if it was not inside double quotes.

"foo bar" bletch returns
['foo bar','bletch']

=cut

sub getPhrases {
	my $self = shift;
	my $userEntry = shift;
	my (@userPhrases);
	@userPhrases = $userEntry =~ m/"(.*?)"|(\S+)/g;
	@userPhrases = grep { defined($_) && $_ ne '' } @userPhrases;
	@userPhrases = map {cleanUserEntry($_)} @userPhrases;
	return \@userPhrases;
}

##################################################

=item B<getFTSHandle>

$dbh = TUSK::Search::UserSearch->getFTSHandle();

Returns a database handle to the FTS database

=cut

sub getFTSHandle {
    my $self = shift;
    HSDB4::Constants::set_db('fts');
    my $fts_dbh = HSDB4::Constants::def_db_handle();
    HSDB4::Constants::set_db('hsdb4');
    return $fts_dbh;
}

##################################################

=item B<dropFTSHandle>

TUSK::Search::UserSearch->dropFTSHandle($dbh);

Disconnects database handle to the FTS Database

=cut

sub dropFTSHandle {
    my $self = shift;
    my $fts_dbh = shift;
    $fts_dbh->disconnect if $fts_dbh && $fts_dbh->ping;
}


##################################################

=item B<createFTSObject>

$fts = $obj->createFTSObject($field);

Returns an DBIx::FullTextSearch object that is appropriate
for the field string that is passed.  The field is mapped to
an FTS index using FTSFieldNameLookup.

=cut

sub createFTSObject{
	my $dbh = shift;
	my $field = shift;
	return DBIx::FullTextSearch->open($dbh,$FTSFieldNameLookup{$field});
}

##################################################

=item B<findObjectives>

$objectives = $obj->findObjectives($userEntry)

HSDB4::SQLRow::Objective objects that match the userEntry string are returned in an arrayref 

=cut

sub findObjectives {
	my $self = shift;
	my $userEntry = shift;
	$userEntry = cleanUserEntry($userEntry);
	my @objectives = HSDB4::SQLRow::Objective->lookup_conditions(' body like "%'.$userEntry.'%" ');
	return \@objectives;

}

##################################################

=item B<findUsers>

$users = $obj->findUsers($userEntry,$getNonUsers);

HSDB4::SQLRow::User or HSDB4::SQLRow::NonUser objects are
returned based on the optional getNonUsers flag.  If getNonUsers
is true then only NonUser objects are searched for and returned.  
Results are returned based on searching the appropriate FTS Index.

=cut

sub findUsers {
	my $self = shift;
	my $userEntry = shift;
	my $getNonUsers = shift || 0;
	$userEntry = cleanUserEntry($userEntry);
	my $FTSHandle = $self->getFTSHandle();
	my $indexName = 'user';
	if ($getNonUsers){
		$indexName = 'non_user';
	}
	my $FTSObject = $self->createFTSObject($FTSHandle, $indexName);
	my @user_ids = $FTSObject->econtains($userEntry);
	my @users;
	if ($getNonUsers){
		@users = HSDB4::SQLRow::NonUser->new->lookup_conditions("order by lastname,firstname",
			"user_id in ('".join("','",@user_ids)."')") if (@user_ids);
	} else {
		@users = HSDB4::SQLRow::User->new->lookup_conditions("order by lastname,firstname",
			"user_id in ('".join("','",@user_ids)."')") if (@user_ids);
	}
	$self->dropFTSHandle($FTSHandle);
	return \@users;

}

##################################################

=item B<findNonUsers>

$nonUsers = $obj->findNonUsers($userEntry);

Similar to findUsers, except NonUsers are always returned.

=cut

sub findNonUsers {
	my $self = shift;
	my $userEntry = shift;
	return $self->findUsers($userEntry,"find non users");
}

##################################################

=item B<cleanUserEntry>

my $string = TUSK::Search::UserSearch::cleanUserEntry($userEntry);

The method removes double quotes and extra space characters.

=cut

sub cleanUserEntry {
	my $userEntry = shift;
	my $skipReserved = shift;

	$userEntry =~ s/\s+/ /g;
	$userEntry =~ s/\s$//g;
	$userEntry =~ s/^\s//g;
	$userEntry =~ s/\// /g;
	$userEntry =~ s/\\/ /g;
	$userEntry =~ s/\*/\%/g;
	$userEntry =~ s/'/\\'/g;

	# this deals with reserved characters in FTS	
	unless ($skipReserved){
	    $userEntry =~ s/\-/zdshz/g;
	    $userEntry =~ s/\_/zbrz/g;
	}

	return lc($userEntry);

}

1;
