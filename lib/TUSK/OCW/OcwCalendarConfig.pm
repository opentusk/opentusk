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


package TUSK::OCW::OcwCalendarConfig;

=head1 NAME

B<TUSK::OCW::OcwCalendarConfig> - Class for manipulating entries in table ocw_calendar_config in tusk database

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
use TUSK::OCW::OcwCalendarContentConfig;

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
					'tablename' => 'ocw_calendar_config',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'ocw_calendar_config_id' => 'pk',
					'ocw_course_config_id'=>'',
					'calendar_date' => '',
					'calendar_label' => '',
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

=item B<getOcwCourseConfigID>

    $string = $obj->getOcwCourseConfigID();

    Get the value of the ocw_course_config_id field

=cut

sub getOcwCourseConfigID{
    my ($self) = @_;
    return $self->getFieldValue('ocw_course_config_id');
}

#######################################################

=item B<setOcwCourseConfigID>

    $obj->setOcwCourseConfigID($value);

    Set the value of the ocw_course_config_id field

=cut

sub setOcwCourseConfigID{
    my ($self, $value) = @_;
    $self->setFieldValue('ocw_course_config_id', $value);
}

#######################################################

=item B<getCalendarDate>

    $string = $obj->getCalendarDate();

    Get the value of the calendar_date field

=cut

sub getCalendarDate{
    my ($self) = @_;
    return $self->getFieldValue('calendar_date');
}

#######################################################

=item B<setCalendarDate>

    $obj->setCalendarDate($value);

    Set the value of the calendar_date field

=cut

sub setCalendarDate{
    my ($self, $value) = @_;
    $self->setFieldValue('calendar_date', $value);
}


#######################################################

=item B<getCalendarLabel>

    $string = $obj->getCalendarLabel();

    Get the value of the calendar_label field

=cut

sub getCalendarLabel{
    my ($self) = @_;
    return $self->getFieldValue('calendar_label');
}

#######################################################

=item B<setCalendarLabel>

    $obj->setCalendarLabel($value);

    Set the value of the calendar_label field

=cut

sub setCalendarLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('calendar_label', $value);
}



=back

=cut

### Other Methods

sub getContent{
	my $self = shift;
	my $contentType = shift;
	my $cond ;
	if ($contentType){
		$cond = "  class_meeting_content_type.label = '$contentType' ";
	}
	my $calendarContent =  TUSK::OCW::OcwCalendarContentConfig->lookup(" ocw_calendar_config_id = "
		.$self->getPrimaryKeyID(), undef,undef,undef,
		[ TUSK::Core::JoinObject->new('TUSK::Core::ClassMeetingContentType',{ cond => $cond })] );
	my @content = map {$_->getContentObject() } @{$calendarContent};
	return \@content;

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

