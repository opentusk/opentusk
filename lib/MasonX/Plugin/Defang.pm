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
  my $skip = 0;

  my $df = HTML::Defang->new();
  # Defanging causes problems when trying to save and load evaluations
  # because it mangles the password. I've inserted special logic here
  # to take care of the eval case, but I think it would be better to
  # only defang fields as needed. The current implementation is
  # overkill. -- Mike Prentice
  # Update: Added special logic for password resets as well, which were also
  # being defanged.
  foreach my $arg (@$args) {
    if ($skip) {
      $skip = 0;
    } else {
      if ($arg eq 'submit_password' or $arg eq 'load_password' or
         $arg eq 'oldpassword' or $arg eq 'newpassword' or
         $arg eq 'newpassword2') {
        $skip = 1;
      } else {
        if (ref $arg eq 'ARRAY') {
          foreach my $subarg (@$arg) {
            next if $subarg eq '0';
            $subarg = $df->defang($subarg);
          }
        } else {
          next if $arg eq '0';
          $arg = $df->defang($arg);
        }
      }
    }
  }
}
1;
