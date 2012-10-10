package TUSK::Schedule::ClassMeetingKeyword;

=head1 NAME

B<TUSK::Schedule::ClassMeetingKeyword> - Class for manipulating entries in table class_meeting_keyword in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Keyword;

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
					'tablename' => 'class_meeting_keyword',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'class_meeting_keyword_id' => 'pk',
					'class_meeting_id' => '',
					'keyword_id' => '',
					'school_id' => '',
					'sort_order' => '',
					'author_weight' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getClassMeetingID>

   $string = $obj->getClassMeetingID();

Get the value of the class_meeting_id field

=cut

sub getClassMeetingID{
    my ($self) = @_;
    return $self->getFieldValue('class_meeting_id');
}

#######################################################

=item B<setClassMeetingID>

    $string = $obj->setClassMeetingID($value);

Set the value of the class_meeting_id field

=cut

sub setClassMeetingID{
    my ($self, $value) = @_;
    $self->setFieldValue('class_meeting_id', $value);
}


#######################################################

=item B<getKeywordID>

   $string = $obj->getKeywordID();

Get the value of the keyword_id field

=cut

sub getKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('keyword_id');
}

#######################################################

=item B<setKeywordID>

    $string = $obj->setKeywordID($value);

Set the value of the keyword_id field

=cut

sub setKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('keyword_id', $value);
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

    $obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
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

    $string = $obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}

#######################################################

=item B<getAuthorWeight>

    $string = $obj->getAuthorWeight();

    Get the value of the author_weight field

=cut

sub getAuthorWeight{
    my ($self) = @_;
    return $self->getFieldValue('author_weight');
}

#######################################################

=item B<setAuthorWeight>

    $obj->setAuthorWeight($value);

    Set the value of the author_weight field

=cut

sub setAuthorWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('author_weight', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($school_id, $class_meeting_id,$keyword_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self,$school_id, $class_meeting_id, $keyword_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id and keyword_id = $keyword_id");
}

#######################################################

=item B<getKeyword>

    $keyword_object = $obj->getKeyword();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Keyword

=cut

sub getKeyword {
	my $self = shift;
	return TUSK::Core::Keyword->new->lookupKey($self->getKeywordID());
}

#######################################################

=item B<getKeywordsByClassMeeting>

    $new_object = $obj->getKeywordsByClassMeeting($school_id, $class_meeting_id);

=cut

sub getKeywordsByClassMeeting{
    my ($self, $school_id, $class_meeting_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id");
}

#######################################################

=item B<getAuthorDefinedKeywordsByClassMeeting>

    $new_object = $obj->getAuthorDefinedKeywordsByClassMeeting($school_id, $class_meeting_id);

=cut

sub getAuthorDefinedKeywordsByClassMeeting{
    my ($self, $school_id, $class_meeting_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id and author_weight is null" );
}

#######################################################

=item B<getUmlsConceptsByClassMeeting>

    $new_object = $obj->getUmlsConceptsByClassMeeting($school_id, $class_meeting_id);

=cut

sub getUmlsConceptsByClassMeeting{
    my ($self, $school_id, $class_meeting_id) = @_;
    return $self->lookup("school_id = $school_id and class_meeting_id = $class_meeting_id and author_weight is not null");
}
=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

