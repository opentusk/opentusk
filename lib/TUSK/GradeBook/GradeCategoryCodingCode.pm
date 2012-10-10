package TUSK::GradeBook::GradeCategoryCodingCode;

=head1 NAME

B<TUSK::GradeBook::GradeCategoryCodingCode> - Class for manipulating entries in table grade_category_coding_code in tusk database

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
					'tablename' => 'grade_category_coding_code',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_category_coding_code_id' => 'pk',
					'grade_category_id' => '',
					'coding_code_id' => '',
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

=item B<getGradeCategoryID>

my $string = $obj->getGradeCategoryID();

Get the value of the grade_category_id field

=cut

sub getGradeCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('grade_category_id');
}

#######################################################

=item B<setGradeCategoryID>

$obj->setGradeCategoryID($value);

Set the value of the grade_category_id field

=cut

sub setGradeCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_category_id', $value);
}


#######################################################

=item B<getCodingCodeID>

my $string = $obj->getCodingCodeID();

Get the value of the coding_code_id field

=cut

sub getCodingCodeID{
    my ($self) = @_;
    return $self->getFieldValue('coding_code_id');
}

#######################################################

=item B<setCodingCodeID>

$obj->setCodingCodeID($value);

Set the value of the coding_code_id field

=cut

sub setCodingCodeID{
    my ($self, $value) = @_;
    $self->setFieldValue('coding_code_id', $value);
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

sub getCodingObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Coding::Code");
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

