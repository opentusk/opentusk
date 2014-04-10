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


package TUSK::Competency::Checklist::Checklist;

=head1 NAME

B<TUSK::Competency::Checklist::Checklist> - Class for manipulating entries in table competency_checklist in tusk database

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
					'tablename' => 'competency_checklist',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_checklist_id' => 'pk',
					'competency_checklist_group_id' => '',
					'competency_id' => '',
					'description' => '',
					'required' => '',
					'self_assessed' => '',
					'partner_assessed' => '',
					'faculty_assessed' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
					no_created => 1,
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

=item B<getCompetencyChecklistGroupID>

my $string = $obj->getCompetencyChecklistGroupID();

Get the value of the competency_checklist_group_id field

=cut

sub getCompetencyChecklistGroupID{
    my ($self) = @_;
    return $self->getFieldValue('competency_checklist_group_id');
}

#######################################################

=item B<setCompetencyChecklistGroupID>

$obj->setCompetencyChecklistGroupID($value);

Set the value of the competency_checklist_group_id field

=cut

sub setCompetencyChecklistGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_checklist_group_id', $value);
}


#######################################################

=item B<getCompetencyID>

my $string = $obj->getCompetencyID();

Get the value of the competency_id field

=cut

sub getCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('competency_id');
}

#######################################################

=item B<setCompetencyID>

$obj->setCompetencyID($value);

Set the value of the competency_id field

=cut

sub setCompetencyID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_id', $value);
}


#######################################################

=item B<getRequired>

my $string = $obj->getRequired();

Get the value of the required field

=cut

sub getRequired{
    my ($self) = @_;
    return $self->getFieldValue('required');
}

#######################################################

=item B<setRequired>

$obj->setRequired($value);

Set the value of the required field

=cut

sub setRequired{
    my ($self, $value) = @_;
    $self->setFieldValue('required', $value);
}


#######################################################

=item B<getDescription>

my $string = $obj->getDescription();

Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

$obj->setDescription($value);

Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}


#######################################################

=item B<getSelfAssessed>

my $string = $obj->getSelfAssessed();

Get the value of the self_assessed field

=cut

sub getSelfAssessed{
    my ($self) = @_;
    return $self->getFieldValue('self_assessed');
}

#######################################################

=item B<setSelfAssessed>

$obj->setSelfAssessed($value);

Set the value of the self_assessed field

=cut

sub setSelfAssessed{
    my ($self, $value) = @_;
    $self->setFieldValue('self_assessed', $value);
}


#######################################################

=item B<getPartnerAssessed>

my $string = $obj->getPartnerAssessed();

Get the value of the partner_assessed field

=cut

sub getPartnerAssessed{
    my ($self) = @_;
    return $self->getFieldValue('partner_assessed');
}

#######################################################

=item B<setPartnerAssessed>

$obj->setPartnerAssessed($value);

Set the value of the partner_assessed field

=cut

sub setPartnerAssessed{
    my ($self, $value) = @_;
    $self->setFieldValue('partner_assessed', $value);
}


#######################################################

=item B<getFacultyAssessed>

my $string = $obj->getFacultyAssessed();

Get the value of the faculty_assessed field

=cut

sub getFacultyAssessed{
    my ($self) = @_;
    return $self->getFieldValue('faculty_assessed');
}

#######################################################

=item B<setFacultyAssessed>

$obj->setFacultyAssessed($value);

Set the value of the faculty_assessed field

=cut

sub setFacultyAssessed{
    my ($self, $value) = @_;
    $self->setFieldValue('faculty_assessed', $value);
}



=back

=cut

### Other Methods

sub getTitle {
    my $self = shift;
    if (my $competency = $self->getJoinObject('TUSK::Competency::Competency')) {
	return $competency->getDescription();
    }
    return undef;
}
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

