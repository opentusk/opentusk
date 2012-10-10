package TUSK::FormBuilder::FormAssociation;

=head1 NAME

B<TUSK::FormBuilder::FormAssociation> - Class for manipulating entries in table form_builder_form_association in tusk database

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
					'tablename' => 'form_builder_form_association',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'form_association_id' => 'pk',
					'form_id' => '',
					'user_id' => '',
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

=item B<getFormID>

my $string = $obj->getFormID();

Get the value of the form_id field

=cut

sub getFormID{
    my ($self) = @_;
    return $self->getFieldValue('form_id');
}

#######################################################

=item B<setFormID>

$obj->setFormID($value);

Set the value of the form_id field

=cut

sub setFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_id', $value);
}


#######################################################

=item B<getUserID>

my $string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
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

