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


package TUSK::Core::HSDB45Tables::Course;

=head1 NAME

B<TUSK::Core::HSDB45Tables::Course> - Class for manipulating entries in table course in hsdb45_med_admin database

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
use HSDB4::Constants;

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
					'tablename' => 'course',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'course_id' => 'pk',
					'title' => '',
					'oea_code' => '',
					'color' => '',
					'abbreviation' => '',
					'associate_users' => '',
					'type' => '',
					'course_source' => '',
					'modified' => '',
					'body' => '',
					'rss'  => '',
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

=item B<getTitle>

    $string = $obj->getTitle();

    Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################


=item B<setTitle>

    $obj->setTitle($value);

    Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################


=item B<setRSS>

    $obj->setRSS($value);

    Set the value of the RSS field

=cut

sub setRSS{
    my ($self, $value) = @_;
    $self->setFieldValue('rss', $value);
}


#######################################################

#######################################################

=item B<getRSS>

    $string = $obj->getRSS();

    Get the value of the RSS field

=cut

sub getRSS{
    my ($self) = @_;
    return $self->getFieldValue('rss');
}

#######################################################





=item B<getOeaCode>

    $string = $obj->getOeaCode();

    Get the value of the oea_code field

=cut

sub getOeaCode{
    my ($self) = @_;
    return $self->getFieldValue('oea_code');
}

#######################################################

=item B<setOeaCode>

    $obj->setOeaCode($value);

    Set the value of the oea_code field

=cut

sub setOeaCode{
    my ($self, $value) = @_;
    $self->setFieldValue('oea_code', $value);
}


#######################################################

=item B<getColor>

    $string = $obj->getColor();

    Get the value of the color field

=cut

sub getColor{
    my ($self) = @_;
    return $self->getFieldValue('color');
}

#######################################################

=item B<setColor>

    $obj->setColor($value);

    Set the value of the color field

=cut

sub setColor{
    my ($self, $value) = @_;
    $self->setFieldValue('color', $value);
}


#######################################################

=item B<getAbbreviation>

    $string = $obj->getAbbreviation();

    Get the value of the abbreviation field

=cut

sub getAbbreviation{
    my ($self) = @_;
    return $self->getFieldValue('abbreviation');
}

#######################################################

=item B<setAbbreviation>

    $obj->setAbbreviation($value);

    Set the value of the abbreviation field

=cut

sub setAbbreviation{
    my ($self, $value) = @_;
    $self->setFieldValue('abbreviation', $value);
}


#######################################################

=item B<getAssociateUsers>

    $string = $obj->getAssociateUsers();

    Get the value of the associate_users field

=cut

sub getAssociateUsers{
    my ($self) = @_;
    return $self->getFieldValue('associate_users');
}

#######################################################

=item B<setAssociateUsers>

    $obj->setAssociateUsers($value);

    Set the value of the associate_users field

=cut

sub setAssociateUsers{
    my ($self, $value) = @_;
    $self->setFieldValue('associate_users', $value);
}


#######################################################

=item B<getType>

    $string = $obj->getType();

    Get the value of the type field

=cut

sub getType{
    my ($self) = @_;
    return $self->getFieldValue('type');
}

#######################################################

=item B<setType>

    $obj->setType($value);

    Set the value of the type field

=cut

sub setType{
    my ($self, $value) = @_;
    $self->setFieldValue('type', $value);
}


#######################################################

=item B<getCourseSource>

    $string = $obj->getCourseSource();

    Get the value of the course_source field

=cut

sub getCourseSource{
    my ($self) = @_;
    return $self->getFieldValue('course_source');
}

#######################################################

=item B<setCourseSource>

    $obj->setCourseSource($value);

    Set the value of the course_source field

=cut

sub setCourseSource{
    my ($self, $value) = @_;
    $self->setFieldValue('course_source', $value);
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


#######################################################

=item B<getBody>

    $string = $obj->getBody();

    Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

    $obj->setBody($value);

    Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}



=back

=cut

### Other Methods

=item B<getTeachingSites>

=cut

sub getWithTeachingSites{
    my ($self, $school, $cond,$orderby, $fields, $limit) = @_;

    my $database = HSDB4::Constants::get_school_db($school);
    $self->setDatabase($database);
    
    $orderby = ['title', 'site_name'] unless ($orderby);

    return $self->lookup($cond, $orderby, $fields, $limit, [
							    TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::LinkCourseTeachingSite", { 'origkey' => 'course_id', 'joinkey' => 'parent_course_id', database => $database}),
							    TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::TeachingSite", { 'joinkey' => 'teaching_site_id', 'origkey' => 'link_course_teaching_site.child_teaching_site_id', 'objtree' => ['TUSK::Core::HSDB45Tables::LinkCourseTeachingSite'], database => $database}),
							    ]);

}

sub getLinkTeachingSiteObjects {
    my ($self) = @_;
    return $self->getJoinObjects("TUSK::Core::HSDB45Tables::LinkCourseTeachingSite");

}


sub getWithUsers {
    my ($self, $school, $cond,$orderby, $fields, $limit) = @_;

    my $database = HSDB4::Constants::get_school_db($school);
    $self->setDatabase($database);
    
    $orderby = ['user_id', 'firstname', 'lastname'] unless ($orderby);

    return $self->lookup($cond, $orderby, $fields, $limit, [
							    TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::LinkCourseUser", { 'origkey' => 'course_id', 'joinkey' => 'parent_course_id', database => $database}),
							    TUSK::Core::JoinObject->new("TUSK::Core::HSDB4Tables::User", { 'joinkey' => 'user_id', 'origkey' => 'link_course_user.child_user_id', 'objtree' => ['TUSK::Core::HSDB45Tables::LinkCourseUser'], database => 'hsdb4'}),
							    ]);

}

sub getLinkUserObjects {
    my ($self) = @_;
    return $self->getJoinObjects("TUSK::Core::HSDB45Tables::LinkCourseUser");

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

