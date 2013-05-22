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

# This module captures mod_perl/mason sigpipe errors
# See: Apache::SIG from Apache 1.x
package TUSK::Apache2::SIGPIPE;

use strict;
use Apache2::RequestRec ();
use Apache2::Const -compile => qw( OK DECLINED );
use ModPerl::Util;



sub handler {
	my $r = shift;
	$SIG{PIPE} = \&PIPE unless ($r->main);
	return Apache2::Const::OK;
}

sub PIPE { 
	my($signal) = @_;
	if( $signal eq 'PIPE' ) {
		warn("Caught fixup signal ($signal) exiting child");
	} else {
		warn("Caught fixup signal ($signal)");
	}
	CORE::exit();
}

1;

__END__
