# Copyright 2013 Tufts University
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


package TUSK::Competency::UserType;

=head1 NAME

B<TUSK::Competency::UserType> - Class for manipulating entries in table competency_user_type in tusk database

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
					'tablename' => 'competency_user_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_user_type_id' => 'pk',
					'name' => '',
					'competency_type_enum_id' => '',
					'school_id' => '',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getName>

my $string = $obj->getName();

Get the value of the name field

=cut

sub getName{
    my ($self) = @_;
    return $self->getFieldValue('name');
}

#######################################################

=item B<setName>

$obj->setName($value);

Set the value of the name field

=cut

sub setName{
    my ($self, $value) = @_;
    $self->setFieldValue('name', $value);
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



#######################################################

=item B<getCompetencyTypeEnumID>

my $string = $obj->getCompetencyTypeEnumID();

Get the value of the competency_type_enum_id field

=cut

sub getCompetencyTypeEnumID{
    my ($self) = @_;
    return $self->getFieldValue('competency_type_enum_id');
}

#######################################################

=item B<setCompetencyTypeEnumID>

$obj->setCompetencyTypeEnumID($value);

Set the value of the competency_type_enum_id field

=cut

sub setCompetencyTypeEnumID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_type_enum_id', $value);
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

