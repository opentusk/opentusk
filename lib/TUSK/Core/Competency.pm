package TUSK::Core::Competency;

=head1 NAME

B<TUSK::Core::Competency> - Class for manipulating entries in table competency in tusk database

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
use Carp qw(cluck croak confess);
use TUSK::Core::CompetencyType;
use TUSK::Core::CompetencyCompetencyType;

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
					'tablename' => 'competency',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_id' => 'pk',
					'school_id' => '',
					'title' => '',
					'description' => '',
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

=item B<getCompetencyID>

    $string = $obj->getCompetencyID();

    Get the value of the competency_id field

=cut

sub getCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('competency_id');
}

#######################################################

=item B<getSchoolID>

    $string = $obj->getSchoolID();

    Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getTitle>

    $string = $obj->getTitle();

    Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

    $string = $obj->setTitle($value);

    Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}

#######################################################

=item B<getDescription>

    $string = $obj->getDescription();

    Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

    $string = $obj->setDescription($value);

    Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}

#######################################################


### Other Methods

#######################################################

sub displayTypes {
	my $self = shift;
	my $types = TUSK::Core::CompetencyCompetencyType->new()->getCompetencyTypesByCompetency( $self->getCompetencyID );
	my @data = map ($_->getCompetencyType->getDescription, @{$types});
	return join( ', ', @data );
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

