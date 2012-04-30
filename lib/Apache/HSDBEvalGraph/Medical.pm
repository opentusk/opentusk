package Apache::HSDBEvalGraph::Medical;

use Apache::HSDBEvalGraph;
use vars qw(@ISA);

@ISA = qw(Apache::HSDBEvalGraph);

sub question_class { return "HSDB4::SQLRow::EvalQuestion::Medical" }

1;
__END__
