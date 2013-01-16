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


#
# $Source: /data/cvs/tusk/lib/TUSK/Services/MMTx.pm,v $
#
# $Id: MMTx.pm,v 1.13 2012-04-20 16:52:41 scorbe01 Exp $
#

package TUSK::Services::MMTx; 

use strict;
use Data::Dumper;
use base qw(Exporter);
use Carp qw(confess);
use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS 
            $NUM_CONCEPTS );

use DBI;
use Digest::MD5 qw( md5_hex );
use IO::File;
use threads;
use threads::shared;

# since we're forking some processes off, don't wait for child processes
$SIG{CHLD} = 'IGNORE';

$NUM_CONCEPTS = 15;

$VERSION =  sprintf("%d.%02d", q$Revision: 1.13 $ =~ /(\d+)\.(\d+)/);

##
## Items to export into callers namespace by default. Note: do not export
## names by default without a very good reason. Use EXPORT_OK instead.
## Do not simply export all your public functions/methods/constants.
##
@EXPORT    = qw();  # leave this blank unless you have a very good reason
@EXPORT_OK = qw();


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

TUSK::Services::MMTx - Perl extension for ...

=head1 SYNOPSIS

  use TUSK::Services::MMTx;   

  #
  # sample usage for TUSK::Services::MMTx goes here
  #

=head1 ABSTRACT

The intent of TUSK::Services::MMTx is to liberate Perl programmers
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

   my $obj = TUSK::Services::MMTx->new('foo' => 'bar', 'num' => 7);

=cut

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = { @_ };
    bless $self, $class;
    return $self;
}

sub scoreText {

    my $self = shift;

    my $concepts = {};

    # we want the following arguments for a given piece of content:
    #   title
    #   text

    my $types = {
	title => {
	    weight => 20,
	},
	text => {
	    weight => 1,
	},
    };
    
    for my $type ( keys %$types ) {
        if ( $self->{ $type } ) {
	    my $matched_concepts = [ $self->find_concepts($self->{ $type }, $self->{'verbose'}) ];

	    foreach my $matched_concept (@$matched_concepts){
		if ( exists($concepts->{ $matched_concept->{concept} })){
		    $concepts->{ $matched_concept->{concept} }->{ num_of_occurrences } += $matched_concept->{ num_of_occurrences };
    		    $concepts->{ $matched_concept->{concept} }->{ score } += $types->{ $type }->{ weight } * $matched_concept->{ score };
    		    push (@{ $concepts->{ $matched_concept->{concept} }->{ mapped_text } }, @{ $matched_concept->{ mapped_text } });
		    push (@{  $concepts->{ $matched_concept->{concept} }->{ context_mentioned } }, $type);
		} else {
		    $concepts->{ $matched_concept->{concept} } = $matched_concept;
		    $concepts->{ $matched_concept->{concept} }->{ score } = $types->{ $type }->{ weight } * $matched_concept->{ score };
		    $concepts->{ $matched_concept->{concept} }->{ context_mentioned } = [ $type ];
		}
	    }
	}
    }

    print Dumper($concepts) if ($self->{verbose});

    return $self->find_top_concepts( $concepts );
}

=head2 find_concepts()

 expects: a IO::File object, a filename argument, or text string
 returns: a list of concepts in has_ref form
 usage:

   $obj->find_concepts()

 notes: Documentation for the MMTx machine output can be found at:
        http://mmtx.nlm.nih.gov/Mapping_Info.html

=cut

