package TUSK::FormBuilder::ItemType;

=head1 NAME

B<TUSK::FormBuilder::ItemType> - Class for manipulating entries in table form_builder_item_type in tusk database

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
					'tablename' => 'form_builder_item_type',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'item_type_id' => 'pk',
					'token' => '',
					'short_label' => '',
					'full_label' => '',
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

=item B<getToken>

    $string = $obj->getToken();

    Get the value of the token field

=cut

sub getToken{
    my ($self) = @_;
    return $self->getFieldValue('token');
}

#######################################################

=item B<setToken>

    $obj->setToken($value);

    Set the value of the token field

=cut

sub setToken{
    my ($self, $value) = @_;
    $self->setFieldValue('token', $value);
}


#######################################################

=item B<getShortLabel>

    $string = $obj->getShortLabel();

    Get the value of the short_label field

=cut

sub getShortLabel{
    my ($self) = @_;
    return $self->getFieldValue('short_label');
}

#######################################################

=item B<setShortLabel>

    $obj->setShortLabel($value);

    Set the value of the short_label field

=cut

sub setShortLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('short_label', $value);
}


#######################################################

=item B<getFullLabel>

    $string = $obj->getFullLabel();

    Get the value of the full_label field

=cut

sub getFullLabel{
    my ($self) = @_;
    return $self->getFieldValue('full_label');
}

#######################################################

=item B<setFullLabel>

    $obj->setFullLabel($value);

    Set the value of the full_label field

=cut

sub setFullLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('full_label', $value);
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

