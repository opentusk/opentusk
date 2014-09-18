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


package TUSK::Application::HTML::Strip;

use strict;
use utf8;
use HTML::Strip;


sub new {
	my ($class, $args) = @_;
	my $self = { stripObj => HTML::Strip->new() };
	bless($self, $class);
	return $self;
}


#############################################
# function to remove html tags
# makes sure that utf8 characters don't get mangled
#############################################
sub removeHTML {
    my ($self, $text) = @_;
    return '' unless $text;
    $self->{stripObj}->set_decode_entities(0);
    $text = $self->{stripObj}->parse($text);
    utf8::decode($text);
    $self->{stripObj}->eof;
    return $text;
}

#############################################
# return any given string in text only (no HTML tags)
# if over passed limit (default= 50), truncate 
# and add "..."
#############################################
sub truncateAndRemoveHTML {
    my ($self, $text, $maxCharSize) = @_;
    $maxCharSize ||= 50;

    if ($text) {
	$text = $self->removeHTML($text);
    }

    return (length($text) > ($maxCharSize - 3))  ? substr($text, 0, ($maxCharSize - 3)) . ' ...' : $text;
}

1;
