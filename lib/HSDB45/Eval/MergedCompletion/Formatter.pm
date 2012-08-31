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


package HSDB45::Eval::MergedCompletion::Formatter;

use strict;

use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Eval::MergedResults;

use base qw(HSDB45::Eval::Completion::Formatter);

sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    $path =~ s/^\///;
    my ($school, $id) = split(/\//, $path);
    my $object = HSDB45::Eval::MergedResults->new(_school => $school, _id => $id);
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = '';
    $self->{-dtd_decl} = '';
    $self->{-stylesheet_decl} = '';
    return $self;
}

sub get_xml_elt {
    my $self = shift();
    unless($self->{-xml_elt}) {
	my $eval = $self->object();
	my $num_users = $eval->enrollment();
	my $num_comps = $eval->total_completions();
	my $percent = 0;
	if (!$num_users){
		$num_users = $num_comps;
		$percent =  sprintf("%.2f", 100);
	}
	else {
		$percent =  sprintf("%.2f", 100 * $num_comps / $num_users);
	}
	my $num_incomps = $num_users - $num_comps;

	$self->{-xml_elt} = XML::Twig::Elt->new("Enrollment", {"count" => $num_users});

	my $complete_users_elt = XML::Twig::Elt->new("CompleteUsers",
						     {"count"   => $num_comps,
						      "percent" => $percent });
	foreach my $complete_user_id ($eval->user_codes()) {
	    my $complete_user_elt = XML::Twig::Elt->new("user-ref",
							{"user-id" => $complete_user_id },
							make_pcdata($complete_user_id));
	    $complete_user_elt->set_asis();
	    $complete_user_elt->paste('last_child', $complete_users_elt);
	}
	$complete_users_elt->paste('last_child', $self->{-xml_elt});

	$percent = 0; 
	if ($num_users){
		$percent = sprintf("%.2f", 100 * $num_incomps / $num_users);
	} 

	my $incomplete_users_elt = XML::Twig::Elt->new("IncompleteUsers",
						       {"count"   => $num_incomps,
							"percent" => $percent });
	$incomplete_users_elt->paste('last_child', $self->{-xml_elt});

	my $deficit =  $num_users - $self->object()->total_completions();
	if($deficit > 0) {
	    my $completion_token_deficit_elt = XML::Twig::Elt->new("CompletionTokenDeficit", {}, $deficit);
	    $completion_token_deficit_elt->paste('last_child', $self->{-xml_elt});
	}

	my $excess =  $num_comps - $num_users;
	if($excess > 0) {
	    my $excess_completions_elt = XML::Twig::Elt->new("ExcessCompletions", {}, $excess);
	    $excess_completions_elt->paste('last_child', $self->{-xml_elt});
	}
    }

    return $self->{-xml_elt};
}

1;
__END__
