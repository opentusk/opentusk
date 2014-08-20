# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Core::SQLRow;

=head1 NAME

B<TUSK::Core::SQLRow> - Virtual class for manipulating entries in TUSK tables

=head1 DESCRIPTION

A virtual class intended to be subclassed.  Used to get retrieve individual rows from TUSK tables and perform generic manipulations on them.  Also intended to provide a standard set of methods for dealing with table rows to take advantage of polymorphism.

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::DB;
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.70 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;
use Carp qw(cluck croak confess); 
use Data::Dumper;
use TUSK::Core::JoinObject;
use TUSK::Core::JoinObject::DerivedTable;
use HSDB4::Constants;

# Non-exported package globals go here
use vars ();

sub new {
    #
    # Does the default creation stuff
    #

    # Get the class name
    my $incoming  = shift;

    my $class = ref($incoming) || $incoming;

    # Get the field/value pairs that are being initialized from @_ and
    # use them to form the hash reference, bless the ref and return it
    
    my $self = { 
	_datainfo => {
	    database => '', # database name 
	    tablename => '', # table name
	    primary_key => '', # name of the primary key field in the table
	    usertoken => undef, # default usertoken for which this object connects to the database under a
            database_handle => '', # default
	},
	_field_names => {},
	_field_values => {},
	_id => undef,
	_attributes => {
	    save_history => 0,
	    tracking_fields => 0,
	    no_created => 0,
	},
	_levels => {
	    reporting => 'warn',
	    error => 3,		     
	},
	_default_join_objects => [],
	_default_order_bys => [],
	@_
	};

=for
	# HSDB45Tables::* have database undefined. This will make your life simpler.
	$self->{_datainfo}{database} = $_ for grep { defined } delete $self->{database};
	# Use 'id' instead of '_id';
	$self->{_id} = $_ for grep { defined } delete $self->{id};
=cut
    bless $self, $class;

    # figure out which field is the pk
    $self->setPrimaryKey;

    # Check on the ID...
    if ($self->{_id} and !$self->{_nolookup}) {
	$self->lookupKey($self->{_id});
    }

    if ($self->getTrackingFieldsAttribute){
	unless ($self->getNoCreatedAttribute()) {
	    $self->{_field_names}->{created_on} = "";
	    $self->{_field_names}->{created_by} = "";
	}
	$self->{_field_names}->{modified_on} = "";
	$self->{_field_names}->{modified_by} = "";
    }

    return $self;
}

=head1 DESCRIPTION

Listed below are all of the methods (split into sections) and their descriptions.

=head2 DEBUG METHODS

=over 4

=cut 

#######################################################

=item  B<debug>

    $obj->debug($msg, $level, $report);

Takes a string msg, a minimum error level, and a report type ('warn' or 'cluck').
If the min error level is <= to the error level set to the object 
then use the correct reporting type to output the message.

=cut

sub debug{
    my ($self, $msg, $level, $report) = @_;
    $report = $self->getReportingLevel() unless ($report);
    
    if ($level <= $self->getErrorLevel()){
	if ($report eq "warn"){
	    warn($msg . " by " . ref($self));
	}elsif ($report eq "cluck"){
	    cluck($msg . " by " . ref($self));
	} elsif ($report eq "logfile") {
	    open LOGFILE, ">>/tmp/".ref($self).".out" or die "Unable to open log file";
            print LOGFILE "[".localtime()."] ".$msg ."\n";
            close LOGFILE;
	}
    }
}

#######################################################

=item B<dump>

    $string = $obj->dump();

Returns a dump of the obj using Data::Dumper.

=cut

sub dump{
    my ($self) = shift;
    return Dumper($self);
}

#######################################################

=item B<join_debug>

    $string = $obj->join_debug();

Returns a representation of all the join objects attached to this object.  Useful (trust me)

=cut

sub join_debug{
    my ($self, $class, $tab) = @_;

	$class = ref($self) unless ($class); # this will make sure class aliases show properly

	print "\t" x $tab . $class;
	if ($class ne ref($self)){
		print " (" . ref($self) . ")";
	}
	print ":" . $self->getPrimaryKeyID() . "\n";

	foreach my $join_object_key (keys %{ $self->{_join_objects} }){
		foreach my $object (@{ $self->getJoinObjects($join_object_key) }){
			$object->join_debug($join_object_key, $tab+1);
		}
	}
}

#######################################################

=back

=head2 ATTRIBUTE METHODS

=over 4

=cut 

#######################################################

=item B<getSaveHistoryAttribute>

    $string = $obj->getSaveHistoryAttribute();

Returns the value of the save_history attribute

=cut

sub getSaveHistoryAttribute{
    my ($self) = @_;
    return $self->{_attributes}->{save_history};
}

#######################################################

=item B<setSaveHistoryAttribute>

    $obj->setSaveHistoryAttribute($value);

Sets the value of the save_history attribute

=cut

sub setSaveHistoryAttribute{
    my ($self, $value) = @_;
    $self->{_attributes}->{save_history} = $value;
}

#######################################################

=item B<getTrackingFieldsAttribute>

    $string = $obj->getTrackingFieldsAttribute();

Returns the value of the tracking_fields attribute

=cut

sub getTrackingFieldsAttribute{
    my ($self) = @_;
    return $self->{_attributes}->{tracking_fields};
}

#######################################################

=item B<setTrackingFieldsAttribute>

    $string = $obj->setTrackingFieldsAttribute();

Sets the value of the tracking_fields attribute

=cut

sub setTrackingFieldsAttribute{
    my ($self, $value) = @_;
    $self->{_attributes}->{tracking_fields} = $value;
}

#######################################################

=item B<getNoCreatedAttribute>

    $string = $obj->getNoCreatedAttribute();

Returns the value of the no_created attribute

=cut

sub getNoCreatedAttribute {
    my ($self) = @_;
    return $self->{_attributes}->{no_created};
}

#######################################################

=item B<getAttributes>

    $hashref = $obj->getAttributes();

Returns the attributes hashref for this object

=cut

sub getAttributes{
    my ($self) = @_;
    return $self->{_attributes};
}

