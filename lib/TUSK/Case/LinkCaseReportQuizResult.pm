package TUSK::Case::LinkCaseReportQuizResult;

=head1 NAME

B<TUSK::Case::LinkCaseReportQuizResult> - Class for manipulating entries in table link_case_report_quiz_result in tusk database

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
					'tablename' => 'link_case_report_quiz_result',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_case_report_quiz_result_id' => 'pk',
					'parent_case_report_id' => '',
					'child_quiz_result_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
                                    _default_join_objects => [
                                        TUSK::Core::JoinObject->new("TUSK::Quiz::Result",
						{origkey=>'child_quiz_result_id',
						'joinkey'=>'quiz_result_id'})
                                        ],
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

=item B<getParentCaseReportID>

    $string = $obj->getParentCaseReportID();

    Get the value of the parent_case_report_id field

=cut

sub getParentCaseReportID{
    my ($self) = @_;
    return $self->getFieldValue('parent_case_report_id');
}

#######################################################

=item B<setParentCaseReportID>

    $obj->setParentCaseReportID($value);

    Set the value of the parent_case_report_id field

=cut

sub setParentCaseReportID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_case_report_id', $value);
}


#######################################################

=item B<getChildQuizResultID>

    $string = $obj->getChildQuizResultID();

    Get the value of the child_quiz_result_id field

=cut

sub getChildQuizResultID{
    my ($self) = @_;
    return $self->getFieldValue('child_quiz_result_id');
}

#######################################################

=item B<setChildQuizResultID>

    $obj->setChildQuizResultID($value);

    Set the value of the child_quiz_result_id field

=cut

sub setChildQuizResultID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_quiz_result_id', $value);
}



=back

=cut

### Other Methods
#######################################################

=item B<getQuizResultObject>

    $quiz_result = $obj->getQuizResultObject();

Returns the quiz_result object associated with this link .

=cut

sub getQuizResultObject {
        my $self = shift;
        return $self->getJoinObject("TUSK::Quiz::Result");
}

=back


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

