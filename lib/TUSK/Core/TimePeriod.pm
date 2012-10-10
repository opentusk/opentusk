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


package TUSK::Core::TimePeriod;

=head1 NAME

B<TUSK::Core::TimePeriod> - Class for manipulating entries in table time_period in tusk database

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
use Carp qw(cluck croak confess);

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
					'tablename' => 'time_period',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'time_period_id' => 'pk',
					'school_id' => '',
					'label' => '',
					'academic_year' => '',
					'start_date' => '',
					'end_date' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
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

=item B<getSchoolID>

    $string = $obj->getSchoolID();

    Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getLabel>

    $string = $obj->getLabel();

    Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

    $string = $obj->setLabel($value);

    Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}


#######################################################

=item B<getAcademicYear>

    $string = $obj->getAcademicYear();

    Get the value of the academic_year field

=cut

sub getAcademicYear{
    my ($self) = @_;
    return $self->getFieldValue('academic_year');
}

#######################################################

=item B<setAcademicYear>

    $string = $obj->setAcademicYear($value);

    Set the value of the academic_year field

=cut

sub setAcademicYear{
    my ($self, $value) = @_;
    $self->setFieldValue('academic_year', $value);
}


#######################################################

=item B<getStartDate>

    $string = $obj->getStartDate();

    Get the value of the start_date field

=cut

sub getStartDate{
    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

#######################################################

=item B<setStartDate>

    $string = $obj->setStartDate($value);

    Set the value of the start_date field

=cut

sub setStartDate{
    my ($self, $value) = @_;
    $self->setFieldValue('start_date', $value);
}


#######################################################

=item B<getEndDate>

    $string = $obj->getEndDate();

    Get the value of the end_date field

=cut

sub getEndDate{
    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

#######################################################

=item B<setEndDate>

    $string = $obj->setEndDate($value);

    Set the value of the end_date field

=cut

sub setEndDate{
    my ($self, $value) = @_;
    $self->setFieldValue('end_date', $value);
}

=back

=cut

### Other Methods

#######################################################

=item B<getMostRecentSchoolTimePeriod>

    $obj = $obj->setMostRecentTimePeriod($school_id);

    Get the most recent time period object for a specific school.

=cut

sub getMostRecentSchoolTimePeriod {
    my ($self, $school_id) = @_;
    croak "getMostRecentSchoolTimePeriod failed - no school speficied in class ".ref($self) unless ($school_id);
    my $time_period = TUSK::Core::TimePeriod->new->passValues($self);
    my @order_by = ("time_period.start_date desc"); 
    my $latest = $time_period->lookup("school_id = $school_id",\@order_by,0,"1");
    return $$latest[0];
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

