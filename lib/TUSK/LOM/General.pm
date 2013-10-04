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

package TUSK::LOM::General;

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use Types::Standard qw( ArrayRef Maybe );
use TUSK::LOM::Types qw( Identifier LangString LanguageCode Vocabulary );
use TUSK::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has identifier => (
    is => 'ro',
    isa => ArrayRef[Identifier],
    lazy => 1,
    builder => '_build_identifier',
);

has title => (
    is => 'ro',
    isa => Maybe[LangString],
    lazy => 1,
    builder => '_build_title',
);

has language => (
    is => 'ro',
    isa => ArrayRef[LanguageCode],
    lazy => 1,
    builder => '_build_language',
);

has description => (
    is => 'ro',
    isa => ArrayRef[LangString],
    lazy => 1,
    builder => '_build_description',
);

has keyword => (
    is => 'ro',
    isa => ArrayRef[LangString],
    lazy => 1,
    builder => '_build_keyword',
);

has coverage => (
    is => 'ro',
    isa => ArrayRef[LangString],
    lazy => 1,
    builder => '_build_coverage',
);

has structure => (
    is => 'ro',
    isa => Maybe[Vocabulary],
    lazy => 1,
    builder => '_build_structure',
);

has aggregationLevel => (
    is => 'ro',
    isa => Maybe[Vocabulary],
    lazy => 1,
    builder => '_build_aggregationLevel',
);


############
# * Builders
############

sub _build_namespace { return lom_ns; }
sub _build_xml_content { return [ qw( identifier title language description
                                      keyword coverage structure
                                      aggregationLevel ) ]; }

sub _build_identifier { return []; }
sub _build_title { return; }
sub _build_language { return []; }
sub _build_description { return []; }
sub _build_keyword { return []; }
sub _build_coverage { return []; }
sub _build_structure { return; }
sub _build_aggregationLevel { return; }

#################
# * Class methods
#################

###################
# * Private methods
###################

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::LOM::General - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::LOM::General> v0.0.1.

=head1 SYNOPSIS

  use TUSK::LOM::General;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

TUSK modules depend on properly set constants in the configuration
file loaded by L<TUSK::Constants>. See the documentation for
L<TUSK::Constants> for more detail.

=head1 INCOMPATIBILITIES

This module has no known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please report problems to the
TUSK development team (tusk@tufts.edu) Patches are welcome.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tufts University

Licensed under the Educational Community License, Version 1.0 (the
"License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
