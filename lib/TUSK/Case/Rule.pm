package TUSK::Case::Rule;

=head1 NAME

B<TUSK::Case::Rule> - Class for manipulating entries in table case_rule in tusk database

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

use TUSK::Case::RuleOperand;
use TUSK::Case::RuleOperatorType;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'case_rule',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'rule_id' => 'pk',
					'phase_id' => '',
					'rule_operator_type_id' => '',
					'message' => '',
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

=item B<getPhaseID>

my $string = $obj->getPhaseID();

Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

$obj->setPhaseID($value);

Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getRuleOperatorTypeID>

my $string = $obj->getRuleOperatorTypeID();

Get the value of the rule_operator_type_id field

=cut

sub getRuleOperatorTypeID{
    my ($self) = @_;
    return $self->getFieldValue('rule_operator_type_id');
}

#######################################################

=item B<setRuleOperatorTypeID>

$obj->setRuleOperatorTypeID($value);

Set the value of the rule_operator_type_id field

=cut

sub setRuleOperatorTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('rule_operator_type_id', $value);
}


#######################################################

=item B<getMessage>

my $string = $obj->getMessage();

Get the value of the message field

=cut

sub getMessage{
    my ($self) = @_;
    return $self->getFieldValue('message');
}

#######################################################

=item B<setMessage>

$obj->setMessage($value);

Set the value of the message field

=cut

sub setMessage{
    my ($self, $value) = @_;
    $self->setFieldValue('message', $value);
}



=back

=cut

### Other Methods


=item B<getOperands>

my $arr_ref = $obj->getOperands();

Get all operands linked to this rule

=cut

sub getOperands{
    my ($self) = @_;

	my $operands = TUSK::Case::RuleOperand->new()->lookup('rule_id=' . $self->getPrimaryKeyID());
	return $operands;
}


#######################################################

=item B<deleteRuleAndOperands>

$obj->deleteRuleAndOperands();

Delete the rule and all of its operands.

=cut

sub deleteRuleAndOperands{
    my ($self, $user_hash) = @_;

	my $operands = $self->getOperands();

	foreach my $op (@$operands) {	
		$op->delete($user_hash);
	}
	$self->delete($user_hash);
}


#######################################################

=item B<getOperatorTypeObj>

my $arr_ref = $obj->getOperatorTypeObj();

Get the TUSK::Case::RuleOperatorType object associated with 
this rule.

=cut

sub getOperatorTypeObj{
    my $self = shift;

	return TUSK::Case::RuleOperatorType->new()->lookupKey($self->getRuleOperatorTypeID());
}


#######################################################

=item B<isSatisfied>

my $int = $rule->isSatisfied($report);

Given a case report, determine if this rule has been satisfied (if satisfied,
this method returns a true value).

=cut

sub isSatisfied{
    my ($self, $report) = @_;

	my $operator_type = $self->getOperatorTypeObj();
	my $operands = $self->getOperands();

	if ($operator_type->getLabel() eq 'AND') {
		foreach my $o (@$operands) {
			unless ($o->evaluatesTrue($report)) {
				return 0;
			}
		}
		return 1;
	}
	else {
		foreach my $o (@$operands) {
			if ($o->evaluatesTrue($report)) {
				return 1;
			}
		}
		return 0;
	}	
}


#######################################################


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

