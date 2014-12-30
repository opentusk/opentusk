# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::Competency::Tree;

use strict;

use TUSK::Application::Competency::Competency;
use TUSK::Competency::Competency;

use TUSK::Enum::Data;

sub new {
    my ($class, $args) = @_;

    my $self = {
	competency_id => $args->{competency_id},
    };
  
    bless($self, $class);

    $self->{competency} = TUSK::Competency::Competency->lookupReturnOne("competency_id =". $self->{competency_id});
    
    return $self;
}

#######################################################

=item B<deleteFromTree>
    #Deletes a given competency and it's child competencies (i.e. everything under it in tree)
	
=cut

sub deleteFromTree {
    
    my ($self, $extra_cond) = @_;
        
    my $competency_tree = $self->getBranch;
    deleteFromTreeHelper($competency_tree);
}

sub deleteFromTreeHelper {
    my ($competency_tree) = @_;
       
    foreach my $key (keys %{$competency_tree}) {
	if (ref $competency_tree->{$key} eq 'HASH') {	    
	    deleteFromTreeHelper($competency_tree->{$key});
	}
	my $competency_args = {
	    competency_id => $key,
	};
	my $competency_to_delete = TUSK::Application::Competency::Competency->new($competency_args);
        $competency_to_delete->delete($key);
	#add delete links here
    }
}

#######################################################

=item B<getLinkedBranch>
   Returns entire subtree for a given parent_competency_id, returns a reference to a nested hash with indefinite dimensions.
   Accepts optional param for maximum depth to reduce the returned tree to a certain number of levels.
=cut

sub getLinkedBranch {
 
    my ($self, $max_depth) = @_;

    use Data::Dumper;

    if (!$max_depth) {
	$max_depth = 99;
    }

    my @branch;
    getLinkedBranchHelper($self->{competency_id}, \@branch, $max_depth);
    
    return $branch[0];

}

sub getLinkedBranchHelper {
     #helper function for implementing getLinkedBranch 

    my ($competency_id, $branch, $max_depth) = @_;

    my $competency  = {
	competency_id => $competency_id,
    };

    my $this_competency = TUSK::Application::Competency::Competency->new($competency);   

    if (! $this_competency) {
	return;
    }

    my %this_competency_hash;

    my $competency_level_enum_id = $this_competency->{'competency'}->getFieldValue('competency_level_enum_id');

    my $competency_level = TUSK::Enum::Data->lookupReturnOne("enum_data_id = $competency_level_enum_id AND namespace = \"competency.level_id\"")->getShortName;        

    %this_competency_hash = (
			     competency_id => $this_competency->{'competency_id'},
			     title => $this_competency->{'competency'}->getFieldValue('title'),
			     description => $this_competency->{'competency'}->getFieldValue('description'),			     
			     level => $competency_level,
			     children => [],
			     course => $competency_level
    );
=for
    if ($competency_level == "course") {
	$this_competency_hash{'course'}  = "testing course";
	my $this_course = TUSK::Competency::Course->lookupReturnOne("competency_id = $this_competency->{'competency_id'}")->getCourseID;
	$this_competency_hash{'course'}  = $this_course;
    }
=cut

    push @{$branch}, {%this_competency_hash};

    $max_depth--;

    if ($max_depth == 0) {
	return;
    }

    foreach my $child_competency_id (@{$this_competency->getLinked}) {
	getLinkedBranchHelper($child_competency_id, $this_competency_hash{'children'}, $max_depth);
    }

}


#######################################################

=item B<getBranch>
   Returns entire subtree for a given parent_competency_id, returns a reference to a nested hash with indefinite dimensions.
	
=cut

sub getBranch {
 
    my ($self, $extra_cond) = @_;
    
    my %branch;

    my $hash_string = '$branch->{'. $self->{competency_id}. '}';

    getBranchHelper($self->{competency_id}, $hash_string , \%branch);
    
    return \%branch;
}


