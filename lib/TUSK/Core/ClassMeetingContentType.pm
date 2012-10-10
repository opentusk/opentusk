package TUSK::Core::ClassMeetingContentType;

=head1 NAME

B<TUSK::Core::ClassMeetingContentType> - Class for manipulating entries in table class_meeting_content_type in tusk database

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
					'tablename' => 'class_meeting_content_type',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'class_meeting_content_type_id' => 'pk',
					'label' => '',
				    },
				    _attributes => {
					save_history => 0,
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

=item B<getLabel>

    $string = $obj->getLabel();

    Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

    $obj->setLabel($value);

    Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
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