#######################################################

=item B<setAttributes>

    $string = $obj->setAttributes($hashref);

Set the attributes hashref for this object

=cut

sub setAttributes{
    my ($self, $attributes) = @_;
    $self->{_attributes} = $attributes;
}

=cut

#######################################################

=back

=head2 LEVEL METHODS

=over 4

=cut 


#######################################################

=item B<getReportingLevel>

    $string = $obj->getReportingLevel();

Gets the value of the reporting level

=cut


sub getReportingLevel{
    my ($self) = @_;
    return $self->{_levels}->{reporting};
}

#######################################################

=item B<setReportingLevel>

    $obj->setReportingLevel($value);

Sets the value of the reporting level

=cut

sub setReportingLevel{
    my ($self, $value) = @_;
    $self->{_levels}->{reporting} = $value;
}

#######################################################

=item B<getErrorLevel>

    $string = $obj->getErrorLevel();

Get the value of the error level

=cut

sub getErrorLevel{
    my ($self) = @_;
    return $self->{_levels}->{error};
}

#######################################################

=item B<setErrorLevel>

    $obj->setErrorLevel($value);

Sets the value of the reporting level

=cut

sub setErrorLevel{
    my ($self, $value) = @_;
    $self->{_levels}->{error} = $value;
}

#######################################################

=item B<getLevels>

    $hashref = $obj->getLevels();

Returns the levels hashref for this object

=cut

sub getLevels{
    my ($self) = @_;
    return $self->{_levels};
}

#######################################################

=item B<setLevels>

    $string = $obj->setLevels($hashref);

Set the attributes hashref for this object

=cut

sub setLevels{
    my ($self, $levels) = @_;
    $self->{_levels} = $levels;
}

#######################################################

=item B<passValues>

    $obj = $obj->passValues($anotherobj);

Copies values from one object to itself.  Used to pass down values that should be inherent to child objects.

This currently includes: Levels hashref, User field

=cut

sub passValues{
    my ($self, $obj) = @_;
    $self->setLevels($obj->getLevels);
    $self->setUser($obj->getUser);
    $self->setDatabaseHandle($obj->getDatabaseHandle);
    $self->setDatabase($obj->getDatabase());

    return $self;
}

#######################################################

=back

=head2 DATAINFO METHODS

=over 4

=cut 

#######################################################

=item B<getTablename>

    $string = $obj->getTablename();

Returns the name of the database table this object uses

=cut

sub getTablename{
    my ($self) = @_;
    return $self->{_datainfo}->{tablename};
}

#######################################################

=item B<getDatabase>

    $string = $obj->getDatabase();

Returns the name of the database this object uses

=cut

sub getDatabase{
    my ($self) = @_;
    return $self->{_datainfo}->{database};
}

#######################################################

=item B<setDatabase>

    $obj->setDatabase($string);

Set the name of the database

=cut

sub setDatabase{
    my ($self, $string) = @_;
    $self->{_datainfo}->{database} = $string;
}

#######################################################

=item B<getDatabaseUserToken>

    $string = $obj->getDatabaseUserToken();

Returns the database user token this object uses.
Complete list of tokens is defined in the constants

=cut

sub getDatabaseUserToken{
    my ($self) = @_;
    return $self->{_datainfo}->{usertoken};
}

#######################################################

=item B<setDatabaseUserToken>

    $string = $obj->setDatabaseUserToken();

Sets the database user token this object uses.
Complete list of tokens is defined in the constants

=cut

sub setDatabaseUserToken{
    my ($self, $token) = @_;
    return $self->{_datainfo}->{usertoken} = $token;
}

#######################################################

=item B<getDatabaseHandle>

    $string = $obj->getDatabaseHandle();

Returns an optionally set database handle to use
for interaction with the database.

=cut

sub getDatabaseHandle{
    my ($self) = @_;
    return $self->{_datainfo}->{database_handle};
}

#######################################################

=item B<setDatabaseHandle>

    $string = $obj->setDatabaseHandle($database_handle);

Set the attributes hashref for this object

=cut

sub setDatabaseHandle{
    my ($self, $dbh) = @_;
    $self->{_datainfo}->{database_handle} = $dbh;
}

#######################################################

=item B<getPrimaryKey>

    $string = $obj->getPrimaryKey();

Return the name of the defined primary key field

=cut

sub getPrimaryKey{
    my ($self) = @_;
    $self->setPrimaryKey unless ($self->{_datainfo}->{primary_key});
    return $self->{_datainfo}->{primary_key};
}

#######################################################

=item B<setPrimaryKey>

    $obj->setPrimaryKey();

Figures out the correct primary key field

=cut

sub setPrimaryKey{
    my ($self) = @_;
    while (my ($key, $value) = each (%{$self->{_field_names}})){
	if ($value eq 'pk'){
	    $self->{_datainfo}->{primary_key} = $key;
	    last;
	}
    }
}



#######################################################

=back

=head2 CORE METHODS

=over 4

=cut 

#######################################################

=item B<getPrimaryKeyID>

    $string = $obj->getPrimaryKeyID;

Get the primary key id

=cut

sub getPrimaryKeyID{
    my ($self) = @_;
    return $self->{_id};
}

#######################################################

=item B<setPrimaryKeyID>

    $obj->setPrimaryKeyID;

Set the primary key id

=cut

sub setPrimaryKeyID{
    my ($self, $id) = @_;
    if ($id){
	$self->{_id} = $id;
	my $primary_key = $self->getPrimaryKey;
	$self->{_field_values}->{$primary_key} = $id;
    }else{
	my $primary_key = $self->getPrimaryKey;
	$self->{_id} = $self->{_field_values}->{$primary_key};
    }
}

#######################################################

=item B<unsetPrimaryKeyID>

    $obj->unsetPrimaryKeyID;

Set the primary key id back to the empty row state

=cut

sub unsetPrimaryKeyID{
    my ($self) = @_;
    $self->{_id} = undef;
    
}

#######################################################

=item B<getCreatedOn>

    $string = $obj->getCreatedOn();

