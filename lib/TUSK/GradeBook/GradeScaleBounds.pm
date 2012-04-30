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


package TUSK::GradeBook::GradeScaleBounds;

=head1 NAME

B<TUSK::GradeBook::GradeScaleBounds> - Class for manipulating entries in table grade_scale_bounds in tusk database

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
					'tablename' => 'grade_scale_bounds',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_scale_bounds_id' => 'pk',
					'grade_scale_id' => '',
					'grade_symbol' => '',
					'lower_bound' => '',
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

=item B<getGradeScaleID>

my $string = $obj->getGradeScaleID();

Get the value of the grade_scale_id field

=cut

sub getGradeScaleID{
    my ($self) = @_;
    return $self->getFieldValue('grade_scale_id');
}

#######################################################

=item B<setGradeScaleID>

$obj->setGradeScaleID($value);

Set the value of the grade_scale_id field

=cut

sub setGradeScaleID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_scale_id', $value);
}


#######################################################

=item B<getGradeSymbol>

my $string = $obj->getGradeSymbol();

Get the value of the grade_symbol field

=cut

sub getGradeSymbol{
    my ($self) = @_;
    return $self->getFieldValue('grade_symbol');
}

#######################################################

=item B<setGradeSymbol>

$obj->setGradeSymbol($value);

Set the value of the grade_symbol field

=cut

sub setGradeSymbol{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_symbol', $value);
}


#######################################################

=item B<getLowerBound>

my $string = $obj->getLowerBound();

Get the value of the lower_bound field

=cut

sub getLowerBound{
    my ($self) = @_;
    return $self->getFieldValue('lower_bound');
}

#######################################################

=item B<setLowerBound>

$obj->setLowerBound($value);

Set the value of the lower_bound field

=cut

sub setLowerBound{
    my ($self, $value) = @_;
    $self->setFieldValue('lower_bound', $value);
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

