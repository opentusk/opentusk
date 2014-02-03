# Copyright 2013 Tufts University 
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

package TUSK::Apache2::I18N;

use strict;
use warnings;
use Carp;
use Apache2::Const -compile => 'OK';
use Apache2::ServerUtil ();

sub post_config {
      my ($conf_pool, $log_pool, $temp_pool, $s) = @_;
      my $count = Apache2::ServerUtil::restart_count();
      carp("configuration is completed ($$) count [$count]");

      {
        # from http://search.cpan.org/~jswartz/HTML-Mason-1.50/lib/HTML/Mason/Admin.pod#External_Modules_Revisited
	# "Explicitly setting the package to HTML::Mason::Commands makes sure that any symbols that the loaded 
	# modules export (constants, subroutines, etc.) get exported into the namespace under which components run. 
	# Of course, if you've changed the component namespace, make sure to change the package name here as well.
	# Alternatively, you might consider creating a separate piece of code to load the modules you need. For example, 
	# you might create a module called MyApp::MasonInit::
	#

	  package HTML::Mason::Commands;      
	  use utf8;
	  use TUSK::I18N::I18N qw(:basic);
  
      } 
      return Apache2::Const::OK;
  }

1;
