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


package TUSK::Keyword::UMLS;

#use Carp;
use strict;

use TUSK::Core::SQLRow;
use HSDB4::SQLRow::User;

use base qw( TUSK::Core::SQLRow Exporter );
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION =  sprintf("%d.%02d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/);

@EXPORT    = qw();  # leave this blank unless you have a very good reason
@EXPORT_OK = qw(
);

##
## importing ':all' will get everything that is "OK" to export
##
%EXPORT_TAGS = (
    'all' => [ @EXPORT_OK ],
);

our $AUTOLOAD;

# Dynamically handle get/set methods
sub AUTOLOAD {
    return if $AUTOLOAD =~ /::DESTROY$/;
    my $self = shift;

    my $name = $AUTOLOAD;

    # trim out the package info and leave on the last word for the name
    ($name ) = $name =~ /(\w+)$/;

    # break-apart words if they are in StudlyCaps and reassemble with _
    # e.g setMappedText becomes set_mapped_text
    $name =~ s#(?<=[a-z])(?=[A-Z])#_#g;

    my $action = 'get';

    if ( $name =~ /^(get|set)_(.*)?/ ) {
        $action = $1;
        $name   = $2;
    } 

    # make sure it's a real field
    return unless grep { lc($_) eq lc($name) } @{$self->getAllFields()};

    if ( $action eq 'set' ||  @_ ) {
        return $self->setFieldValue( $name, $_[0] );
    } else {
        return $self->getFieldValue( $name );
    }
}

sub save_concept_rankings {
    my %args = @_;

    my $content_id = $args{'content_id'};
    my @concept_data = @{$args{'concepts'}};
    my %selected_ranks = %{$args{'selected_ranks'}};

    my @concepts;

    # add the concept to the umls_concept table
    for my $concept ( @concept_data ) {
        my $concept_obj = TUSK::Keyword::UMLS::umls_concept->new
                                ->lookupKey( $concept->{'concept'} );

        if ( ! defined $concept_obj ) {
                    $concept_obj = TUSK::Keyword::UMLS::umls_concept->new();
                    $concept_obj->set_umls_concept_id( $concept->{'concept'});
                    $concept_obj->set_preferred_form(
                                    $concept->{'concept_name'} );
                    $concept_obj->save();
        }

        my $concept_cond = "umls_concept_id = '".$concept->{'concept'}.
                                    "' AND content_id = '".$content_id . "'";
        my $concept_mention_objs = TUSK::Keyword::UMLS::umls_concept_mention
                                        ->new->lookup( $concept_cond);

        if ( ! @{$concept_mention_objs} ) {
            $concept_mention_objs = [
                TUSK::Keyword::UMLS::umls_concept_mention->new() ];

            $concept_mention_objs->[0]->set_umls_concept_id(
                                            $concept->{'concept'} );
            $concept_mention_objs->[0]->set_content_id( $content_id );
            $concept_mention_objs->[0]->set_mapped_weight( $concept->{'score'});

            $concept_mention_objs->[0]->save();
        }

        # now check the link_content_umls_concept
        my $link_content_concept_objs =
                TUSK::Keyword::UMLS::link_content_umls_concept->new
                    ->lookup( $concept_cond );

        if ( ! @{$link_content_concept_objs} ) {

            $link_content_concept_objs = [
                TUSK::Keyword::UMLS::link_content_umls_concept->new()];

            $link_content_concept_objs->[0]->set_umls_concept_id(
                                                $concept->{'concept'} );
            $link_content_concept_objs->[0]->set_content_id( $content_id );
            $link_content_concept_objs->[0]->set_author_weight(
                                                $selected_ranks{'rank_'.$concept->{'concept'}});

            $link_content_concept_objs->[0]->save();
        } else {
            if ( $args{'update_rankings'} &&
                $selected_ranks{ 'rank_' . $concept->{'concept'} } !=
                 $link_content_concept_objs->[0]->get_author_weight() ) {
                $link_content_concept_objs->[0]->set_author_weight( $selected_ranks{ 'rank_' . $concept->{'concept'} } );
                $link_content_concept_objs->[0]->save();
            }

            $selected_ranks{'rank_'. $concept->{'concept'}} =
                    $link_content_concept_objs->[0]->get_author_weight;
        }

    }

};

package TUSK::Keyword::UMLS::umls_concept;

use base qw( TUSK::Keyword::UMLS );

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
                    _datainfo => {
                                database => "tusk_umls",
                               tablename => "umls_concept",
                               usertoken => "jderi",
                    },
                    _field_names => {
                       'umls_concept_id' => 'pk',
                        'preferred_form' => '',
                    },
                    _attributes => {
                            save_history => 0,
                         tracking_fields => 0,
                    },
                    _levels =>  {
                    reporting => 'warn',
                    error => 0,  
                    },
                    @_);

    return $self;
}

package TUSK::Keyword::UMLS::umls_concept_mention;

use base qw( TUSK::Keyword::UMLS );

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new (
                    _datainfo => {
                                database => "tusk_umls",
                               tablename => "umls_concept_mention",
                               usertoken => "jderi",
                    },
                    _field_names => {
                        'umls_concept_mention_id' => 'pk',
                                'umls_concept_id' => 'pk',
                                     'content_id' => 'pk',
                              'context_mentioned' => '',
                                        'node_id' => '',
                                     'map_weight' => '',
                                    'mapped_text' => '',
                                       'modified' => '',
                    },
                    _attributes => {
                            save_history => 0,
                         tracking_fields => 0,
                    },
                    _levels =>  {
                    reporting => 'warn',
                    error => 0,
                    },
                    @_);

    return $self;
}

