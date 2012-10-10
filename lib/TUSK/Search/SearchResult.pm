package TUSK::Search::SearchResult;

=head1 NAME

B<TUSK::Search::SearchResult> - Class for manipulating entries in table search_result in tusk database

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
					'tablename' => 'search_result',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'search_result_id' => 'pk',
					'search_result_type_id' => '',
					'search_result_category_id' => '',
					'result_label' => '',
					'result_url' => '',
					'entity_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				_default_join_objects => [
                                                          TUSK::Core::JoinObject->new("TUSK::Search::SearchResultType"),
                                                         ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getSearchResultTypeID>

my $string = $obj->getSearchResultTypeID();

Get the value of the search_result_type_id field

=cut

sub getSearchResultTypeID{
    my ($self) = @_;
    return $self->getFieldValue('search_result_type_id');
}

#######################################################

=item B<setSearchResultTypeID>

$obj->setSearchResultTypeID($value);

Set the value of the search_result_type_id field

=cut

sub setSearchResultTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('search_result_type_id', $value);
}


#######################################################

=item B<getSearchResultCategoryID>

my $string = $obj->getSearchResultCategoryID();

Get the value of the search_result_category_id field

=cut

sub getSearchResultCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('search_result_category_id');
}

#######################################################

=item B<setSearchResultCategoryID>

$obj->setSearchResultCategoryID($value);

Set the value of the search_result_category_id field

=cut

sub setSearchResultCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('search_result_category_id', $value);
}


#######################################################

=item B<getResultLabel>

my $string = $obj->getResultLabel();

Get the value of the result_label field

=cut

sub getResultLabel{
    my ($self) = @_;
    return $self->getFieldValue('result_label');
}

#######################################################

=item B<setResultLabel>

$obj->setResultLabel($value);

Set the value of the result_label field

=cut

sub setResultLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('result_label', $value);
}


#######################################################

=item B<getResultUrl>

my $string = $obj->getResultUrl();

Get the value of the result_url field

=cut

sub getResultUrl{
    my ($self) = @_;
    return $self->getFieldValue('result_url');
}

#######################################################

=item B<setResultUrl>

$obj->setResultUrl($value);

Set the value of the result_url field

=cut

sub setResultUrl{
    my ($self, $value) = @_;
    $self->setFieldValue('result_url', $value);
}


#######################################################

=item B<getEntityID>

my $string = $obj->getEntityID();

Get the value of the entity_id field

=cut

sub getEntityID{
    my ($self) = @_;
    return $self->getFieldValue('entity_id');
}

#######################################################

=item B<setEntityID>

$obj->setEntityID($value);

Set the value of the entity_id field

=cut

sub setEntityID{
    my ($self, $value) = @_;
    $self->setFieldValue('entity_id', $value);
}



=back

=cut

### Other Methods

sub getSearchResultTypeObject {
        my $self = shift;
        return $self->getJoinObject('TUSK::Search::SearchResultType');

}

sub delete {
	my $self = shift;
	my $terms = TUSK::Search::SearchTerm->lookup(" search_term.search_result_id = ".$self->getPrimaryKeyID());
	foreach my $term (@{$terms}){
		$term->delete();
	}
	return $self->SUPER::delete();
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

