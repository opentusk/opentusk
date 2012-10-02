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


package TUSK::Search::SearchQueryFieldType;

=head1 NAME

B<TUSK::Search::SearchQueryFieldType> - Class for manipulating entries in table search_query_field_type in tusk database

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
					'tablename' => 'search_query_field_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'search_query_field_type_id' => 'pk',
					'search_query_field_name' => '',
					'display_text'=>'',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getSearchQueryFieldName>

my $string = $obj->getSearchQueryFieldName();

Get the value of the search_query_field_name field

=cut

sub getSearchQueryFieldName{
    my ($self) = @_;
    return $self->getFieldValue('search_query_field_name');
}

#######################################################

=item B<setSearchQueryFieldName>

$obj->setSearchQueryFieldName($value);

Set the value of the search_query_field_name field

=cut

sub setSearchQueryFieldName{
    my ($self, $value) = @_;
    $self->setFieldValue('search_query_field_name', $value);
}

#######################################################

=item B<getDisplayText>

my $string = $obj->getDisplayText();

Get the value of the display_text field

=cut

sub getDisplayText{
    my ($self) = @_;
    return $self->getFieldValue('display_text');
}

#######################################################

=item B<setDisplayText>

$obj->setDisplayText($value);

Set the value of the display_text field

=cut

sub setDisplayText{
    my ($self, $value) = @_;
    $self->setFieldValue('display_text', $value);
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