sub get_content_object{
    my $self = shift;
    return HSDB4::SQLRow::Content->new()->lookup_key($self->get_content_id);
}

package TUSK::Keyword::UMLS::link_content_umls_concept;

use base qw( TUSK::Keyword::UMLS );

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new (
                    _datainfo => {
                                database => "tusk_umls",
                               tablename => "link_content_umls_concept",
                               usertoken => "jderi",
                    },
                    _field_names => {
           'link_content_umls_concept_id' => 'pk',
                             'content_id' => 'pk',
                        'umls_concept_id' => 'pk',
                          'author_weight' => '',
                               'modified' => '',
                    },
                    _attributes => {
                            save_history => 0,
                         tracking_fields => 0,
                    },
                    _levels =>  {
                    reporting => 'warn',
                    error => 0,
                    },
                    @_);

    return $self;
}

sub get_content_object{
    my $self = shift;
    return HSDB4::SQLRow::Content->new()->lookup_key($self->get_content_id);
}

1;

__END__

#
#sub insertResponse{
#    my ($self, $user, $values_hashref) = @_;
#
#    my $response = TUSK::Quiz::Response->new();
#    $response->setFieldValues($values_hashref);
#
#    my $retval = $response->save({ user => $user });
#
#    if ($retval != 0){
#    push (@{$self->getResponses}, $response);
#    }
#    
#    return($retval);
#}
#
#sub getResponses{
#    my $self = shift;
#    unless (exists $self->{_responses}){
#    $self->{_responses} = TUSK::Quiz::Response->new->passValues($self)->lookup(
#            "quiz_result_id = " . $self->getPrimaryKeyID, ["quiz_response_id"]);
#    }
#    return $self->{_responses};
#}
#
#sub defineResponses{
#    my ($self) = @_;
#    unless (exists $self->{_responses}){
#    $self->{_responses} = [];
#    }
#}
#
#sub createResponses{
##
##  Responses is a hash ref, the key is a link_quiz_quiz_item_id and the value is the response_text
##  QuizItems is a hash ref, the key is a link_quiz_quiz_item and the value is the relevant quiz_item
##
#    my ($self, $user, $quizItems, $responses) = @_;
#
#    $self->defineResponses;
#
#    my $quiz_id = $self->getQuizID;
#    my $result_id = $self->getPrimaryKeyID;
#
#    foreach my $key (keys %$quizItems){
#    my $response = {};
#
#    my $quizItem = $quizItems->{$key};
#
#    $response->{quiz_result_id} = $result_id;
#    $response->{correct} = undef;
#    $response->{link_quiz_quiz_item_id} = $quizItem->getPrimaryKeyID();
#    
#    my $question = $quizItem->getQuestionObject();
#    $response->{response_text} = $responses->{$question->getPrimaryKeyID()};
#    my $questionType = $question->getType();
#    my $answers = $question->getAnswers() || [];
#    if ($response->{response_text}){
#        foreach my $answer (@{$answers}){
#        if ($questionType eq 'FillIn'){
#            if (lc($response->{response_text}) eq lc($answer->getValue)){
#                $response->{correct} = $answer->getCorrect;
#                $response->{quiz_answer_id} = $answer->getPrimaryKeyID();
#                last;
#            }
#        } else {
#            if ($response->{response_text} == $answer->getPrimaryKeyID()){
#                $response->{correct} = $answer->getCorrect();
#                $response->{quiz_answer_id} = $answer->getPrimaryKeyID();
#                $response->{response_text} = $answer->getValue();
#                last;
#            }
#            
#        }
#        }
#    }
#    $self->insertResponse($user, $response);
#    }
#}
#    
#sub findOpenResult{
#    my ($user_id,$quiz_id) = @_;
#    my $cond = sprintf (" user_id = '%s' AND quiz_id = %d AND end_date IS NULL",$user_id,$quiz_id);
#    my $results = TUSK::Quiz::Result->lookup($cond,undef,undef); 
#    if (scalar(@{$results}) > 1){
#        croak "There is more than one open quiz for user $user_id in quiz $quiz_id";
#    }
#    return pop @{$results};     
#
#}
#
#
#sub isOverdue{
#    my $self = shift;
#    my ($quiz_id,$result_id) = ($self->getQuizID(), $self->getPrimaryKeyID());
#    my $sth = $self->databaseSelect(<<EOM);
#
#SELECT 1
#FROM tusk.quiz_result r, 
#tusk.quiz q
#WHERE r.quiz_result_id = $result_id  AND
#q.quiz_id = r.quiz_id AND
#q.quiz_id = $quiz_id AND
#q.duration != '00:00:00' AND
#((UNIX_TIMESTAMP(r.end_date) - UNIX_TIMESTAMP(r.start_date)) > TIME_TO_SEC(q.duration))
#
#EOM
#    my $results = $sth->fetchrow_array(); 
#    $sth->finish();
#    if ($results){
#        return 1;        
#    } 
#    return 0;    
#}
#

