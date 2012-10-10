package TUSK::FormBuilder::EntryAssociation;

=head1 NAME

B<TUSK::FormBuilder::EntryAssociation> - Class for manipulating entries in table form_builder_entry_association in tusk database

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
use TUSK::FormBuilder::Entry;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'form_builder_entry_association',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'entry_association_id' => 'pk',
					'entry_id' => '',
					'user_id' => '',
					'is_final' => '',
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

=item B<getEntryID>

my $string = $obj->getEntryID();

Get the value of the entry_id field

=cut

sub getEntryID{
    my ($self) = @_;
    return $self->getFieldValue('entry_id');
}

#######################################################

=item B<setEntryID>

$obj->setEntryID($value);

Set the value of the entry_id field

=cut

sub setEntryID{
    my ($self, $value) = @_;
    $self->setFieldValue('entry_id', $value);
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



#######################################################

=item B<getIsFinal>

my $string = $obj->getIsFinal();

Get the value of the is_final field

=cut

sub getIsFinal{
    my ($self) = @_;
    return $self->getFieldValue('is_final');
}

#######################################################

=item B<setIsFinal>

$obj->setIsFinal($value);

Set the value of the is_final field

=cut

sub setIsFinal{
    my ($self, $value) = @_;
    $self->setFieldValue('is_final', $value);
}


=back

=cut

### Other Methods

sub getEntryObject {
	my $self = shift;
	return $self->getJoinObject('TUSK::FormBuilder::Entry');
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

