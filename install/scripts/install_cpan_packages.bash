#!/bin/bash

# Install with cpanm.
# This is a helper script useful to setup e.g. a Perlbrew environment
# for TUSK development.

# For now, does its work by scanning the yum script for Perl packages
# and adding XML::Twig.

grep -o 'perl([^\)]\+)' install_yum_packages.bash \
    | grep -o '[[:alnum:]:]\+' \
    | grep -v '^perl$' \
    | xargs cpanm

cpanm XML::Twig
