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


package TUSK::Case::RuleOperandRelation;

=head1 NAME

B<TUSK::Case::RuleOperandRelation> - Class for manipulating entries in table case_rule_operand_relation in tusk database

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
					'tablename' => 'case_rule_operand_relation',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'rule_operand_relation_id' => 'pk',
					'rule_operand_id' => '',
					'rule_relation_type_id' => '',
					'value' => '',
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

=item B<getRuleOperandID>

my $string = $obj->getRuleOperandID();

Get the value of the rule_operand_id field

=cut

sub getRuleOperandID{
    my ($self) = @_;
    return $self->getFieldValue('rule_operand_id');
}

#######################################################

=item B<setRuleOperandID>

$obj->setRuleOperandID($value);

Set the value of the rule_operand_id field

=cut

sub setRuleOperandID{
    my ($self, $value) = @_;
    $self->setFieldValue('rule_operand_id', $value);
}


#######################################################

=item B<getRuleRelationTypeID>

my $string = $obj->getRuleRelationTypeID();

Get the value of the rule_relation_type_id field

=cut

sub getRuleRelationTypeID{
    my ($self) = @_;
    return $self->getFieldValue('rule_relation_type_id');
}

#######################################################

=item B<setRuleRelationTypeID>

$obj->setRuleRelationTypeID($value);

Set the value of the rule_relation_type_id field

=cut

sub setRuleRelationTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('rule_relation_type_id', $value);
}


#######################################################

=item B<getValue>

my $string = $obj->getValue();

Get the value of the value field

=cut

sub getValue{
    my ($self) = @_;
    return $self->getFieldValue('value');
}

#######################################################

=item B<setValue>

$obj->setValue($value);

Set the value of the value field

=cut

sub setValue{
    my ($self, $value) = @_;
    $self->setFieldValue('value', $value);
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

