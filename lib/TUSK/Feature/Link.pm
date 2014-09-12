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


package TUSK::Feature::Link;

=head1 NAME

B<TUSK::Feature::Link> - Class for manipulating entries in table feature_link in tusk database

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
					'tablename' => 'feature_link',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'feature_link_id' => 'pk',
					'feature_type_enum_id' => '',
					'feature_id' => '',
					'url' => '',
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

=item B<getFeatureTypeEnumID>

my $string = $obj->getFeatureTypeEnumID();

Get the value of the feature_type_enum_id field

=cut

sub getFeatureTypeEnumID{
    my ($self) = @_;
    return $self->getFieldValue('feature_type_enum_id');
}

#######################################################

=item B<setFeatureTypeEnumID>

$obj->setFeatureTypeEnumID($value);

Set the value of the feature_type_enum_id field

=cut

sub setFeatureTypeEnumID{
    my ($self, $value) = @_;
    $self->setFieldValue('feature_type_enum_id', $value);
}


#######################################################

=item B<getFeatureID>

my $string = $obj->getFeatureID();

Get the value of the feature_id field

=cut

sub getFeatureID{
    my ($self) = @_;
    return $self->getFieldValue('feature_id');
}

#######################################################

=item B<setFeatureID>

$obj->setFeatureID($value);

Set the value of the feature_id field

=cut

sub setFeatureID{
    my ($self, $value) = @_;
    $self->setFieldValue('feature_id', $value);
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
    $self->setFieldValue('url', $value);
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

