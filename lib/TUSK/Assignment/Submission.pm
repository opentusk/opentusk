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


package TUSK::Assignment::Submission;

=head1 NAME

B<TUSK::Assignment::Submission> - Class for manipulating entries in table assignment_submission in tusk database

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
					'tablename' => 'assignment_submission',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'assignment_submission_id' => 'pk',
					'link_id' => '',
					'link_type' => '',
					'submit_sequence' => '',
					'submit_date' => '',
					'grade' => '',
					'feedback_post_flag' => '',
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

=item B<getLinkID>

my $string = $obj->getLinkID();

Get the value of the link_id field

=cut

sub getLinkID{
    my ($self) = @_;
    return $self->getFieldValue('link_id');
}

#######################################################

=item B<setLinkID>

$obj->setLinkID($value);

Set the value of the link_id field

=cut

sub setLinkID{
    my ($self, $value) = @_;
    $self->setFieldValue('link_id', $value);
}


#######################################################

=item B<getLinkType>

my $string = $obj->getLinkType();

Get the value of the link_type field

=cut

sub getLinkType{
    my ($self) = @_;
    return $self->getFieldValue('link_type');
}

#######################################################

=item B<setLinkType>

$obj->setLinkType($value);

Set the value of the link_type field

=cut

sub setLinkType{
    my ($self, $value) = @_;
    $self->setFieldValue('link_type', $value);
}


#######################################################

=item B<getSubmitSequence>

my $string = $obj->getSubmitSequence();

Get the value of the submit_sequence field

=cut

sub getSubmitSequence{
    my ($self) = @_;
    return $self->getFieldValue('submit_sequence');
}

#######################################################

=item B<setSubmitSequence>

$obj->setSubmitSequence($value);

Set the value of the submit_sequence field

=cut

sub setSubmitSequence{
    my ($self, $value) = @_;
    $self->setFieldValue('submit_sequence', $value);
}


#######################################################

=item B<getSubmitDate>

my $string = $obj->getSubmitDate();

Get the value of the submit_date field

=cut

sub getSubmitDate{
    my ($self) = @_;
    return $self->getFieldValue('submit_date');
}


#######################################################

=item B<getFormattedSubmitDate>

   $string = $obj->getFormattedSubmitDate();

Get the value of the submit_date field with no secs

=cut

sub getFormattedSubmitDate{
    my ($self) = @_;
    my $submit_date = $self->getSubmitDate();
    $submit_date =~ s/:\d\d$//;
    return $submit_date;
}


#######################################################

=item B<setSubmitDate>

$obj->setSubmitDate($value);

Set the value of the submit_date field

=cut

sub setSubmitDate{
    my ($self, $value) = @_;
    $self->setFieldValue('submit_date', $value);
}


#######################################################

=item B<getGrade>

my $string = $obj->getGrade();

Get the value of the grade field

=cut

sub getGrade{
    my ($self) = @_;
    return $self->getFieldValue('grade');
}

#######################################################

=item B<setGrade>

$obj->setGrade($value);

Set the value of the grade field

=cut

sub setGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('grade', $value);
}


#######################################################

=item B<getFeedbackPostFlag>

my $string = $obj->getFeedbackPostFlag();

Get the value of the feedback_post_flag field

=cut

sub getFeedbackPostFlag{
    my ($self) = @_;
    return $self->getFieldValue('feedback_post_flag');
}

#######################################################

=item B<setFeedbackPostFlag>

$obj->setFeedbackPostFlag($value);

Set the value of the feedback_post_flag field

=cut

sub setFeedbackPostFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('feedback_post_flag', $value);
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

