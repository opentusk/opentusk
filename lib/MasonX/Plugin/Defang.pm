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


package MasonX::Plugin::Defang;
use base qw(HTML::Mason::Plugin);

use HTML::Defang;


sub start_request_hook {
	my ($self, $context) = @_;

	my $args = $context->args();
	return unless scalar @$args;

	my $m = $context->request();
	unless ($m->request_comp()->attr_if_exists('no_filter')) {
		clean_args($args);
	}
}


sub clean_args {
	my $args = shift;

	my $df = HTML::Defang->new();
	foreach my $arg (@$args) {
		if (ref $arg eq 'ARRAY') {
			foreach my $subarg (@$arg) {
				$subarg = $df->defang($subarg);
			}
		}
		else {
			$arg = $df->defang($arg);
		}
	}
}
1;
