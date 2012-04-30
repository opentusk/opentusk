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


package HSDB4::SQLRow::Objective::PharmCategory;

use strict;

BEGIN {
    require HSDB4::SQLRow::Objective;
    require HSDB4::SQLRow::Content::PharmAgent;
    use vars qw($VERSION @ISA);
    @ISA = qw(HSDB4::SQLRow::Objective);
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

my $tablename = "epharm.objective";
my %cache = ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _blob_fields => {},
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

sub parent_objectives {
    #
    # Return the objectives this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_objectives}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'epharm.link_objective_objective'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_objectives} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_objectives}->parents();
}

sub child_objectives {
    #
    # Get the objective linked down from this objective
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_objectives}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'epharm.link_objective_objective'};
        # And use it to get a LinkSet of users
        $self->{-child_objectives} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_objectives}->children();
}

sub child_content {
    #
    # Get the content linked down from this objective
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'epharm.link_objective_content'};
        # And use it to get a LinkSet of users
        $self->{-child_content} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_content}->children();
}


1;
__END__
