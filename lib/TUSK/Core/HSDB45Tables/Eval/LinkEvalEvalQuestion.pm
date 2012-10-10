package TUSK::Core::HSDB45Tables::Eval::LinkEvalEvalQuestion;

=head1 NAME

B<TUSK::Eval::LinkEvalEvalQuestion> - Class for manipulating entries in table link_eval_eval_question in hsdb45_med_admin database

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
					'database' => '',
					'tablename' => 'link_eval_eval_question',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'parent_eval_id' => '',
					'child_eval_question_id' => 'pk',
					'label' => '',
					'sort_order' => '',
					'required' => '',
					'grouping' => '',
					'graphic_stylesheet' => '',
					'modified' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
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

=item B<getLabel>

my $string = $obj->getLabel();

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


#######################################################

=item B<getGrouping>

my $string = $obj->getGrouping();

Get the value of the grouping field

=cut

sub getGrouping{
    my ($self) = @_;
    return $self->getFieldValue('grouping');
}

#######################################################

=item B<setGrouping>

$obj->setGrouping($value);

Set the value of the grouping field

=cut

sub setGrouping{
    my ($self, $value) = @_;
    $self->setFieldValue('grouping', $value);
}


#######################################################

=item B<getGraphicStylesheet>

my $string = $obj->getGraphicStylesheet();

Get the value of the graphic_stylesheet field

=cut

sub getGraphicStylesheet{
    my ($self) = @_;
    return $self->getFieldValue('graphic_stylesheet');
}

#######################################################

=item B<setGraphicStylesheet>

$obj->setGraphicStylesheet($value);

Set the value of the graphic_stylesheet field

=cut

sub setGraphicStylesheet{
    my ($self, $value) = @_;
    $self->setFieldValue('graphic_stylesheet', $value);
}


#######################################################

=item B<getModified>

my $string = $obj->getModified();

Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
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

