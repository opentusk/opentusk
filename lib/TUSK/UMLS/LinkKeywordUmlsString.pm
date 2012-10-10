package TUSK::UMLS::LinkKeywordUmlsString;

=head1 NAME

B<TUSK::UMLS::LinkKeywordUmlsString> - Class for manipulating entries in table link_keyword_umls_string in tusk database

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
use TUSK::UMLS::UmlsString;

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
					'tablename' => 'link_keyword_umls_string',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_keyword_umls_string_id' => 'pk',
					'parent_keyword_id' => '',
					'child_umls_string_id' => '',
					'term_status' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [
					TUSK::Core::JoinObject->new("TUSK::UMLS::UmlsString",
				{ joinkey => 'umls_string_id', origkey => 'child_umls_string_id' } ),
					],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentKeywordID>

my $string = $obj->getParentKeywordID();

Get the value of the parent_keyword_id field

=cut

sub getParentKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('parent_keyword_id');
}

#######################################################

=item B<setParentKeywordID>

$obj->setParentKeywordID($value);

Set the value of the parent_keyword_id field

=cut

sub setParentKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_keyword_id', $value);
}


#######################################################

=item B<getChildUmlsStringID>

my $string = $obj->getChildUmlsStringID();

Get the value of the child_umls_string_id field

=cut

sub getChildUmlsStringID{
    my ($self) = @_;
    return $self->getFieldValue('child_umls_string_id');
}

#######################################################

=item B<setChildUmlsStringID>

$obj->setChildUmlsStringID($value);

Set the value of the child_umls_string_id field

=cut

sub setChildUmlsStringID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_umls_string_id', $value);
}


#######################################################

=item B<getTermStatus>

my $string = $obj->getTermStatus();

Get the value of the term_status field

=cut

sub getTermStatus{
    my ($self) = @_;
    return $self->getFieldValue('term_status');
}

#######################################################

=item B<setTermStatus>

$obj->setTermStatus($value);

Set the value of the term_status field

=cut

sub setTermStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('term_status', $value);
}



=back

=cut

### Other Methods

sub getUmlsStringObject {
        my $self = shift;
        return $self->getJoinObject('TUSK::UMLS::UmlsString');

}

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

