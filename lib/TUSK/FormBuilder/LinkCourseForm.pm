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


package TUSK::FormBuilder::LinkCourseForm;

=head1 NAME

B<TUSK::FormBuilder::LinkCourseForm> - Class for manipulating entries in table link_course_form in tusk database

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
use HSDB45::Course;

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
					'tablename' => 'link_course_form',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_course_form_id' => 'pk',
					'parent_course_id' => '',
					'child_form_id' => '',
					'school_id' => '',
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

=item B<getParentCourseID>

    $string = $obj->getParentCourseID();

    Get the value of the parent_course_id field

=cut

sub getParentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_course_id');
}

#######################################################

=item B<setParentCourseID>

    $obj->setParentCourseID($value);

    Set the value of the parent_course_id field

=cut

sub setParentCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_course_id', $value);
}


#######################################################

=item B<getChildFormID>

    $string = $obj->getChildFormID();

    Get the value of the child_form_id field

=cut

sub getChildFormID{
    my ($self) = @_;
    return $self->getFieldValue('child_form_id');
}

#######################################################

=item B<setChildFormID>

    $obj->setChildFormID($value);

    Set the value of the child_form_id field

=cut

sub setChildFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_form_id', $value);
}


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

    $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}



=back

=cut

### Other Methods

sub getCourseObject{
    my ($self) = @_;
    return HSDB45::Course->new(_school => $self->getSchoolID() )->lookup_path("/" . $self->getSchoolID() . "/" . $self->getParentCourseID());
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

