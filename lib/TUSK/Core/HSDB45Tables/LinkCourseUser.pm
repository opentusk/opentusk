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


package TUSK::Core::HSDB45Tables::LinkCourseUser;

=head1 NAME

B<TUSK::Core::HSDB45Tables::LinkCourseUser> - Class for manipulating entries in table link_course_user in hsdb45_med_admin database

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
					'tablename' => 'link_course_user',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'parent_course_id' => 'pk',
					'child_user_id' => 'pk',
					'sort_order' => '',
					'roles' => '',
					'teaching_site_id' => '',
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

my $string = $obj->getParentCourseID();

Get the value of the parent_course_id field

=cut

sub getParentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_course_id');
}


#######################################################

=item B<setParentCourseID>

my $string = $obj->setParentCourseID();

Set the value of the parent_course_id field

=cut

sub setParentCourseID{
    my ($self, $value) = @_;
    return $self->setFieldValue('parent_course_id', $value);
}


#######################################################

=item B<getChildUserID>

my $string = $obj->getChildUserID();

Get the value of the child_user_id field

=cut

sub getChildUserID{
    my ($self) = @_;
    return $self->getFieldValue('child_user_id');
}


#######################################################

=item B<setChildUserID>

my $string = $obj->setChildUserID();

Set the value of the child_user_id field

=cut

sub setChildUserID{
    my ($self, $value) = @_;
    return $self->setFieldValue('child_user_id', $value);
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


#######################################################

=item B<getRoles>

my $string = $obj->getRoles();

Get the value of the roles field

=cut

sub getRoles{
    my ($self) = @_;
    return $self->getFieldValue('roles');
}

#######################################################

=item B<setRoles>

$obj->setRoles($value);

Set the value of the roles field

=cut

sub setRoles{
    my ($self, $value) = @_;
    $self->setFieldValue('roles', $value);
}


#######################################################

=item B<getTeachingSiteID>

my $string = $obj->getTeachingSiteID();

Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

$obj->setTeachingSiteID($value);

Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
}


#######################################################

=item B<getModified>

my $string = $obj->getModified();

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
sub getUserObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Core::HSDB4Tables::User");

}


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

