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


package TUSK::FormBuilder::FieldType;

=head1 NAME

B<TUSK::FormBuilder::FieldType> - Class for manipulating entries in table form_builder_field_type in tusk database

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
					'tablename' => 'form_builder_field_type',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'field_type_id' => 'pk',
					'token' => '',
					'label' => '',
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

=item B<getToken>

    $string = $obj->getToken();

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


#######################################################

=item B<getLabel>

    $string = $obj->getLabel();

    Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

    $obj->setLabel($value);

    Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}



=back

=cut

### Other Methods

=item B<getDropDownValue>

    $string = $obj->getDropDownValue();

    Get the value for this object to be used in a dropdown.  The token is needed in case we do any comparisons.

=cut

sub getDropDownValue{
    my ($self) = @_;
    return $self->getPrimaryKeyID() . "#" . $self->getFieldValue('token');
}

#######################################################

=item B<checkToken>

    $int = $obj->checkToken($string);

    Check to see if this obj has token $string

=cut

sub checkToken{
    my ($self, $string) = @_;

    if ($self->getToken() eq $string){
	return 1;
    }

    return 0;
}


sub getFieldTypes {
	my ($self, $form_token) = @_;

	my $field_types = {
		PatientLog => [ 'FillIn', 'SingleSelect', 'SingleSelectAllowMulti', 'MultiSelect', 'MultiSelectWithAttributes', 'RadioSelect', 'Essay', 'DynamicList' ],
		SP => [ 'FillIn', 'SingleSelect', 'SingleSelectAllowMulti',  'MultiSelectWithAttributes', 'RadioSelect', 'Essay', 'DynamicList', 'CheckList', 'Heading', ],
        Assessment => [ 'Scaling' ],
	};

	my $cond = undef;
	if (defined $form_token && exists $field_types->{$form_token}) {
		$cond = 'token in (' . join(", ", map { "'$_'" } @{$field_types->{$form_token}}) . ')';
	}

	return $self->lookup($cond, ['label']);
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

