package TUSK::Case::Phase::ProblemList;

use strict;
use base qw(TUSK::Case::Phase);
use TUSK::Case::PhaseOption;
use TUSK::Case::CaseReport;
use TUSK::Case::PhaseOptionSelection;
use Carp qw(confess cluck);
use Data::Dumper; 

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}


sub getIncludeFile {
    my $self = shift;
    return "problem_list_phase";
}

sub findModelAnswer {
        my $self = shift;
        my $phase_id = $self->getPrimaryKeyID() or return TUSK::Case::PhaseOption->new() ;
        unless ($self->{-model_answer}) {
                my $options = TUSK::Case::PhaseOption->lookup(" phase_id = $phase_id ");
		if (scalar(@{$options}) > 1 ){
			confess "There are multiple model answers";
		} elsif (scalar(@{$options}) == 0){
			$self->{-model_answer} = TUSK::Case::PhaseOption->new();	
		} else {
			$self->{-model_answer} = pop @{$options} ;
		}
	}
	return $self->{-model_answer};

}
sub getModelAnswer {
	my $self = shift;
	return $self->findModelAnswer()->getOptionText() || "";
}


sub setModelAnswer{
	my $self = shift;
	my $model = shift;
	my $option;
	if (!$self->{-model_answer}){
		$self->findModelAnswer();
	}
	if ($self->{-model_answer} 
		&& ref $self->{-model_answer} 
		&& $self->{-model_answer}->isa('TUSK::Case::PhaseOption')){
		$self->{-model_answer}->setOptionText($model);
	} else {
		$option = TUSK::Case::PhaseOption->new();
		$option->setPhaseID($self->getPrimaryKeyID());  	
		$option->setOptionText($model);
		$self->{-model_answer} = $option;
	}

}


sub afterSave {
        my $self = shift;
        my $params = shift;
	if ($self->{-model_answer}){
		$self->{-model_answer}->setPhaseID($self->getPrimaryKeyID());
		$self->{-model_answer}->save($params);
	}
        return 1;

}
1;
