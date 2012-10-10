package TUSK::Core::HSDB4Tables::Content;

=head1 NAME

B<TUSK::Core::HSDB4Tables::Content> - Class for manipulating entries in table content in hsdb4 database

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
use HSDB4::SQLRow::Content;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'hsdb4',
					'tablename' => 'content',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'content_id' => 'pk',
					'type' => '',
					'title' => '',
					'course_id' => '',
					'school' => '',
					'system' => '',
					'copyright' => '',
					'source' => '',
					'body' => '',
					'hscml_body' => '',
					'style' => '',
					'modified' => '',
					'created' => '',
					'read_access' => '',
					'write_access' => '',
					'checked_out_by' => '',
					'check_out_time' => '',
					'conversion_status' => '',
					'display' => '',
					'reuse_content_id' => '',
					'start_date' => '',
					'end_date' => '',
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

=item B<getType>

my $string = $obj->getType();

Get the value of the type field

=cut

sub getType{
    my ($self) = @_;
    return $self->getFieldValue('type');
}

#######################################################

=item B<setType>

$obj->setType($value);

Set the value of the type field

=cut

sub setType{
    my ($self, $value) = @_;
    $self->setFieldValue('type', $value);
}


#######################################################

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getCourseID>

my $string = $obj->getCourseID();

Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

$obj->setCourseID($value);

Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getSchool>

my $string = $obj->getSchool();

Get the value of the school field

=cut

sub getSchool{
    my ($self) = @_;
    return $self->getFieldValue('school');
}

#######################################################

=item B<setSchool>

$obj->setSchool($value);

Set the value of the school field

=cut

sub setSchool{
    my ($self, $value) = @_;
    $self->setFieldValue('school', $value);
}


#######################################################

=item B<getSystem>

my $string = $obj->getSystem();

Get the value of the system field

=cut

sub getSystem{
    my ($self) = @_;
    return $self->getFieldValue('system');
}

#######################################################

=item B<setSystem>

$obj->setSystem($value);

Set the value of the system field

=cut

sub setSystem{
    my ($self, $value) = @_;
    $self->setFieldValue('system', $value);
}


#######################################################

=item B<getCopyright>

my $string = $obj->getCopyright();

Get the value of the copyright field

=cut

sub getCopyright{
    my ($self) = @_;
    return $self->getFieldValue('copyright');
}

#######################################################

=item B<setCopyright>

$obj->setCopyright($value);

Set the value of the copyright field

=cut

sub setCopyright{
    my ($self, $value) = @_;
    $self->setFieldValue('copyright', $value);
}


#######################################################

=item B<getSource>

my $string = $obj->getSource();

Get the value of the source field

=cut

sub getSource{
    my ($self) = @_;
    return $self->getFieldValue('source');
}

#######################################################

=item B<setSource>

$obj->setSource($value);

Set the value of the source field

=cut

sub setSource{
    my ($self, $value) = @_;
    $self->setFieldValue('source', $value);
}


#######################################################

=item B<getBody>

my $string = $obj->getBody();

Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

$obj->setBody($value);

Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}


#######################################################

=item B<getHscmlBody>

my $string = $obj->getHscmlBody();

Get the value of the hscml_body field

=cut

sub getHscmlBody{
    my ($self) = @_;
    return $self->getFieldValue('hscml_body');
}

#######################################################

=item B<setHscmlBody>

$obj->setHscmlBody($value);

Set the value of the hscml_body field

=cut

sub setHscmlBody{
    my ($self, $value) = @_;
    $self->setFieldValue('hscml_body', $value);
}


#######################################################

=item B<getStyle>

my $string = $obj->getStyle();

Get the value of the style field

=cut

sub getStyle{
    my ($self) = @_;
    return $self->getFieldValue('style');
}

#######################################################

=item B<setStyle>

$obj->setStyle($value);

Set the value of the style field

=cut

sub setStyle{
    my ($self, $value) = @_;
    $self->setFieldValue('style', $value);
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

#######################################################

=item B<setModified>

$obj->setModified($value);

Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
}


#######################################################

=item B<getCreated>

my $string = $obj->getCreated();

Get the value of the created field

=cut

sub getCreated{
    my ($self) = @_;
    return $self->getFieldValue('created');
}

#######################################################

