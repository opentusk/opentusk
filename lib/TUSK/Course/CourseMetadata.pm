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


package TUSK::Course::CourseMetadata;

=head1 NAME

B<TUSK::Course::CourseMetadata> - Class for manipulating entries in table course_metadata in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Course::CourseMetadataDisplay;

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
					'tablename' => 'course_metadata',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'metadata_id' => 'pk',
					'course_id' => '',
					'metadata_type' => '',
					'value' => '',
					'parent' => '',
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

=item B<getCourseID>

my $string = $obj->getCourseID();

Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

$obj->setCourseID($value);

Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getMetadataType>

my $string = $obj->getMetadataType();

Get the value of the metadata_type field

=cut

sub getMetadataType{
    my ($self) = @_;
    return $self->getFieldValue('metadata_type');
}

#######################################################

=item B<setMetadataType>

$obj->setMetadataType($value);

Set the value of the metadata_type field

=cut

sub setMetadataType{
    my ($self, $value) = @_;
    $self->setFieldValue('metadata_type', $value);
}


#######################################################

=item B<getValue>

my $string = $obj->getValue();

Get the value of the value field

=cut

sub getValue{
    my ($self) = @_;
    return $self->getFieldValue('value');
}

#######################################################

=item B<setValue>

$obj->setValue($value);

Set the value of the value field

=cut

sub setValue{
    my ($self, $value) = @_;
    $self->setFieldValue('value', $value);
}


#######################################################

=item B<getParent>

my $string = $obj->getParent();

Get the value of the parent field

=cut

sub getParent{
    my ($self) = @_;
    return $self->getFieldValue('parent');
}

#######################################################

=item B<setParent>

$obj->setParent($value);

Set the value of the parent field

=cut

sub setParent{
    my ($self, $value) = @_;
    $self->setFieldValue('parent', $value);
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

