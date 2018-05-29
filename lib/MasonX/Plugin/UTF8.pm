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


package MasonX::Plugin::UTF8;
use base qw(HTML::Mason::Plugin);
use utf8;

sub start_request_hook {
    my ( $self, $context ) = @_;
    my $args_ref = $context->args();
    foreach my $arg ( @{$args_ref} ) {
         if (ref($arg) eq "ARRAY" ) {
            my $max = scalar(@{$arg}) - 1;
            for (my $i = 0; $i<=$max; $i++){
                utf8::is_utf8($arg->[$i]) || utf8::decode($arg->[$i]);
            }
        } else {
            utf8::is_utf8($arg) || utf8::decode($arg);
        }
    }
    return;
}


1;