=item B<setCreated>

$obj->setCreated($value);

Set the value of the created field

=cut

sub setCreated{
    my ($self, $value) = @_;
    $self->setFieldValue('created', $value);
}


#######################################################

=item B<getReadAccess>

my $string = $obj->getReadAccess();

Get the value of the read_access field

=cut

sub getReadAccess{
    my ($self) = @_;
    return $self->getFieldValue('read_access');
}

#######################################################

=item B<setReadAccess>

$obj->setReadAccess($value);

Set the value of the read_access field

=cut

sub setReadAccess{
    my ($self, $value) = @_;
    $self->setFieldValue('read_access', $value);
}


#######################################################

=item B<getWriteAccess>

my $string = $obj->getWriteAccess();

Get the value of the write_access field

=cut

sub getWriteAccess{
    my ($self) = @_;
    return $self->getFieldValue('write_access');
}

#######################################################

=item B<setWriteAccess>

$obj->setWriteAccess($value);

Set the value of the write_access field

=cut

sub setWriteAccess{
    my ($self, $value) = @_;
    $self->setFieldValue('write_access', $value);
}


#######################################################

=item B<getCheckedOutBy>

my $string = $obj->getCheckedOutBy();

Get the value of the checked_out_by field

=cut

sub getCheckedOutBy{
    my ($self) = @_;
    return $self->getFieldValue('checked_out_by');
}

#######################################################

=item B<setCheckedOutBy>

$obj->setCheckedOutBy($value);

Set the value of the checked_out_by field

=cut

sub setCheckedOutBy{
    my ($self, $value) = @_;
    $self->setFieldValue('checked_out_by', $value);
}


#######################################################

=item B<getCheckOutTime>

my $string = $obj->getCheckOutTime();

Get the value of the check_out_time field

=cut

sub getCheckOutTime{
    my ($self) = @_;
    return $self->getFieldValue('check_out_time');
}

#######################################################

=item B<setCheckOutTime>

$obj->setCheckOutTime($value);

Set the value of the check_out_time field

=cut

sub setCheckOutTime{
    my ($self, $value) = @_;
    $self->setFieldValue('check_out_time', $value);
}


#######################################################

=item B<getConversionStatus>

my $string = $obj->getConversionStatus();

Get the value of the conversion_status field

=cut

sub getConversionStatus{
    my ($self) = @_;
    return $self->getFieldValue('conversion_status');
}

#######################################################

=item B<setConversionStatus>

$obj->setConversionStatus($value);

Set the value of the conversion_status field

=cut

sub setConversionStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('conversion_status', $value);
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


#######################################################

=item B<getReuseContentID>

my $string = $obj->getReuseContentID();

Get the value of the reuse_content_id field

=cut

sub getReuseContentID{
    my ($self) = @_;
    return $self->getFieldValue('reuse_content_id');
}

#######################################################

=item B<setReuseContentID>

$obj->setReuseContentID($value);

Set the value of the reuse_content_id field

=cut

sub setReuseContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('reuse_content_id', $value);
}


#######################################################

=item B<getStartDate>

my $string = $obj->getStartDate();

Get the value of the start_date field

=cut

sub getStartDate{
    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

#######################################################

=item B<setStartDate>

$obj->setStartDate($value);

Set the value of the start_date field

=cut

sub setStartDate{
    my ($self, $value) = @_;
    $self->setFieldValue('start_date', $value);
}


#######################################################

=item B<getEndDate>

my $string = $obj->getEndDate();

Get the value of the end_date field

=cut

sub getEndDate{
    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

#######################################################

=item B<setEndDate>

$obj->setEndDate($value);

Set the value of the end_date field

=cut

sub setEndDate{
    my ($self, $value) = @_;
    $self->setFieldValue('end_date', $value);
}



=back

=cut

### Other Methods

sub getHSDB4ContentObject{
    my ($self) = @_;

    my $content = HSDB4::SQLRow::Content->new();

    my $fields = $self->getAllFields();

    foreach my $field (@$fields){
	if ($self->getPrimaryKey() eq $field){
	    $content->primary_key($self->getPrimaryKeyID());
	}
	else{
	    $content->field_value($field, $self->getFieldValue($field));
	}
    }

    $content->rebless();

    return $content;
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

