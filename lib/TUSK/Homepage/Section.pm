package TUSK::Homepage::Section;

=head1 NAME

B<TUSK::Homepage::Section> - Class for manipulating entries in table homepage_section in tusk database

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
					'tablename' => 'homepage_section',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'homepage_section_id' => 'pk',
					'token' => '',
					'label' => '',
					'display_column' => '',
					'sort_order' => '',
					'display' => '',
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

=item B<getToken>

my $string = $obj->getToken();

Get the value of the token field

=cut

sub getToken{
    my ($self) = @_;
    return $self->getFieldValue('token');
}

#######################################################

=item B<setToken>

$obj->setToken($value);

Set the value of the token field

=cut

sub setToken{
    my ($self, $value) = @_;
    $self->setFieldValue('token', $value);
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

=item B<getDisplayColumn>

my $string = $obj->getDisplayColumn();

Get the value of the display_column field

=cut

sub getDisplayColumn{
    my ($self) = @_;
    return $self->getFieldValue('display_column');
}

#######################################################

=item B<setDisplayColumn>

$obj->setDisplayColumn($value);

Set the value of the display_column field

=cut

sub setDisplayColumn{
    my ($self, $value) = @_;
    $self->setFieldValue('display_column', $value);
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

=item B<getDisplay>

my $string = $obj->getDisplay();

Get the value of the display field

=cut

sub getDisplay{
    my ($self) = @_;
    return $self->getFieldValue('display');
}

#######################################################

=item B<setDisplay>

$obj->setDisplay($value);

Set the value of the display field

=cut

sub setDisplay{
    my ($self, $value) = @_;
    $self->setFieldValue('display', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getMajorSections>

$obj->getMajorSections();

Get all major homepage sections.

=cut

sub getMajorSections{
    my ($self) = @_;
    my $sections = $self->lookup("display_column='major' and display=1", ['sort_order asc', 'homepage_section_id desc']);
	return $sections;
}
#######################################################

=item B<getMinorSections>

$obj->getMinorSections();

Get all minor homepage sections.

=cut

sub getMinorSections{
    my ($self) = @_;
    my $sections = $self->lookup("display_column='minor' and display=1", ['sort_order asc', 'homepage_section_id desc']);
	return $sections;
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

