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


package TUSK::GradeBook::LinkGradeEventGradeScale;

=head1 NAME

B<TUSK::GradeBook::LinkGradeEventGradeScale> - Class for manipulating entries in table link_grade_event_grade_scale in tusk database

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
					'tablename' => 'link_grade_event_grade_scale',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_grade_event_grade_scale_id' => 'pk',
					'grade_event_id' => '',
					'numeric_value' => '',
					'symbolic_value' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getGradeEventID>

my $string = $obj->getGradeEventID();

Get the value of the grade_event_id field

=cut

sub getGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_id');
}

#######################################################

=item B<setGradeEventID>

$obj->setGradeEventID($value);

Set the value of the grade_event_id field

=cut

sub setGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_id', $value);
}


#######################################################

=item B<getNumericValue>

my $string = $obj->getNumericValue();

Get the value of the numeric_value field

=cut

sub getNumericValue{
    my ($self) = @_;
    return $self->getFieldValue('numeric_value');
}

#######################################################

=item B<setNumericValue>

$obj->setNumericValue($value);

Set the value of the numeric_value field

=cut

sub setNumericValue{
    my ($self, $value) = @_;
    $self->setFieldValue('numeric_value', $value);
}


#######################################################

=item B<getSymbolicValue>

my $string = $obj->getSymbolicValue();

Get the value of the symbolic_value field

=cut

sub getSymbolicValue{
    my ($self) = @_;
    return $self->getFieldValue('symbolic_value');
}

#######################################################

=item B<setSymbolicValue>

$obj->setSymbolicValue($value);

Set the value of the symbolic_value field

=cut

sub setSymbolicValue{
    my ($self, $value) = @_;
    $self->setFieldValue('symbolic_value', $value);
}



=back

=cut

### Other Methods

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

