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


package HSDB45::Versioner;

use strict;
use Digest::MD5;

sub new {
    my $incoming = shift;
    my $class = ref($incoming) || $incoming;
    my $self = bless({}, $class);
    $self->{-class} = shift or die "Did not specify a class to version";
    return $self;
}

sub get_mod_deps {
    my $self = shift();
    $self->generate_deps unless($self->{-mod_deps});
    return keys(%{$self->{-mod_deps}});
}

sub get_file_deps {
    my $self = shift();
    $self->generate_deps unless($self->{-file_deps});
    return keys(%{$self->{-file_deps}});
}

sub generate_deps {
    my $self = shift;
    my %mod_deps;
    my %file_deps;
    my @queue = ($self->{-class});

    while(@queue) {
	my $class = shift(@queue);
	eval "require $class" or die "could not load $class";
	die "$class has no get_mod_deps method" unless $class->can('get_mod_deps');
	die "$class has no get_file_deps method" unless $class->can('get_file_deps');
	die "$class has no version method" unless $class->can('version');

	foreach my $mod_dep ($class->get_mod_deps) {
	    unless($mod_deps{$mod_dep}) {
		push(@queue, $mod_dep);
		$mod_deps{$mod_dep} = 1;
	    }
	}

	foreach my $file_dep ($class->get_file_deps) {
	    die "$file_dep does not exist" unless -e $file_dep;
	    $file_deps{$file_dep} = 1;
	}
    }

    $self->{-mod_deps} = \%mod_deps;
    $self->{-file_deps} = \%file_deps;
}

sub get_version_code {
    my $self = shift;

    my (@mod_deps, @file_deps);
    eval {
	@mod_deps = sort $self->get_mod_deps;
	@file_deps = sort $self->get_file_deps;
    };
    if($@) {
	die "$@\t...problem generating version_code for ", $self->{-class};
    }

    my $ctx = Digest::MD5->new;
    $ctx->add($self->{-class}->version);
    $ctx->add(map { $_->version } @mod_deps);

    local $/;
    foreach my $file_dep (@file_deps) {
	open(FILE, "<$file_dep") or die "Could not open $file_dep in get_version_code";
	my $file_contents = <FILE>;
	$ctx->add($file_contents);
    }

    return $ctx->add($ctx->b64digest)->b64digest;
}

1;