Gets the value of the created_on field.  Method checks that track_fields attribute is set to 1.

=cut

sub getCreatedOn{
    my ($self) = @_;
    if ($self->getTrackingFieldsAttribute){ 
	return $self->getFieldValue("created_on");
    }
}

#######################################################

=item B<getCreatedBy>

    $string = $obj->getCreatedBy;

Gets the value of the created_by field.  Method checks that track_fields attribute is set to 1.

=cut

sub getCreatedBy{
    my ($self) = @_;
    if ($self->getTrackingFieldsAttribute){ 
	return $self->getFieldValue("created_by");
    }
}

#######################################################

=item B<getModifiedOn>

    $string = $obj->getModifiedOn();

Gets the value of the modified_on field.  Method checks that track_fields attribute is set to 1.

=cut

sub getModifiedOn{
    my ($self) = @_;
    if ($self->getTrackingFieldsAttribute){ 
	return $self->getFieldValue("modified_on");
    }
}

#######################################################

=item B<getModifiedBy>

    $string = $obj->getModifiedBy();

Gets the value of the modified_by field. Method checks that track_fields attribute is set to 1.

=cut

sub getModifiedBy{
    my ($self) = @_;
    if ($self->getTrackingFieldsAttribute){ 
	return $self->getFieldValue("modified_by");
    }
}

#######################################################

=item B<getNonSkipFields>

    $arrayref = $obj->getNonSkipFields();

Returns the nonskip field list for this table

=cut

sub getNonSkipFields{
    my ($self) = @_;
    my @non_skips;

    foreach my $key (keys %{$self->{_field_names}}){
	if ($self->{_field_names}->{$key} ne 'skip'){
	    push (@non_skips, $key);
	}
    }

    return [@non_skips];
}

#######################################################

=item B<getAllFields>

    $arrayref = $obj->getAllFields();

Returns the complete field list for this table

=cut

sub getAllFields { 
    my ($self) = @_;
    return [keys %{$self->{_field_names}}];
}

#######################################################

=item B<isValidField>

    $bool = $obj->isValidField($field);

Returns true if $field is a valid field name

=cut

sub isValidField {
   my ($self, $field) = @_;
   if (exists($self->{_field_names}->{$field})){
	return 1;
   }
   return 0;
}

#######################################################

=item B<getFieldValue>

    $string = $obj->getFieldValue($field);

Get the value of a field

=cut

sub getFieldValue{
    my ($self, $field) = @_;
    if (!exists ($self->{_field_values}->{$field})){
	$self->lookupFields([$field]) if ($self->getPrimaryKeyID);
    }
    return $self->{_field_values}->{$field};
}

#######################################################

=item B<getFieldValues>

    $string = $obj->getFieldValues($fields);

Get the values of fields

=cut

sub getFieldValues{
    my ($self, $fields) = @_;

    my @values = ();
    foreach my $field (@$fields) {
	unless (exists ($self->{_field_values}->{$field})){
	    $self->lookupFields([$field]) if ($self->getPrimaryKeyID);
	}
	push @values, $self->{_field_values}->{$field};
    }
    return \@values;
}


#######################################################

=item B<setFieldValue>

    $obj->setFieldValue($field, $value);

Set the value of a field

=cut

sub setFieldValue{
    my ($self, $field, $value) = @_;

    if (!$self->isValidField($field)){
	confess "The field $field is not a valid field for object ". ref($self);
    }
    # Initialize the modified array if necessary
    $self->{_modified} = {} unless $self->{_modified};
    # Store the old value
    $self->{_modified}->{$field} = $self->{_field_values}->{$field};
    # ...and replace with the new value
    
    $self->{_field_values}->{$field} = $value;
}

#######################################################

=item B<setFieldValues>

    $obj->setFieldValues($hash);

Set multiple field values at a time. Checks to make sure all keys of the hash are valid fields

=cut

sub setFieldValues{
    my ($self, $hash) = @_;
    while (my ($key, $value) = each (%$hash)){
	 $self->setFieldValue($key, $value);
    }
}

#######################################################

=item B<changedFields>

    $array = $obj->changedFields;

 Returns the fields which have changed

=cut

sub changedFields {
    my ($self) = @_;
    return () unless ref $self->{_modified} eq 'HASH';
    return keys %{$self->{_modified}};
}

#######################################################

=item B<changedFieldHash>

    $hash = $obj->changedFieldHash();

Returns key/value pairs for the field values which have changed

=cut

sub changedFieldHash {
    my ($self) = @_;
    return () unless ref $self->{_modified} eq 'HASH';
    return $self->{_modified};
}

#######################################################

=item B<getUser>

    $string = $obj->getUser();

 Get the user that is working with this object

=cut

sub getUser{
    my ($self) = @_;
    return $self->{_user};
}

#######################################################

=item B<setUser>

    $obj = $obj->setUser($value);

Set the user that is working with this object

=cut

sub setUser{
    my ($self, $value) = @_;
    $self->{_user} = $value;
    return $self;
}

#######################################################

=item B<getTime>

    $string = $obj->getTime;

Gets the time the object was looked up

=cut

sub getTime{
    my ($self) = @_;
    return $self->{_lookup_time};
}

#######################################################

=item B<setTime>

    $obj->setTime($time);

Sets the time the object was looked up ago

=cut

sub setTime {
    my ($self, $time) = @_;
    $self->{_lookup_time} = $time;
}

#######################################################

=item B<setDefaultOrderBys>

    $obj->setDefaultOrderBys($orderbys);

Set the arrayref of default orderbys

=cut

sub setDefaultOrderBys {
    my ($self, $orderbys) = @_;
    $self->{_default_order_bys} = $orderbys;
}

#######################################################

=item B<getDefaultOrderBys>

    $orderbys = $obj->getDefaultOrderBys();

Return the arrayref of default orderbys

=cut

sub getDefaultOrderBys {
    my ($self) = @_;
    return $self->{_default_order_bys};
}

#######################################################

=back

=head2 JOIN METHODS

Every SQLRow object has the following:

=item B<default join objects>

these are joins that should be done any time a lookup is done on this object

=item B<current join objects>

