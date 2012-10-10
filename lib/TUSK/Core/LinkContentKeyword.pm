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


package TUSK::Core::LinkContentKeyword;

=head1 NAME

B<TUSK::Core::LinkContentKeyword> - Class for manipulating entries in table link_content_keyword in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp qw(confess);

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
					'tablename' => 'link_content_keyword',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_content_keyword_id' => 'pk',
					'parent_content_id' => '',
					'child_keyword_id' => '',
					'sort_order' => '',
					'author_weight'=>'',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_order_bys => ['sort_order'],

				    _default_join_objects => [
                                        TUSK::Core::JoinObject->new("TUSK::Core::Keyword",{'origkey'=>'child_keyword_id',
						'joinkey'=>'keyword_id'})
                                        ],
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentContentID>

    $string = $obj->getParentContentID();

    Get the value of the parent_content_id field

=cut

sub getParentContentID{
    my ($self) = @_;
    return $self->getFieldValue('parent_content_id');
}

#######################################################

=item B<setParentContentID>

    $obj->setParentContentID($value);

    Set the value of the parent_content_id field

=cut

sub setParentContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_content_id', $value);
}


#######################################################

=item B<getChildKeywordID>

    $string = $obj->getChildKeywordID();

    Get the value of the child_keyword_id field

=cut

sub getChildKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('child_keyword_id');
}

#######################################################

=item B<setChildKeywordID>

    $obj->setChildKeywordID($value);

    Set the value of the child_keyword_id field

=cut

sub setChildKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_keyword_id', $value);
}


#######################################################

=item B<getSortOrder>

    $string = $obj->getSortOrder();

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

#######################################################

=item B<getAuthorWeight>

    $string = $obj->getAuthorWeight();

    Get the value of the author_weight field

=cut

sub getAuthorWeight{
    my ($self) = @_;
    return $self->getFieldValue('author_weight');
}

#######################################################

=item B<setAuthorWeight>

    $obj->setAuthorWeight($value);

    Set the value of the author_weight field

=cut

sub setAuthorWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('author_weight', $value);
}


=back

=cut

### Other Methods

#######################################################

=item B<getKeywordObject>

    $keyword = $obj->getKeywordObject($value);

    Return the TUSK::Core::Keyword object associated with this link record

=cut

sub getKeywordObject {
        my $self = shift;
        return $self->getJoinObject("TUSK::Core::Keyword");
}

=back

#######################################################

=item B<getContentObject>

    $keyword = $obj->getContentObject($value);

    Return the HSDB4::SQLRow::Content object associated with this link record

=cut

sub getContentObject {
        my $self = shift;
	return HSDB4::SQLRow::Content->new->lookup_key($self->getParentContentID());
}

=back

#######################################################

=item B<lookupByRelation>

    $link = $obj->lookupByRelation($parent_id, $child_id);

    Return the LinkContentKeyword object associated with this link record

=cut

sub lookupByRelation {
        my $self = shift;
	my $parent_id = shift or confess "Need to pass parent id ";
	my $child_id = shift or confess "Need to pass child id ";
	return $self->lookup("parent_content_id = $parent_id ".
        " and child_keyword_id = '$child_id' ");

}

=back



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

