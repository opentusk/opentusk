package TUSK::Search::LinkSearchQueryContent;

=head1 NAME

B<TUSK::Search::LinkSearchQueryContent> - Class for manipulating entries in table link_search_query_content in tusk database

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
					'tablename' => 'link_search_query_content',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_search_query_content_id' => 'pk',
					'parent_search_query_id' => '',
					'child_content_id' => '',
					'computed_score' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
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

=item B<getChildContentID>

my $string = $obj->getChildContentID();

Get the value of the child_content_id field

=cut

sub getChildContentID{
    my ($self) = @_;
    return $self->getFieldValue('child_content_id');
}

#######################################################

=item B<setChildContentID>

$obj->setChildContentID($value);

Set the value of the child_content_id field

=cut

sub setChildContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_content_id', $value);
}


#######################################################

=item B<getComputedScore>

my $string = $obj->getComputedScore();

Get the value of the computed_score field

=cut

sub getComputedScore{
    my ($self) = @_;
    return $self->getFieldValue('computed_score');
}

#######################################################

=item B<setComputedScore>

$obj->setComputedScore($value);

Set the value of the computed_score field

=cut

sub setComputedScore{
    my ($self, $value) = @_;
    $self->setFieldValue('computed_score', $value);
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

