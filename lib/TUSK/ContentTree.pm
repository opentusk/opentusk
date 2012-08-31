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


package TUSK::ContentTree;

use strict;
use HSDB4::SQLRow::Content;
use HSDB4::SQLLink;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { 
		 branches=>[],
		 _filter=>"",
	         _mod_time=>"",
	         _seen => {},
	         _count => 0};
    $self->{_ids} = shift;
    $self->{_filter} = shift;
    # modified since time will limit results
    $self->{_mod_time} = shift;
    bless $self, $class;
    $self->spider_tree;
    return $self;
}

sub return_branches_ref{
    my $self=shift;
    return $self->{branches};
}

sub get_filter {
    my $self = shift;
    return $self->{_filter};
}

sub get_modified_since_time {
    my $self = shift;
    return $self->{_mod_time};
}

sub spider_tree{
    my $self=shift;
    my $arrayref = shift || $self->{_ids};
    my $tab = shift || 0;
    my $count= scalar (@{$arrayref});
    my $parent = shift;
    for(my $i=0; $i<$count; $i++){
	my $content = $arrayref->[$i];
	$self->{_count}++;
	if ($self->run_filter($content)) {
	    my $authors= join(',', map {$_->out_abbrev} $content->child_users) || "";
	    push(@{$self->{branches}}, {content => $content,
				    tab => $tab,
				    path => $parent,
				    authors => $authors});
	}
	if ($content->field_value('type') eq "Collection" && !$self->{_seen}{$content->primary_key}){
	    $self->{_seen}{$content->primary_key}++;
	    $self->spider_tree($content->child_contentref, $tab+1, $parent . "/" . $content->primary_key);
	}

    }

}

sub run_filter {
    my $self = shift;
    my $content = shift;
    if ($self->get_filter) {
	return unless ($self->get_filter eq $content->type);
    }
    if ($self->get_modified_since_time) {
	return unless ($content->modified->out_unix_time > $self->get_modified_since_time);
    }
    return 1;
}

1;
