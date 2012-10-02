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


package TUSK::Search::SearchQueryField;

=head1 NAME

B<TUSK::Search::SearchQueryField> - Class for manipulating entries in table search_query_field in tusk database

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
					'tablename' => 'search_query_field',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'search_query_field_id' => 'pk',
					'search_query_id' => '',
					'search_query_field_type_id' => '',
					'search_query_field' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
					_default_join_objects => [
                                                 TUSK::Core::JoinObject->new("TUSK::Search::SearchQueryFieldType"),
                                                 ],

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

=item B<getSearchQueryID>

my $string = $obj->getSearchQueryID();

Get the value of the search_query_id field

=cut

sub getSearchQueryID{
    my ($self) = @_;
    return $self->getFieldValue('search_query_id');
}

#######################################################

=item B<setSearchQueryID>

$obj->setSearchQueryID($value);

Set the value of the search_query_id field

=cut

sub setSearchQueryID{
    my ($self, $value) = @_;
    $self->setFieldValue('search_query_id', $value);
}


#######################################################

=item B<getSearchQueryFieldTypeID>

my $string = $obj->getSearchQueryFieldTypeID();

Get the value of the search_query_field_type_id field

=cut

sub getSearchQueryFieldTypeID{
    my ($self) = @_;
    return $self->getFieldValue('search_query_field_type_id');
}

#######################################################

=item B<setSearchQueryFieldTypeID>

$obj->setSearchQueryFieldTypeID($value);

Set the value of the search_query_field_type_id field

=cut

sub setSearchQueryFieldTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('search_query_field_type_id', $value);
}


#######################################################

=item B<getSearchQueryField>

my $string = $obj->getSearchQueryField();

Get the value of the search_query_field field

=cut

sub getSearchQueryField{
    my ($self) = @_;
    return $self->getFieldValue('search_query_field');
}

#######################################################

=item B<setSearchQueryField>

$obj->setSearchQueryField($value);

Set the value of the search_query_field field

=cut

sub setSearchQueryField{
    my ($self, $value) = @_;
    $self->setFieldValue('search_query_field', $value);
}



=back

=cut

### Other Methods

sub getSearchQueryFieldTypeObject {
        my $self = shift;
        return $self->getJoinObject('TUSK::Search::SearchQueryFieldType');
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

