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


package TUSK::Search::Indexer;

=head1 NAME

B<TUSK::Search::Indexer> - Class for manipulating entries in table
search_query in tusk database

=head1 SYNOPSIS

This module is to be used as an interface between the content object and the
indexing system.  The rules used to index content are in this module.

=head1 DESCRIPTION


=head1 INTERFACE

=over 4

=cut

use strict;
use Carp qw(confess);
use TUSK::Services::MMTx;
use TUSK::UMLS::UmlsConceptMention;
use TUSK::Search::Content;
use TUSK::Constants;
use TUSK::Content::External::MetaData;

#######################################################

=item B<new>

TUSK::Search::Indexer->new();

Returns new instance of the Indexer object;

=cut

sub new {
  my $class = shift;
  my $self = {};
  return bless $self,$class;
}

#######################################################

=item B<indexContent>

$obj->indexContent($contentObject, $UMLSIndex, $verbose);

The method takes two parameters: a content object and an optional flag
that indicates whether to search the content for UMLS Concepts. A true
value will cause the content to be searched, with no value passed the
content is not searched.

=cut

sub indexContent {
  my ($self, $contentObject, $UMLSIndex, $verbose) = @_;

  # check to see if the display is on, if it's off then make sure and unindex it
  if (!$contentObject->display) {
    return $self->unindexContent($contentObject->primary_key);
  }

  if ($contentObject->type() eq 'Collection') {
    my $title = $contentObject->title();
    # give more weight to titles of collections
    $contentObject->field_value('title', "$title " x 5);
  }
  my $contentIndex = TUSK::Search::Content->new()->lookupReturnOne(
      "content_id = " . $contentObject->primary_key()
    );

  unless (ref ($contentIndex)) {
    $contentIndex = TUSK::Search::Content->new();
  }

  $contentIndex->setContentID($contentObject->primary_key());

  my $keyword_links = TUSK::Core::LinkContentKeyword->new()->lookup(
      "parent_content_id = " . $contentObject->primary_key()
    );

  my $keywords = [];

  my $use_suggested_concepts = 1;

  foreach my $keyword_link (@$keyword_links) {
    my $keyword = $keyword_link->getKeywordObject();
    if ($keyword->isUMLS()) {
      $use_suggested_concepts = 0; # if there are UMLS
      if ($keyword_link->getAuthorWeight()) {
        my $factor = 1;
        $factor = 10 if ($keyword_link->getAuthorWeight() > 1);
        for (1..$factor) {
          push(@$keywords, $keyword->getConceptID());
        }
      }
    } else {
      push(@$keywords, $keyword->getKeyword());
    }
  }

  # check for umls_concept_mentions (ie this content has run through
  # UMLS before)
  my $umls_concept_mentions = TUSK::UMLS::UmlsConceptMention->lookup(
      "content_id = '" . $contentObject->getPrimaryKeyID() . "'",
      ['map_weight desc'], undef, 5
    );

  if (-e $TUSK::Constants::MMTxExecutable && $UMLSIndex
      && !scalar(@$umls_concept_mentions)) {

    $self->UMLSIndexContent($contentObject, $verbose);

    # we didn't have any umls_concept_mentions before lets go get the
    # freshly created ones
    $umls_concept_mentions = TUSK::UMLS::UmlsConceptMention->lookup(
        "content_id = '" . $contentObject->getPrimaryKeyID() . "'",
        ['map_weight desc'], undef, 5
      );
  }

  if ($use_suggested_concepts) {
    foreach my $umls_concept_mention (@$umls_concept_mentions) {
      my $keyword_obj = $umls_concept_mention->getKeywordObject();
      my $concept_id = $keyword_obj->getConceptID();
      push (@$keywords, $concept_id);
    }
  }

  ## index the authors
  my $authors_string;
  my @users = $contentObject->child_users;
  foreach my $user (@users) {
    $authors_string .= $user->primary_key . " " . $user->out_short_name . " ";
  }

  my $abstract = '';
  if ($contentObject->type() eq 'External') {
    if (my $metadata = TUSK::Content::External::MetaData->lookupReturnOne(
          "content_id = " . $contentObject->primary_key())) {

      my $external_authors = $metadata->getAuthor();
      $external_authors =~ s/;//g;
      $authors_string .= $external_authors;
      $abstract = $metadata->getAbstract() || '';
    }
  }

  $contentIndex->setAuthors($authors_string);

  ## index the course
  my $courses_string = '';
  if ($contentObject->school) {
    my @courses = ($contentObject->linked_courses, $contentObject->course);
    my %courseHash = ();
    foreach my $course (@courses) {
      my $id = $course->primary_key;
      if ($id && !$courseHash{$id}) {
        my $label = $course->field_value('title');
        $courses_string .= $id . " " . $label . " ";
        $courseHash{$id} = 1;
      }
    }
  }

  $contentIndex->setCourses($courses_string);
  $contentIndex->setKeywords(join(' ', @$keywords));
  $contentIndex->setCopyright($contentObject->field_value('copyright'));
  $contentIndex->setTitle($contentObject->field_value('title'));
  $contentIndex->setBody($contentObject->out_index_body() . " $abstract");
  $contentIndex->setSchool($contentObject->school());
  $contentIndex->setType($contentObject->type());

  $contentIndex->save();

  return();
}

