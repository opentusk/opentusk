package Forum::Board;

=head1 NAME

B<Forum::Board> - Class for manipulating entries in table boards in mwforum database

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
					'database' => 'mwforum',
					'tablename' => 'boards',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'id' => 'pk',
					'title' => '',
					'categoryId' => '',
					'pos' => '',
					'expiration' => '',
					'locking' => '',
					'approve' => '',
					'private' => '',
					'anonymous' => '',
					'unregistered' => '',
					'announce' => '',
					'flat' => '',
					'attach' => '',
					'shortDesc' => '',
					'longDesc' => '',
					'postNum' => '',
					'lastPostTime' => '',
					'boardkey' => '',
					'start_date' => '',
					'end_date' => '',
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

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getCategoryID>

my $string = $obj->getCategoryID();

Get the value of the categoryId field

=cut

sub getCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('categoryId');
}

#######################################################

=item B<setCategoryID>

$obj->setCategoryID($value);

Set the value of the categoryId field

=cut

sub setCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('categoryId', $value);
}


#######################################################

=item B<getPos>

my $string = $obj->getPos();

Get the value of the pos field

=cut

sub getPos{
    my ($self) = @_;
    return $self->getFieldValue('pos');
}

#######################################################

=item B<setPos>

$obj->setPos($value);

Set the value of the pos field

=cut

sub setPos{
    my ($self, $value) = @_;
    $self->setFieldValue('pos', $value);
}


#######################################################

=item B<getExpiration>

my $string = $obj->getExpiration();

Get the value of the expiration field

=cut

sub getExpiration{
    my ($self) = @_;
    return $self->getFieldValue('expiration');
}

#######################################################

=item B<setExpiration>

$obj->setExpiration($value);

Set the value of the expiration field

=cut

sub setExpiration{
    my ($self, $value) = @_;
    $self->setFieldValue('expiration', $value);
}


#######################################################

=item B<getLocking>

my $string = $obj->getLocking();

Get the value of the locking field

=cut

sub getLocking{
    my ($self) = @_;
    return $self->getFieldValue('locking');
}

#######################################################

=item B<setLocking>

$obj->setLocking($value);

Set the value of the locking field

=cut

sub setLocking{
    my ($self, $value) = @_;
    $self->setFieldValue('locking', $value);
}


#######################################################

=item B<getApprove>

my $string = $obj->getApprove();

Get the value of the approve field

=cut

sub getApprove{
    my ($self) = @_;
    return $self->getFieldValue('approve');
}

#######################################################

=item B<setApprove>

$obj->setApprove($value);

Set the value of the approve field

=cut

sub setApprove{
    my ($self, $value) = @_;
    $self->setFieldValue('approve', $value);
}


#######################################################

=item B<getPrivate>

my $string = $obj->getPrivate();

Get the value of the private field

=cut

sub getPrivate{
    my ($self) = @_;
    return $self->getFieldValue('private');
}

#######################################################

=item B<setPrivate>

$obj->setPrivate($value);

Set the value of the private field

=cut

sub setPrivate{
    my ($self, $value) = @_;
    $self->setFieldValue('private', $value);
}


#######################################################

=item B<getAnonymous>

my $string = $obj->getAnonymous();

Get the value of the anonymous field

=cut

sub getAnonymous{
    my ($self) = @_;
    return $self->getFieldValue('anonymous');
}

#######################################################

=item B<setAnonymous>

$obj->setAnonymous($value);

Set the value of the anonymous field

=cut

sub setAnonymous{
    my ($self, $value) = @_;
    $self->setFieldValue('anonymous', $value);
}


#######################################################

=item B<getUnregistered>

my $string = $obj->getUnregistered();

Get the value of the unregistered field

=cut

sub getUnregistered{
    my ($self) = @_;
    return $self->getFieldValue('unregistered');
}

#######################################################

=item B<setUnregistered>

$obj->setUnregistered($value);

Set the value of the unregistered field

=cut

sub setUnregistered{
    my ($self, $value) = @_;
    $self->setFieldValue('unregistered', $value);
}


#######################################################

=item B<getAnnounce>

my $string = $obj->getAnnounce();

Get the value of the announce field

=cut

