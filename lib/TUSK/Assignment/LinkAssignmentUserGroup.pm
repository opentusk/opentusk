package TUSK::Assignment::LinkAssignmentUserGroup;

=head1 NAME

B<TUSK::Assignment::LinkAssignmentUserGroup> - Class for manipulating entries in table link_assignment_user_group in tusk database

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
					'tablename' => 'link_assignment_user_group',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_assignment_user_group_id' => 'pk',
					'parent_assignment_id' => '',
					'child_user_group_id' => '',
					'resubmit_flag' => '',
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

=item B<getChildUserGroupID>

my $string = $obj->getChildUserGroupID();

Get the value of the child_user_group_id field

=cut

sub getChildUserGroupID{
    my ($self) = @_;
    return $self->getFieldValue('child_user_group_id');
}

#######################################################

=item B<setChildUserGroupID>

$obj->setChildUserGroupID($value);

Set the value of the child_user_group_id field

=cut

sub setChildUserGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_user_group_id', $value);
}


#######################################################

=item B<getResubmitFlag>

my $string = $obj->getResubmitFlag();

Get the value of the resubmit_flag field

=cut

sub getResubmitFlag{
    my ($self) = @_;
    return $self->getFieldValue('resubmit_flag');
}


#######################################################

=item B<setResubmitFlag>

$obj->setResubmitFlag($value);

Set the value of the resubmit_flag field

=cut

sub setResubmitFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('resubmit_flag', $value);
}


=back

=cut

### Other Methods

sub getLastSubmitDate {
    my $self = shift;
    my $submit = TUSK::Assignment::Submission->lookupReturnOne("link_id = " . $self->getPrimaryKeyID() . " AND link_type = '" . $self->getTablename() . "' AND submit_sequence = " . $self->getSubmissions());
    return ($submit) ? $submit->getFormattedSubmitDate() : undef;
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