sub find_concepts {
  my $self = shift;

  my $file = shift;

  my $verbose = shift || 0;

  my ($text, $mmtx_output);
  my %concepts = ();

  return () unless (defined($file));

  if (ref($file) ne 'IO::File' ) {

    if ( $file !~ /\n/ && -e $file ) {
      my $fh = new IO::File $file, "r"; # open read-only

      if ( ! defined $fh ) {
        throw Error::Simple( "Unable to open $file: $!" );
      }
      else {
        local $/;
        $/ = undef;
        $text = <$fh>;
      }
    }
    else {
      $text = $file;
    }

  }
  else {
    local $/;
    $/ = undef;
    $text = <$file>;
  }


  ### We have found that common every day things get matched by the MetaMapper
  $text =~ s/\bP\.?H\.?D\.?\b//gi; # remove Ph.D. which might appear
  $text =~ s/\bM\.?D\.?\b//gi;     # remove Ph.D. which might appear

  # strip out an HTML/XML tags
  $text =~ s#</?[^> ][^>]*>##g;

  # strip out the odd \n characters
  $text =~ s#\\n##g;

  # now make in to all one line so that the mmtx tool doesn't stop at
  # newline
  $text =~ s#[\r\n]#  #g;

  my $temp_file = "/tmp/mmtx_temp_file.$$.txt";

  open TMP_FILE, ">", $temp_file || die "Unable to open $temp_file: $!";

  print TMP_FILE $text;

  close TMP_FILE;

  my $SPACE = q{ };
  my $cmd = $TUSK::Constants::mmtxExecutable
    . $SPACE
    . '--restrict_to_sts=aapp,antb,bacs,carb,chvf,chvs,clnd,eico,elii,enzy,'
    . 'hops,horm,imft,irda,inch,lipd,nsba,nnon,orch,opco,phsu,rcpt,strd,vita,'
    . 'amas,crbs,mosq,gngm,nusq,celf,clna,genf,moft,dsyn,bpoc,gngm,blor,bsoj,'
    . 'orgf,ortf,genf,patf,mobd,evnt,hlca,diap,topp,aggp,sosy,bact'
    . $SPACE
    . '-X --machine_output --fileName='
    . $temp_file;
  $cmd .= $SPACE . "2>>/tmp/mmtx_err.$$.txt" unless ($verbose);

  if ((! -f $TUSK::Constants::MMTxExecutable) || (! -x $TUSK::Constants::MMTxExecutable)) {
    confess "MMTx program not found at $TUSK::Constants::MMTxExecutable";
  }

  # Get the MMTx output, timing out in case MMTx hangs (has been a problem)
  my $mmtx_pid :shared;
  my $mmtx_thread_output :shared;
  my $mmtx_is_finished :shared;
  my $mmtx_timeout_seconds = $TUSK::Constants::MMTxIndexerTimeout;
  $mmtx_is_finished = 0;
  async {
    $mmtx_pid = open my $mmtx_fh, "$cmd |" or die "$!, $^E";
    local $/;
    $mmtx_thread_output = <$mmtx_fh>;
    $mmtx_is_finished = 1;
  }->detach();
  sleep 1 while (!$mmtx_is_finished && $mmtx_timeout_seconds--);
  if ($mmtx_is_finished) {
    # copy over threaded output to unthreaded variable
    $mmtx_output = $mmtx_thread_output;
  }
  else {
    # Signal that something went wrong. Probably that the Java process
    # hung. We don't know why this happens.
    killfam SIGKILL, $mmtx_pid;
    die "MMTx indexing timeout";
  }

  print $mmtx_output ."\n" if ($verbose);

  unlink $temp_file;
  unlink "/tmp/mmtx_err.$$.txt" unless ($verbose);

  # to keep track of which "phrase" we're getting concepts from
  my $current_phrase = '';

  for ( split "\n", $mmtx_output ) {

    if ( /utterance\((.*?[^\\])\)\./ms ) {
      next;
    }
    elsif ( /phrase\((.*?[^\\])\)\./ms ) {

      my ( $tagging_info );
      ( $current_phrase, $tagging_info ) = $1 =~ /
                                                   ^\s*
                                                   [\'\"]*(.*?)[\'\"]*
                                                   \s*,\s*
                                                   (\[.*?\])
                                                   \s*$
                                                 /x;
      next;

    }
    elsif ( /candidates\((.*?[^\\])\)\./ms ) {
      next;
    }
    elsif ( /mappings\((.*?[^\\])\)\./ms ) {
      unless ( $1 =~ /^\s*\[\]\s*$/ ) {
        my @mappings = split /\)\s*,\s*map\(/, $1;

        for ( @mappings ) {
          s/^\s*\[map\(//;      # strip out the leading 'map('
          s/\)\]\s*$//;         # strip out any trailng ')]'

          my ($overall_score, $ev_list) = $_ =~ /^(-*\d+),(.*)/;

          for my $ev ( split /\)\s*ev\(/, $ev_list ) {
            $ev =~ s/^\s*\[ev\(//; # strip out the leading 'ev('
            $ev =~ s/\)\]\s*$//;   # strip out any trailng ')]'

            # now grab the actual candidate data
            my %parse_ev = &parse_ev($ev);

            if ( %parse_ev ) {
              unless ( $concepts{$parse_ev{'concept'}} ) {
                $concepts{$parse_ev{'concept'}} = {
                                                   %parse_ev,
                                                   score => 0,
                                                  };
              }
              $concepts{$parse_ev{'concept'}}{'score'} += $overall_score;
              $concepts{$parse_ev{'concept'}}{'num_of_occurrences'}++;

              push (@{$concepts{$parse_ev{'concept'}}{'mapped_text'}}, $current_phrase);
            }
          }

        }
      }
    }
    elsif ( /'EOU'\./ ) {
    }
  }

  return values %concepts;
}

#  find_top_concepts takes a list of concept hashes and sorts them by 'score'
#  and then 'name'.  It returns the top $NUM_CONCEPTS concepts based on that
#  sort.  If there are more than $NUM_CONCEPTS that are all in the top score,
#  (e.g. 1000), it will return all those in that score.

sub find_top_concepts {
    my ($self, $concepts_to_sort) = @_;
    
    my @sorted_concepts = sort { 
	abs($b->{'score'}) <=> abs($a->{'score'}) 
	    ||
	    $a->{'name'} cmp $b->{'name'}
    } values %$concepts_to_sort;
    
    my $top_concepts = [];

    foreach my $sort_concept (@sorted_concepts){
	if (scalar(@$top_concepts) < $NUM_CONCEPTS){
	    push (@$top_concepts, $sort_concept);
	}
	else{
	    last;
	}
    }

    return $top_concepts;

};


sub parse_ev {
    my $ev = shift;

    my @map_parts = $ev =~
                /^  (-*\d+),        # negated score
                    \s*'(.*?)',     # UMLS concept
                    \s*('.*?'),     # Preferred name for concept
                    \s*\[(.*?)\],   # , separated list of matched words
                    \s*\[(.*?)\],   # , separated list of semantic types
                    \s*\[(.*?)\],   # match map list
                    \s*(yes|no),    # involved with head of phrase (yes|no)
                    \s*(yes|no)     # is overmatch (yes|no)
                    \s*             # end with optional string
                $/x;

    my %results;
    @results{ qw/ score concept name matched_words semantic_types
                  match_map_list is_phrase_head is_overmatch
                  optional_string / } = @map_parts;

    # get rid of that darned '-'
    $results{'score'} = abs($results{'score'});

    if ( $results{'name'} =~ /,/ ) {
        my @name_parts = split ',', $results{'name'};

        for ( @name_parts ) {
            s/^\s*'//;
            s/'\s*$//;
        }

        $results{'name'} = "$name_parts[0] [ $name_parts[1] ]";
    }

    return %results;
};

1;

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=head1 SEE ALSO

B<Perl>

=head1 REVISION HISTORY

 $Log: MMTx.pm,v $
 Revision 1.13  2012-04-20 16:52:41  scorbe01
 Committing ECL License header.

 Revision 1.12  2007-06-21 18:05:38  psilev01
 * remove any M.D. from the text that gets parsed
 * fixed bug which was resuling in bad data getting inserted into the mapped_text field in umls_concept_mention

 Revision 1.11  2007/06/12 16:07:54  psilev01
 added semantic type bact to list

 Revision 1.10  2007/04/30 14:57:40  psilev01
 changed which semantic types mmtx uses

 Revision 1.9  2007/04/10 19:59:21  psilev01
 made a whole host of changes:
 1) mmtx command skips the custom database
 2) mmtx only returns concepts within a select semantic types
 3) sum scores for each concept
 4) times 20 to concepts found in the title

 Revision 1.8  2007/01/23 20:05:06  psilev01
 * added a verbose option to spit out mmtx debug text

 Revision 1.7  2006/11/20 18:34:36  jwestc01
 Added MMTx executable variable

 Revision 1.6  2006/07/14 16:29:04  bkessler
 Made sure that the CONCEPTS hash is cleaned out between runs of scoreText

 Revision 1.5  2006/07/13 15:15:24  bkessler
 Changed number of concepts to return to be 50
 and renamed field to be returned

 Revision 1.4  2006/07/12 19:55:19  bkessler
 Added some error handling

 Revision 1.3  2006/07/10 18:26:49  bkessler
 Removed print statement

 Revision 1.2  2006/07/10 17:51:07  bkessler
 Removed extra code for web service

 Revision 1.1  2006/07/05 15:29:03  bkessler
 Initial Coding from Justin Deri


=cut
