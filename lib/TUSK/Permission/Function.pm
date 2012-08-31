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


package TUSK::Permission::Function;

=head1 NAME

B<TUSK::Permission::Function> - Class for manipulating entries in table permission_function in tusk database

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
					'tablename' => 'permission_function',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'function_id' => 'pk',
					'function_token' => '',
					'function_desc' => '',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getFunctionToken>

    $string = $obj->getFunctionToken();

    Get the value of the function_token field

=cut

sub getFunctionToken{
    my ($self) = @_;
    return $self->getFieldValue('function_token');
}

#######################################################

=item B<setFunctionToken>

    $obj->setFunctionToken($value);

    Set the value of the function_token field

=cut

sub setFunctionToken{
    my ($self, $value) = @_;
    $self->setFieldValue('function_token', $value);
}


#######################################################

=item B<getFunctionDesc>

    $string = $obj->getFunctionDesc();

    Get the value of the function_desc field

=cut

sub getFunctionDesc{
    my ($self) = @_;
    return $self->getFieldValue('function_desc');
}

#######################################################

=item B<setFunctionDesc>

    $obj->setFunctionDesc($value);

    Set the value of the function_desc field

=cut

sub setFunctionDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('function_desc', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getPrettyFunctionToken>

my $string = $obj->getPrettyFunctionToken();

Return a pretty version of the function_token field

=cut

sub getPrettyFunctionToken{
    my ($self) = @_;
    return TUSK::Core::SQLRow::MakePretty($self->getFunctionToken());

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

