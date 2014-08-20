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


package TUSK::Competency::Relation;

=head1 NAME

B<TUSK::Competency::Relation> - Class for manipulating entries in table competency_relation in tusk database

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
					'tablename' => 'competency_relation',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_relation_id' => 'pk',
					'competency_id_1' => '',
					'competency_id_2' => '',
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

=item B<getCompetencyId1>

my $string = $obj->getCompetencyId1();

Get the value of the competency_id_1 field

=cut

sub getCompetencyId1{
    my ($self) = @_;
    return $self->getFieldValue('competency_id_1');
}

#######################################################

=item B<setCompetencyId1>

$obj->setCompetencyId1($value);

Set the value of the competency_id_1 field

=cut

sub setCompetencyId1{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_id_1', $value);
}


#######################################################

=item B<getCompetencyId2>

my $string = $obj->getCompetencyId2();

Get the value of the competency_id_2 field

=cut

sub getCompetencyId2{
    my ($self) = @_;
    return $self->getFieldValue('competency_id_2');
}

#######################################################

=item B<setCompetencyId2>

$obj->setCompetencyId2($value);

Set the value of the competency_id_2 field

=cut

sub setCompetencyId2{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_id_2', $value);
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

