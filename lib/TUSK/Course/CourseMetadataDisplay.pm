package TUSK::Course::CourseMetadataDisplay;

=head1 NAME

B<TUSK::Course::CourseMetadataDisplay> - Class for manipulating entries in table course_metadata_display in tusk database

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
					'tablename' => 'course_metadata_display',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'metadata_display_id' => 'pk',
					'display_title' => '',
					'sort_order' => '',
					'parent' => '',
					'edit_type' => '',
					'edit_comment' => '',
					'locked' => '',
					'school_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}




#######################################################

=item B<getDisplayTitle>

$obj->getMetadataDisplayHash($school_id, \%aHashRef);

Set a hash to contain all of the metadata see CourseMetadata::getSchoolMetadata

=cut

sub getMetadataDisplayHash{
    my ($self, $schoolID, $returnHashRef) = @_;
    $self->_getSchoolMetadataDisplayLevel("NULL", $schoolID, $returnHashRef);
}

sub _getSchoolMetadataDisplayLevel{
  my ($self, $parent, $schoolID, $hashToFill) = @_;
  if($parent eq 'NULL') {$parent = "IS NULL";} else {$parent = "= $parent";}
  my $tempArrayRef = $self->lookup("parent $parent AND school_id=$schoolID");
  foreach my $metadataDBLine (@{$tempArrayRef})
  {
    push @{${$hashToFill}{metadataOrder}}, $metadataDBLine->getPrimaryKeyID();
    ${$hashToFill}{ $metadataDBLine->getPrimaryKeyID() }{displayName} = $metadataDBLine->getFieldValue('display_title');
    ${$hashToFill}{ $metadataDBLine->getPrimaryKeyID() }{editType} = $metadataDBLine->getFieldValue('edit_type');
    ${$hashToFill}{ $metadataDBLine->getPrimaryKeyID() }{editComment} = $metadataDBLine->getFieldValue('edit_comment');
    ${$hashToFill}{ $metadataDBLine->getPrimaryKeyID() }{locked} = $metadataDBLine->getFieldValue('locked');
    $self->_getSchoolMetadataDisplayLevel($metadataDBLine->getFieldValue('metadata_display_id'), $schoolID,
                                          \%{${$hashToFill}{ $metadataDBLine->getPrimaryKeyID() }{children}}
                                         );
  }
}

### Get/Set methods

#######################################################

=item B<getDisplayTitle>

my $string = $obj->getDisplayTitle();

Get the value of the display_title field

=cut

sub getDisplayTitle{
    my ($self) = @_;
    return $self->getFieldValue('display_title');
}

#######################################################

=item B<setDisplayTitle>

$obj->setDisplayTitle($value);

Set the value of the display_title field

=cut

sub setDisplayTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('display_title', $value);
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

=item B<getParent>

my $string = $obj->getParent();

Get the value of the parent field

=cut

sub getParent{
    my ($self) = @_;
    return $self->getFieldValue('parent');
}

#######################################################

=item B<setParent>

$obj->setParent($value);

Set the value of the parent field

=cut

sub setParent{
    my ($self, $value) = @_;
    $self->setFieldValue('parent', $value);
}


#######################################################

=item B<getLocked>

my $string = $obj->getLocked();

Get the value of the locked field

=cut

sub getLocked{
    my ($self) = @_;
    return $self->getFieldValue('locked');
}

#######################################################

=item B<setLocked>

$obj->setLocked($value);

Set the value of the locked field

=cut

sub setLocked{
    my ($self, $value) = @_;
    $self->setFieldValue('locked', $value);
}


#######################################################

=item B<getEditComment>

my $string = $obj->getEditComment();

Get the value of the edit_comment field

=cut

sub getEditComment{
    my ($self) = @_;
    return $self->getFieldValue('edit_comment');
}

#######################################################

=item B<setEditComment>

$obj->setEditComment($value);

Set the value of the edit_comment field

=cut

sub setEditComment{
    my ($self, $value) = @_;
    $self->setFieldValue('edit_comment', $value);
}


#######################################################

=item B<getEditType>

my $string = $obj->getEditType();

Get the value of the edit_type field

=cut

sub getEditType{
    my ($self) = @_;
    return $self->getFieldValue('edit_type');
}

#######################################################

=item B<setEditType>

$obj->setEditType($value);

Set the value of the edit_type field

=cut

sub setEditType{
    my ($self, $value) = @_;
    $self->setFieldValue('edit_type', $value);
}


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

