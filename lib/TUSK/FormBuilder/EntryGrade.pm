package TUSK::FormBuilder::EntryGrade;

=head1 NAME

B<TUSK::FormBuilder::EntryGrade> - Class for manipulating entries in table form_builder_entry_grade in tusk database

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
					'tablename' => 'form_builder_entry_grade',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'entry_grade_id' => 'pk',
					'entry_id' => '',
					'score' => '',
					'comments' => '',
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

=item B<getScore>

my $string = $obj->getScore();

Get the value of the score field

=cut

sub getScore{
    my ($self) = @_;
    return $self->getFieldValue('score');
}

#######################################################

=item B<setScore>

$obj->setScore($value);

Set the value of the score field

=cut

sub setScore{
    my ($self, $value) = @_;
    $self->setFieldValue('score', $value);
}


#######################################################

=item B<getComments>

my $string = $obj->getComments();

Get the value of the comments field

=cut

sub getComments{
    my ($self) = @_;
    return $self->getFieldValue('comments');
}

#######################################################

=item B<setComments>

$obj->setComments($value);

Set the value of the comments field

=cut

sub setComments{
    my ($self, $value) = @_;
    $self->setFieldValue('comments', $value);
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