#######################################################

=item B<unindexContent>

$obj->unindexContent();

The method takes an array of content ids to be unindexed.
The array will be cycled though and the piece of content
will be removed from all indexes.

=cut

sub unindexContent {
  my $self = shift;

  foreach my $content_id (@_) {

    my $content_search = TUSK::Search::Content->new()->lookupReturnOne(
      "content_id = " . $content_id);

    if (ref($content_search) && $content_search->getPrimaryKeyID()) {
      $content_search->delete();
    }
  }
  return();
}

#######################################################

=item B<unindexDeletedContent>

$obj->unindexDeletedContent();

This is a utility function that should be called
only for cleaning up irregularities that occur when
content is deleted but the indexes are not updated
to reflect their removal.

=cut

sub unindexDeletedContent{
  my $self = shift;

  my $stmt = <<EOM;
        DELETE
    FROM tusk.full_text_search_content
    WHERE content_id NOT IN (SELECT content_id
        FROM hsdb4.content)
EOM
  my $sql_obj = TUSK::Search::Content->new()->databaseDo($stmt);
}


#######################################################

=item B<UMLSIndexContent>

$obj->UMLSIndexContent($contentObject);

The method takes a content object and sends it to a
UMLS service that examines it for UMLS Concepts. The
concepts are then saved as a UMLSConceptMention, if
it does not already appear as a mention.

=cut

sub UMLSIndexContent{
  my $self = shift;
  my $content = shift;
  my $verbose = shift;

  confess "Invalid content object passed" if (!$content->primary_key);

  my $mmtx = TUSK::Services::MMTx->new(
                                       content_id =>$content->primary_key ,
                                       title => $content->title(),
                                       verbose => $verbose,
                                       text => $content->out_index_body(),
                                      );

  my $concepts = $mmtx->scoreText();

  my $delete = TUSK::UMLS::UmlsConceptMention->new()->delete(
    "content_id = '" . $content->primary_key() . "'");

  foreach my $concept (@$concepts) {

    next if (! $concept->{concept} );

    my $keyword = TUSK::Core::Keyword->lookup(
      "concept_id = '" . $concept->{concept} . "'" );

    if (! @$keyword ) {
      next;
    }

    my $keywordID = $keyword->[0]->getPrimaryKeyID();

    my $mention = TUSK::UMLS::UmlsConceptMention->new();

    $mention->setKeywordID( $keywordID );
    $mention->setContentID( $content->primary_key() );
    $mention->setMappedText( join(';', @{ $concept->{'mapped_text'} }) );
    $mention->setContextMentioned( join(',', @{ $concept->{'context_mentioned'} }) );
    $mention->setMapWeight( abs($concept->{'score'}) );
    $mention->save( { user => 'indexer' } );
  }
}

1;
