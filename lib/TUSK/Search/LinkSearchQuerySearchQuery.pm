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


package TUSK::Search::LinkSearchQuerySearchQuery;

=head1 NAME

B<TUSK::Search::LinkSearchQuerySearchQuery> - Class for manipulating entries in table link_search_query_search_query in tusk database

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
					'tablename' => 'link_search_query_search_query',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_search_query_search_query_id' => 'pk',
					'parent_search_query_id' => '',
					'child_search_query_id' => '',
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

=item B<getParentSearchQueryID>

my $string = $obj->getParentSearchQueryID();

Get the value of the parent_search_query_id field

=cut

sub getParentSearchQueryID{
    my ($self) = @_;
    return $self->getFieldValue('parent_search_query_id');
}

#######################################################

=item B<setParentSearchQueryID>

$obj->setParentSearchQueryID($value);

Set the value of the parent_search_query_id field

=cut

sub setParentSearchQueryID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_search_query_id', $value);
}


#######################################################

=item B<getChildSearchQueryID>

my $string = $obj->getChildSearchQueryID();

Get the value of the child_search_query_id field

=cut

sub getChildSearchQueryID{
    my ($self) = @_;
    return $self->getFieldValue('child_search_query_id');
}

#######################################################

=item B<setChildSearchQueryID>

$obj->setChildSearchQueryID($value);

Set the value of the child_search_query_id field

=cut

sub setChildSearchQueryID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_search_query_id', $value);
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

