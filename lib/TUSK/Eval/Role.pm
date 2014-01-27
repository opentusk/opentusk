package TUSK::Eval::Role;

=head1 NAME

B<TUSK::Eval::Role> - Class for manipulating entries in table eval_role in tusk database

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
					'tablename' => 'eval_role',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_role_id' => 'pk',
					'school_id' => '',
					'eval_id' => '',
					'role_id' => '',
					'sort_order' => '',
					'required_evals' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getEvalID>

my $string = $obj->getEvalID();

Get the value of the eval_id field

=cut

sub getEvalID{
    my ($self) = @_;
    return $self->getFieldValue('eval_id');
}

#######################################################

=item B<setEvalID>

$obj->setEvalID($value);

Set the value of the eval_id field

=cut

sub setEvalID{
    my ($self, $value) = @_;
    $self->setFieldValue('eval_id', $value);
}


#######################################################

=item B<getRoleID>

my $string = $obj->getRoleID();

Get the value of the role_id field

=cut

sub getRoleID{
    my ($self) = @_;
    return $self->getFieldValue('role_id');
}

#######################################################

=item B<setRoleID>

$obj->setRoleID($value);

Set the value of the role_id field

=cut

sub setRoleID{
    my ($self, $value) = @_;
    $self->setFieldValue('role_id', $value);
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

=item B<getRequiredEvals>

my $string = $obj->getRequiredEvals();

Get the value of the required_evals field

=cut

sub getRequiredEvals{
    my ($self) = @_;
    return $self->getFieldValue('required_evals');
}

#######################################################

=item B<setRequiredEvals>

$obj->setRequiredEvals($value);

Set the value of the required_evals field

=cut

sub setRequiredEvals{
    my ($self, $value) = @_;
    $self->setFieldValue('required_evals', $value);
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

