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


package TUSK::Core::HSDB45Tables::LinkCourseTeachingSite;

=head1 NAME

B<TUSK::Core::HSDB45Tables::LinkCourseTeachingSite> - Class for manipulating entries in table link_course_teaching_site in hsdb45_med_admin database

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
					'tablename' => 'link_course_teaching_site',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'parent_course_id' => 'pk',
					'child_teaching_site_id' => 'pk',
					'max_students' => '',
					'modified' => '',
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

=item B<getChildTeachingSiteID>

    $string = $obj->getChildTeachingSiteID();

    Get the value of the child_teaching_site_id field

=cut

sub getChildTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('child_teaching_site_id');
}

#######################################################

=item B<setChildTeachingSiteID>

    $obj->setChildTeachingSiteID($value);

    Set the value of the child_teaching_site_id field

=cut

sub setChildTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_teaching_site_id', $value);
}


#######################################################

=item B<getMaxStudents>

    $string = $obj->getMaxStudents();

    Get the value of the max_students field

=cut

sub getMaxStudents{
    my ($self) = @_;
    return $self->getFieldValue('max_students');
}

#######################################################

=item B<setMaxStudents>

    $obj->setMaxStudents($value);

    Set the value of the max_students field

=cut

sub setMaxStudents{
    my ($self, $value) = @_;
    $self->setFieldValue('max_students', $value);
}


#######################################################

=item B<getModified>

    $string = $obj->getModified();

    Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
}

#######################################################

=item B<setModified>

    $obj->setModified($value);

    Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
}



=back

=cut

### Other Methods
sub getTeachingSiteObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Core::HSDB45Tables::TeachingSite");

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

