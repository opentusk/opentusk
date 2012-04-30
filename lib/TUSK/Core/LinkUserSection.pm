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


package TUSK::Core::LinkUserSection;

=head1 NAME

B<TUSK::Core::LinkUserSection> - Class for manipulating entries in table link_user_section in tusk database

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
					'tablename' => 'link_user_section',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_user_section_id' => 'pk',
					'section_id' => '',
					'user_id' => '',
					'role_id' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 0,
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

=item B<getSectionID>

    $string = $obj->getSectionID();

    Get the value of the section_id field

=cut

sub getSectionID{
    my ($self) = @_;
    return $self->getFieldValue('section_id');
}

#######################################################

=item B<setSectionID>

    $string = $obj->setSectionID($value);

    Set the value of the section_id field

=cut

sub setSectionID{
    my ($self, $value) = @_;
    $self->setFieldValue('section_id', $value);
}


#######################################################

=item B<getUserID>

    $string = $obj->getUserID();

    Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

    $string = $obj->setUserID($value);

    Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}


#######################################################

=item B<getRoleID>

    $string = $obj->getRoleID();

    Get the value of the role_id field

=cut

sub getRoleID{
    my ($self) = @_;
    return $self->getFieldValue('role_id');
}

#######################################################

=item B<setRoleID>

    $string = $obj->setRoleID($value);

    Set the value of the role_id field

=cut

sub setRoleID{
    my ($self, $value) = @_;
    $self->setFieldValue('role_id', $value);
}


#######################################################

=item B<getSortOrder>

    $string = $obj->getSortOrder();

    Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

    $string = $obj->setSortOrder($value);

    Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
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