this is the array of join objects used for the current lookup (default plus any specified)

=item B<returned join objects>

when a lookup is made, a hashref is created where the key is the joined object class name and the value is a array ref of joined objects of that class.

=over 4

=cut 

#######################################################

=item B<getJoinObjects>

    $arrayref = $obj->getJoinObjects($objclass);

Return arrayref of joined objs

=cut

sub getJoinObjects{
    my ($self, $objclass) = @_;
    if (defined($self->{_join_objects}->{$objclass})){
		return $self->{_join_objects}->{$objclass};
    } else {
		return [];
    }
}

#######################################################

=item B<checkJoinObject>

    $bool = $obj->checkJoinObject($objclass);

Check to see if a particular $objclass appears in the _join_objects hashref.
Returns 1 if yes and 0 if no.

=cut

sub checkJoinObject{
    my ($self, $objclass) = @_;
	if (exists($self->{_join_objects}->{$objclass})){
		return 1;
	}
	else {
		return 0;
	}
}

#######################################################

=item B<getJoinObject>

    $object = $obj->getJoinObject($objclass, $index);

Return a specific joined obj, if index is not passed, it is defaulted to zero.
An index of zero is the first object in the array.

=cut

sub getJoinObject{
	my ($self, $objclass, $index) = @_;
	if (!defined($index)){
		$index = 0;
	}
	if (defined($self->{_join_objects}->{$objclass}->[$index])){
		return $self->{_join_objects}->{$objclass}->[$index];
	}else{
		return undef;
	}
}


#######################################################

=item B<getJoinObjectPK>

    $arrayref = $obj->getJoinObjectPK($objclass, $primary_key);

Return a specific joined obj that has the primary_key of the passed scalar $primary_key

=cut

sub getJoinObjectPK{
    my ($self, $objclass, $primary_key) = @_;
    return() unless $primary_key;
    my $join_objects = $self->getJoinObjects($objclass);
    foreach my $obj (@{$join_objects}){
	if ($obj->getPrimaryKeyID() =~ /^\d+$/) {
	    if ($obj->getPrimaryKeyID() == $primary_key){
		return $obj;
	    }
	} else {
	    if ($obj->getPrimaryKeyID() eq $primary_key) {
		return $obj;
	    }
	}
    }
    return();
}

#######################################################

=item B<pushJoinObject>

    $obj->pushJoinObject($objclass, $obj);

Push $obj onto the join objs arrayref with class $objclass

=cut

sub pushJoinObject{
    my ($self, $objclass, $obj) = @_;
    push (@{$self->{_join_objects}->{$objclass}}, $obj);
}

=back

=head2 QUERY METHODS

=over 4

=cut 

#######################################################

=item B<lookupKey>

    $obj = TUSK::SQLRow::SubClass->new->lookupKey($key);

Attempts to retrive a document from the database based on an ID.
Called like HSDB4::SQLRow::SubClass->new->lookupKey (3323). Returns
a object.

=cut

sub lookupKey {
    my ($self, $key, $joinobjs) = @_;
    # Make $self a new object for sure
    $self = $self->new unless (ref $self);
    $self->setPrimaryKeyID($key) unless ($self->getPrimaryKeyID);
    $self->lookupFields($self->getAllFields(), $joinobjs, $self->getDefaultOrderBys());
    if (defined($self->getPrimaryKeyID())){
        return $self;
    } else {
	return undef;
    }
}

#######################################################

=item B<lookupFields>

    $obj->lookupFields($fields);

Does a select on a row asking for certain fields.  $fields is an array ref.

=cut

sub lookupFields{
    my ($self, $fields, $joinobjs, $order_bys) = @_;

    return unless ($self->getPrimaryKeyID);

    my $sth = $self->databaseSelect($self->sqlSelect($fields, undef, $order_bys, undef, $joinobjs));

    my $rowCount = 0;
    while (my $row_hashref = $sth->fetchrow_hashref){
	$self->processRow($row_hashref, $self->getCurJoinObjects());
	$rowCount = 1;
    }
    if(!$rowCount){
	$self->unsetPrimaryKeyID();
    }

    $sth->finish;
    
    return $self;
}

#######################################################

=item B<lookup>

    $arrayref = $obj->lookup($cond, $orderby, $fields, $limit, $joinobjs);

Get a bunch of objects based on a set of SQL conditions from the appropriate table.  $cond is a string, $orderby is an array ref, $fields is an array ref and $limit is a string (ie "10" or "10,20").

=cut

sub lookup{
    # Get the incoming object or class name
    my ($self, $cond, $orderby, $fields, $limit, $joinobjs) = @_;

    # Make $self a new object for sure
    $self = $self->new unless (ref $self);

    if ($fields) {
	# make sure that the primary key is in the list
	push @{$fields}, $self->getPrimaryKey();
    } else {
	# if no fields defined get them all
        $fields = $self->getNonSkipFields ;
    }
    
    my $sth = $self->databaseSelect($self->sqlSelect($fields, $cond, $orderby, $limit, $joinobjs));
    
    # An empty list to push the rows onto
    my $outObjects = [];
    
    # While we're getting rows...
    
    my $currentPK = "-1";

    while (my $row_hashref = $sth->fetchrow_hashref) {
	if ($currentPK ne $row_hashref->{$self->getPrimaryKey}){
	    # Make a new object...
	    my $rowobj = $self->new();
	    
	    $rowobj->passValues($self);
	    $currentPK = $row_hashref->{$self->getPrimaryKey};
	    
	    push @$outObjects, $rowobj;	    
	}

	$outObjects->[scalar(@$outObjects) - 1]->processRow($row_hashref, $self->getCurJoinObjects());
    }
    
    # Clean up the database stuff
    $sth->finish;

    return $outObjects;
}

#######################################################

=item B<lookupReturnOne>

    $arrayref = $obj->lookupReturnOne($cond, $orderby, $fields, $limit, $joinobjs);

Useful method that does a lookup and then returns the first matching row

=cut

