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


package TUSK::Import;

use strict;
use TUSK::ImportLog;
use TUSK::ImportRecord;

=head1 NAME

B<TUSK::Import> - a module for handling data imports to Tufts University Sciences Knowledgebase

=head1 SYNOPSIS

    use TUSK::Import;
    my $import = TUSK::Import->new;
    $import->set_fields(qw(field1 field2 field3));
    $import->read_filehandle(<FH>);
    $import->grep_records("field1","value");

=head1 DESCRIPTION

B<TUSK::Import> is designed to provide common methods and data storage for subclasses that handle more specific processing of data imports to TUSK (Tufts University Sciences Knowledgebase). The module allows you to create an object filled with data, grep out certain sets of that data, step through remaining records and keep a log of messages. The primary logic happens within the subclasses, thus Import is designed to be reused among a variety of import subclasses.

=head1 INTERFACE

=over

=item new()

Creates a new C<TUSK::Import> object, sets up arrays for storage of records and logs.

=cut

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_log_items => [],
		_ignore_empty_fields=>0,
	        _record_items => [],
		_err_msgs => []};
    return bless $self, $class;
}

=item set_fields()

Creates a list of the field names for the import. Similar to column titles, these names can be used to pull specific values from a given record.

=cut

sub set_fields {
    my $self = shift;
    $self->{_fields} = \@_;
    return 1;
}

=item get_fields()

Returns array of field names.

=cut

sub get_fields {
    my $self = shift;
    return @{$self->{_fields}};
}

=item read_filehandle()

Takes a filehandle, a delineator and a regex and reads in data from the file, creating a C<TUSK::ImportRecord> for each line in the file. 

The default delineator is set to , for comma separator. 

The default regex is set to \"(.*)\"\\W* (matches value within quotes). Each field is passed through the regex, resetting the value to the match specified in the regex (s/$regex/$1/).

This method returns a 1 if successful, a 0 if it is not.

=cut

sub read_filehandle {
    my ($self,$filehandle,$delineator,$clean_regex) = @_;
    $delineator = "," unless $delineator;
    $clean_regex = "^\"(.*)\"\$" unless $clean_regex; ## strip out starting and trailing quotes

    while (my $import_line = <$filehandle>) {
	next if $import_line =~ /^#/; # skip if comment

	$import_line =~ s/\r?\n$//; ## take out line feed & new line
	my $record = TUSK::ImportRecord->new($self->get_fields());
	my @fields = map { s/$clean_regex/$1/ ? $1 : $_ } split($delineator,$import_line);

	# add padding if ignore_empty_fields flag is set
	if ($self->get_ignore_empty_fields() && scalar(@fields) < scalar($self->get_fields())){
	    for my $i (scalar(@fields)..scalar($self->get_fields()-1)){
		$fields[$i] = '';
	     }
	}
	
	my ($status, $msg) = $record->set_field_values(@fields);

	$self->push_record($record) if ($status);
	$self->push_err_msg($msg . ": " . $import_line) unless ($status);
    }
}

=item read_file()

Takes a file path (in string format), a delineator and a regex and reads in data from the file, creating a C<TUSK::ImportRecord> for each line in the file. 

The default delineator is set to , for comma separator. 

The default regex is set to ^\"(.*)\"\$ (matches value within quotes). Each field is passed through the regex, resetting the value to the match specified in the regex (s/$regex/$1/).

This method returns a 1 if successful, a 0 if it is not.

=cut

sub read_file {
    my ($self,$file,$delineator,$clean_regex) = @_;
    $delineator = "," unless $delineator;
    $clean_regex = "^\"(.*)\"\$" unless $clean_regex; ## strip out starting and trailing quotes
    my $limit = -1;
    if ($self->get_ignore_empty_fields){
	$limit = scalar($self->get_fields);
    }
    unless (-e $file) {
	die "cannot open $file\n";
    }
    open RECORDFILE, "$file";
    while (my $import_line = <RECORDFILE>) {
	$import_line =~ s/\r?\n$//; ## take out line feed & new line
	my $record = TUSK::ImportRecord->new($self->get_fields());
	my @fields = map { s/$clean_regex/$1/ ? $1 : $_ } split($delineator,$import_line,$limit); 
	my ($status, $msg) = $record->set_field_values(@fields);
	$self->push_record($record) if ($status);
	$self->push_err_msg($msg . ": " . $import_line) unless ($status);
    }
    close RECORDFILE;
}

