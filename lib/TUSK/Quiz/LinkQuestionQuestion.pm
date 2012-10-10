package TUSK::Quiz::LinkQuestionQuestion;

=head1 NAME

B<TUSK::TUSK::Quiz::LinkQuestionQuestion> - Class for manipulating entries in table link_question_question in tusk database

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
					'tablename' => 'link_question_question',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_question_question_id' => 'pk',
					'parent_question_id' => '',
					'child_question_id' => '',
					'label' => '',
					'sort_order' => '',
					'points' => '',
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

=item B<getParentQuestionID>

    $string = $obj->getParentQuestionID();

    Get the value of the parent_question_id field

=cut

sub getParentQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('parent_question_id');
}

#######################################################

=item B<setParentQuestionID>

    $obj->setParentQuestionID($value);

    Set the value of the parent_question_id field

=cut

sub setParentQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_question_id', $value);
}


#######################################################

=item B<getChildQuestionID>

    $string = $obj->getChildQuestionID();

    Get the value of the child_question_id field

=cut

sub getChildQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('child_question_id');
}

#######################################################

=item B<setChildQuestionID>

    $obj->setChildQuestionID($value);

    Set the value of the child_question_id field

=cut

sub setChildQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_question_id', $value);
}


#######################################################

=item B<getLabel>

    $string = $obj->getLabel();

    Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

    $obj->setLabel($value);

    Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}


#######################################################

=item B<getSortOrder>

    $string = $obj->getSortOrder();

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

=item B<getPoints>

    $string = $obj->getPoints();

    Get the value of the points field

=cut

sub getPoints{
    my ($self) = @_;
    return $self->getFieldValue('points');
}

#######################################################

=item B<setPoints>

    $obj->setPoints($value);

    Set the value of the points field

=cut

sub setPoints{
    my ($self, $value) = @_;
    $self->setFieldValue('points', $value);
}



=back

=cut

### Other Methods

sub getQuestionObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Quiz::Question");
}

sub lookupByRelation {
    my ($self, $parent_question_id, $child_question_id) = @_; 
    return $self->lookup("parent_question_id = $parent_question_id and child_question_id = $child_question_id");
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