sub lookupReturnOne{
    my ($self, $cond, $orderby, $fields, $limit, $joinobjs) = @_;
    my $results = $self->lookup($cond, $orderby, $fields, $limit, $joinobjs);
    if (scalar(@$results)){
	return $results->[0];
    }else{
	return();
    }
}

sub lookupCourseSchool {


}

#######################################################

=item B<exists>

    $bool = $Obj::exists($cond);

This method should be called statically to determine 
whether a row exists for that object based on the
condition passed.  The function returns 1 if a row
exists and 0 if the row doesnt.

=cut

sub exists {
	my $self = shift;
	my $cond = shift || confess "A Condition needs to be passed";
	$self = $self->new() unless (ref $self);
	my $sql = "select 1 from " . $self->getDatabase . "." . $self->getTablename;
	$sql .= " where " . $cond ." limit 1";
	my $sth = $self->databaseSelect($sql);
	my $row = $sth->fetchrow_arrayref();
	$sth->finish;
	return $row ? 1 : 0;
}

#######################################################

=item B<beforeSave>

    $bool = $obj->beforeSave();

This subroutine is a place holder to be overridden if the object 
wants to do something before the save occurs.  Returning 0 is
an error state and the save will not continue. 

=cut

sub beforeSave {
	return 1;
}

#######################################################

=item B<afterSave>

    $bool = $obj->afterSave();

This subroutine is a place holder to be overridden if the object 
wants to do something after the save occurs.  Returning 0 is
an error state.  This will only be called if the save was successful. 

=cut

sub afterSave {
	return 1;
}

#######################################################

=item B<saveDebug>

    $retval = $obj->saveDebug($debugging, $params);

Calls save($params) is $debugging is 0.  Outputs what save($params) would do if $debugging is 1. 
$params is a variable passed to beforeSave and afterSave methods.

=cut

sub saveDebug {
    my ($self, $debugging, $params) = @_;
    if (!defined ($self)){
		confess "saveDebug is not a static method.  You must pass an object.";
    }

	if ($debugging) {
		my $user = 'unknown';
	    if (defined ($params->{'user'})){
			if(ref($params->{'user'})){
				if($params->{'user'}->isa('HSDB4::SQLRow::User')){
					$user = $params->{'user'}->primary_key();
				}
			}
			else {
				$user = $params->{'user'};
			}
	    }
		$self->setUser($user);

	    my $retval;

	    # Forget it unless there's stuff in modified
	    return $self->getPrimaryKeyID() unless ($self->changedFields);

	    if ($self->getPrimaryKeyID){
			$retval = $self->sqlUpdate(undef, $params->{'cond'});
	    }else{
			$retval = $self->sqlInsert($params->{'cond'});
	    }

	    return $retval;		
	}
	else {
		return $self->save( $params );
	}
}

#######################################################

=item B<save>

    $retval = $obj->save($parms);

Saves the current values of the in-memory object back to the database. $params is a variable passed to beforeSave and afterSave methods.

=cut

sub save {
    my ($self, $params) = @_;
    if (!defined ($self)){
	confess "Save is not a static method.  You must pass an object.";
    }

	my $user = 'unknown';
    if (defined ($params->{'user'})){
		if(ref($params->{'user'})){
			if($params->{'user'}->isa('HSDB4::SQLRow::User')){
				$user = $params->{'user'}->primary_key();
			}
		}
		else {
			$user = $params->{'user'};
		}
    }
	$self->setUser($user);
	
    my $retval;

    $self->beforeSave($params) or return undef;

    # Forget it unless there's stuff in modified
    return $self->getPrimaryKeyID() unless ($self->changedFields);
    
    if ($self->getPrimaryKeyID){
	$retval = $self->databaseDo($self->sqlUpdate(undef, $params->{'cond'}));
	$self->databaseDo($self->sqlSaveHistory('Update')) if ($self->getSaveHistoryAttribute);
    }else{
	$retval = $self->databaseDo($self->sqlInsert($params->{'cond'}));
	$self->setPrimaryKeyID($retval) unless($self->getPrimaryKeyID);
	$self->databaseDo($self->sqlSaveHistory('Insert')) if ($self->getSaveHistoryAttribute);
    }
    
    
    $self->afterSave($params) if ($retval);
    return $retval;
}

#######################################################

=item B<deleteKey>

    $obj->deleteKey($id);

delete one row from the database.  

=cut

sub deleteKey{
    my ($self, $id) = @_;
    return unless ($id);

    $self->delete($self->getPrimaryKey . "='" . $id . "'");    
}

#######################################################

=item B<update>

    $retval = $obj->update($update, $cond);

 update from database with given conditions.  $update and $cond are strings.

=cut

sub update{
    my ($self, $update, $cond) = @_;
    my @ids;
    return 0 unless $update;
    if ($self->getSaveHistoryAttribute){
	my $sth = $self->databaseSelect($self->sqlSelect([ $self->getPrimaryKey ], $cond));
	while (my @row_values = $sth->fetchrow_array) {
	    push(@ids, $row_values[0]);
	}
	$sth->finish;
    }
    my $retval = $self->databaseDo($self->sqlUpdate($update, $cond));
    $self->databaseDo($self->sqlSaveHistory('Update', $self->getPrimaryKey() . " IN (" . join(', ',  @ids) . ")" )) if ($self->getSaveHistoryAttribute && scalar(@ids));
    return $retval;
}

#######################################################

=item B<delete>

    $retval = $obj->delete($cond);

delete from database with given conditions.  $cond is a string.  If called with no $cond tries to delete itself.

=cut

sub delete {
    my ($self, $params) = @_;

    my $cond;
    if (defined($params) && ref ($params) eq ''){
	$cond = $params;	

    } elsif (defined($params) && ref ($params) eq 'HASH'){
	$self->setUser($params->{user});
	$cond = $params->{cond};
    } 
    
    if ($self->getPrimaryKeyID()){
	$cond .= ' and ' if ($cond);
	$cond .= $self->getPrimaryKey . "='" . $self->getPrimaryKeyID . "'";	
    }

    $self->databaseDo($self->sqlSaveHistory('Delete', $cond)) if ($self->getSaveHistoryAttribute);

    return ($self->databaseDo($self->sqlDelete($cond)));
}

