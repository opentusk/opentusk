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


package TUSK::Core::AuditTrail::TeachingSiteHistory;

=head1 NAME

B<TUSK::Core::AuditTrail::TeachingSiteHistory> - Class for manipulating entries in table teaching_site_history in tusk database

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
					'tablename' => 'teaching_site_history',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'teaching_site_history_id' => 'pk',
					'teaching_site_id' => '',
					'school_id' => '',
					'sitename' => '',
					'site_city_state' => '',
					'body' => '',
					'history_action' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getSitename>

my $string = $obj->getSitename();

Get the value of the sitename field

=cut

sub getSitename{
    my ($self) = @_;
    return $self->getFieldValue('sitename');
}

#######################################################

=item B<setSitename>

$obj->setSitename($value);

Set the value of the sitename field

=cut

sub setSitename{
    my ($self, $value) = @_;
    $self->setFieldValue('sitename', $value);
}


#######################################################

=item B<getSiteCityState>

my $string = $obj->getSiteCityState();

Get the value of the site_city_state field

=cut

sub getSiteCityState{
    my ($self) = @_;
    return $self->getFieldValue('site_city_state');
}

#######################################################

=item B<setSiteCityState>

$obj->setSiteCityState($value);

Set the value of the site_city_state field

=cut

sub setSiteCityState{
    my ($self, $value) = @_;
    $self->setFieldValue('site_city_state', $value);
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


#######################################################

=item B<getHistoryAction>

my $string = $obj->getHistoryAction();

Get the value of the history_action field

=cut

sub getHistoryAction{
    my ($self) = @_;
    return $self->getFieldValue('history_action');
}

#######################################################

=item B<setHistoryAction>

$obj->setHistoryAction($value);

Set the value of the history_action field

=cut

sub setHistoryAction{
    my ($self, $value) = @_;
    $self->setFieldValue('history_action', $value);
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

