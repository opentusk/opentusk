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


package TUSK::GradeBook::GradeEventType;

=head1 NAME

B<TUSK::GradeBook::GradeEventType> - Class for manipulating entries in table grade_event_type in tusk database

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
					'tablename' => 'grade_event_type',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_event_type_id' => 'pk',
					'grade_event_type_token' => '',
					'grade_event_type_name' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['grade_event_type_name'],
				    @_
				  );
    # Finish initialization...
    return $self;
}




### Get/Set methods

#######################################################

=item B<getGradeEventTypeID>

    $string = $obj->getGradeEventTypeID();

    Get the value of the grade_event_type_id field

=cut

sub getGradeEventTypeID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_type_id');
}



#######################################################

=item B<getGradeEventTypeName>

    $string = $obj->getGradeEventTypeName();

    Get the value of the grade_event_type_name field

=cut

sub getGradeEventTypeName{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_type_name');
}

#######################################################

=item B<setGradeEventTypeName>

    $string = $obj->setGradeEventTypeName($value);

    Set the value of the grade_event_type_name field

=cut

sub setGradeEventTypeName{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_type_name', $value);
}



#######################################################

=item B<getGradeEventTypeToken>

    $string = $obj->getGradeEventTypeToken();

    Get the value of the grade_event_type_token field

=cut

sub getGradeEventTypeToken{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_type_token');
}


#######################################################

=item B<setGradeEventTypeToken>

    $string = $obj->setGradeEventTypeToken($value);

    Set the value of the grade_event_type_token field

=cut

sub setGradeEventTypeToken{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_type_token', $value);
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

