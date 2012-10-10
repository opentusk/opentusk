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


package HSDB45::Eval::Question::Categorization;

use strict;

# Description: Constructor
# Input: Parent HSDB45::Eval::Question::Results object, Grouping ::Question::Results object
# Output: Newly created HSDB45::Eval::Question::Categorization object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub null_resp {
    return '__NULL__';
}

# Description: Private initializer
# Input: Parent HSDB45::Eval::Question::Results object, Grouping ::Question::Results object
# Output: Initialized HSDB45::Eval::Question::ResponseGroup object
sub init {
    my $self = shift;
    $self->{-parent_results} = shift;
    $self->{-grouping_results} = shift;
    $self->do_categorization;
    return $self;
}

sub parent_results {
    my $self = shift();
    return $self->{-parent_results};
}

sub grouping_results {
    my $self = shift();
    return $self->{-grouping_results};
}

# Description: Returns a response group if we have it
# Input: The label for the group
# Output: The Eval::Question::ResponseGroup object
sub response_group {
    my $self = shift;
    my $label = shift;
    return $self->{-categories}{$label};
}

# Description: Get the categories for the responses
# Input: 
# Output: A list of the labels of the response groups
sub response_group_labels {
    my $self = shift;
    return keys %{$self->{-categories}};
}

# Description: Makes a new response group, and does the right thing with it
# Input: 
# Output: 
sub new_response_group {
    my $self = shift;
    my $label = shift;
    my $response_group = HSDB45::Eval::Question::ResponseGroup->new ($self->parent_results, $label);
    $self->{-categories}{$label} = $response_group;
}

# Description: Private function to actually split responses into ResponseGroups
# Input: 
# Output: 
sub do_categorization {
    my $self = shift;
    $self->{-categories} = {};
    # Make a ResponseGroup for non-existent responses
    $self->new_response_group (null_resp());
    for my $resp ($self->parent_results()->responses()) {
	# Find the response for this user to the other question
	my $otherresp = $self->grouping_results ()->response( $resp->user_code );
	my $label = $otherresp ? $otherresp->interpreted_response() : null_resp();
	# See if we have a category like that yet, and make it otherwise
	$self->new_response_group ($label) unless $self->response_group ($label);
	# And then add the response
	$self->response_group ($label)->add_response ($resp);
    }
    # If there are no responses for non-existent responses, then delete that group
    if ($self->response_group(null_resp())->responses() == 0) {
	delete($self->{-categories}{ null_resp() });
    }
}

1;
__END__
