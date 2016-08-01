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


package TUSK::Quiz::RandomQuestion;

=head1 NAME

B<TUSK::Quiz::RandomQuestion> - Class for manipulating entries in table quiz_random_question in tusk database

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
					'tablename' => 'quiz_random_question',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'quiz_random_question_id' => 'pk',
					'quiz_id' => '',
					'user_id' => '',
					'quiz_question_id' => '',
					'sort_order' => '',
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

=item B<getQuizID>

my $string = $obj->getQuizID();

Get the value of the quiz_id field

=cut

sub getQuizID{
    my ($self) = @_;
    return $self->getFieldValue('quiz_id');
}

#######################################################

=item B<setQuizID>

$obj->setQuizID($value);

Set the value of the quiz_id field

=cut

sub setQuizID{
    my ($self, $value) = @_;
    $self->setFieldValue('quiz_id', $value);
}


#######################################################

=item B<getQuizQuestionID>

my $string = $obj->getQuizQuestionID();

Get the value of the quiz_question_id field

=cut

sub getQuizQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('quiz_question_id');
}

#######################################################

=item B<setQuizQuestionID>

$obj->setQuizQuestionID($value);

Set the value of the quiz_question_id field

=cut

sub setQuizQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('quiz_question_id', $value);
}


#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

$obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
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

