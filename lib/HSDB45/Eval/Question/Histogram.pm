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


package HSDB45::Eval::Question::Histogram;

use strict;
#use XML::Twig;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.11 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub init {
    my $self = shift;
    $self->{-histogram} = {};
    my @choices = @{shift()};
    $self->{-choices} = [@choices];
    foreach my $choice (@choices) { $self->{-histogram}{$choice} = 0; }
    return $self;
}

sub add_response {
    my $self = shift;
    my $resp = shift;
    $self->{-histogram}{$resp}++;
}

sub bins {
    my $self = shift;
    return @{$self->{-choices}};
#    return sort( keys( %{$self->{-histogram}} ) );
}

sub bin_count {
    my $self = shift;
    my $resp = shift;
    return $self->{-histogram}{$resp};
}

1;
__END__
