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


package TUSK::Application::GradeBook::FinalGrade::ByEvent;

use base qw(TUSK::Application::GradeBook::FinalGrade);

use strict;
use TUSK::Functions;


sub new {
    my ($class, $args) = @_;
    my $self = {
		user_id => $args->{user_id},
		final_grade_event => $args->{final_grade_event},
		course => $args->{course},
	};
    bless($self, $class);
    return $self;
}

=item
   Given link_user_grade_event objects, mapped with event objects, keyed by student_id, we calculate the final grades
=cut

sub calculate {
	my ($self, $grade_records) = @_;
	foreach my $student_id (keys %$grade_records) {
		my $final_grade = 0;
		my $records = $grade_records->{$student_id};

		foreach my $record (@$records) {
			my $weight = $record->getGradeEventObject()->getWeight();
			my $grade = $record->getGrade();
			my $max_possible_points = $record->getGradeEventObject()->getMaxPossiblePoints();
			if (TUSK::Functions::isValidNumber($grade) && TUSK::Functions::isPositiveNumber($max_possible_points) && TUSK::Functions::isPositiveNumber($weight)) {
				$final_grade += ($grade/$max_possible_points) * ($weight);
			}
		}
		$self->{final_grade_records}{$student_id} = $final_grade;
	}
		   

}

1;
