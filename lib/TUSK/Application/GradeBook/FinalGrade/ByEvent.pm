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
			if (TUSK::Functions::isValidNumber($grade) && TUSK::Functions::isValidNumber($weight)) {
				$final_grade += ($grade/$max_possible_points) * ($weight);
			}
		}
		$self->{final_grade_records}{$student_id} = $final_grade;
	}
		   

}

1;
