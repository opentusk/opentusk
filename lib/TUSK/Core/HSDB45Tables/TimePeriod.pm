# Copyright 2013 Tufts University
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


package TUSK::Core::HSDB45Tables::TimePeriod;

use HSDB4::DateTime;

=head1 NAME

B<TUSK::Core::HSDB45Tables::TimePeriod> - Class for manipulating entries in table time_period in hsdb45_med_admin database

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
					'database' => '',
					'tablename' => 'time_period',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'time_period_id' => 'pk',
					'academic_year' => '',
					'period' => '',
					'start_date' => '',
					'end_date' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
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

=item B<getAcademicYear>

my $string = $obj->getAcademicYear();

Get the value of the academic_year field

=cut

sub getAcademicYear{
    my ($self) = @_;
    return $self->getFieldValue('academic_year');
}

#######################################################

=item B<setAcademicYear>

$obj->setAcademicYear($value);

Set the value of the academic_year field

=cut

sub setAcademicYear{
    my ($self, $value) = @_;
    $self->setFieldValue('academic_year', $value);
}


#######################################################

=item B<getPeriod>

my $string = $obj->getPeriod();

Get the value of the period field

=cut

sub getPeriod{
    my ($self) = @_;
    return $self->getFieldValue('period');
}

#######################################################

=item B<setPeriod>

$obj->setPeriod($value);

Set the value of the period field

=cut

sub setPeriod{
    my ($self, $value) = @_;
    $self->setFieldValue('period', $value);
}


#######################################################

=item B<getStartDate>

my $string = $obj->getStartDate();

Get the value of the start_date field

=cut

sub getStartDate{
    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

#######################################################

=item B<setStartDate>

$obj->setStartDate($value);

Set the value of the start_date field

=cut

sub setStartDate{
    my ($self, $value) = @_;
    $self->setFieldValue('start_date', $value);
}


#######################################################

=item B<getEndDate>

my $string = $obj->getEndDate();

Get the value of the end_date field

=cut

sub getEndDate{
    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

#######################################################

=item B<setEndDate>

$obj->setEndDate($value);

Set the value of the end_date field

=cut

sub setEndDate{
    my ($self, $value) = @_;
    $self->setFieldValue('end_date', $value);
}



=back

=cut

### Other Methods

sub isCurrent {
    my $self = shift;
    my $start_date = HSDB4::DateTime->new()->in_mysql_date($self->getFieldValue('start_date'));
    my $end_date = HSDB4::DateTime->new()->in_mysql_date($self->getFieldValue('end_date'));
    my $now = HSDB4::DateTime->new();

    return ($start_date->is_before($now) && $end_date->is_after($now)) ? 1 : 0;
}

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

