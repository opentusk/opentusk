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


package TUSK::Content::GroupContent;

=head1 NAME

B<TUSK::Content::GroupContent> - Class for manipulating entries in table group_content in tusk database

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
					'tablename' => 'group_content',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'group_content_id' => 'pk',
					'user_group_id' => '',
					'group_content_type_id' => '',
					'body' => '',
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

=item B<getUserGroupID>

my $string = $obj->getUserGroupID();

Get the value of the user_group_id field

=cut

sub getUserGroupID{
    my ($self) = @_;
    return $self->getFieldValue('user_group_id');
}

#######################################################

=item B<setUserGroupID>

$obj->setUserGroupID($value);

Set the value of the user_group_id field

=cut

sub setUserGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_group_id', $value);
}


#######################################################

=item B<getGroupContentTypeID>

my $string = $obj->getGroupContentTypeID();

Get the value of the group_content_type_id field

=cut

sub getGroupContentTypeID{
    my ($self) = @_;
    return $self->getFieldValue('group_content_type_id');
}

#######################################################

=item B<setGroupContentTypeID>

$obj->setGroupContentTypeID($value);

Set the value of the group_content_type_id field

=cut

sub setGroupContentTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('group_content_type_id', $value);
}


#######################################################

=item B<getBody>

my $string = $obj->getBody();

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

