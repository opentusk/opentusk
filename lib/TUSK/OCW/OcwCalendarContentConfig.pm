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


package TUSK::OCW::OcwCalendarContentConfig;

=head1 NAME

B<TUSK::OCW::OcwCalendarContentConfig> - Class for manipulating entries in table ocw_calendar_content_config in tusk database

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
					'tablename' => 'ocw_calendar_content_config',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'ocw_calendar_content_config_id' => 'pk',
					'ocw_calendar_config_id' => '',
					'content_id' => '',
					'class_meeting_content_type_id' => '',
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

=item B<getOcwCalendarConfigID>

    $string = $obj->getOcwCalendarConfigID();

    Get the value of the ocw_calendar_config_id field

=cut

sub getOcwCalendarConfigID{
    my ($self) = @_;
    return $self->getFieldValue('ocw_calendar_config_id');
}

#######################################################

=item B<setOcwCalendarConfigID>

    $obj->setOcwCalendarConfigID($value);

    Set the value of the ocw_calendar_config_id field

=cut

sub setOcwCalendarConfigID{
    my ($self, $value) = @_;
    $self->setFieldValue('ocw_calendar_config_id', $value);
}


#######################################################

=item B<getContentID>

    $string = $obj->getContentID();

    Get the value of the content_id field

=cut

sub getContentID{
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}

#######################################################

=item B<setContentID>

    $obj->setContentID($value);

    Set the value of the content_id field

=cut

sub setContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_id', $value);
}


#######################################################

=item B<getClassMeetingContentTypeID>

    $string = $obj->getClassMeetingContentTypeID();

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



=back

=cut

### Other Methods

#######################################################

=item B<getContentObject>

    $content = obj->getContentObject();

    Return the content object associated with this calendar content
record.

=cut

sub getContentObject {
	my $self = shift;
	return HSDB4::SQLRow::Content->new->lookup_key($self->getContentID());

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

