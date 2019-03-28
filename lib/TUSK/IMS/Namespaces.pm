# Copyright 2019 Tufts University
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

package TUSK::IMS::Namespaces;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

our (@ISA, @EXPORT_OK, %EXPORT_TAGS);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
        manifest_ns
        lom_ns
        qti_quiz_ns
        qti_quiz_questions_ns
        xml_schema_instance_ns

    );

    %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );
}

sub manifest_ns {
    return "http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1/";
}

sub lom_ns {
    return "http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource";
}

sub qti_quiz_ns {
    return "http://canvas.instructure.com/xsd/cccv1p0";

}
sub xml_schema_instance_ns {
    return "http://www.w3.org/2001/XMLSchema-instance";
}

sub qti_quiz_questions_ns  {
    return "http://www.imsglobal.org/xsd/ims_qtiasiv1p2";
}

1;

__END__

=head1 NAME

TUSK::Namespaces - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Namespaces> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Namespaces;

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
