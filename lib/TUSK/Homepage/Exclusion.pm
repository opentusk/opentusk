package TUSK::Homepage::Exclusion;

=head1 NAME

B<TUSK::Homepage::Exclusion> - Class for manipulating entries in table homepage_exclusion in tusk database

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

#use TUSK::GradeBook::GradeEvent;

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
					'tablename' => 'homepage_exclusion',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'homepage_exclusion_id' => 'pk',
					'user_id' => '',
					'section_token' => '',
					},
					_attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				     _default_join_objects => [
				     ],
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

=item B<getHomepageExclusionID>

my $string = $obj->getHomepageExclusionID();

Get the value of the homepage_exclusion_id field

=cut

sub getHomepageExclusionID{
    my ($self) = @_;
    return $self->getFieldValue('homepage_exlcusion_id');
}

#######################################################

=item B<getUserID>

$obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
	my ($self) = @_;
	$self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID('user_id');

Set the value of the user_id field

=cut

sub setUserID{
	my ($self, $uid) = @_;
	$self->setFieldValue('user_id', $uid);
}

#######################################################

=item B<getSectionToken>

$obj->getSectionToken();

Get the value of the section_token field

=cut

sub getSectionToken{
	my ($self) = @_;
	$self->getFieldValue('section_token');
}

#######################################################

=item B<setSectionToken>

$obj->setSectionToken('section_token');

Set the value of the section_token field

=cut

sub setSectionToken{
	my ($self, $id) = @_;
	$self->setFieldValue('section_token', $id);
}

#######################################################

=item B<excludeSection>

$obj->excludeSection();

Given a HomepageExclusion obj, save it to the DB, thereby
excluding it from display on the homepage

=cut

sub excludeSection{
	my $self = shift;
	# confirm that fields are set?
	$self->save();
}

#######################################################

=item B<includeSection>

$obj->includeSection();

Given a HomepageExclusion obj, delete it from the DB, thereby
including it for display on the homepage

=cut

sub includeSection{
	my $self = shift;
	my $pk = $self->getPrimaryKeyID(); 
	if($pk){
		return $self->deleteKey($pk);
	}
	else {
		return 0;
	}
}

1;
