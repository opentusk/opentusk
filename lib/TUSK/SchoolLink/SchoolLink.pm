package TUSK::SchoolLink::SchoolLink;

=head1 NAME

B<TUSK::SchoolLink::SchoolLink> - Class for manipulating entries in table school_link in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use HSDB4::DateTime;


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
					'tablename' => 'school_link',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'school_link_id' => 'pk',
					'school_id' => '',
					'label' => '',
					'url' => '',
					'sort_order' => '',
					'parent_school_link_id' => '',
					'show_date' => '',
					'hide_date' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_order_bys => ['sort_order'],
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

#######################################################

=item B<delete>

    $retval = $obj->delete($cond);

update sort orders of any links that follow the deleted link 
and then call superclass's delete() method.

=cut

sub delete {
    my ($self, $params) = @_;

	my $sort_order = $self->getSortOrder();
	my $school_id = $self->getSchoolID();
	my $sublinks = $self->getChildLinks();
	
	my $retval = $self->SUPER::delete($params);

	if($retval){
		foreach my $sl (@$sublinks) {
			$sl->SUPER::delete($params);
		}

		my $links = TUSK::SchoolLink::SchoolLink->new()->lookup("school_id=$school_id and parent_school_link_id is NULL and sort_order >= $sort_order");

		foreach my $l (@$links){
			my $order = $l->getSortOrder();
			$l->setSortOrder( ($order - 10) );
			$l->save($params);
		}
	}
	return $retval; 
}

### Get/Set methods

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

=item B<getUrl>

my $string = $obj->getUrl();

Get the value of the url field

=cut

sub getUrl{
    my ($self) = @_;
    return $self->getFieldValue('url');
}

#######################################################

=item B<setUrl>

$obj->setUrl($value);

Set the value of the url field

=cut

sub setUrl{
    my ($self, $value) = @_;

	$value = 'http://' . $value unless (!$value || $value =~ /^[A-z]*:\/\//);

    $self->setFieldValue('url', $value);
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

=item B<getParentSchoolLinkID>

my $id = $obj->getParentSchoolLinkID();

Get the value of the parent_school_link_id field

=cut

sub getParentSchoolLinkID{
    my ($self) = @_;
    return $self->getFieldValue('parent_school_link_id');
}

#######################################################

=item B<setParentSchoolLinkID>

$obj->setParentSchoolLinkID($value);

Set the value of the parent_school_link_id field

=cut

sub setParentSchoolLinkID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_school_link_id', $value);
}


#######################################################

=item B<getShowDate>

my $string = $obj->getShowDate();

Get the value of the show_date field

=cut

sub getShowDate{
    my ($self) = @_;
    return $self->getFieldValue('show_date');
}

#######################################################

=item B<setShowDate>

$obj->setShowDate($value);

Set the value of the show_date field

=cut

sub setShowDate{
    my ($self, $value) = @_;
    $self->setFieldValue('show_date', $value);
}


#######################################################

=item B<getHideDate>

my $string = $obj->getHideDate();

Get the value of the hide_date field

=cut

sub getHideDate{
    my ($self) = @_;
    return $self->getFieldValue('hide_date');
}

#######################################################

=item B<setHideDate>

$obj->setHideDate($value);

Set the value of the hide_date field

=cut

sub setHideDate{
    my ($self, $value) = @_;
    $self->setFieldValue('hide_date', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<updateSortOrders>

    $obj->updateSortOrders($school_id,$change_order_string,$arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  
$index is array index of the object that changed,
$newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateSortOrders {
    my ($self, $school_id,  $change_order_string, $arrayref) = @_;
    return [] unless $school_id;

    my $cond = "school_id = " . $school_id ;
    
    my ($index, $newindex) = split ("-", $change_order_string);
    return $self->SUPER::updateSortOrders($index, $newindex, $cond, $arrayref);
}

#######################################################

=item B<isActive>

    $obj->isActive();

Determine whether the link should be displayed based upon its
"hide_date" and "show_date" values.

=cut

sub isActive {
    my $self = shift;

	my $hide_date = HSDB4::DateTime->new()->in_mysql_date($self->getHideDate());
	my $show_date = HSDB4::DateTime->new()->in_mysql_date($self->getShowDate());
	my $today = HSDB4::DateTime->new();#->out_mysql_date();

	if(   ($show_date->has_value() && $today->is_before($show_date))
	   || ($hide_date->has_value() && $today->is_after($hide_date)) ){
		return 0;
	}
	else {
		return 1;
	}
}

#######################################################

=item B<isActiveDisplay>

    $obj->isActiveDisplay();

isActive returns a boolean (1 or 0). This method returns an English
language "yes" or "no"

=cut

sub isActiveDisplay {
    my $self = shift;

	if($self->isActive()){
		return "Yes";
	}
	else {
		return "No";
	}
}

#######################################################

=item B<getChildLinks>

    $obj->getChildLinks();

Returns the active sublinks

=cut

sub getChildLinks {
    my $self = shift;

	my $subs = [];
	if($self->getPrimaryKeyID()){
		$subs = TUSK::SchoolLink::SchoolLink->new()->lookup('parent_school_link_id=' . $self->getPrimaryKeyID());
	}

	return $subs;
}

#######################################################

=item B<countChildLinks>

    $obj->countChildLinks();

Returns the number of active sublinks

=cut

sub countChildLinks {
    my $self = shift;

	my $subs = [];
	if($self->getPrimaryKeyID()){
		$subs = TUSK::SchoolLink::SchoolLink->new()->lookup('parent_school_link_id=' . $self->getPrimaryKeyID());
	}

	return scalar(@$subs);
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

