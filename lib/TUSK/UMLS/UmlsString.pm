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


package TUSK::UMLS::UmlsString;

=head1 NAME

B<TUSK::UMLS::UmlsString> - Class for manipulating entries in table umls_string in tusk database

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
					'tablename' => 'umls_string',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'umls_string_id' => 'pk',
					'string_id' => '',
					'string_text' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
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

=item B<getStringID>

my $string = $obj->getStringID();

Get the value of the string_id field

=cut

sub getStringID{
    my ($self) = @_;
    return $self->getFieldValue('string_id');
}

#######################################################

=item B<setStringID>

$obj->setStringID($value);

Set the value of the string_id field

=cut

sub setStringID{
    my ($self, $value) = @_;
    $self->setFieldValue('string_id', $value);
}


#######################################################

=item B<getStringText>

my $string = $obj->getStringText();

Get the value of the string_text field

=cut

sub getStringText{
    my ($self) = @_;
    return $self->getFieldValue('string_text');
}

#######################################################

=item B<setStringText>

$obj->setStringText($value);

Set the value of the string_text field

=cut

sub setStringText{
    my ($self, $value) = @_;
    $self->setFieldValue('string_text', $value);
}



=back

=cut

### Other Methods

sub getKeywords {
	my $self = shift;
	my $links = TUSK::UMLS::LinkKeywordUmlsString->lookup("child_umls_string_id = ".$self->getPrimaryKeyID());
	my $keywords  = [];
	foreach my $link (@{$links}){
		push @{$keywords}, TUSK::Core::Keyword->lookupKey($link->getParentKeywordID());
	}
	return $keywords;

}

sub getStringTextNormalized {
    my ($self) = @_;
    my $text = $self->getStringText();
    $text =~ s/\b(.)/uc($1)/eg;
    return ($text);
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

