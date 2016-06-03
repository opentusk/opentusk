# Copyright 2016 Tufts University
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


package TUSK::User::Creation;

=head1 NAME

B<TUSK::User::Creation> - Class for manipulating entries in table user_creation in tusk database

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
					'tablename' => 'user_creation',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_creation_id' => 'pk',
					'user_id' => '',
					'source_enum_id' => '',
					'object_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
					no_created => 1,
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

=item B<getUserID>

my $string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}


#######################################################

=item B<getSourceEnumID>

my $string = $obj->getSourceEnumID();

Get the value of the source_enum_id field

=cut

sub getSourceEnumID{
    my ($self) = @_;
    return $self->getFieldValue('source_enum_id');
}

#######################################################

=item B<setSourceEnumID>

$obj->setSourceEnumID($value);

Set the value of the source_enum_id field

=cut

sub setSourceEnumID{
    my ($self, $value) = @_;
    $self->setFieldValue('source_enum_id', $value);
}


#######################################################

=item B<getObjectID>

my $string = $obj->getObjectID();

Get the value of the object_id field

=cut

sub getObjectID{
    my ($self) = @_;
    return $self->getFieldValue('object_id');
}

#######################################################

=item B<setObjectID>

$obj->setObjectID($value);

Set the value of the object_id field

=cut

sub setObjectID{
    my ($self, $value) = @_;
    $self->setFieldValue('object_id', $value);
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

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

