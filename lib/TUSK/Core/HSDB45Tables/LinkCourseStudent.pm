package TUSK::Core::HSDB45Tables::LinkCourseStudent;

=head1 NAME

B<TUSK::Core::HSDB45Tables::LinkCourseStudent> - Class for manipulating entries in table link_course_student in hsdb45_med_admin database

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
					'database' => '',
					'tablename' => 'link_course_student',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'parent_course_id' => 'pk',
					'child_user_id' => 'pk',
					'time_period_id' => 'pk',
					'modified' => '',
					'teaching_site_id' => 'pk',
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

=item B<getModified>

my $string = $obj->getModified();

Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
}

#######################################################

=item B<setModified>

$obj->setModified($value);

Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
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

