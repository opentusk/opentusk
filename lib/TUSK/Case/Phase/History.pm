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


package TUSK::Case::Phase::History;

=head1 NAME

B<TUSK::Case::Phase::History> 

=head1 DESCRIPTION

=over 4

=cut

use strict;
use base qw(TUSK::Case::Phase);
use Carp qw(confess cluck);
use Data::Dumper; 

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}



###################
# Field Accessors #
###################


##########################
# End of Field Accessors #
##########################

############
# LinkDefs #
############


###################
# End of LinkDefs #
###################

#######################################################

=item B<getChildHistoryQuestions>

    $arrayref = $phase->getChildHistoryQuestions();

    For an initialized History Phase, this method 
returns an arrayref of TUSK::Case::Phase::History::Question 
objects.

=cut

sub getChildHistoryQuestions{
	my $self = shift;
        if (!defined($self) || !$self->isa("TUSK::Case::Phase::History")){
                confess "Must have TUSK::Case::Phase::History to query for questions";
        }
	my $phase_id = $self->getPrimaryKeyID() or confess "The Phase is not initialized";
	return TUSK::Case::Phase::History::Question->lookup(" phase_id = $phase_id ");

}

#######################################################

=item B<getIncludeFile>

    $string = $phase->getIncludeFile();

    Returns the name of the file containing the UI information
for this phase

=cut
sub getIncludeFile {
    my $self = shift;
    return "history_phase";
}

#######################################################

=item B<getBatteryType>

    $string = $obj->getBatteryType();

Overrides the base method in Phase.pm.

=cut

sub getBatteryType{
	return 'History';
}


package TUSK::Case::Phase::History::Question;


=head1 NAME

B<TUSK::Case::Phase::History::Question> - Class for manipulating entries in table history_phase_question in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'history_phase_question',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'history_phase_question_id' => 'pk',
					'phase_id' => '',
					'question' => '',
					'answer' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getPhaseID>

    $string = $obj->getPhaseID();

    Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

    $string = $obj->setPhaseID($value);

    Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getQuestion>

    $string = $obj->getQuestion();

    Get the value of the question field

=cut

sub getQuestion{
    my ($self) = @_;
    return $self->getFieldValue('question');
}

#######################################################

=item B<setQuestion>

    $string = $obj->setQuestion($value);

    Set the value of the question field

=cut

sub setQuestion{
    my ($self, $value) = @_;
    $self->setFieldValue('question', $value);
}


#######################################################

=item B<getAnswer>

    $string = $obj->getAnswer();

    Get the value of the answer field

=cut

sub getAnswer{
    my ($self) = @_;
    return $self->getFieldValue('answer');
}

#######################################################

=item B<setAnswer>

    $string = $obj->setAnswer($value);

    Set the value of the answer field

=cut

sub setAnswer{
    my ($self, $value) = @_;
    $self->setFieldValue('answer', $value);
}

#######################################################

=item B<getSortOrder>

    $string = $obj->getSortOrder();

    Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

    $string = $obj->setSortOrder($value);

    Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}


#######################################################


=back

=cut

### Other Methods

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;
