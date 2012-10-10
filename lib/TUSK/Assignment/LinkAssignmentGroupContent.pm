package TUSK::Assignment::LinkAssignmentGroupContent;

=head1 NAME

B<TUSK::Assignment::LinkAssignmentGroupContent> - Class for manipulating entries in table link_assignment_group_content in tusk database

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
					'tablename' => 'link_assignment_group_content',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_assignment_group_content_id' => 'pk',
					'parent_assignment_id' => '',
					'child_group_content_id' => '',
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

=item B<getParentAssignmentID>

my $string = $obj->getParentAssignmentID();

Get the value of the parent_assignment_id field

=cut

sub getParentAssignmentID{
    my ($self) = @_;
    return $self->getFieldValue('parent_assignment_id');
}

#######################################################

=item B<setParentAssignmentID>

$obj->setParentAssignmentID($value);

Set the value of the parent_assignment_id field

=cut

sub setParentAssignmentID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_assignment_id', $value);
}


#######################################################

=item B<getChildGroupContentID>

my $string = $obj->getChildGroupContentID();

Get the value of the child_group_content_id field

=cut

sub getChildGroupContentID{
    my ($self) = @_;
    return $self->getFieldValue('child_group_content_id');
}

#######################################################

=item B<setChildGroupContentID>

$obj->setChildGroupContentID($value);

Set the value of the child_group_content_id field

=cut

sub setChildGroupContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_group_content_id', $value);
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

