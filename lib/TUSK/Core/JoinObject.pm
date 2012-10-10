package TUSK::Core::JoinObject;

=head1 NAME

B<TUSK::Core::JoinObject> - allow for joining tables

=head1 DESCRIPTION

Class that makes it possible to get fields from other tables


=cut

use strict;

BEGIN {
    require Exporter;
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.9 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;
use Carp qw(cluck croak confess); 
use Data::Dumper;

# Non-exported package globals go here
use vars ();

=begin 

my $join_obj = TUSK::Core::JoinObject->new($objclass,$args);

$objclass is the name of the object to return

$args is a hashref of different parameters

Here are the possible keys:

=item B<joinkey> (scalar)

the key on the table specified in $objclass on which the join should use.  If not defined, then takes the primary key field from $objclass.

=item B<origkey> (scalar)

the key on the table original table (ie the table specified in the SQLRow class that is using this join object).  If not defined, takes the value of joinkey from above.

=item B<jointype> (scalar)

Let you choose different types of joins.  The default is 'left join'.

=item B<cond> (scalar)

extra cond to be used in query.  You could also use the cond parameter in a TUSK::Core::SQLRow::lookup method (this is more preferred).

=item B<joincond> (scalar)

extra cond to be used in a JOIN's "on" clause.

=item B<alias> (scalar)

alias for join table.

=item B<objtree> (array ref)

an array ref that shows the relationship $objclass has in relation to the original SQLRow class.  TUSK::Core::SQLRow::processRow uses this to figure out where joined objects should be pushed to.  Check SQLRow perldoc for more info.

=item B<fields> (array ref)

list of fields that should be queried.  Note this is hardly ever used (default is to get all fields).

=cut

sub new {
    #
    # Does the default creation stuff
    #

    my ($incoming, $objclass, $args)  = @_;

    my $class = ref($incoming) || $incoming;

    # skeleton
    my $self = {
	_fields => [],
	_cond => '',
	_objclass => '',
	_obj => '',
	_joinkey => '',
	_joincond => '',
	_jointype => '',
	_alias => '',
	_origkey => '',
	_objtree => [],
    };

    bless $self, $class;

    $self->setObjClass($objclass) if ($objclass);

    $self->_processArgs($args);

    return ($self);
}

sub _processArgs{
    my ($self, $args) = @_;

    $self->setJoinKey($args->{joinkey});
    $self->setOrigKey($args->{origkey});
    $self->setJoinType($args->{jointype});

    $self->setCond($args->{cond}) if ($args->{cond});
    
    $self->setJoinCond($args->{joincond}) if ($args->{joincond});
    
    $self->setAlias($args->{alias}) if ($args->{alias});
    
    $self->setObjTree($args->{objtree}) if (exists($args->{objtree}));
    
    if ($self->getObj){
	$self->getObj()->setDatabase($args->{database}) if ($args->{database});
    }

    
    if ($args->{fields}){
	$self->setFields($args->{fields});
    }elsif ($self->getObj){
	$self->setFields($self->getObj()->getNonSkipFields());
    
    }
}

=head1 METHODS

=cut

#######################################################

=item B<setFields>

$obj->setFields($arraryref);

set the arrayref fields

=cut

sub setFields{
    my ($self, $arrayref) = @_;
    if (ref($arrayref) eq "SCALAR"){
	$arrayref = [$arrayref];
    }
    $self->{_fields} =  $arrayref;
}
#######################################################

=item B<getFields>

$arrayref = $obj->getFields();

get the arrayref of the fields

=cut

sub getFields{
    my ($self) = @_;
    return $self->{_fields};
}

#######################################################

=item B<setCond>

$obj->setCond($value);

set the value of the cond

=cut

sub setCond{
    my ($self, $value) = @_;
    $self->{_cond} =  $value;
}

#######################################################

=item B<getCond>

$string = $obj->getCond();

get the value of the cond

=cut

sub getCond{
    my ($self) = @_;
    return $self->{_cond};
}

#######################################################

=item B<setJoinCond>

$obj->setJoinCond($value);

set the value of the join cond

=cut

sub setJoinCond{
    my ($self, $value) = @_;
    $self->{_joincond} =  $value;
}

#######################################################

=item B<getJoinCond>

$string = $obj->getJoinCond();

get the value of the join cond

=cut

sub getJoinCond{
    my ($self) = @_;
    return $self->{_joincond};
}

#######################################################

=item B<setAlias>

$obj->setAlias($value);

set the value of the alias

=cut

sub setAlias{
    my ($self, $value) = @_;
    $self->{_alias} =  $value;
}

#######################################################

=item B<getAlias>

$string = $obj->getAlias();

get the value of the alias

=cut

sub getAlias{
    my ($self) = @_;
    return $self->{_alias};
}

#######################################################

=item B<setJoinKey>

$obj->setJoinKey($value);

set the value of joinkey

=cut

sub setJoinKey{
    my ($self, $value) = @_;
    if ($value){
	$self->{_joinkey} =  $value;
    }else{
	$self->{_joinkey} = $self->getObj()->getPrimaryKey();
    }
}

#######################################################

=item B<getJoinKey>

$string = $obj->getJoinKey();

get the value of joinkey

=cut

sub getJoinKey{
    my ($self) = @_;
    return $self->{_joinkey};
}


#######################################################

=item B<setJoinType>

$obj->setJoinType($value);

set the value of jointype

=cut

sub setJoinType{
    my ($self, $value) = @_;
    if ($value){
	$self->{_jointype} =  $value;
    }else{
	$self->{_jointype} = 'left';
    }
}

#######################################################

=item B<getJoinType>

$string = $obj->getJoinType();

get the value of jointype

=cut

sub getJoinType{
    my ($self) = @_;
    return $self->{_jointype};
}


#######################################################

=item B<setOrigKey>

$obj->setOrignKey($value);

set the value of origkey (if the key names don't match up)

=cut

sub setOrigKey{
    my ($self, $value) = @_;
    if ($value){
	$self->{_origkey} =  $value;
    }else{
	$self->{_origkey} = $self->getJoinKey();
    }
}

#######################################################

=item B<getOrigKey>

$string = $obj->getOrigKey();

get the value of origkey

=cut

sub getOrigKey{
    my ($self) = @_;
    return $self->{_origkey};
}

#######################################################

=item B<setObjTree>

$obj->setObjTree($value);

set the array ref of objTree (look at SQLRow perldoc for more info)

=cut

sub setObjTree{
    my ($self, $value) = @_;
    if (ref ($value) eq 'ARRAY'){
	$self->{_objtree} =  $value;
    }
}

#######################################################

=item B<getObjTree>

$string = $obj->getObjTree();

get the array ref of objTree (look at SQLRow perldoc for more info)

=cut

sub getObjTree{
    my ($self) = @_;
    return $self->{_objtree};
}

#######################################################

=item B<setObjClass>

$obj->setObjClass($value);

set the value of the objclass

=cut

sub setObjClass{
    my ($self, $value) = @_;
    $self->{_objclass} =  $value;
    eval "require $value";
    $self->setObj($value->new());
}

#######################################################
  
=item B<getObjClass>
  
$string = $obj->getObjClass();
  
get the value of the objclass
  
=cut
  
sub getObjClass{
	my ($self) = @_;
    return $self->{_objclass};
}

#######################################################

=item B<getObjectKey>

$string = $obj->getObjectKey();

get the value of the key to be used for _join_objects hash ref in sql row.
usually returns _objclass, unless an alias is defined

=cut

sub getObjectKey{
    my ($self) = @_;

	if ($self->getAlias()){
		return $self->getAlias();
	}
	else {
		return $self->getObjClass();
	}
}

#######################################################

=item B<setObj>

$obj->setObj();

set the obj object

=cut

sub setObj{
    my ($self, $value) = @_;
    $self->{_obj} = $value;
}

#######################################################

=item B<getObj>

$class = $obj->getObj();

get the obj object

=cut

sub getObj{
    my ($self) = @_;
    return $self->{_obj};
}

#######################################################

=item B<getDatabase>

$string = $obj->getDatabase();

get the database used by the joined obj

=cut

sub getDatabase{
    my ($self) = @_;
    return $self->getObj()->getDatabase();
}

#######################################################

=item B<getTablename>

$string = $obj->getTablename();

get the tablename used by the joined obj

=cut

sub getTablename{
    my ($self, $with_alias) = @_;

	if($self->getAlias()){
		if(defined $with_alias){
			return $self->getObj()->getTablename()
				. " AS " 
				. $self->getAlias();
		}
		else {
			return $self->getAlias();
		}
	} 
	else {
		return $self->getObj()->getTablename();
	}
}

#######################################################

=item B<dump>

$string = $obj->dump();

return the data dumper of this obj

=cut

sub dump{
    my ($self) = @_;
    return (Dumper($self));
}

sub getOnCond{
    my ($self, $orig_tablename) = @_;

    my $origKey = ($self->getOrigKey() =~ /\./) ? $self->getOrigKey() : $orig_tablename . "." . $self->getOrigKey(); # check to see if a table was already given
    
    my $oncond .= $self->getTablename . "." 
	. $self->getJoinKey() . "=" . $origKey;
    
    if($self->getJoinCond()){
	$oncond .= " and " . $self->getJoinCond();
    }
		
    return $oncond;
}


1;
