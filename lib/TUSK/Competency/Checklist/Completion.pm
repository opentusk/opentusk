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


package TUSK::Competency::Checklist::Completion;

=head1 NAME

B<TUSK::Competency::Checklist::Completion> - Class for manipulating entries in table competency_checklist_completion in tusk database

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
					'tablename' => 'competency_checklist_completion',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_checklist_completion_id' => 'pk',
					'competency_checklist_entry_id' => '',
					'competency_id' => '',
					'completed' => '',
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

=item B<getCompetencyChecklistEntryID>

my $string = $obj->getCompetencyChecklistEntryID();

Get the value of the competency_checklist_entry_id field

=cut

sub getCompetencyChecklistEntryID{
    my ($self) = @_;
    return $self->getFieldValue('competency_checklist_entry_id');
}

#######################################################

=item B<setCompetencyChecklistEntryID>

$obj->setCompetencyChecklistEntryID($value);

Set the value of the competency_checklist_entry_id field

=cut

sub setCompetencyChecklistEntryID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_checklist_entry_id', $value);
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

=item B<getCompleted>

my $string = $obj->getCompleted();

Get the value of the completed field

=cut

sub getCompleted{
    my ($self) = @_;
    return $self->getFieldValue('completed');
}

#######################################################

=item B<setCompleted>

$obj->setCompleted($value);

Set the value of the completed field

=cut

sub setCompleted{
    my ($self, $value) = @_;
    $self->setFieldValue('completed', $value);
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

