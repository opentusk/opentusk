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


package TUSK::Eval::EvalLoadTime;

=head1 NAME

B<TUSK::Eval::EvalLoadTime> - Class for manipulating entries in table eval_load_time in tusk database

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
					'tablename' => 'eval_load_time',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_load_time_id' => 'pk',
					'school_id' => '',
					'eval_id' => '',
					'load_time' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    # If we got a school in the format Medical we need to change it to the TUSK school number
    unless($value =~ /^\d*$/) {  $value = TUSK::Core::School->getSchoolID($value);  }
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getEvalID>

my $string = $obj->getEvalID();

Get the value of the eval_id field

=cut

sub getEvalID{
    my ($self) = @_;
    return $self->getFieldValue('eval_id');
}

#######################################################

=item B<setEvalID>

$obj->setEvalID($value);

Set the value of the eval_id field

=cut

sub setEvalID{
    my ($self, $value) = @_;
    $self->setFieldValue('eval_id', $value);
}


#######################################################

=item B<getLoadTime>

my $string = $obj->getLoadTime();

Get the value of the load_time field

=cut

sub getLoadTime{
    my ($self) = @_;
    return $self->getFieldValue('load_time');
}

#######################################################

=item B<setLoadTime>

$obj->setLoadTime($value);

Set the value of the load_time field

=cut

sub setLoadTime{
    my ($self, $value) = @_;
    $self->setFieldValue('load_time', $value);
}

#######################################################

=item B<getStats>

$obj->getStats();

$arrayRef = count, avg, max
Get the number of loads, average and max values

=cut

sub getStats{
	my ($self) = @_;
	my $schoolId = $self->getSchoolID();
	my $evalId = $self->getEvalID();
	unless($schoolId =~ /^\d*$/) {  $schoolId = TUSK::Core::School->getSchoolID($schoolId);  }

	my $results = $self->databaseSelect("select count(1), avg(load_time), max(load_time) from tusk.eval_load_time where school_id='". $schoolId ."' and eval_id='". $evalId ."';");
	my $array_ref = $results->fetchrow_arrayref();
	$self->{-total} = ${$array_ref}[0];
	$self->{-average} = ${$array_ref}[1];
	$self->{-max} = ${$array_ref}[2];
}


#######################################################

=item B<totalLoads>

$variable = $obj->totalLoads();

Get the total number of times this eval appeared in the timer table

=cut

sub totalLoads{
	my $self = shift;
	unless($self->{-total}) {$self->getStats();}
	return $self->{-total};
}
#######################################################

=item B<agerage>

$variable $obj->agerage();

Get the average time it took this eval to load

=cut

sub average{
	my $self = shift;
	unless($self->{-average}) {$self->getStats();}
	return $self->{-average};
}
#######################################################

=item B<max>

$variable = $obj->max();

Get the max time it took this eval to load

=cut

sub max{
	my $self = shift;
	unless($self->{-max}) {$self->getStats();}
	return $self->{-max};
}
#######################################################

=item B<start>

$obj->start();

Start the timer

=cut

sub start{
	my $self = shift;
	$self->{-start} = time;
}

#######################################################

=item B<stop>

$obj->stop();

Stop and save the timer

=cut

sub stop{
	my $self = shift;

	if(! $self->{-start}) {confess("You must call start before calling stop");}
	else {
		my $stop = time;
		$self->setLoadTime($stop - $self->{-start}); 
		$self->save();
	}
}

#######################################################

=item B<setEval>

$obj->setEva;( $evalObject );

Takes the eval object we are interested in and sets the times school and eval ids.

=cut

sub setEval() {
	my $self = shift;
	my $evalObject = shift;

	unless($evalObject) {confess ("An invalid eval was passed");}
	else {
		$self->setSchoolID( $evalObject->school );
		$self->setEvalID( $evalObject->getPrimaryKeyID );
	}
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

