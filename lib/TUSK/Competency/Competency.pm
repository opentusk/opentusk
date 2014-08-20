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


package TUSK::Competency::Competency;

=head1 NAME

B<TUSK::Competency::Competency> - Class for manipulating entries in table competency in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

use TUSK::Feature::Link;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use Carp qw(cluck croak confess);

use TUSK::Competency::UserType;
use TUSK::Enum::Data;
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
					'tablename' => 'competency',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_id' => 'pk',
					'version_id' => '',
					'school_id' => '',
					'title' => '',
					'description' => '',
					'competency_level_enum_id' => '',
					'competency_user_type_id' => '',
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

=item B<getCompetencyID>

    $string = $obj->getCompetencyID();

    Get the value of the competency_id field

=cut

sub getCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('competency_id');
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

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}

#######################################################

=item B<getVersionID>

    $string = $obj->getVersionID();

    Get the value of the version_id field

=cut

sub getVersionID{
    my ($self) = @_;
    return $self->getFieldValue('version_id');
}

#######################################################

=item B<setVersionID>

    $string = $obj->setVersionID($value);

    Set the value of the version_id field

=cut

sub setVersionID{
    my ($self, $value) = @_;
    $self->setFieldValue('version_id', $value);
}


#######################################################

#######################################################

=item B<getCompetencyUserTypeID>

    $string = $obj->getCompetencyUserTypeID();

    Get the value of the competency_user_type_id field

=cut

sub getCompetencyUserTypeID{
    my ($self) = @_;
    return $self->getFieldValue('competency_user_type_id');
}

#######################################################

=item B<setCompetencyUserTypeID>

    $string = $obj->setCompetencyUserTypeID($value);

    Set the value of the competency_user_type_id field

=cut

sub setCompetencyUserTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_user_type_id', $value);
}


#######################################################


=item B<getTitle>

    $string = $obj->getTitle();

    Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

    $string = $obj->setTitle($value);

    Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}

#######################################################

=item B<getUri>

    $string = $obj->getUri();

    Get the value of the uri field

=cut

sub getUri{
    my ($self) = @_;
    
    my $URI;

    if (TUSK::Feature::Link->lookupReturnOne("feature_id = ".$self->getPrimaryKeyID)){
        $URI = TUSK::Feature::Link->lookupReturnOne("feature_id = ".$self->getPrimaryKeyID)->getUrl;
    }

    return $URI;
}

#######################################################

=item B<setUri>

    $string = $obj->setUri($value);

    Set the value of the uri field

=cut

sub setUri{
    my ($self, $value) = @_;
    TUSK::Feature::Link->lookupReturnOne("feature_id = ".$self->getPrimaryKeyID)->setFieldValue('url', $value);
}


#######################################################

=item B<getCompetencyLevelEnumID>

    $string = $obj->getCompetencyLevelEnumID();

    Get the value of the competency_level_enum_id field

=cut

sub getCompetencyLevelEnumID{
    my ($self) = @_;
    return $self->getFieldValue('competency_level_enum_id');
}

#######################################################

=item B<setCompetencyLevelEnumID>

    $string = $obj->setCompetencyLevelEnumID();

    Set the value of the competency_level_enum_id field

=cut

sub setCompetencyLevelEnumID{
    my ($self, $value) = @_;
    return $self->setFieldValue('competency_level_enum_id', $value);
}

#######################################################

=item B<getDescription>

    $string = $obj->getDescription();

    Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

    $string = $obj->setDescription($value);

    Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}

#######################################################

### Other Methods

#######################################################

sub getCompetencyLevel{
    my $self = shift;
    my $enum_data = TUSK::Enum::Data->lookup( "enum_data_id=". $self->getCompetencyLevelEnumID() );
    return $enum_data->[0]->getShortName;
}

sub getType{
    my $self = shift;
    my $type_id = $self->getCompetencyUserTypeID;
    my $competency_user_type = TUSK::Competency::UserType->lookupReturnOne( "competency_user_type_id=". $type_id );
    my $enum_data = TUSK::Enum::Data->lookupReturnOne( "enum_data_id=".$competency_user_type->getCompetencyTypeEnumID);
    my $type = $enum_data->getShortName;
    return $type;
}


sub getTypes{
    my $self = shift;                                                                                                                                                                                                                     
    my $types = TUSK::Competency::UserType->new()->getPrimaryKeyID( $self->getCompetencyUserTypeID );                                                                                                                             
    my @data = map ($_->getPrimaryKeyID->getName, @{$types});                                                                                                                                                                     
    return join( ', ', @data );                        
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