sub getAnnounce{
    my ($self) = @_;
    return $self->getFieldValue('announce');
}

#######################################################

=item B<setAnnounce>

$obj->setAnnounce($value);

Set the value of the announce field

=cut

sub setAnnounce{
    my ($self, $value) = @_;
    $self->setFieldValue('announce', $value);
}


#######################################################

=item B<getFlat>

my $string = $obj->getFlat();

Get the value of the flat field

=cut

sub getFlat{
    my ($self) = @_;
    return $self->getFieldValue('flat');
}

#######################################################

=item B<setFlat>

$obj->setFlat($value);

Set the value of the flat field

=cut

sub setFlat{
    my ($self, $value) = @_;
    $self->setFieldValue('flat', $value);
}


#######################################################

=item B<getAttach>

my $string = $obj->getAttach();

Get the value of the attach field

=cut

sub getAttach{
    my ($self) = @_;
    return $self->getFieldValue('attach');
}

#######################################################

=item B<setAttach>

$obj->setAttach($value);

Set the value of the attach field

=cut

sub setAttach{
    my ($self, $value) = @_;
    $self->setFieldValue('attach', $value);
}


#######################################################

=item B<getShortDesc>

my $string = $obj->getShortDesc();

Get the value of the shortDesc field

=cut

sub getShortDesc{
    my ($self) = @_;
    return $self->getFieldValue('shortDesc');
}

#######################################################

=item B<setShortDesc>

$obj->setShortDesc($value);

Set the value of the shortDesc field

=cut

sub setShortDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('shortDesc', $value);
}


#######################################################

=item B<getLongDesc>

my $string = $obj->getLongDesc();

Get the value of the longDesc field

=cut

sub getLongDesc{
    my ($self) = @_;
    return $self->getFieldValue('longDesc');
}

#######################################################

=item B<setLongDesc>

$obj->setLongDesc($value);

Set the value of the longDesc field

=cut

sub setLongDesc{
    my ($self, $value) = @_;
    $self->setFieldValue('longDesc', $value);
}


#######################################################

=item B<getPostNum>

my $string = $obj->getPostNum();

Get the value of the postNum field

=cut

sub getPostNum{
    my ($self) = @_;
    return $self->getFieldValue('postNum');
}

#######################################################

=item B<setPostNum>

$obj->setPostNum($value);

Set the value of the postNum field

=cut

sub setPostNum{
    my ($self, $value) = @_;
    $self->setFieldValue('postNum', $value);
}


#######################################################

=item B<getLastPostTime>

my $string = $obj->getLastPostTime();

Get the value of the lastPostTime field

=cut

sub getLastPostTime{
    my ($self) = @_;
    return $self->getFieldValue('lastPostTime');
}

#######################################################

=item B<setLastPostTime>

$obj->setLastPostTime($value);

Set the value of the lastPostTime field

=cut

sub setLastPostTime{
    my ($self, $value) = @_;
    $self->setFieldValue('lastPostTime', $value);
}


#######################################################

=item B<getBoardkey>

my $string = $obj->getBoardkey();

Get the value of the boardkey field

=cut

sub getBoardkey{
    my ($self) = @_;
    return $self->getFieldValue('boardkey');
}

#######################################################

=item B<setBoardkey>

$obj->setBoardkey($value);

Set the value of the boardkey field

=cut

sub setBoardkey{
    my ($self, $value) = @_;
    $self->setFieldValue('boardkey', $value);
}



=back

=cut
#######################################################

=item B<getStartDate>

my $string = $obj->getStartDate();

Get the value of the start_date field

=cut

sub getStartDate{
    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

#######################################################

=item B<setStartDate>

$obj->setStartDate($value);

Set the value of the start_date field

=cut

sub setStartDate{
    my ($self, $value) = @_;
    $self->setFieldValue('start_date', $value);
}



=back

=cut

#######################################################

=item B<getEndDate>

my $string = $obj->getEndDate();

Get the value of the end_date field

=cut

sub getEndDate{
    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

#######################################################

=item B<setEndDate>

$obj->setEndDate($value);

Set the value of the end_date field

=cut

sub setEndDate{
    my ($self, $value) = @_;
    $self->setFieldValue('end_date', $value);
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

