package TUSK::Enum::Data;

=head1 NAME

B<TUSK::Enum::Data> - Class for manipulating entries in table enum_data in tusk database

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
					'tablename' => 'enum_data',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'enum_data_id' => 'pk',
					'namespace' => '',
					'short_name' => '',
					'display_name' => '',
					'description' => '',
				    },
				    _attributes => {
					save_history => 0,
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

=item B<getNamespace>

my $string = $obj->getNamespace();

Get the value of the namespace field

=cut

sub getNamespace{
    my ($self) = @_;
    return $self->getFieldValue('namespace');
}

#######################################################

=item B<setNamespace>

$obj->setNamespace($value);

Set the value of the namespace field

=cut

sub setNamespace{
    my ($self, $value) = @_;
    $self->setFieldValue('namespace', $value);
}


#######################################################

=item B<getShortName>

my $string = $obj->getShortName();

Get the value of the short_name field

=cut

sub getShortName{
    my ($self) = @_;
    return $self->getFieldValue('short_name');
}

#######################################################

=item B<setShortName>

$obj->setShortName($value);

Set the value of the short_name field

=cut

sub setShortName{
    my ($self, $value) = @_;
    $self->setFieldValue('short_name', $value);
}


#######################################################

=item B<getDisplayName>

my $string = $obj->getDisplayName();

Get the value of the display_name field

=cut

sub getDisplayName{
    my ($self) = @_;
    return $self->getFieldValue('display_name');
}

#######################################################

=item B<setDisplayName>

$obj->setDisplayName($value);

Set the value of the display_name field

=cut

sub setDisplayName{
    my ($self, $value) = @_;
    $self->setFieldValue('display_name', $value);
}


#######################################################

=item B<getDescription>

my $string = $obj->getDescription();

Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

$obj->setDescription($value);

Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}



=back

=cut

### Other Methods

=item
    Return the enum id for the given namespace and token
=cut
sub getID {
    my ($self, $namespace, $token) = @_;

    if (my $enum = $self->lookupReturnOne("namespace = '$namespace' AND short_name = '$token'")) {
	return $enum->getPrimaryKeyID();
    }
    return undef;
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