#######################################################

=item B<processRow>

    $obj->processRow($row_hashref, $joinobjs);

Important method that does the meat of SQLRow.  The idea is that in a given row you might have information from multiple tables (based on JoinObject).  This method cycles through all the field values and tries to bundle the fields based on which objclass they belong to.  Once this has been done, need to figure out which objects need to be created (might have info for an object that has already been created).  Look through these objects and push them in the right place.  If a objtree arrayref has been defined for a JoinObject, the method recursively tries to figure out which object to push into.  Currently, we are assuming that objtree defines objects that have already been defined.  Please look at the TUSK::Core::JoinObject perldoc and the JoinObject section of this perldoc.

=cut

sub processRow{
    my ($self, $row_hashref, $joinobjs) = @_;
    my $joinvalues = {};
	
    foreach my $key (keys %$row_hashref){
		if ($key =~ /(.*)__(.*)/){
			my ($jointable, $joinfield) = ($1, $2);
			if (my ($objectkey, $objectclass, $primarykey) = $self->findJoinClass($joinobjs, $jointable)){
				$joinvalues->{$objectkey}->{field_values}->{$joinfield} = $row_hashref->{$key};
				
				if ($joinfield eq $primarykey){
					$joinvalues->{$objectkey}->{id} = $row_hashref->{$key};
					$joinvalues->{$objectkey}->{objclass} = $objectclass;
				}
			}	    
		}else{
			$self->setFieldValue($key, $row_hashref->{$key});
		}
    }

    my $newobjs = {};
    foreach my $objectkey (keys (%$joinvalues)){
		unless ($self->getJoinObjectPK($objectkey, $joinvalues->{$objectkey}->{id})){
			my $obj = $joinvalues->{$objectkey}->{objclass}->new();
			$obj->setFieldValues($joinvalues->{$objectkey}->{field_values});
			$obj->setPrimaryKeyID();
			$obj->setTime(time());
			$newobjs->{$objectkey} = $obj if ($obj->getPrimaryKeyID());
		}
    }
	
    # put the objects in the right place
    foreach my $joinobj (@{$joinobjs}){
		my $objectkey = $joinobj->getObjectKey();
		next unless ($newobjs->{$objectkey});
		
		if (scalar(@{$joinobj->getObjTree()})){
			my $parent_obj = $self;
			foreach my $objtree (@{$joinobj->getObjTree()}){
				last unless ($parent_obj); # something bad happened
				$parent_obj = $parent_obj->getJoinObjectPK($objtree, $joinvalues->{$objtree}->{id});
			}
			if ($parent_obj){
				unless($parent_obj->getJoinObjectPK($objectkey, $joinvalues->{$objectkey}->{id})){
					$parent_obj->pushJoinObject($objectkey, $newobjs->{$objectkey});
				}
			}
			else{
				 confess "Unable to attach join object to parent\n";
			}
		}else{
			$self->pushJoinObject($objectkey, $newobjs->{$objectkey});
		}
	}

    $self->setPrimaryKeyID();

    $self->setTime(time());
}

#######################################################

=item B<findJoinClass>

    $obj->findJoinClass($joinobjs, $tablename);

Finds the class name needed for the join obj

=cut

sub findJoinClass{
    my ($self, $joinobjs, $tablename) = @_;
    foreach my $joinobj (@$joinobjs){
	if ($joinobj->getTablename eq $tablename){
	    return ($joinobj->getObjectKey(), $joinobj->getObjClass(), $joinobj->getObj()->getPrimaryKey());
	    last;
	}
    }

}

#######################################################

=back

=head2 DATABASE METHODS

=over 4

=cut 

#######################################################

=item B<getDatabaseReadHandle>

    $dbh = $obj->getDatabaseReadHandle;

grab database handle

=cut

sub getDatabaseReadHandle{
    my ($self) = @_;
    my $dbh;

    return $self->getDatabaseHandle if ($self->getDatabaseHandle);

    eval {
	$dbh = TUSK::Core::DB::getReadHandle($self->getDatabaseUserToken);
    };

    if ($@){
	croak "$@ - getDatabaseReadHandle failed to obtain database handle for class " . ref($self);
    }
    return $dbh;
}

#######################################################

=item B<getDatabaseWriteHandle>

    $dbh = $obj->getDatabaseWriteHandle;

grab database handle

=cut

sub getDatabaseWriteHandle{
    my ($self) = @_;
    my $dbh;

    return $self->getDatabaseHandle if ($self->getDatabaseHandle);

    eval {
	$dbh = TUSK::Core::DB::getWriteHandle($self->getDatabaseUserToken);
    };
    if ($@){
	croak "$@ - getDatabaseWriteHandle failed to obtain database handle for class " . ref($self);
    }
    return $dbh;
}

#######################################################

=item B<databaseDo>

    $number = $obj->databaseDo($sql);

Do a dbi do :)  Where $sql is a string.  Returns number of rows changed.

=cut

sub databaseDo{
    my ($self, $sql) = @_;
    my $retval;
    my $dbh = $self->getDatabaseWriteHandle;

    eval {
	$retval = $dbh->do($sql);
    };
    croak "$@ - query $sql failed for class " . ref($self) if $@;

    return $dbh->{'mysql_insertid'} if ($dbh->{'mysql_insertid'}); # return new id if insert

    # 0 if we changed no rows, 1 if we changed just the correct row,
    # and more than one if we changed many rows. 
    return $retval; 
}

#######################################################

=item B<databaseSelect>

    $sth = $obj->databaseSelect($sql);

Do a dbi execute on a $sql string :)  It is your job to call $sth->finish when you are done.

=cut

sub databaseSelect{
    my $self = shift;
    my $sql = shift;
    my @sqlArgs = @_;

    my $dbh = $self->getDatabaseReadHandle();

    my $sth = $dbh->prepare($sql);

    eval {
	    $sth->execute(@sqlArgs);
    };
    croak "error : $@ query $sql failed for class " . ref($self) if ($@);

    return $sth;
}

#######################################################

=back

