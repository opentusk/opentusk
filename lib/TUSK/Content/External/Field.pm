package TUSK::Content::External::Field;

=head1 NAME

B<TUSK::Content::External::Field> - Class for manipulating entries in table external_content_field in tusk database

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
					'tablename' => 'content_external_field',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'field_id' => 'pk',
					'source_id' => '',
					'name' => '',
					'token' => '',
					'sort_order' => '',
					'required' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getSourceID>

my $string = $obj->getSourceID();

Get the value of the source_id field

=cut

sub getSourceID{
    my ($self) = @_;
    return $self->getFieldValue('source_id');
}

#######################################################

=item B<setSourceID>

$obj->setSourceID($value);

Set the value of the source_id field

=cut

sub setSourceID{
    my ($self, $value) = @_;
    $self->setFieldValue('source_id', $value);
}


#######################################################

=item B<getName>

my $string = $obj->getName();

Get the value of the name field

=cut

sub getName{
    my ($self) = @_;
    return $self->getFieldValue('name');
}

#######################################################

=item B<setName>

$obj->setName($value);

Set the value of the name field

=cut

sub setName{
    my ($self, $value) = @_;
    $self->setFieldValue('name', $value);
}


#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

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

=item B<getToken>

my $string = $obj->getToken();

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

=item B<getRequired>

my $string = $obj->getRequired();

Get the value of the required field

=cut

sub getRequired{
    my ($self) = @_;
    return $self->getFieldValue('required');
}

#######################################################

=item B<setRequired>

$obj->setRequired($value);

Set the value of the required field

=cut

sub setRequired{
    my ($self, $value) = @_;
    $self->setFieldValue('required', $value);
}


=back

=cut

### Other Methods

sub getSource{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Content::External::Source');
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

