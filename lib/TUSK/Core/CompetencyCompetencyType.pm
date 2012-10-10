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


package TUSK::Core::CompetencyCompetencyType;

=head1 NAME

B<TUSK::Core::CompetencyCompetencyType> - Class for manipulating entries in table competency_competency_type in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Competency;
use TUSK::Core::CompetencyType;

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
					'tablename' => 'competency_competency_type',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'competency_competency_type_id' => 'pk',
					'competency_id' => '',
					'competency_type_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['competency_id'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getCompetencyID>

   $string = $obj->getCompetencyID();

Get the value of the competency_id field

=cut

sub getCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('competency_id');
}

#######################################################

=item B<setCompetencyID>

    $string = $obj->setCompetencyID($value);

Set the value of the competency_id field

=cut

sub setCompetencyID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_id', $value);
}


#######################################################

=item B<getCompetencyTypeID>

   $string = $obj->getCompetencyTypeID();

Get the value of the competency_type_id field

=cut

sub getCompetencyTypeID{
    my ($self) = @_;
    return $self->getFieldValue('competency_type_id');
}

#######################################################

=item B<setCompetencyTypeID>

    $string = $obj->setCompetencyTypeID($value);

Set the value of the competency_type_id field

=cut

sub setCompetencyTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_type_id', $value);
}


=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($competency_id,$competency_type_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $competency_id, $competency_type_id) = @_;
    return $self->lookup("competency_id = $competency_id and competency_type_id = $competency_type_id");
}

#######################################################

=item B<getCompetency>

    $competency_type_object = $obj->getCompetency();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Competency

=cut

sub getCompetency {
	my $self = shift;
	return TUSK::Core::Competency->new->lookupKey($self->getCompetencyID());
}

#######################################################

=item B<getCompetencyType>

    $competency_type_object = $obj->getCompetencyType();

Use the link to get the child object of this relation.  Returns a TUSK::Core::CompetencyType

=cut

sub getCompetencyType {
	my $self = shift;
	return TUSK::Core::CompetencyType->new->lookupKey($self->getCompetencyTypeID());
}

#######################################################

=item B<getCompetencyTypesByCompetency>

    $new_object = $obj->getCompetencyTypesByCompetency($competency_id);

=cut

sub getCompetencyTypesByCompetency{
    my ($self, $competency_id) = @_;
    return $self->lookup("competency_id = $competency_id");
}

#######################################################

=item B<getCompetenciesByCompetencyType>

    $new_object = $obj->getCompetenciesByCompetencyType($competency_type_id);

=cut

sub getCompetenciesByCompetencyType{
    my ($self, $competency_type_id) = @_;
    return $self->lookup("competency_type_id = $competency_type_id");
}

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

