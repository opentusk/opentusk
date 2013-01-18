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


package TUSK::Cron::VariableManager;

=head1 NAME

B<TUSK::Cron::VariableManager> - Class for working with Variable in tusk

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SQL STATEMENTS

=head1 INTERFACE

=head2 STATIC METHODS

#######################################################

=item B<getProcess>

my $string = getProcess();

Get the process name of the current process.
Not intended for external usage.

=cut

sub getProcess{
  my $processName = $0;
  $processName =~ s/^.*\///;
  return ($processName);
}


=item B<buildNewVariable>

my $object = buildNewVariable($variableName);

Build a new Cron::Variable named $variableName and fill it with some defaults
Not intended for external usage.

=cut

sub buildNewVariable{
  my ($variableName) = @_;
  my $variable = TUSK::Cron::Variable->new();
  $variable->setVariableName($variableName);
  $variable->setVariableCronName(getProcess());
  $variable->setVariableHostname(hostname());
  return $variable;
}


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Cron::Variable;
use Sys::Hostname;

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

my %variables;

sub new {
  # Find out what class we are
  my $class = shift;
  $class = ref $class || $class;
  # Call the super-class's constructor and give it all the values
  my $self = $class->SUPER::new (
      _datainfo => {
                    'database' => 'tusk',
                    'tablename' => 'cron_job_variables',
                    'usertoken' => 'ContentManager',
                    'database_handle' => '',
                   },
      _field_names => {
                       'cron_job_variable_id' => 'pk',
                       'cron_name' => '',
                       'variable_name' => '',
                       'variable_value' => '',
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

  # Was looking up by host_name, but I removed. If this causes a
  # problem, add it back.
  # my $tempArrayRef = TUSK::Cron::Variable->new()->lookup(
  #   "cron_name='".getProcess()."' and host_name='".hostname()."'");
  # TODO Properly escape process name SQL query
  my $tempArrayRef = TUSK::Cron::Variable->new()->lookup(
    "cron_name=" . q{'} . getProcess() . q{'});
  foreach my $variable (@{$tempArrayRef}) {
    $variables{ $variable->getVariableName() } = $variable;
  }
  return $self;
}

### Get/Set methods


#######################################################

=item B<getValue>

my $string = $obj->getValue($variableName);

Returns the value of the Variable named $variableName

=cut

sub getValue{
  my ($self, $variableName) = @_;
  unless (exists($variables{$variableName})) {
    $variables{$variableName} = buildNewVariable($variableName);
  }
  return $variables{$variableName}->getVariableValue();
}

#######################################################

=item B<setValue>

$obj->setValue($variableName, $variableValue);

Set the name of the variable $variableName to $variableValue

=cut

sub setValue{
  my ($self, $variableName, $variableValue) = @_;
  unless (exists($variables{$variableName})) {
    $variables{$variableName} = buildNewVariable($variableName);
  }
  $variables{$variableName}->setVariableValue($variableValue);
}

#######################################################

=item B<saveValue>

$obj->saveValue($variableName);

Save the value of the variable named $variableName to the database

=cut

sub saveValue{
  my ($self, $variableName) = @_;
  unless (exists($variables{$variableName})) {
    $variables{$variableName} = buildNewVariable($variableName);
  }
  $variables{$variableName}->setVariableHostname(hostname());
  $variables{$variableName}->save();
}


=back

=cut

### Other Methods

=head1 BUGS

None Reported (yet).

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

