package TUSK::Core::HSDB45Tables::TeachingSite;

=head1 NAME

B<TUSK::Core::HSDB45Tables::TeachingSite> - Class for manipulating entries in table teaching_site in hsdb45_med_admin database

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
					'tablename' => 'teaching_site',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'teaching_site_id' => 'pk',
					'site_name' => '',
					'site_city_state' => '',
					'modified' => '',
					'body' => '',
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

=item B<getSiteName>

    $string = $obj->getSiteName();

    Get the value of the site_name field

=cut

sub getSiteName{
    my ($self) = @_;
    return $self->getFieldValue('site_name');
}

#######################################################

=item B<setSiteName>

    $obj->setSiteName($value);

    Set the value of the site_name field

=cut

sub setSiteName{
    my ($self, $value) = @_;
    $self->setFieldValue('site_name', $value);
}


#######################################################

=item B<getSiteCityState>

    $string = $obj->getSiteCityState();

    Get the value of the site_city_state field

=cut

sub getSiteCityState{
    my ($self) = @_;
    return $self->getFieldValue('site_city_state');
}

#######################################################

=item B<setSiteCityState>

    $obj->setSiteCityState($value);

    Set the value of the site_city_state field

=cut

sub setSiteCityState{
    my ($self, $value) = @_;
    $self->setFieldValue('site_city_state', $value);
}


#######################################################

=item B<getModified>

    $string = $obj->getModified();

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


#######################################################

=item B<getBody>

    $string = $obj->getBody();

    Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

    $obj->setBody($value);

    Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
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

