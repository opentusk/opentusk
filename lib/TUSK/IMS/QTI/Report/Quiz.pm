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

package TUSK::IMS::QTI::Report::Quiz;

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

use XML::Writer;
use Types::Standard qw( Int );
use TUSK::Types qw( Course Quiz );
use TUSK::IMS::Types qw( QTIQuiz );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Quiz;

use Moose;


####################
# * Class attributes
####################

has output => (
    is => 'ro',
    isa => 'IO::File',
    required => 1,
);

has course => (
    is => 'ro',
    isa => Course,
    required => 1,
);

has quiz => (
    is => 'ro',
    isa => Quiz,
    required => 1,
);

has total_points => (
    is => 'ro',
    isa => Int,
    required => 1,
);

has qti_quiz => (
    is => 'ro',
    isa => QTIQuiz,
    lazy => 1,
    builder => '_build_qti_quiz',
);

has writer => (
    is => 'ro',
    isa => 'XML::Writer',
    lazy => 1,
    builder => '_build_writer'
);


############
# * Builders
############

sub _build_writer {
    my $self = shift;
    return XML::Writer->new(
        OUTPUT => $self->output(),
        ENCODING => 'utf-8',
        DATA_MODE => 1,
        DATA_INDENT => 2,
        NAMESPACES => 1,
        FORCED_NS_DECLS => [
            qti_quiz_ns(),
            xml_schema_instance_ns(),
        ],
        PREFIX_MAP => {
            qti_quiz_ns() => '',
            xml_schema_instance_ns() => 'xsi',
        },
    );
}

sub _build_qti_quiz {
    my $self = shift;
    return TUSK::IMS::QTI::Quiz->new(course => $self->course(), quiz => $self->quiz(), total_points => $self->total_points());
}


#################
# * Class methods
#################

sub write_report {
    my $self = shift;
    my $writer = $self->writer;

    # Set up curriculum inventory with proper namespaces
    $writer->xmlDecl();
    $self->qti_quiz()->write_xml($writer);

    # Finish up
    $writer->end;
    return;
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
