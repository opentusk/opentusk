package TUSK::Core::LinkIntegratedCourseContent;

=head1 NAME

B<TUSK::Core::LinkIntegratedCourseContent> - Class for manipulating entries in table link_content_keyword in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp qw(confess);

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;
	require TUSK::Course;
	require HSDB4::SQLRow::Content;

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
					'tablename' => 'link_integrated_course_content',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_integrated_course_content_id' => 'pk',
					'parent_integrated_course_id' => '',
					'child_content_id' => '',
					'originating_course_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getChildContentID>

    $string = $obj->getChildContentID();

    Get the value of the child_content_id field

=cut

sub getChildContentID{
    my ($self) = @_;
    return $self->getFieldValue('child_content_id');
}

#######################################################

=item B<setChildContentID>

    $obj->setChildContentID($value);

    Set the value of the child_content_id field

=cut

sub setChildContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_content_id', $value);
}


#######################################################

=item B<getParentIntegratedCourseID>

    $string = $obj->getParentIntegratedCourseID();

    Get the value of the parent_integrated_course_id field

=cut

sub getParentIntegratedCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_integrated_course_id');
}

#######################################################

=item B<setParentIntegratedCourseID>

    $obj->setParentIntegratedCourseID($value);

    Set the value of the parent_integrated_course_id field

=cut

sub setParentIntegratedCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_integrated_course_id', $value);
}

#######################################################

=item B<getOriginatingCourseID>

    $string = $obj->getOriginatingCourseID();

    Get the value of the originating_course_id field

=cut

sub getOriginatingCourseID{
    my ($self) = @_;
    return $self->getFieldValue('originating_course_id');
}

#######################################################

=item B<setOriginatingCourseID>

    $obj->setOriginatingCourseID($value);

    Set the value of the originating_course_id field

=cut

sub setOriginatingCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('originating_course_id', $value);
}


### Other Methods

#######################################################

=item B<getIntegratedCourseObject>

    $keyword = $obj->getIntegratedCourseObject($value);

    Return the TUSK::Course object associated with this link record as a parent

=cut

sub getIntegratedCourseObject {
        my $self = shift;
        return TUSK::Course->new()->lookupKey( $self->getParentIntegratedCourseID() );
}

=back

#######################################################

=item B<getContentObject>

    $keyword = $obj->getContentObject($value);

    Return the HSDB4::SQLRow::Content object associated with this link record

=cut

sub getContentObject {
        my $self = shift;
	return HSDB4::SQLRow::Content->new->lookup_key($self->getChildContentID());
}

=back

#######################################################

=item B<getOriginatingCourseObject>

    $keyword = $obj->getOriginatingCourseObject($value);

    Return the TUSK::Course object associated with this link record as an originating course

=cut

sub getOriginatingCourseObject {
        my $self = shift;
        return TUSK::Course->new()->lookupKey( $self->getOriginatingCourseID() );
}

=back

#######################################################

=item B<lookupByRelation>

    $link = $obj->lookupByRelation($parent_id, $child_id);

    Return the LinkIntegratedCourseContent object associated with this link record

=cut

sub lookupByRelation {
        my $self = shift;
	my $parent_id = shift or confess "Need to pass parent id ";
	my $child_id = shift or confess "Need to pass child id ";
	return $self->lookupReturnOne("parent_integrated_course_id = $parent_id ".
        " and child_content_id = '$child_id' ");

}

=back



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

