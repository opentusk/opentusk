# Copyright 2013 Albert Einstein College of Medicine of Yeshiva University 
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

package Zoo::Stash;

use strict;
use warnings;
our $AUTOLOAD;

sub new # (%params)
{
	return bless { @_ }, ref || $_ for shift;
}

sub AUTOLOAD : lvalue # lvalue-chain accessor
{
	$AUTOLOAD =~ /::(.*?)$/;
	if (@_ == 1) {
		$_[0]->{$1};
	} else {
		$_[0]->{$1} = $_[1];
		$_[0];
	}
}

sub DESTROY
{
	%{$_[0]} = ();
}

1;
