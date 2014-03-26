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


sub new{
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

sub deleteFromTree{
    
    my ($self, $extra_cond) = @_;
        
    my $competency_tree = $self->getBranch;
    deleteFromTreeHelper($competency_tree);
}

sub deleteFromTreeHelper{
    my ($competency_tree) = @_;
       
    foreach my $key(keys %{$competency_tree}){
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

=item B<getBranch>
   Returns entire subtree for a given parent_competency_id, returns a reference to a nested hash with indefinite dimensions.
	
=cut

sub getBranch{
 
    my ($self, $extra_cond) = @_;
    
    my %branch;

    my $hash_string = '$branch->{'. $self->{competency_id}. '}';

    getBranchHelper($self->{competency_id}, $hash_string , \%branch);
    
    return \%branch;
}


sub getBranchHelper{
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



sub walk{ 

    my ($lib, $competency_tree, $depth) = @_;

    $depth = $depth + 1;
    
    foreach my $key(keys %{$competency_tree}){
	print "Competency id: $key <br>";
	if (ref $competency_tree->{$key} eq 'HASH') {
	    print "&nbsp&nbsp&nbsp&nbsp" x $depth;
	    walk($lib, $competency_tree->{$key}, $depth);
	}
    }    
}



sub build{
    my $competencies;

    foreach( @{TUSK::Competency::Competency->new()->lookup()} ) {                                                                                                                                                                               	$competencies->{$_->getCompetencyID} = $_;                                                                                                                                                                                    
    }   

    my ($lib, $school_id, $root_id) = @_;
    my $c_href;
    my $children_storage;
    my %p_c_pairs;
    
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
	    if (!$p_c_pairs{$cr_row->getParentCompetencyID() . "-" . $child_comp->getCompetencyID}) {
		$p_c_pairs{$cr_row->getParentCompetencyID() . "-" . $child_comp->getCompetencyID} = 1;
		push @{$children_storage->{$cr_row->getParentCompetencyID()}}, $c_href->{$child_comp->getCompetencyID} 
	    }
	}
    }
    
    return $children_storage->{$root_id};
}



1;

