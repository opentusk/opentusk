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


package TUSK::Core::JoinObject::DerivedTable;

=head1 NAME

B<TUSK::Core::JoinObject::DerivedTable> - allow for joining derived tables

=head1 DESCRIPTION

Class that makes it possible to join derived tables with your query (useful!)

So if you wanted to do:

select hsdb4.content.* 
from
    hsdb4.content inner join
    (select * 
     from tusk.link_search_query_content 
     where parent_search_query_id = '4856' 
     order by computed_score DESC 
     limit 0, 10
    ) as link_search_query_content on (link_search_query_content.child_content_id=content.content_id) 
order by computed_score DESC, content.created DESC, content.modified DESC

You can do:
    
    my $derivedtable = "select child_content_id, computed_score from tusk.link_search_query_content where parent_search_query_id = '4856' order by computed_score DESC limit 0, 10";

my $contentArray = TUSK::Core::HSDB4Tables::Content->new()->lookup(
    "",
    [
    'computed_score DESC',
    'content.created DESC',
    'content.modified DESC',
    ],
    '',
    '',
    [
    TUSK::Core::JoinObject::DerivedTable->new(
{
    jointype => 'inner', 
    alias => 'link_search_query_content',
    joinkey => 'child_content_id',
    origkey => 'content_id',
    derivedtable => $derivedtable,
}
),
    ]
    );

Make sense?

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::JoinObject;
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::JoinObject Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;
use Carp qw(cluck croak confess); 
use Data::Dumper;

# Non-exported package globals go here
use vars ();

sub new {
    #
    # Does the default creation stuff
    #

    my ($incoming, $args)  = @_;

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
	_derivedtable => '',
    };

    bless $self, $class;

    $self->_processArgs($args);

    $self->{_derivedtable} = $args->{derivedtable};

    return ($self);
}

# get the actual derived table sql

sub getDerivedTable{
    my ($self) = @_;

    return $self->{_derivedtable};
}

# get the on cond for the join

sub getOnCond {
    my ($self) = @_;

    my $oncond .= $self->getAlias() . "." . $self->getJoinKey() . "=" . $self->getOrigKey();
    
    if($self->getJoinCond()){
	$oncond .= " and " . $self->getJoinCond();
    }

    return $oncond;
}

1;


