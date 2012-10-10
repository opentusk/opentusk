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


package TUSK::Case::PhaseVisit;

=head1 NAME

B<TUSK::Case::PhaseVisit> - Class for manipulating entries in table case_phase_visit in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


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
					'tablename' => 'case_phase_visit',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'phase_visit_id' => 'pk',
					'case_report_id' => '',
					'phase_id' => '',
					'visit_date' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_join_objects => [
					TUSK::Core::JoinObject->new("TUSK::Case::Phase")
					],
				    _default_order_bys =>['visit_date'],
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getCaseReportID>

my $string = $obj->getCaseReportID();

Get the value of the case_report_id field

=cut

sub getCaseReportID{
    my ($self) = @_;
    return $self->getFieldValue('case_report_id');
}

#######################################################

=item B<setCaseReportID>

$obj->setCaseReportID($value);

Set the value of the case_report_id field

=cut

sub setCaseReportID{
    my ($self, $value) = @_;
    $self->setFieldValue('case_report_id', $value);
}


#######################################################

=item B<getPhaseID>

my $string = $obj->getPhaseID();

Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

$obj->setPhaseID($value);

Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getVisitDate>

my $string = $obj->getVisitDate();

Get the value of the visit_date field

=cut

sub getVisitDate{
    my ($self) = @_;
    return $self->getFieldValue('visit_date');
}

#######################################################

=item B<setVisitDate>

$obj->setVisitDate($value);

Set the value of the visit_date field

=cut

sub setVisitDate{
    my ($self, $value) = @_;
    $self->setFieldValue('visit_date', $value);
}

#######################################################

=item B<getPhaseObject>

$phase = $obj->getPhaseObject();

Return the phase object associated with this phase visit.

=cut

sub getPhaseObject {
	my $self = shift;
	return $self->getJoinObject("TUSK::Case::Phase");
}


=back

=cut

### Other Methods



#######################################################

=item B<setVisitOrder>

$phase = $obj->setVisitOrder();

Set a visit order.

=cut

sub setVisitOrder {
	my $self = shift;
	my $order = shift;
	$self->{-visit_order} = $order;
}

#######################################################

=item B<getVisitOrder>

$phase = $obj->getVisitOrder();

Return the visit order.

=cut

sub getVisitOrder {
	my $self = shift;
	return $self->{-visit_order};
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

