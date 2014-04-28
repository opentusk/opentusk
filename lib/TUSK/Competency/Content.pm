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


package TUSK::Competency::Content;

=head1 NAME

B<TUSK::Competency::Content> - Class for manipulating entries in table content_competency in tusk database

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
					'tablename' => 'competency_content',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'content_competency_id' => 'pk',
					'competency_id' => '',
					'content_id' => '',
					'sort_order' => '',
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

=item B<getContentID>

my $string = $obj->getContentID();

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

