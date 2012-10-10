package TUSK::Content::External::LinkContentField;

=head1 NAME

B<TUSK::Content::External::LinkContentField> - Class for manipulating entries in table external_content_link_content_field in tusk database

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
					'tablename' => 'content_external_link_content_field',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_content_field_id' => 'pk',
					'parent_content_id' => '',
					'child_field_id' => '',
					'value' => '',
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

=item B<getParentContentID>

my $string = $obj->getParentContentID();

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

=item B<getChildFieldID>

my $string = $obj->getChildFieldID();

Get the value of the child_field_id field

=cut

sub getChildFieldID{
    my ($self) = @_;
    return $self->getFieldValue('child_field_id');
}

#######################################################

=item B<setChildFieldID>

$obj->setChildFieldID($value);

Set the value of the child_field_id field

=cut

sub setChildFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_field_id', $value);
}

#######################################################

=item B<getValue>

my $string = $obj->getValue();

Get the value of the value field

=cut

sub getValue{
    my ($self) = @_;
    return $self->getFieldValue('value');
}

#######################################################

=item B<setValue>

$obj->setValue($value);

Set the value of the value field

=cut

sub setValue{
    my ($self, $value) = @_;
    $self->setFieldValue('value', $value);
}


=back

=cut

### Other Methods

sub getField{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Content::External::Field');
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

