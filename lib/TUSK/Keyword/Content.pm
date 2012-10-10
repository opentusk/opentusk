#
# $Source: /data/cvs/tusk/lib/TUSK/Keyword/Content.pm,v $
#
# $Id: Content.pm,v 1.1 2006-07-05 18:52:28 bkessler Exp $
#

package TUSK::Keyword::Content; 

use strict;
use Error qw(:try);
use Data::Dumper;
use base qw(Exporter);
use XML::Parser;

use MySQL::Password;
HSDB4::Constants::set_user_pw (get_user_pw);
use HSDB4::SQLRow::Content;

# use Carp::Assert;
use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS 
            %CONCEPTS $NUM_CONCEPTS );

$VERSION =  sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

##
## Items to export into callers namespace by default. Note: do not export
## names by default without a very good reason. Use EXPORT_OK instead.
## Do not simply export all your public functions/methods/constants.
##
@EXPORT    = qw();  # leave this blank unless you have a very good reason
@EXPORT_OK = qw( 
);

##
## importing ':all' will get everything that is "OK" to export
##
%EXPORT_TAGS = (
    'all' => [ @EXPORT_OK ],
);

##-----------------------------------------------------------------
## pod header for module -- name, copyright, synopsis, abstract
##-----------------------------------------------------------------

=head1 NAME

TUSK::Keyword::Content - Perl extension for ...

=head1 SYNOPSIS

  use TUSK::Keyword::Content;   

  #
  # sample usage for TUSK::Keyword::Content goes here
  #

=head1 ABSTRACT

The intent of TUSK::Keyword::Content is to liberate Perl programmers
from the some of the tedium of creating easily installable, 
testable modules.

=head1 DESCRIPTION

Available functionality is described below.

=cut

##-----------------------------------------------------------------
##
## public methods
##
##-----------------------------------------------------------------
=head1 PUBLIC METHODS

=head2 new()

 purpose: creates new instance of object and 
          blesses it into the class whose constructor 
          was called, or into the class of the package 
          in which the constructor was called.
 expects: first argument to be class name or object type, 
          followed by key => value style parameters
 returns: a reference to the object created
 usage:

   my $obj = TUSK::Keyword::Content->new('foo' => 'bar', 'num' => 7);

=cut

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};

    bless $self, $class;
    return $self;
};

sub extract_content_parts {
    my $content_id = shift;

    my $content = HSDB4::SQLRow::Content->new;

    $content->lookup_key($content_id);

    my $text = ( $content->field_value('conversion_status') eq '2' ?
                        $content->field_value('hscml_body') :
                        $content->out_html_body );

    return {
            'Text' => $text,
          'Header' => '',
           'Title' => $content->field_value('title'),
         'Keyword' => [
            TUSK::Keyword::Content::ParseXML::get_keywords_from_content($text)
                      ],
    };

};

sub index_content {
    my $self = shift;

    my $content_id = shift;

    for my $content ( $self->extract_content_parts($content_id) ) {

        for my $concept ( find_concept( $content->text ) ) {

            for my $mapped_text ( @{$concept->{'mapped_text'}} ) {

                my $mention = TUSK::Keyword::UMLS::umls_concept_mention->new(
                        'umls_concept_id' => $concept->concept_id,
                             'concent_id' => $content->id,
                      'context_mentioned' => $content->context,
                            'mapped_text' => $content->context,
                );
            }
        }
    }
};

sub find_concept {
    my $text = shift;

};

package TUSK::Keyword::Content::ParseXML;

my (@keywords, $current_tag);

my $parser  = XML::Parser->new( 'Handlers' => {
                                            'Char' => \&char_handler,
                                           'Start' => \&content_sub_tag_start,
                                             'End' => \&content_sub_tag_end,
                                              },
);

sub get_keywords_from_content {
    my $text = shift;

    eval {
        $parser->parse($text);
    };

    return @keywords;
};

sub char_handler {
    my ($parser, $text ) = @_;

    if ( $current_tag && $current_tag eq 'keyword' ) {
        push @keywords, $text;
    }
}

sub content_sub_tag_start {
    my ($parser, $tag, %attr) = @_;

    $current_tag = $tag;
}

sub content_sub_tag_end {
    my ($parser, $tag, %attr) = @_;

    $current_tag = '';
}

1;

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=head1 SEE ALSO

B<Perl>

=head1 REVISION HISTORY

 $Log: Content.pm,v $
 Revision 1.1  2006-07-05 18:52:28  bkessler
 Justin Deri's initial coding of modules


=cut
