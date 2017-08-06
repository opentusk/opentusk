#!/usr/bin/env perl

# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use 5.008;
use strict;
use warnings;
use utf8;
use version;
use Carp;
use Cwd qw(abs_path);
use Getopt::Long;
use FindBin;
use File::Spec::Functions;

our $VERSION = qv('0.0.1');

exit main(@ARGV) unless caller;

sub usage {
    return <<END_USAGE;
Usage: perl bin/bootstrap_carton.pl

Bootstrap to use cpanminus, local::lib and Carton to install
required dependencies on a fresh install with system perl.
END_USAGE
}

sub main {
    local @ARGV = @_;

    # parse options
    my ($help);
    GetOptions(
        'help' => \$help,
    );

    if ($help) {
        print usage;
        return 0;
    }

    my $curdir = abs_path;
    eval {
        my $base_dir = abs_path(catfile($FindBin::Bin, '..'));
        my $local_dir = catfile($base_dir, 'local');
        my $bin_dir = catfile($local_dir, 'bin');
        chdir $base_dir or confess "Could not chdir $base_dir: $!";
        if (! -d "$local_dir") {
            mkdir $local_dir or confess "Could not mkdir $local_dir";
        }
        if (! -d "$bin_dir") {
            mkdir $bin_dir or confess "Could not mkdir $bin_dir";
        }
        bootstrap($local_dir, $bin_dir);
    };
    if ($@) {
        chdir $curdir;
        confess $@;
    }

    chdir $curdir;
    return 0;
}

sub bootstrap {
    my ($local_dir, $bin_dir) = @_;
    my $cpanm = catfile($bin_dir, 'cpanm');
    my $carton = catfile($bin_dir, 'carton');
    if (! -f $cpanm) {
        run_or_die('curl', '--location', '--insecure',
                   '--output' => $cpanm, "http://cpanmin.us");
        chmod 0755, $cpanm;
    }

    run_or_die( $cpanm, '--notest', '--local-lib-contained' => $local_dir,
                qw(App::cpanminus App::local::lib::helper Carton) );

    run_or_die($carton, 'install');
}

sub run_or_die {
    my @args = @_;
    system(@args) == 0
        or confess "Error while running: " . join(q( ), @args);
    return;
}
