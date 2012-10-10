package TUSK::Search::SearchResultCategory;

=head1 NAME

B<TUSK::Search::SearchResultCategory> - Class for manipulating entries in table search_result_category in tusk database

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
					'tablename' => 'search_result_category',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'search_result_category_id' => 'pk',
					'school_id' => '',
					'category_label' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getCategoryLabel>

my $string = $obj->getCategoryLabel();

Get the value of the category_label field

=cut

sub getCategoryLabel{
    my ($self) = @_;
    return $self->getFieldValue('category_label');
}

#######################################################

=item B<setCategoryLabel>

$obj->setCategoryLabel($value);

Set the value of the category_label field

=cut

sub setCategoryLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('category_label', $value);
}



=back

=cut

### Other Methods

sub delete {
        my $self = shift;
        my $results = TUSK::Search::SearchResult->lookup(" search_result.search_result_category_id = ".$self->getPrimaryKeyID());
        foreach my $result (@{$results}){
                $result->delete();
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

