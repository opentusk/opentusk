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


package TUSK::Content::External::Source;

=head1 NAME

B<TUSK::Content::External::Source> - Class for manipulating entries in table external_content_source in tusk database

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
use TUSK::Content::External::Field;
use TUSK::Content::External::Source::OVID;
use TUSK::Content::External::Source::OVID::Medline;

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
					'tablename' => 'content_external_source',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'source_id' => 'pk',
					'name' => '',
					'token' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['name'],
				    _default_join_objects => [ TUSK::Core::JoinObject->new("TUSK::Content::External::Field", { joinkey => 'source_id' } ) ],
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

=item B<getToken>

my $string = $obj->getToken();

Get the value of the token field

=cut

sub getToken{
    my ($self) = @_;
    return $self->getFieldValue('token');
}

#######################################################

=item B<setToken>

$obj->setToken($value);

Set the value of the token field

=cut

sub setToken{
    my ($self, $value) = @_;
    $self->setFieldValue('token', $value);
}


=back

=cut

### Other Methods


sub getFields{
    my ($self) = @_;
    return $self->getJoinObjects('TUSK::Content::External::Field');

}


my $object_hash = { 
    medline => 'TUSK::Content::External::Source::OVID::Medline',
    acp  => 'TUSK::Content::External::Source::OVID',
    caba => 'TUSK::Content::External::Source::OVID',
    dare => 'TUSK::Content::External::Source::OVID',
    coch => 'TUSK::Content::External::Source::OVID',
};

sub redirect{
    my ($self, $content, $user) = @_;
    if ($object_hash->{$self->getToken()}) {
	my $source = $object_hash->{ $self->getToken() }->new();
	return $source->redirect($content, $user, $self->getToken());
    }
}

sub metadata{
    my ($self, $content, $formdata) = @_;

    my $data = {};
    my $fields = $self->getFields();
    foreach my $field (@$fields){
	$data->{ $field->getToken() } = $formdata->{ $field->getPrimaryKeyID() };
    }

    if ($object_hash->{$self->getToken()}) {
	my $source = $object_hash->{ $self->getToken() }->new();
	$data->{user} = $formdata->{user};
	$data->{token} = $self->getToken();

	return $source->metadata($content, $data);
    }
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

