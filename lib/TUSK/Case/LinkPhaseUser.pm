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


package TUSK::Case::LinkPhaseUser;

=head1 NAME

B<TUSK::Case::LinkPhaseUser> - Class for manipulating entries in table link_phase_user in tusk database

=head1 DESCRIPTION

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
					'tablename' => 'link_phase_user',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_phase_user_id' => 'pk',
					'parent_phase_id' => '',
					'child_user_id' => '',
					'role' => '',
					'sort_order'=> '' 
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentPhaseID>

   $string = $obj->getParentPhaseID();

Get the value of the parent_phase_id field

=cut

sub getParentPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_phase_id');
}

#######################################################

=item B<setParentPhaseID>

    $string = $obj->setParentPhaseID($value);

Set the value of the parent_phase_id field

=cut

sub setParentPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_phase_id', $value);
}


#######################################################

=item B<getChildUserID>

   $string = $obj->getChildUserID();

Get the value of the child_user_id field

=cut

sub getChildUserID{
    my ($self) = @_;
    return $self->getFieldValue('child_user_id');
}

#######################################################

=item B<setChildUserID>

    $string = $obj->setChildUserID($value);

Set the value of the child_user_id field

=cut

sub setChildUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_user_id', $value);
}


#######################################################

=item B<getRole>

   $string = $obj->getRole();

Get the value of the role field

=cut

sub getRole{
    my ($self) = @_;
    return $self->getFieldValue('role');
}

#######################################################

=item B<setRole>

    $string = $obj->setRole($value);

Set the value of the role field

=cut

sub setRole{
    my ($self, $value) = @_;
    $self->setFieldValue('role', $value);
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

######################################################


=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id) = @_;
    return $self->lookup("parent_phase_id = $parent_id ".
        " and child_user_id = '$child_id' ");
}

#######################################################

=item B<getUserObject>

    $user_object = $obj->getUserObject();

Use the link to get the child object of this relation.  Returns a HSDB4::SQLRow::User

=cut

sub getUserObject {
        my $self = shift;
	unless ($self->{-user_object}) {
		$self->{-user_object} = HSDB4::SQLRow::User->new->lookup_key($self->getChildUserID());
	}
	return $self->{-user_object};
}


#######################################################


=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

