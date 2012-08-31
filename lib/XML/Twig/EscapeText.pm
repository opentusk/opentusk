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


package XML::Twig::EscapeText;

use base('Exporter');

use strict;

use vars qw/@EXPORT/;

@EXPORT = qw/escape_text/;

# Description: Makes sure that some text is XML-escaped
# Input: The text
# Output: The text, but with &, <, >, and " escaped
sub escape_text {
    $_ = shift;
    return unless $_;
    s/\&/\&amp;/g;
    s/\</\&lt;/g;
    s/\>/\&gt;/g;
    # s/\"/\&quot;/g;
    # s/\'/\&apos;/g;
    s/\x92/\&apos;/g;
    s/\015/\n/g;
    s!\cM!\n!g;

    return $_;
}

1;
__END__
