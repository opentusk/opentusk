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


package TUSK::GradeBook::GradeMultiple;

=head1 NAME

B<TUSK::GradeBook::GradeMultiple> - Class for manipulating entries in table grade_multiple in tusk database

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
use TUSK::GradeBook::LinkUserGradeEvent;

# Non-exported package globals go here
use vars ();

## grade types
our $FAILED_GRADETYPE = 1;
our $CALCULATED_FINAL_GRADETYPE = 2;
our $ADJUSTED_FINAL_GRADETYPE = 3;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'grade_multiple',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_multiple_id' => 'pk',
					'link_user_grade_event_id' => '',
					'grade' => '',
					'grade_date' => '',
					'grade_type' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getLinkUserGradeEventID>

my $string = $obj->getLinkUserGradeEventID();

Get the value of the link_user_grade_event_id field

=cut

sub getLinkUserGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('link_user_grade_event_id');
}

#######################################################

=item B<setLinkUserGradeEventID>

$obj->setLinkUserGradeEventID($value);

Set the value of the link_user_grade_event_id field

=cut

sub setLinkUserGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('link_user_grade_event_id', $value);
}


#######################################################

=item B<getGrade>

my $string = $obj->getGrade();

Get the value of the grade field

=cut

sub getGrade{
    my ($self) = @_;
    return $self->getFieldValue('grade');
}

#######################################################

=item B<setGrade>

$obj->setGrade($value);

Set the value of the grade field

=cut

sub setGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('grade', $value);
}


#######################################################

=item B<getGradeDate>

my $string = $obj->getGradeDate();

Get the value of the grade_date field

=cut

sub getGradeDate{
    my ($self) = @_;
    return $self->getFieldValue('grade_date');
}

#######################################################

=item B<setGradeDate>

$obj->setGradeDate($value);

Set the value of the grade_date field

=cut

sub setGradeDate{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_date', $value);
}


#######################################################

=item B<getGradeType>

my $string = $obj->getGradeType();

Get the value of the grade_type field

=cut

sub getGradeType{
    my ($self) = @_;
    return $self->getFieldValue('grade_type');
}

#######################################################

=item B<setGradeType>

$obj->setGradeType($value);

Set the value of the grade_type field

=cut

sub setGradeType{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_type', $value);
}


#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

$obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}

=back

=cut

### Other Methods

sub getLinkUserGradeEventObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::GradeBook::LinkUserGradeEvent");
}

sub getGradeEventID {
	my ($self) = @_;
	if (ref $self->getLinkUserGradeEventObject() eq 'TUSK::GradeBook::LinkUserGradeEvent') {
		return $self->getLinkUserGradeEventObject()->getChildGradeEventID();
	}
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

