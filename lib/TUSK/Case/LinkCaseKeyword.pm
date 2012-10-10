package TUSK::Case::LinkCaseKeyword;

=head1 NAME

B<TUSK::Case::LinkCaseKeyword> - Class for manipulating entries in table link_case_keyword in tusk database

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
					'tablename' => 'link_case_keyword',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_case_keyword_id' => 'pk',
					'parent_case_id' => '',
					'child_keyword_id' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _default_order_bys => ['sort_order','link_case_keyword_id'],
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

=item B<getParentCaseID>

    $string = $obj->getParentCaseID();

    Get the value of the parent_case_id field

=cut

sub getParentCaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_case_id');
}

#######################################################

=item B<setParentCaseID>

    $obj->setParentCaseID($value);

    Set the value of the parent_case_id field

=cut

sub setParentCaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_case_id', $value);
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



=back

=cut

### Other Methods

#######################################################

=item B<getKeywordObject>

    $keyword = $link->getKeywordObject();

    Return the keyword associated with this link object

=cut

sub getKeywordObject{
	my $self = shift;
	return TUSK::Core::Keyword->lookupKey($self->getChildKeywordID());
}


#######################################################

=item B<lookupByRelation>

    $link = TUSK::Case::LinkCaseKeyword->lookupByRelation($parent_id,$child_id);

    Return the link identified by this parent - child combination

=cut

sub lookupByRelation{
        my $self = shift;
	my $parent_id = shift;
	my $child_id = shift;
	return TUSK::Case::LinkCaseKeyword->lookup(" parent_case_id = $parent_id and child_keyword_id = $child_id ");
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

