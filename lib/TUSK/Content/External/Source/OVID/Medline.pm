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


package TUSK::Content::External::Source::OVID::Medline;

=head1 NAME

B<TUSK::Content::External::Source::OVID::Medline> - Class for handling external content from the OVID Medline source

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use base 'TUSK::Content::External::Source::OVID';

## use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();
use HSDB4::SQLRow::User;
use HSDB4::Constants;
use TUSK::Constants;
use TUSK::Core::Keyword;
use TUSK::Core::LinkContentKeyword;
use TUSK::Content::External::MetaData;
use TUSK::UMLS::UmlsString;


sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;

    my $self = {};
    
    bless $self, $class;

    # Finish initialization...
    return $self;
}

sub metadata {
    my ($self, $content, $data) = @_;
    
    my $child_users = [];
    my $keywords = [];
    my $metadata; my $accession_number;

    return ($content, (), ()) unless ($data->{'UI'});
    my $browser = LWP::UserAgent->new();
    my $url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=" . $data->{'UI'};
    
    my $response = $browser->get($url);
    
    my $twig = XML::Twig->new();
    
    $twig->parse($response->content());
    
    my $root = $twig->root();
    if (my $pubmed_article = $root->first_child('PubmedArticle')){
	if (my $medline_citation = $pubmed_article->first_child('MedlineCitation')){
	    $metadata = TUSK::Content::External::MetaData->new();

	    if (my $article = $medline_citation->first_child('Article')){
		if (my $article_title = $article->first_child('ArticleTitle')){
		    my $title = $article_title->text();
		    $title =~ s/\.$//;
		    $content->field_value('title', $title);
		}

		if (my $abstract = $article->first_child('Abstract')) {
		    my $abstract_text = $abstract->first_child('AbstractText')->text();
		    $metadata->setAbstract($abstract_text);
		    if (my $copyright = $abstract->first_child('CopyrightInformation')) {
			$content->field_value('copyright', $copyright->text());
		    }
		}

		my $year = '';
		if (my $journal = $article->first_child('Journal')) {
		    my $journal_title;
		    if (my $title = $journal->first_child('Title')) {
			$journal_title = $title->text();
			$journal_title =~ s/\.$//;

			my ($journal_issue, $publish);
			if (my $j_issue = $journal->first_child('JournalIssue')) {
			    if (my $vol = $j_issue->first_child('Volume')) {
				$journal_issue = $vol->text();
			    }
			    if (my $issue = $j_issue->first_child('Issue')) {
				$journal_issue .= '(' . $issue->text() . ')';
			    }

			    if (my $pubdate = $j_issue->first_child('PubDate')) {
				if (my $meddate = $pubdate->first_child('MedlineDate')) {
				    $publish = $meddate->text();
				    if ($publish =~ /([19|20]{2}\d{2}).+/) {
					$year = $1;
				    } 
				} elsif (my $pub_year = $pubdate->first_child('Year')) {
				    $year = $pub_year->text();

				    if (my $pub_month = $pubdate->first_child('Month')) {
					$publish = ' ' . $pub_month->text();
				    }

				    $publish .= " $year";
				}
			    }
			}

			my $journal_page;
			if (my $pagination = $article->first_child('Pagination')) {
			    if (my $page = $pagination->first_child('MedlinePgn')) {
				$journal_page = $page->text();
			    }
			}


			$content->field_value('source', $journal_title . '. ' . $journal_issue . ':' . $journal_page . ',' . $publish);
		    }

		    if ($content->source()) {
			if (my $journal_issue = $journal->first_child('JournalIssue')) {
			    if ($journal_title) {
				$content->field_value('copyright', "Copyright $year, $journal_title");
			    }
			} 
		    }
		}

		if (my $author_list = $article->first_child('AuthorList')){
		    my $author_names = join("; ", @{$self->getAuthors($author_list)});
		    $metadata->setAuthor($author_names);
		}
	    }

	    if (my $mesh_heading_list = $medline_citation->first_child('MeshHeadingList')){
		$keywords = $self->getKeywords($mesh_heading_list);
	    }

	}

	if (my $pubmed_data = $pubmed_article->first_child('PubmedData')) {
	    if (my $list = $pubmed_data->first_child('ArticleIdList')) {
		if (my @elems = $list->children('ArticleId')) {
		    foreach my $elem (@elems) {
			if ($elem->att('IdType') eq 'doi') {
			    $metadata->setUrl('http://dx.doi.org/' . $elem->text());
			}

			if ($elem->att('IdType') eq 'pii') {
			    $accession_number = $elem->text();
			}

		    }
		}
	    }

	}
    }

    return ($content, $metadata, $keywords, $accession_number);
    
}


sub getAuthors {
    my ($self, $author_list) = @_;
    my @authors = $author_list->children('Author');
    my @names = ();
    foreach my $author (@authors){
	if (my $lastname = $author->first_child('LastName')){
	    my $firstname;
	    if ($firstname = $author->first_child('FirstName') or $firstname = $author->first_child('ForeName')){
		push @names, $firstname->text() . ' ' . $lastname->text();
	    }
	}
    }

    return \@names;
}


sub getKeywords {
    my ($self, $mesh_heading_list) = @_;
    my @headings = $mesh_heading_list->children('MeshHeading');
    my %keywords;

    foreach my $heading (@headings){
	my @meshs = $heading->children('DescriptorName');
	push(@meshs, $heading->children('QualifierName'));
		    
	foreach my $mesh (@meshs){
		my $mesh_text = $mesh->text();
		$mesh_text  =~ s/'/\\'/g;
	    my $strings = TUSK::UMLS::UmlsString->lookup("string_text = '$mesh_text'");
	    if (scalar(@{$strings})){
		foreach my $string (@{$strings}) {
		    if (scalar (my @one_keyword =  @{$string->getKeywords}) == 1) {
			$keywords{$one_keyword[0]->getPrimaryKeyID()} = $one_keyword[0];
		    }
		}
	    }
	}
	
    }

    return [ values %keywords ];
}

1;
