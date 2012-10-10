package TUSK::Cron::Variable;

=head1 NAME

B<TUSK::Cron::Variable> - Class for storing cron temp data into the tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SQL STATEMENTS

	CREATE TABLE IF NOT EXISTS tusk.cron_job_variable (
		cron_job_variable_id INT NOT NULL AUTO_INCREMENT,
		cron_name VARCHAR(100) NOT NULL,
		host_name VARCHAR(100),
		variable_name VARCHAR(100) NOT NULL,
		variable_value VARCHAR(255),
		created_by VARCHAR(24),
		created_on DATETIME,
		modified_by VARCHAR(24),
		modified_on DATETIME,
		PRIMARY KEY (cron_job_variable_id),
		CONSTRAINT UNIQUE KEY `cron_job_variabls_u01` (`cron_name`, `variable_name`)
	);

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
					'tablename' => 'cron_job_variable',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'cron_job_variable_id' => 'pk',
					'cron_name' => '',
					'host_name' => '',
					'variable_name' => '',
					'variable_value' => '',
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

=item B<getVariableCronName>

my $string = $obj->getVariableCronName();

Get the name of the cron job this variable is related to

=cut

sub getVariableCronName{
	my ($self) = @_;
	return $self->getFieldValue('cron_name');
}

#######################################################

=item B<setVariableCronName>

$obj->setVariableCronName($value);

Sets the name of the cron job this variable is related to

=cut

sub setVariableCronName{
    my ($self, $value) = @_;
    $self->setFieldValue('cron_name', $value);
}

#######################################################

=item B<getVariableHostname>

my $string = $obj->getVariableHostname();

Get the hostname that this cron job was run on

=cut

sub getVariableHostname{
	my ($self) = @_;
	return $self->getFieldValue('host_name');
}

#######################################################

=item B<setVariableHostname>

$obj->setVariableHostname($value);

Sets the hostname that this cron job was run on

=cut

sub setVariableHostname{
    my ($self, $value) = @_;
    $self->setFieldValue('host_name', $value);
}

#######################################################

=item B<getVariableName>

my $string = $obj->getVariableName($variableName);

Get the name of this variable

=cut

sub getVariableName{
    my ($self) = @_;
    return $self->getFieldValue('variable_name');
}

#######################################################

=item B<setVariableName>

$obj->setVariableName($variableName, $variableName);

Set the name of this variable

=cut

sub setVariableName{
    my ($self, $name) = @_;
    $self->setFieldValue('variable_name', $name);
}

#######################################################

=item B<getVariableValue>

my $string = $obj->getVariableValue($variableName);

Get the value of this varaiable

=cut

sub getVariableValue{
    my ($self) = @_;
    return $self->getFieldValue('variable_value');
}

#######################################################

=item B<setVariableValue>

$obj->setVariableValue($variableName, $variableValue);

Set the value of this variable

=cut

sub setVariableValue{
    my ($self, $value) = @_;
    $self->setFieldValue('variable_value', $value);
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

