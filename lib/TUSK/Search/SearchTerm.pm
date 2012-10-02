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


package TUSK::Search::SearchTerm;

=head1 NAME

B<TUSK::Search::SearchTerm> - Class for manipulating entries in table search_term in tusk database

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
					'tablename' => 'search_term',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'search_term_id' => 'pk',
					'search_result_id' => '',
					'search_term' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [
                                                          TUSK::Core::JoinObject->new("TUSK::Search::SearchResult"),
                                                         ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getSearchResultID>

my $string = $obj->getSearchResultID();

Get the value of the search_result_id field

=cut

sub getSearchResultID{
    my ($self) = @_;
    return $self->getFieldValue('search_result_id');
}

#######################################################

=item B<setSearchResultID>

$obj->setSearchResultID($value);

Set the value of the search_result_id field

=cut

sub setSearchResultID{
    my ($self, $value) = @_;
    $self->setFieldValue('search_result_id', $value);
}


#######################################################

=item B<getSearchTerm>

my $string = $obj->getSearchTerm();

Get the value of the search_term field

=cut

sub getSearchTerm{
    my ($self) = @_;
    return $self->getFieldValue('search_term');
}

#######################################################

=item B<setSearchTerm>

$obj->setSearchTerm($value);

Set the value of the search_term field

=cut

sub setSearchTerm{
    my ($self, $value) = @_;
    $self->setFieldValue('search_term', $value);
}



=back

=cut

### Other Methods

sub getSearchResultObject {
        my $self = shift;
        return $self->getJoinObject('TUSK::Search::SearchResult');

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

