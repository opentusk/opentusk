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


package TUSK::Quiz::QuestionCopy;

=head1 NAME

B<TUSK::Quiz::QuestionCopy> - Class for manipulating entries in table quiz_question_copy in tusk database

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
					'tablename' => 'quiz_question_copy',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'quiz_question_copy_id' => 'pk',
					'parent_copy_question_id' => '',
					'child_copy_question_id' => '',
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

=item B<getParentCopyQuestionID>

my $string = $obj->getParentCopyQuestionID();

Get the value of the parent_copy_question_id field

=cut

sub getParentCopyQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('parent_copy_question_id');
}

#######################################################

=item B<setParentCopyQuestionID>

$obj->setParentCopyQuestionID($value);

Set the value of the parent_copy_question_id field

=cut

sub setParentCopyQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_copy_question_id', $value);
}


#######################################################

=item B<getChildCopyQuestionID>

my $string = $obj->getChildCopyQuestionID();

Get the value of the child_copy_question_id field

=cut

sub getChildCopyQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('child_copy_question_id');
}

#######################################################

=item B<setChildCopyQuestionID>

$obj->setChildCopyQuestionID($value);

Set the value of the child_copy_question_id field

=cut

sub setChildCopyQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_copy_question_id', $value);
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

