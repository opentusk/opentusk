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


package TUSK::Application::Competency::Copy;

use strict;

use TUSK::Course;

use TUSK::Competency::Competency;
use TUSK::Competency::Course;
use TUSK::Competency::Hierarchy;



sub new {
    my ($class, $args) = @_;

    my $self = {
	school => $args->{school},
	course_source => $args->{course_source},
	course_target => $args->{course_target}
    };

    bless($self);

    return $self;
}

#######################################################

=item B<copyCompetencies>

    Copy competencies from source course to target course
=cut

sub copyCompetencies {
    my ($self) = @_;

    my $school_id = TUSK::Core::School->new->getSchoolID($self->{school});

    my $tusk_source_id = TUSK::Course->getTuskCourseIDFromSchoolID($school_id, $self->{course_source});
    my $tusk_target_id = TUSK::Course->getTuskCourseIDFromSchoolID($school_id, $self->{course_target});
    
    my $competencies = TUSK::Competency::Course->lookup("course_id=$tusk_source_id AND competency.school_id=$school_id", undef, undef, undef,
			[TUSK::Core::JoinObject->new("TUSK::Competency::Competency", {origkey => 'competency_id', joinkey => 'competency_id', jointype => 'inner'}),
			TUSK::Core::JoinObject->new("TUSK::Competency::Hierarchy", {origkey => 'competency.competency_id', joinkey => 'child_competency_id', jointype => 'inner'})]);

    my %old_new;

    foreach my $competency (@{$competencies}) {
	my $current_competency = $competency->getJoinObject("TUSK::Competency::Competency");
	
	print "Processing competency: " . $current_competency->getTitle(). "\n";

	my $new_competency =  TUSK::Competency::Competency->new();

	$new_competency->setFieldValues({
	    title => $current_competency->getTitle(),
	    competency_user_type_id => $current_competency->getFieldValue('competency_user_type_id'),
	    school_id => $school_id,
	    competency_level_enum_id => $current_competency->getFieldValue('competency_level_enum_id'),
	    version_id => $current_competency->getFieldValue('version_id'),
	});

	$new_competency->save({user => 'copy_script'});

	$old_new{$current_competency->getPrimaryKeyID()} = $new_competency->getPrimaryKeyID();
	
	my $new_competency_course = TUSK::Competency::Course->new();

	$new_competency_course->setFieldValues({
	    competency_id => $new_competency->getPrimaryKeyID(),
	    course_id => $tusk_target_id,
	    sort_order => $competency->getFieldValue('sort_order')
	});

	$new_competency_course->save({user => 'copy_script'});
    }

    foreach my $competency (@{$competencies}) {
	my $current_hierarchy = $competency->getJoinObject("TUSK::Competency::Hierarchy");
	
	my $new_hierarchy = TUSK::Competency::Hierarchy->new();
	my $new_parent_id;

	if ($current_hierarchy->getParentCompetencyID == 0) {
	    $new_parent_id = 0;
	} else  {
	    $new_parent_id = $old_new{$current_hierarchy->getParentCompetencyID};
	}

	my $new_child_id = $old_new{$competency->getCompetencyID};

	$new_hierarchy->setFieldValues({
	    school_id => $school_id,
	    lineage => '/',
	    parent_competency_id => $new_parent_id,
	    child_competency_id => $new_child_id,
	    sort_order => $current_hierarchy->getFieldValue('sort_order'),
	    depth => $current_hierarchy->getFieldValue('depth'),
	});
	
	$new_hierarchy->save({user => 'copy_script'});
    }
    
}

#######################################################

1;
