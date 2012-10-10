package TUSK::Application::GradeBook::FinalGrade;

=head1 NAME

B<TUSK::Application::GradeBook::FinalGrade> - Class for calculating final grades

=cut


use strict;
use TUSK::GradeBook::LinkUserGradeEvent;
use TUSK::GradeBook::GradeMultiple;

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

sub process {
	my ($self, $raw_grade_records) = @_;

	return unless $raw_grade_records;
	$self->calculate($raw_grade_records);

	if ($self->{final_grade_records}) {  ### this attribute is derived from final grade calculation
		if ($self->{final_grade_event}) {
			my ($final_grades, $saved_grades) = $self->{final_grade_event}->getFinalGradeRecords($self->{course});

			my %existing_records = map { $_->getParentUserID() => $_ } @$saved_grades;
			foreach my $student_id (keys %{$self->{final_grade_records}}) {
				if (exists $existing_records{$student_id}) {
					$existing_records{$student_id}->setGrade($self->{final_grade_records}{$student_id});
					$existing_records{$student_id}->save({user => $self->{user_id}});
					my $calc = $existing_records{$student_id}->getJoinObject('calculated');
					if (ref $calc eq 'TUSK::GradeBook::GradeMultiple') {
						$calc->setGrade($self->{final_grade_records}{$student_id});
						$calc->save({user => $self->{user_id}});
					} else {
						my $multi = TUSK::GradeBook::GradeMultiple->new();
						$multi->setLinkUserGradeEventID($existing_records{$student_id}->getPrimaryKeyID());
						$multi->setGrade($self->{final_grade_records}{$student_id});
						$multi->setGradeType($TUSK::GradeBook::GradeMultiple::CALCULATED_FINAL_GRADETYPE);
						$multi->save({user => $self->{user_id}});
					}
				} else {
					my $link = TUSK::GradeBook::LinkUserGradeEvent->new();
					$link->setParentUserID($student_id);
					$link->setChildGradeEventID($self->{final_grade_event}->getPrimaryKeyID());
					$link->setGrade($self->{final_grade_records}{$student_id});
					$link->save({user => $self->{user_id}});

					my $multi = TUSK::GradeBook::GradeMultiple->new();
					$multi->setLinkUserGradeEventID($link->getPrimaryKeyID());
					$multi->setGrade($self->{final_grade_records}{$student_id});
					$multi->setGradeType($TUSK::GradeBook::GradeMultiple::CALCULATED_FINAL_GRADETYPE);
					$multi->save({user => $self->{user_id}});
				}
			}
		}
	}
}


1;
