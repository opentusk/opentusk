package TUSK::Import::Structure;

use strict;
use Data::Dumper;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_course_users => [],
	        };
    return bless $self, $class;
}

sub add_course_student {
    my ($self,$course_id,$user_id,$time_period_id) = @_;
    my $course_student = {"course_id" => $course_id,
			  "user_id" => $user_id,
			  "time_period_id" => $time_period_id};
    push(@{$self->{_course_users}},$course_student);
}

sub save {
    my ($self,$un,$pw) = @_;
    foreach (@{$self->{_course_users}}) {
	print Dumper($_);
    }    
}

1;
