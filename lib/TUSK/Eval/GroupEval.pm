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


package TUSK::Eval::GroupEval;

=head1 NAME

B<TUSK::Eval::GroupEval> - Class for manipulating entries in table eval_group_eval in tusk database

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
					'tablename' => 'eval_group_eval',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_group_eval_id' => 'pk',
					'parent_eval_group_id' => '',
					'child_eval_id' => '',
					'user_id' => '',
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

=item B<getParentEvalGroupID>

my $string = $obj->getParentEvalGroupID();

Get the value of the parent_eval_group_id field

=cut

sub getParentEvalGroupID{
    my ($self) = @_;
    return $self->getFieldValue('parent_eval_group_id');
}

#######################################################

=item B<setParentEvalGroupID>

$obj->setParentEvalGroupID($value);

Set the value of the parent_eval_group_id field

=cut

sub setParentEvalGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_eval_group_id', $value);
}


#######################################################

=item B<getChildEvalID>

my $string = $obj->getChildEvalID();

Get the value of the child_eval_id field

=cut

sub getChildEvalID{
    my ($self) = @_;
    return $self->getFieldValue('child_eval_id');
}

#######################################################

=item B<setChildEvalID>

$obj->setChildEvalID($value);

Set the value of the child_eval_id field

=cut

sub setChildEvalID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_eval_id', $value);
}


#######################################################

=item B<getUserID>

my $string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
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

