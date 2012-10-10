package TUSK::Coding::Code;

=head1 NAME

B<TUSK::Coding::Code> - Class for manipulating entries in table coding_code in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Coding::Category;

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
					'tablename' => 'coding_code',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'coding_code_id' => 'pk',
					'code' => '',
					'label' => '',
					'coding_category_id' => '',
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

=item B<getCode>

my $string = $obj->getCode();

Get the value of the code field

=cut

sub getCode{
    my ($self) = @_;
    return $self->getFieldValue('code');
}

#######################################################

=item B<setCode>

$obj->setCode($value);

Set the value of the code field

=cut

sub setCode{
    my ($self, $value) = @_;
    $self->setFieldValue('code', $value);
}


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

=item B<getCodingCategoryID>

my $string = $obj->getCodingCategoryID();

Get the value of the coding_category_id field

=cut

sub getCodingCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('coding_category_id');
}

#######################################################

=item B<setCodingCategoryID>

$obj->setCodingCategoryID($value);

Set the value of the coding_category_id field

=cut

sub setCodingCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('coding_category_id', $value);
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

sub getCodingCategoryObject {
	my $self = shift;
	return $self->getJoinObject("TUSK::Coding::Category");
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

