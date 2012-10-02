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


package TUSK::Core::AdminTuskLookup;

=head1 NAME

B<TUSK::Core::AdminTuskLookup> - Class for manipulating entries in table admin_tusk_lookup in tusk database

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
					'tablename' => 'admin_tusk_lookup',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'admin_tusk_lookup_id' => 'pk',
					'admin_type' => '',
					'admin_id' => '',
					'admin_school' => '',
					'tusk_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
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

=item B<getAdminType>

    $string = $obj->getAdminType();

    Get the value of the admin_type field

=cut

sub getAdminType{
    my ($self) = @_;
    return $self->getFieldValue('admin_type');
}

#######################################################

=item B<setAdminType>

    $string = $obj->setAdminType($value);

    Set the value of the admin_type field

=cut

sub setAdminType{
    my ($self, $value) = @_;
    $self->setFieldValue('admin_type', $value);
}


#######################################################

=item B<getAdminID>

    $string = $obj->getAdminID();

    Get the value of the admin_id field

=cut

sub getAdminID{
    my ($self) = @_;
    return $self->getFieldValue('admin_id');
}

#######################################################

=item B<setAdminID>

    $string = $obj->setAdminID($value);

    Set the value of the admin_id field

=cut

sub setAdminID{
    my ($self, $value) = @_;
    $self->setFieldValue('admin_id', $value);
}


#######################################################

=item B<getAdminSchool>

    $string = $obj->getAdminSchool();

    Get the value of the admin_school field

=cut

sub getAdminSchool{
    my ($self) = @_;
    return $self->getFieldValue('admin_school');
}

#######################################################

=item B<setAdminSchool>

    $string = $obj->setAdminSchool($value);

    Set the value of the admin_school field

=cut

sub setAdminSchool{
    my ($self, $value) = @_;
    $self->setFieldValue('admin_school', $value);
}


#######################################################

=item B<getTuskID>

    $string = $obj->getTuskID();

    Get the value of the tusk_id field

=cut

sub getTuskID{
    my ($self) = @_;
    return $self->getFieldValue('tusk_id');
}

#######################################################

=item B<setTuskID>

    $string = $obj->setTuskID($value);

    Set the value of the tusk_id field

=cut

sub setTuskID{
    my ($self, $value) = @_;
    $self->setFieldValue('tusk_id', $value);
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

