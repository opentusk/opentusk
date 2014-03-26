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


package TUSK::Application::Competency::Competency;

use strict;

use Data::Dumper; #Note: For testing purposes, remember to remove!

use TUSK::Competency::Competency;
use TUSK::Competency::Course;
use TUSK::Competency::Hierarchy;

sub new{
    my ($class, $args) = @_;

    my $self = {
	competency_id => $args->{competency_id},
	title => $args->{title},
	description => $args->{description},
	uri => $args->{uri},
	user_type_id => $args->{user_type_id},
	school_id => $args->{school_id},
	competency_level_enum_id => $args->{competency_level_enum_id},
	version_id => $args->{version_id},
	user => $args->{user},
    };
  
    bless($self, $class);

    $self->{competency} = defined($self->{competency_id}) ? TUSK::Competency::Competency->lookupReturnOne( "competency_id =". $self->{competency_id}) : TUSK::Competency::Competency->new();

    return $self;
}

#######################################################

=item B<getChildren>

	Return All children for a particular parent_competency, returns an arrayref.
=cut

sub getChildren {
	my ($self, $extra_cond) = @_;

	my $competency_hierarchy = TUSK::Competency::Hierarchy->lookup("parent_competency_id=" . $self->{competency_id});
    
	my @child_competencies;

	foreach my $competency(@{$competency_hierarchy}){
	    push @child_competencies, $competency->getChildCompetencyID;
	}

	return \@child_competencies;
}


#######################################################

=item B<delete>
    Deletes a given competency object
=cut

sub delete{

    my ($self, $extra_cond) = @_;
    
    my $linked_competencies = $self->getLinked;

    #if no linked child competencies, procede with deleting, otherwise not.
    if ((scalar(@{$linked_competencies})) == 0){
	#delete call to database
	my $delete_check = $self->{competency}->delete();

	return $delete_check; 
    } else { 
	return 0;
    }

}

#######################################################


=item B<deleteAssociated>
    Deletes a given competency object with an associated link ( i.e course_competency, session_competency or content_competency )
=cut

sub deleteAssociated{
    
    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    if (!defined($competency)){
	print "Invalid entry";
	return 0;
    }

    my $competency_level = $competency->getCompetencyLevel;

    if ($competency_level eq "course") {
	my $competency_course = TUSK::Competency::Course->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_course->delete();
    } elsif ($competency_level eq "class_meet"){
	my $competency_class_meet = TUSK::Competency::ClassMeeting->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_class_meet->delete();       
    } elsif ($competency_level eq "content"){
	my $competency_content = TUSK::Competency::Content->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_content->delete();
    } else {
	return 0;
    }
    $self->delete;
    return 1;
}


#######################################################

=item B<update>
    Change different values for the given competency
=cut

sub update{
    
    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    $competency->setTitle((defined($self->{title})) ? $self->{title}: '');
    $competency->setDescription((defined($self->{description})) ? $self->{description}: '');
    $competency->setUri((defined($self->{uri})) ? $self->{uri}: '');
    $competency->setCompetencyUserTypeID((defined($self->{user_type_id})) ? $self->{user_type_id}: '');
    $competency->setSchoolID((defined($self->{school_id})) ? $self->{school_id}: '');
    $competency->setCompetencyLevelEnumID((defined($self->{competency_level_enum_id})) ? $self->{competency_level_enum_id}: '');
    $competency->setVersionID((defined($self->{version_id})) ? $self->{version_id}: '');

    $competency->save({user => $self->{user}});
}


#######################################################

=item B<add>
    Adds a new competency
=cut

sub add{

    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    $competency->setTitle($self->{title});
    $competency->setDescription($self->{description});
    $competency->setUri($self->{uri});
    $competency->setCompetencyUserTypeID($self->{user_type_id});
    $competency->setSchoolID($self->{school_id});
    $competency->setCompetencyLevelEnumID($self->{competency_level_enum_id});
    $competency->setVersionID($self->{school_id}); 

    $competency->save({user => $self->{user}});

    return $competency->getPrimaryKeyID;
}
#######################################################

=item B<addChild>
    Adds a new competency as a child to the current competency
=cut

sub addChild{

    my ($self, $extra_cond) = @_;
    
    print Dumper $self->{competency_id};

    my $child_competency_id = $self->add;

    my $hierarchy = TUSK::Competency::Hierarchy->new();
    $hierarchy->setSchoolID($self->{schooL_id});
    # $hierarchy->setLineage(placeholder);
    # $hierarhcy->setSortOrder(placeholder);
    # $hierarchy->setDepth(placeholder);
    $hierarchy->setParentCompetencyID($self->{competency_id});
    $hierarchy->setChildCompetencyID($child_competency_id);
    $hierarchy->save({user => $self->{user}});
}


#######################################################


=item B<getLinked>
    returns the competencies that have been linked to the current competency.
=cut

sub getLinked{
    my ($self, $extra_cond) = @_;

    my $competency_id_1 = $self->{competency_id};
    
    my $linked = TUSK::Competency::Competency->lookup( 'competency_relation.competency_id_1 =' . $competency_id_1,
                [ 'competency_relation.competency_id_1', 'competency_relation.competency_id_2', 'competency.title', 'competency.description' ],
                undef, undef,
	        [ TUSK::Core::JoinObject->new('TUSK::Competency::Relation', { origkey=> 'competency_id', joinkey=> 'competency_id_2', jointype=> 'inner'})]);

    return $linked;
}

#######################################################

#Other functions:


my @comp_categories;

sub getCategories{
    my ($lib, $data) = @_;
    
    getCategoriesSub($data);
    
    return \@comp_categories;
}

sub getCategoriesSub{

    my ($data) = @_;

    foreach my $d (@{$data}){
	if (($d->{'children'})){
	    my %comp_category;
	    $comp_category{$d->{'id'}} = $d->{title};
	    push @comp_categories, \%comp_category;	
	    getCategoriesSub ($d->{'children'});
	}
    }
    
}


1;