=head2 JOIN FIELD METHODS

=over 4

=cut 

#######################################################

=item B<getDefaultJoinObjects>

    $arrayref = $obj->getDefaultJoinObjects();

Return the default joinobjs arrayref

=cut

sub getDefaultJoinObjects{
    my ($self) = @_;
    return $self->{_default_join_objects};
}

#######################################################

=item B<getCurJoinObjects>

    $arrayref = $obj->getCurJoinObjects();

Return the currrent joinobjs arrayref

=cut

sub getCurJoinObjects{
    my ($self) = @_;

    return $self->{_cur_join_objects};
}

#######################################################

=item B<setCurJoinObjects>

    $obj->setCurJoinObjects($joinobjs);

Sets the current joinobjs arrayref

=cut

sub setCurJoinObjects{
    my ($self, $joinobjs) = @_;
    $self->{_cur_join_objects} = $joinobjs;
}

=back

=head2 OTHER METHODS

=over 4

=cut 

#######################################################

=item B<updateSortOrders>

    $arrayref = $obj->updateSortOrders($index, $newindex, $cond, $arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  $index is array index of the object that changed,
$newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateSortOrders{
    my ($self, $index, $newindex, $cond, $arrayref, $multiple) = @_;
    
    return [] if scalar (@$arrayref == 0); #opps
    return [] if ($index == $newindex); # opps
    return [] if ($index == 0 or $index > scalar(@$arrayref)); #opps again

    my $field = @$arrayref[$index-1]->getPrimaryKey;
	
    my $class = ref(@$arrayref[0]); # figure out what class these objects are

    splice(@$arrayref, ($newindex - 1), 0,splice(@$arrayref, ($index - 1), 1));
	$multiple = 10 unless defined $multiple;
	my $length = scalar(@$arrayref);
	for(my $i=0; $i<$length; $i++){
		$class->new->update("sort_order = " . ($i+1)*$multiple, $cond . " and " . $field . " = '" . $arrayref->[$i]->getPrimaryKeyID() . "'");
	}

    return $arrayref;
}

#######################################################

=back

=head2 SQL METHODS

=over 4

=cut 

#######################################################

=item B<sqlSelect>

    $string = $obj->sqlSelect($fields, $cond, $orderbys, $limit, $joinobjs);

A faster way to generate SQL select statements. $fields is an array ref, $cond is a string $orderbys is an array ref and $limit is a string (ie "10" or "10,20").

=cut

sub sqlSelect{
    my ($self, $fields, $cond, $orderbys, $limit, $joinobjs) = @_;

    # assume we are given good input as mysql will do the error checking

    if ($self->getPrimaryKeyID()){
	$cond .= " and " if ($cond);
	$cond .= $self->getTablename() . "." . $self->getPrimaryKey() . "='" . $self->getPrimaryKeyID() ."'";  
    }else{
	$orderbys = $self->getDefaultOrderBys() unless ($orderbys);
    }

    my $tables = [$self->getDatabase . "." . $self->getTablename];

    my $tableshashref = {
	$self->getDatabase . "." . $self->getTablename => 1
	};

    push (@$joinobjs, @{$self->getDefaultJoinObjects()});

    if (scalar(@$joinobjs)){
	@$fields = map {$self->getTablename . "." . $_ . " as " . $_} @$fields;
    }

    foreach my $joinobj (@$joinobjs){
	
	if ($joinobj->isa('TUSK::Core::JoinObject::DerivedTable')){
	    push (@$tables, $joinobj->getJoinType() . " join (" . $joinobj->getDerivedTable() . ") as " . $joinobj->getAlias() . " on (" . $joinobj->getOnCond() . ")");
	}
	else {
	    my $jointable = $joinobj->getDatabase . "." . $joinobj->getTablename('with_alias');
	    
	    unless ($tableshashref->{$jointable}){
		foreach my $joindbfield (@{$joinobj->getFields()}){
		    push (@$fields, $joinobj->getTablename . "." . $joindbfield 
			  . " as " . $joinobj->getTablename . "__" . $joindbfield);
		}
		
		if ($joinobj->getCond()){
		    $cond .= " and " if ($cond);
		    $cond .= $joinobj->getCond(); 
		}
		push (@$tables, $joinobj->getJoinType() . " join " . $jointable . " on (" . $joinobj->getOnCond($self->getTablename()) . ")");
		$tableshashref->{$jointable} = 1;
	    }
	}
    }

    my $sql = "select " . join(', ', @$fields) .
              " from " . join(' ', @$tables); 
    $sql .= " where " . $cond if ($cond);
    $sql.= " order by " . join(', ', @$orderbys) if ($orderbys and scalar(@$orderbys));
    $sql.= " limit " . $limit if ($limit);
    
    $self->setCurJoinObjects($joinobjs);

    $self->debug($sql, 1);
    return ($sql);
}

#######################################################

=item B<sqlUpdate>

    $string = $obj->sqlUpdate($update, $cond);

generate sql update statement.  $update

=cut

sub sqlUpdate{
    #
    # generate sql update statement
    #

    my ($self, $update, $cond) = @_;
    my $sql;
    
    if ($update){
	# do a straight update
	if ($self->getTrackingFieldsAttribute){
	    $update .= ", modified_by = '".$self->getUser . "'";
	    $update .= ", modified_on = now()";
	}
	$sql = sprintf("update %s.%s set %s where %s",
		       $self->getDatabase, $self->getTablename,
		       $update, $cond);
    }else{
	# check for modified fields
	my $modified = $self->changedFieldHash;
	my @changes;
	
	foreach my $key (keys %{$modified}){
	    push (@changes, sprintf ("%s=%s", $key, sql_escape($self->getFieldValue($key))));
	}

	if ($self->getTrackingFieldsAttribute){
	    push(@changes, "modified_by = '".$self->getUser . "'");
	    push(@changes, "modified_on = now()");
	}
	
	$sql = sprintf("update %s.%s set %s where %s = '%s'", 
		       $self->getDatabase, $self->getTablename, join(',', @changes), 
		       $self->getPrimaryKey, $self->getPrimaryKeyID); 
	$sql .= ' and ' . $cond if $cond;
    }

    $self->debug($sql, 1);
    return $sql;
}

#######################################################

=item B<sqlInsert>

    $string = $obj->sqlInsert();

generate sql insert statement

=cut

sub sqlInsert{
    my ($self, $cond) = @_;
    
    my $modified = $self->changedFieldHash;

    # Make a list of fields and values
    my @fields = keys %$modified;

    my @values = map (&sql_escape($self->getFieldValue($_)),  (keys %$modified));

    if ($self->getTrackingFieldsAttribute){
	unless ($self->getNoCreatedAttribute()) {
	    push(@fields, "created_on");
	    push(@values, "now()");
	    push(@fields, "created_by");
	    push(@values, "'" . $self->getUser ."'");
	}

	push(@fields, "modified_on");
	push(@values, "now()");
	push(@fields, "modified_by");
	push(@values, "'" . $self->getUser . "'");
    }

    my $sql = sprintf("insert into %s.%s (%s) values (%s)",
			$self->getDatabase, $self->getTablename, join (', ', @fields), join (', ', @values));

    $sql .= ' and ' . $cond if $cond;
    
    $self->debug($sql, 1);
    return $sql;
}

#######################################################

=item B<sqlDelete>

    $string = $obj->sqlDelete($cond);

generate sql delete statement where $cond is a string

=cut

sub sqlDelete{
    my ($self, $cond) = @_;

    return 0 unless ($cond =~ /=/); # make sure there is a cond here
    my $sql = sprintf("delete from %s.%s where $cond", $self->getDatabase, $self->getTablename);

    $self->debug($sql, 1);
    return $sql;
}

#######################################################

=item B<sqlSaveHistory>

    $string = $obj->sqlSaveHistory($history_type, $cond);

generate sql statement used for objects that need to save history.  $history_type is either Insert, Update, or Delete and $cond is the where clause when multiple rows have been altered.

=cut

sub sqlSaveHistory{
    my ($self, $history_type, $cond) = @_;
    return 0 unless ($history_type eq "Delete" or $history_type eq "Update" or $history_type eq "Insert");
    
    # Make a list of fields and values
    my $fields = $self->getAllFields();
    my @fields = @$fields;
    my @selectfields = @fields;
    

    if ($self->getTrackingFieldsAttribute){
	# we need to jump through the following hoop cause we want modified_on in the history table
	# to get its value from the now function.  (ie when you delete a row, it has the date of the date)
	for(my $i=0; $i<scalar(@selectfields); $i++){
	    if ($selectfields[$i] eq "modified_on"){
		$selectfields[$i] = "now()";
	    } elsif ($history_type eq 'Delete' && $selectfields[$i] eq "modified_by"){
		$selectfields[$i] = "'" . $self->getUser() . "'";
	    }
	}
    }

    push (@fields, "history_action");
    push (@selectfields, "\'$history_type\'");
    
    unless ($cond){
	return 0 unless ($self->getPrimaryKeyID);
	$cond = $self->getPrimaryKey . " = " . $self->getPrimaryKeyID; 
    }

    my $sql = sprintf("insert into %s.%s_history (%s) select %s from %s.%s where %s", 
		      $self->getDatabase, $self->getTablename,
		      join (', ', @fields),
		      join (', ', @selectfields),
		      $self->getDatabase, $self->getTablename,
		      $cond
		      );

    $self->debug($sql, 1);
    return $sql;
}

#######################################################

=item B<sql_escape>

    $obj = $obj->sql_escape($value);

make sql_escapes needed to make sql statements

=cut

sub sql_escape{
    my ($value) = @_;
    if (not defined($value)){
	return "NULL";
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/'/\\'/g;
    return "'" . $value . "'";
}

#######################################################

=item B<MakePretty>

my $string = TUSK::Core::SQLRow::MakePretty($value);

Return a *pretty* form of the value of $field.  Make the first letter capitalized and change any underscores to spaces.  Note this is a static method.

=cut

sub MakePretty{
    my ($value) = @_;

    $value = ucfirst ($value);
    $value =~ s/_/ /g;

    return $value;
}


#######################################################

=item B<clone>

    $new_obj = $obj->clone();
    $new_obj = $obj->clone($some_new_field_value_hash);

This creates a copy of the given $obj, optionally with any supplied column values.

=cut

sub clone {
    my ($self, $values) = @_;
    $values = {} unless defined $values;
    return $self->_croak("clone needs a hashref if a parameter is passed") unless ref $values eq 'HASH';

    my $class = ref($self);
    my $clone = $class->new();

    my $fields = $self->getAllFields();
    foreach my $field (@$fields){
	next if ($field eq $self->getPrimaryKey());
	next if ($field =~ /modified_by|modified_on|created_by|created_on/);
	my $value = (exists $values->{$field}) ? $values->{$field} : $self->getFieldValue($field);
	$clone->setFieldValue($field, $value);
    }
    return $clone;
}



=head2 CONSTRUCTOR

The constructor for B<TUSK::Core::SQLRow> contains the following hash refs:

=over 4

=item *

_datainfo: contains database parameters specific to the object

=over 4

=item *

database: database name

=item *

tablename: table name

=item *

primary_key: name of the primary key field in the table

=item *

usertoken: default usertoken for which this object uses to connect to the database

=back

=item *

_field_names: contains a hash of all the field names; possible values could be:

=over 4

=item *

pk: primary key

=item *

skip: field is not meant to be grabbed from the database by default (used for blob fields mostly)

=back 

=item *

_field_values: contains the values of the fields (ie username => 'superman')

=item *

_attributes: contains values for attributes that allows for fine tuning of object functionality

=over 4

=item *

save_history: does this object save history on insert, update and delete

=item *

tracking_fields: does this object have tracking fields for storing created_by, created_on, modified_by and modified_on

=back

=item *

_levels: stores logging levels

=over 4

=item *

reporting: allows to change the way events are logged; allowable values: warn, cluck

=item *

error: error level; higher the number the more I<stuff> is logged

=back

=back

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

=cut

1;
