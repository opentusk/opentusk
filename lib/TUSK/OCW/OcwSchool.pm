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


package TUSK::OCW::OcwSchool;

=head1 NAME

B<TUSK::OCW::OcwSchool> - Class for manipulating entries in table ocw_school in tusk database

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
					'tablename' => 'ocw_school',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'ocw_school_id' => 'pk',
					'status' => '',
					'sort_order' => '',
					'school_id'=>'',
					'ocw_school_page' => '',
					'school_label' => '',
					'school_image' => '',
					'school_desc' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [ 
					TUSK::Core::JoinObject->new("TUSK::Core::School")
                                     ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getStatus>

    $string = $obj->getStatus();

    Get the value of the status field: Active or Inactive

=cut

sub getStatus{
    my ($self) = @_;
    return $self->getFieldValue('status');
}

#######################################################

=item B<setStatus>

    $obj->setStatus($value);

    Set the value of the status field: Active or Inactive

=cut

sub setStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('status', $value);
}

#######################################################

=item B<getSortOrder>

    $integer = $obj->getSortOrder();

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

=item B<getOcwSchoolPage>

    $string = $obj->getOcwSchoolPage();

    Get the value of the ocw_school_page field

=cut

sub getOcwSchoolPage{
    my ($self) = @_;
    return $self->getFieldValue('ocw_school_page');
}

#######################################################

=item B<setOcwSchoolPage>

    $obj->setOcwSchoolPage($value);

    Set the value of the ocw_school_page field

=cut

sub setOcwSchoolPage{
    my ($self, $value) = @_;
    $self->setFieldValue('ocw_school_page', $value);
}


#######################################################

=item B<getSchoolLabel>

    $string = $obj->getSchoolLabel();

    Get the value of the school_label field

=cut

sub getSchoolLabel{
    my ($self) = @_;
    return $self->getFieldValue('school_label');
}

#######################################################

=item B<setSchoolLabel>

    $obj->setSchoolLabel($value);

    Set the value of the school_label field

=cut

sub setSchoolLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('school_label', $value);
}


#######################################################

=item B<getSchoolImage>

    $string = $obj->getSchoolImage();

    Get the value of the school_image field

=cut

sub getSchoolImage{
    my ($self) = @_;
    return $self->getFieldValue('school_image');
}

#######################################################

=item B<setSchoolImage>

    $obj->setSchoolImage($value);

    Set the value of the school_image field

=cut

sub setSchoolImage{
    my ($self, $value) = @_;
    $self->setFieldValue('school_image', $value);
}


#######################################################

=item B<getSchoolDesc>

    $string = $obj->getSchoolDesc();

    Get the value of the school_desc field

=cut

sub getSchoolDesc{
    my ($self) = @_;
    return $self->getFieldValue('school_desc');
}

#######################################################

=item B<setSchoolDesc>

    $obj->setSchoolDesc($value);

    Set the value of the school_desc field

=cut

sub setSchoolDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('school_desc', $value);
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

