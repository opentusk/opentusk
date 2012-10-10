package TUSK::Eval::Prototype;

=head1 NAME

B<TUSK::Eval::Prototype> - Class for manipulating entries in table eval_prototype in tusk database

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
					'tablename' => 'eval_prototype',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_prototype_id' => 'pk',
					'school_id' => '',
					'eval_id' => '',
					'course_code' => '',
					'exact_match' => '',
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

=item B<getCourseCode>

my $string = $obj->getCourseCode();

Get the value of the course_code field

=cut

sub getCourseCode{
    my ($self) = @_;
    return $self->getFieldValue('course_code');
}

#######################################################

=item B<setCourseCode>

$obj->setCourseCode($value);

Set the value of the course_code field

=cut

sub setCourseCode{
    my ($self, $value) = @_;
    $self->setFieldValue('course_code', $value);
}


#######################################################

=item B<getExactMatch>

my $string = $obj->getExactMatch();

Get the value of the exact_match field

=cut

sub getExactMatch{
    my ($self) = @_;
    return $self->getFieldValue('exact_match');
}

#######################################################

=item B<setExactMatch>

$obj->setExactMatch($value);

Set the value of the exact_match field

=cut

sub setExactMatch{
    my ($self, $value) = @_;
    $self->setFieldValue('exact_match', $value);
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

