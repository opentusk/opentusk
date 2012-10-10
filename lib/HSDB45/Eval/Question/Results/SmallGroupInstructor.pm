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


package HSDB45::Eval::Question::Results::SmallGroupInstructor;

### results for a same small group instructor

use base qw( HSDB45::Eval::Question::Results );
use HSDB45::Eval::Question::ResponseGroup::SmallGroupInstructor;

# Description: Constructor
# Input: HSDB45::Eval::Question::Results object, HSDB45::Eval::Results, and list of user codes
# Output: Newly created HSDB45::Eval::Question::ResponseGroup object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}


# Description: Private initializer
# Input: HSDB45::Eval::Question object, HSDB45::Eval::Results, user_id of the small group instructor
# Output: HSDB45::Eval::Question::Results object which has been initialized; reblesses object as required
sub init {
    my $self = shift;

    $self->{-eval_question} = shift;
    die "Was expecting an HSDB45::Eval::Question object..." unless($self->question()->isa("HSDB45::Eval::Question"));
    $self->{-eval_results} = shift;
    die "Was expecting an HSDB45::Eval::Results object..." unless($self->eval_results()->isa("HSDB45::Eval::Results"));

    $self->{-user_codes} = shift;

    $self->{-resps_by_instructor} = HSDB45::Eval::Question::ResponseGroup::SmallGroupInstructor->new($self, "__Instructor__");

    $self->lookup_responses();
    return $self;
}



# Description: Looks up the responses from the database
sub lookup_responses {
    my $self = shift;
    my @user_codes = map { "'" . $_ . "'" } keys %{$self->{-user_codes}};
    my @conds = (sprintf ("eval_id=%d", $self->question()->parent_eval()->primary_key),
		 sprintf ("eval_question_id=%d", $self->question()->primary_key),  
		 "user_code in (" . join( ',', @user_codes) . ")" );
    my $blankresp = HSDB45::Eval::Question::Response->new(_school => $self->question()->school());

    push @{$self->{some_responses}}, join("\n", $blankresp->lookup_conditions(@conds));
    push @{$self->{some_responses}}, join("\n", @conds);
    for my $resp ($blankresp->lookup_conditions(@conds)) {
	$resp->set_aux_info ('parent_results' => $self);
	$self->{-resps_by_instructor}->add_response($resp);

    }
    return;
}


# Description: Look up a response by user_code
# Input: User code
# Output: Response object
sub response {
    my $self = shift;
    $self->{-resps_by_instructor}->response (@_);
}


# Description: Look up all of the responses
# Input: 
# Output: List of Response objects
sub responses {
    my $self = shift;
    $self->{-resps_by_instructor}->responses (@_);
}

sub is_numeric {
    my $self = shift;
    return 1;
}


sub statistics {
    my $self = shift();
    return HSDB45::Eval::Question::ResponseStatistics->new($self->{-resps_by_instructor});
}


1;
