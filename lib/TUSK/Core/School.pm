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


package TUSK::Core::School;

=head1 NAME

B<TUSK::Core::School> - Class for manipulating entries in table school in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::SchoolLink::SchoolLink;

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
					'tablename' => 'school',
					'user' => '',
					},
				    _field_names => {
					'school_id' => 'pk',
					'school_display' => '',
					'school_name' => '',
					'school_db' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getSchoolDisplay>

   $string = $obj->getSchoolDisplay();

Get the value of the school_display field

=cut

sub getSchoolDisplay{
    my ($self) = @_;
    return $self->getFieldValue('school_display');
}

#######################################################

=item B<setSchoolDisplay>

    $string = $obj->setSchoolDisplay($value);

Set the value of the school_display field

=cut

sub setSchoolDisplay{
    my ($self, $value) = @_;
    $self->setFieldValue('school_display', $value);
}


#######################################################

=item B<getSchoolName>

   $string = $obj->getSchoolName();

Get the value of the school_name field

=cut

sub getSchoolName{
    my ($self) = @_;
    return $self->getFieldValue('school_name');
}

#######################################################

=item B<setSchoolName>

    $string = $obj->setSchoolName($value);

Set the value of the school_name field

=cut

sub setSchoolName{
    my ($self, $value) = @_;
    $self->setFieldValue('school_name', $value);
}


#######################################################

=item B<getSchoolDb>

   $string = $obj->getSchoolDb();

Get the value of the school_db field

=cut

sub getSchoolDb{
    my ($self) = @_;
    return $self->getFieldValue('school_db');
}

#######################################################

=item B<setSchoolDb>

    $string = $obj->setSchoolDb($value);

Set the value of the school_db field

=cut

sub setSchoolDb{
    my ($self, $value) = @_;
    $self->setFieldValue('school_db', $value);
}


### Other Methods

#######################################################

=item B<getSchoolID>

    $school_id = $obj->getSchoolID($school_name);

Given a school_name return the school id

=cut

sub getSchoolID{
    my ($self, $school_name) = @_;
    my $schools = TUSK::Core::School->new->lookup("school_name = lcase('$school_name')");
    return 0 unless $schools;
    return 0 unless $schools->[0];
    return $schools->[0]->getPrimaryKeyID;
}

#######################################################

=item B<getHomepageSchoolLinks>

    $links_arr_ref = $obj->getHomepageSchoolLinks();

Get all of the School Links for the Homepage returned in an array ref.

=cut

sub getHomepageSchoolLinks{
    my ($self) = @_;

	my $links = TUSK::SchoolLink::SchoolLink->lookup("school_link.school_id =" . $self->getPrimaryKeyID() . " AND school_link.parent_school_link_id is null AND (school_link.hide_date is null or school_link.hide_date > now()) and (school_link.show_date is null or school_link.show_date <= now())",
	            ['school_link.sort_order', 'subLink.sort_order'],
	            undef, undef,
	            [TUSK::Core::JoinObject->new('TUSK::SchoolLink::SchoolLink',
	                {alias    => 'subLink', 
	                 joinkey  => 'parent_school_link_id', 
	                 origkey  => 'school_link.school_link_id',
	                 joincond => '(subLink.hide_date is null or subLink.hide_date > now()) and (subLink.show_date is null or subLink.show_date <= now())', 
	                }),
	            ]);

	return $links;
}

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