=item clear_records()

Removes records stored in the object.

=cut

sub clear_records {
    my $self = shift;
    undef $self->{_record_items};
    $self->{_record_items} = [];
}

=item grep_records()

Takes a field name and a value and loops over the records eliminating any records who's field doesn't match the value. Loose matching allows the string to have characters before and after the match.

=cut

sub grep_records {
    my ($self,$field,$value,$loose) = @_;
    my @records;
    if ($loose) {
	@records = grep { $_->get_field_value($field) =~ /$value/i } $self->get_records;
    }
    else {
	@records = grep { $_->get_field_value($field) =~ /^$value$/i } $self->get_records;
    }
    $self->clear_records;
    $self->push_record(@records);
}

=item push_record()

Takes one or more C<TUSK::ImportRecord> objects and pushes them onto the list of records for the current import.

=cut

sub push_record {
    my $self = shift;
    foreach my $record_item (@_) {
	unless ($record_item && ref $record_item && $record_item->isa("TUSK::ImportRecord")) {
	    warn "Tried to push an invalid object onto Record stack: ".ref $record_item;
	    next;
	}
	unless (scalar $record_item->get_field_count == scalar $self->get_fields) {
	    warn "Tried to push a record onto ImportRecord which has ".scalar $record_item->get_field_values.
		" fields, ".scalar $self->get_fields." required";
	    next;
	}
	push(@{$self->{_record_items}},$record_item);
    }
    return 1;
}

=item get_records()

Returns the array of C<TUSK::ImportRecord> objects.

=cut

sub get_records {
    my $self = shift;
    return @{$self->{_record_items}};
}

=item add_log()

Takes a type and a message and creates a C<TUSK::ImportLog> object.

=cut

sub add_log {
    my $self = shift;
    my $type = shift;
    my $message = shift;
    my $log_item = TUSK::ImportLog->new($type);
    $log_item->set_message($message);
    $self->push_log($log_item);
}

=item push_log()

Takes a C<TUSK::ImportLog> object and pushes it onto the list of logs for the current import.

=cut

sub push_log {
    my $self = shift;
    my $log_item = shift;
    unless ($log_item && ref $log_item && $log_item->isa("TUSK::ImportLog")) {
	warn "Tried to push an invalid object onto Log stack: ".ref $log_item;
	return;
    }
    push(@{$self->{_log_items}},$log_item);
    return 1;
}

=item get_logs()

Returns the array of C<TUSK::ImportLog> objects.

=back
=cut

sub get_logs {
    my $self = shift;
    return @{$self->{_log_items}};    
}

=item set_ignore_empty_fields()

This function sets the property to ignore missing fields and make sure that the record has 
empty entries for each field that is supposed to be there.  For example if the file has two 
columns and the second column is optional, the record set will have the second value in it, but
it will be undefined.  

=back
=cut

sub set_ignore_empty_fields {
    my $self = shift;
    my $value = shift;
    $self->{_ignore_empty_fields} = $value;	
    return $self->{_ignore_empty_fields};	
}

=item get_ignore_empty_fields()

This function gets the property to ignore missing fields and make sure that the record has 
empty entries for each field that is supposed to be there.  For example if the file has two 
columns and the second column is optional, the record set will have the second value in it, but
it will be undefined.  


=back
=cut

sub get_ignore_empty_fields {
    my $self = shift;
    return $self->{_ignore_empty_fields};     
}

=item push_err_msg($msg)

Push $msg to the err_msg arrayref

=back

=cut

sub push_err_msg{
    my ($self, $msg) = @_;
    push (@{$self->{_err_msgs}}, $msg);
}

=item get_err_msgs()

return arrayref of err messages from this import

=back

=cut

sub get_err_msgs{
    my ($self) = @_;
    return ($self->{_err_msgs});
}

=head1 AUTHOR

Michael Kruckenberg, michael.kruckenberg@tufts.edu

=cut

1;
