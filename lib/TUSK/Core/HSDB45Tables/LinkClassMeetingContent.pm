# Copyright 2013 Tufts University
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


package TUSK::Core::HSDB45Tables::LinkClassMeetingContent;

=head1 NAME

B<TUSK::Core::HSDB45Tables::LinkClassMeetingContent> - Class for manipulating entries in table link_class_meeting_content in hsdb45_med_admin database

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
					'tablename' => 'link_class_meeting_content',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_class_meeting_content_id' => 'pk',
					'parent_class_meeting_id' => '',
					'child_content_id' => '',
					'class_meeting_content_type_id' => '',
					'anchor_label' => '',
					'sort_order' => '',
					'label' => '',
					'modified' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
					no_created => 0,
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

=item B<getParentClassMeetingID>

my $string = $obj->getParentClassMeetingID();

Get the value of the parent_class_meeting_id field

=cut

sub getParentClassMeetingID{
    my ($self) = @_;
    return $self->getFieldValue('parent_class_meeting_id');
}

#######################################################

=item B<setParentClassMeetingID>

$obj->setParentClassMeetingID($value);

Set the value of the parent_class_meeting_id field

=cut

sub setParentClassMeetingID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_class_meeting_id', $value);
}


#######################################################

=item B<getChildContentID>

my $string = $obj->getChildContentID();

Get the value of the child_content_id field

=cut

sub getChildContentID{
    my ($self) = @_;
    return $self->getFieldValue('child_content_id');
}

#######################################################

=item B<setChildContentID>

$obj->setChildContentID($value);

Set the value of the child_content_id field

=cut

sub setChildContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_content_id', $value);
}


#######################################################

=item B<getClassMeetingContentTypeID>

my $string = $obj->getClassMeetingContentTypeID();

Get the value of the class_meeting_content_type_id field

=cut

sub getClassMeetingContentTypeID{
    my ($self) = @_;
    return $self->getFieldValue('class_meeting_content_type_id');
}

#######################################################

=item B<setClassMeetingContentTypeID>

$obj->setClassMeetingContentTypeID($value);

Set the value of the class_meeting_content_type_id field

=cut

sub setClassMeetingContentTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('class_meeting_content_type_id', $value);
}


#######################################################

=item B<getAnchorLabel>

my $string = $obj->getAnchorLabel();

Get the value of the anchor_label field

=cut

sub getAnchorLabel{
    my ($self) = @_;
    return $self->getFieldValue('anchor_label');
}

#######################################################

=item B<setAnchorLabel>

$obj->setAnchorLabel($value);

Set the value of the anchor_label field

=cut

sub setAnchorLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('anchor_label', $value);
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

=item B<getLabel>

my $string = $obj->getLabel();

Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

$obj->setLabel($value);

Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
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

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

