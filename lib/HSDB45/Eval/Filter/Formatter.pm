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


package HSDB45::Eval::Filter::Formatter;

use strict;
use HSDB45::Eval;
use HSDB45::Eval::Formatter;
use HSDB45::StyleSheet;

sub new {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {};
    bless($self, $class);
    $self->{-eval_object} = shift();
    $self->{-filter_id} = shift();
    return $self;
}

sub new_from_path {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {};
    bless($self, $class);
    my $path = shift();
    $path =~ /\/(.+)\/(.+)\/(.+)/;
    $path = '/' . $1 . '/' . $2;
    $self->{-filter_id} = $3;
    $self->{-eval_object} = HSDB45::Eval->lookup_path($path);
    return $self;
}

sub object {
    my $self = shift();
    return $self->{-eval_object};
}

sub filter_id {
    my $self = shift();
    return $self->{-filter_id};
}

sub get_xml_text {
    my $self = shift();
    my $formatter = HSDB45::Eval::Formatter->new($self->object());
    my $stylesheet = HSDB45::StyleSheet->new(_school => $self->object()->school(), _id => $self->filter_id());
    my $transformed_text = $stylesheet->apply_stylesheet($formatter->get_xml_text());
    $transformed_text =~ s/\<\?xml version=\"1\.0\"\?>//;
    return $transformed_text;
}

1;
