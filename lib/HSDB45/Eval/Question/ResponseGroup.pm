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


package HSDB45::Eval::Question::ResponseGroup;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

# Description: Constructor
# Input: HSDB45::Eval::Question::Results object, label for group
# Output: Newly created HSDB45::Eval::Question::ResponseGroup object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub init {
    my $self = shift;
    $self->{-parent_results} = shift;
    $self->{-label} = shift;
    $self->{-responses} = {};
    return $self;
}

sub label { 
    my $self = shift;
    return $self->{-label};
}

sub parent_results {
    my $self = shift;
    return $self->{-parent_results};
}

sub add_response {
    my $self = shift;
    my @valids = grep { ref $_ && $_->isa ('HSDB45::Eval::Question::Response') } @_;
    for (@valids) { $self->{-responses}{$_->user_code} = $_ }
}

sub responses {
    my $self = shift;
    return values %{$self->{-responses}};
}

sub interpreted_responses {
    my $self = shift;
    return grep { defined } map { $_->interpreted_response() } $self->responses();
}

sub undef_responses {
    my $self = shift;
    return grep { not defined $_->interpreted_response() } $self->responses();
}

sub response {
    my $self = shift;
    my $user_code = shift;
    return $self->{-responses}{$user_code};
}


sub statistics {
    my $self = shift();
    return HSDB45::Eval::Question::ResponseStatistics->new($self);
}

1;
__END__
