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


package TUSK::Mobile::Device;

=head1 NAME

B<TUSK::Mobile::Device> - Class for manipulating entries in table mobile_device in tusk database

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
					'tablename' => 'mobile_device',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'mobile_device_id' => 'pk',
					'user_agent' => '',
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

=item B<getUserAgent>

my $string = $obj->getUserAgent();

Get the value of the user_agent field

=cut

sub getUserAgent{
    my ($self) = @_;
    return $self->getFieldValue('user_agent');
}

#######################################################

=item B<setUserAgent>

$obj->setUserAgent($value);

Set the value of the user_agent field

=cut

sub setUserAgent{
    my ($self, $value) = @_;
    $self->setFieldValue('user_agent', $value);
}





=back

=cut

### Other Methods

#######################################################

=item B<findByAgent>

$obj->findByAgent($value);

Simple heuristic to see if user_agent is in wurfl.xml file

=cut

sub isMobileDevice{
    my ($ua) = shift;

	my $devices = findDevice($ua);

	return scalar @$devices;
}


sub findDevice{
    my ($ua, $recursed) = @_;

	my $devices = TUSK::Mobile::Device->new()->lookup('user_agent = ' . TUSK::Core::SQLRow::sql_escape($ua) );
	return $devices;
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

