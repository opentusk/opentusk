package TUSK::Search::SearchResultType;

=head1 NAME

B<TUSK::Search::SearchResultType> - Class for manipulating entries in table search_result_type in tusk database

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
					'tablename' => 'search_result_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'search_result_type_id' => 'pk',
					'type_name' => '',
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

=item B<getTypeName>

my $string = $obj->getTypeName();

Get the value of the type_name field

=cut

sub getTypeName{
    my ($self) = @_;
    return $self->getFieldValue('type_name');
}

#######################################################

=item B<setTypeName>

$obj->setTypeName($value);

Set the value of the type_name field

=cut

sub setTypeName{
    my ($self, $value) = @_;
    $self->setFieldValue('type_name', $value);
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