sub getBranchHelper {
     #helper function for implementing getBranch 

    my ($competency_id, $index, $branch) = @_;

    my %child_competencies;

    my $competency  = {
	competency_id => $competency_id,
    };

    my $this_competency = TUSK::Application::Competency::Competency->new($competency);

    %child_competencies = map {$_ => 0} @{$this_competency->getChildren};
    my $assign = $index.' = {%child_competencies};';
    eval($assign);

    foreach my $key(keys %child_competencies){
	my $new_index = $index."->{".$key."}";
	getBranchHelper($key, $new_index, $branch);
    }
}



######################################################

#generic walk tree function to traverse competency trees.

sub walk{ 

    my ($lib, $competency_tree, $depth) = @_;

    $depth = $depth + 1;
    
    foreach my $key(keys %{$competency_tree}) {
	print "Competency id: $key <br>";
	if (ref $competency_tree->{$key} eq 'HASH') {
	    print "&nbsp&nbsp&nbsp&nbsp" x $depth;
	    walk($lib, $competency_tree->{$key}, $depth);
	}
    }    
}



sub build {
    my $competencies;

    foreach( @{TUSK::Competency::Competency->new()->lookup()} ) {                                                                                                                                                                               	$competencies->{$_->getCompetencyID} = $_;                                                                                                                                                                                    
    }   

    my ($lib, $school_id, $root_id) = @_;
    my $c_href;
    my $children_storage;
    my %p_c_pairs;
    my $info_user_type_id;
    
    if (TUSK::Competency::UserType->lookupReturnOne( "school_id = $school_id", undef, undef, undef, [TUSK::Core::JoinObject->new( 'TUSK::Enum::Data', {joinkey => 'enum_data_id', origkey => 'competency_type_enum_id', joincond => "namespace=\"competency.user_type.id\" AND short_name=\"info\"", jointype => 'inner'})])){
    $info_user_type_id = TUSK::Competency::UserType->lookupReturnOne( "school_id = $school_id", undef, undef, undef, 
								       [TUSK::Core::JoinObject->new( 'TUSK::Enum::Data', {joinkey => 'enum_data_id', origkey => 'competency_type_enum_id', joincond => "namespace=\"competency.user_type.id\" AND short_name=\"info\"", jointype => 'inner'})])->getPrimaryKeyID;
} else {
    $info_user_type_id = 0;
}
    
    my $cr = TUSK::Competency::Hierarchy->lookup( 'competency_hierarchy.school_id ='. $school_id, 
						  ['depth desc', 'parent_competency_id', 'sort_order'], undef, undef,
						  [ TUSK::Core::JoinObject->new('TUSK::Competency::Competency', { origkey=> 'child_competency_id', joinkey=> 'competency_id', jointype=> 'inner'})]);

    foreach my $cr_row (@{$cr}) {
	if (defined($competencies->{$cr_row->getChildCompetencyID()})){
	    my $child_comp = $competencies->{$cr_row->getChildCompetencyID()};
	    if (!defined( $c_href->{$child_comp->getCompetencyID}) ) {
		$c_href->{$child_comp->getCompetencyID} = { 
		                                               id          => $child_comp->getCompetencyID, 
							       title       => $child_comp->getTitle,
							       description => $child_comp->getDescription,
							       children    => $children_storage->{$child_comp->getCompetencyID},
							   };
			}	

	    if (!$p_c_pairs{$cr_row->getParentCompetencyID() . "-" . $child_comp->getCompetencyID} && $child_comp->getCompetencyUserTypeID != $info_user_type_id) {
		$p_c_pairs{$cr_row->getParentCompetencyID() . "-" . $child_comp->getCompetencyID} = 1;
		push @{$children_storage->{$cr_row->getParentCompetencyID()}}, $c_href->{$child_comp->getCompetencyID} 

	    }
	}
    }
    
    return $children_storage->{$root_id};
}



1;

