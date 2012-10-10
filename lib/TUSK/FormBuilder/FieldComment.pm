package TUSK::FormBuilder::FieldComment;

=head1 NAME

B<TUSK::FormBuilder::FieldComment> - Class for manipulating entries in table form_builder_field_comment in tusk database

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
					'tablename' => 'form_builder_field_comment',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'field_comment_id' => 'pk',
					'field_id' => '',
					'comment' => '',
					'sort_order' => '',
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

=item B<getFieldID>

my $string = $obj->getFieldID();

Get the value of the field_id field

=cut

sub getFieldID{
    my ($self) = @_;
    return $self->getFieldValue('field_id');
}

#######################################################

=item B<setFieldID>

$obj->setFieldID($value);

Set the value of the field_id field

=cut

sub setFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('field_id', $value);
}


#######################################################

=item B<getComment>

my $string = $obj->getComment();

Get the value of the comment field

=cut

sub getComment{
    my ($self) = @_;
    return $self->getFieldValue('comment');
}

#######################################################

=item B<setComment>

$obj->setComment($value);

Set the value of the comment field

=cut

sub setComment{
    my ($self, $value) = @_;
    $self->setFieldValue('comment', $value);
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

