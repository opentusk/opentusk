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


package TUSK::Case::Phase::SOAP;

use strict;
use base qw(TUSK::Case::Phase);
use TUSK::Case::PhaseOption;
use TUSK::Case::CaseReport;
use TUSK::Case::PhaseOptionSelection;
use Carp qw(confess cluck);
use Data::Dumper; 

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}
our $SOAPOptions = {'Subjective' => 1, 'Objective'=>1,'Assessment'=>1,'Plan'=>1};
our @SOAPOptions = ('Subjective','Objective','Assessment','Plan');

sub getIncludeFile {
    my $self = shift;
    return "soap_phase";
}

#######################################################

=item B<isValidSOAPOption>

   $class->isValidSOAPOption('<SOAP Type>')

This internal function returns whether the text specified is a 
valid soap option type

=cut

sub isValidSOAPOption{
	my $self = shift;
	my $soapOption = shift;
	return 1 if ($TUSK::Case::Phase::SOAP::SOAPOptions->{$soapOption});
	return 0;

}
#######################################################

=item B<setSOAPOption>

   $phase->setSOAPOption('<SOAP Type>',$phase_option_obj)

This internal function sets a phase option object and corresponds it 
to a soap type for the phase

=cut

sub setSOAPOption{
        my $self = shift;
        my $soapOption = shift;
	my $phase_option = shift;
	if ($self->isValidSOAPOption($soapOption)){
		$self->{-phase_options}->{$soapOption} = $phase_option;
	} else {
		confess "Invalid soap option trying to be set $soapOption";
	}
}

#######################################################

=item B<findSOAPOption>

   $phase_option = $phase->findSOAPOption('<SOAP Type>')

This internal function returns the phase option associated with the soap type
requested for the particular phase.

=cut

sub findSOAPOption{
	my $self = shift;
	my $soapOption = shift;
        unless ($self->{-phase_options}){
		my %tempHash =  map { ($_->getSoapType() , $_  ) } @{$self->getPhaseOptions()};
                $self->{-phase_options} = \%tempHash;
        }
	if (!$self->isValidSOAPOption($soapOption)){
		confess "Invalid soap option trying to be found  $soapOption";
	}

	my $phase_option = $self->{-phase_options}->{$soapOption};
	return $phase_option;

}
#######################################################


=item B<getSubjectiveOption>


=cut

sub getSubjectiveOption {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Subjective');
        if (defined($phase_option)){
                return $phase_option;
        }
        return undef;
}

#######################################################
=item B<getObjectiveOption>


=cut

sub getObjectiveOption {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Objective');
        if (defined($phase_option)){
                return $phase_option;
        }
        return undef;
}

#######################################################
=item B<getAssessmentOption>


=cut

sub getAssessmentOption {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Assessment');
        if (defined($phase_option)){
                return $phase_option;
        }
        return undef;
}

#######################################################
=item B<getPlanOption>


=cut

sub getPlanOption {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Plan');
        if (defined($phase_option)){
                return $phase_option;
        }
        return undef;
}

#######################################################

=item B<getSubjective>


=cut

sub getSubjective {
	my $self = shift;
	my $phase_option = $self->findSOAPOption('Subjective');
	if (defined($phase_option)){
		return $phase_option->getOptionText();
	}
	return undef;	
}
#######################################################

=item B<getObjective>


=cut

sub getObjective {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Objective');
        if (defined($phase_option)){
                return $phase_option->getOptionText();
        }
        return undef; 
}

#######################################################

=item B<getAssessment>


=cut

sub getAssessment {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Assessment');
        if (defined($phase_option)){
                return $phase_option->getOptionText();
        }
        return undef; 


}
#######################################################

=item B<getPlan>


=cut

sub getPlan {
        my $self = shift;
        my $phase_option = $self->findSOAPOption('Plan');
        if (defined($phase_option)){
                return $phase_option->getOptionText();
        }
        return undef; 
}


#######################################################

=item B<setOption>


=cut


sub setOption {
	my $self = shift;
	my $option_type = shift;
	my $text = shift;
	my $phase_option = $self->findSOAPOption($option_type);
	if (!defined($phase_option)){
		$phase_option = TUSK::Case::PhaseOption->new();
		$self->setSOAPOption($option_type,$phase_option);
		$phase_option->setPhaseID($self->getPrimaryKeyID());
		$phase_option->setSoapType($option_type);
	}
	$phase_option->setOptionText($text);

}


#######################################################

=item B<setSubjective>


=cut


sub setSubjective{
	my $self = shift;
	my $val = shift;
	$self->setOption('Subjective',$val);
}
#######################################################

=item B<setObjective>


=cut

sub setObjective{
	my $self = shift;
	my $val = shift;
	$self->setOption('Objective',$val);
}
#######################################################

=item B<setAssessment>


=cut

sub setAssessment{
	my $self = shift;
	my $val = shift;
	$self->setOption('Assessment',$val);
}
#######################################################

=item B<setPlan>


=cut

sub setPlan{
	my $self = shift;
	my $val = shift;
	$self->setOption('Plan',$val);
}
#######################################################

=item B<afterSave>


=cut

sub afterSave{
	my $self = shift;
	my $params = shift;
	foreach my $opt (keys %{$self->{-phase_options}}){
		$self->{-phase_options}->{$opt}->save($params);
	}
	return 1;
}

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut


1;
