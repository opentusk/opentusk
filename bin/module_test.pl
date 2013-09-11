#!/usr/bin/perl
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


use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Find;

my (@Missing, %modules);
my $removePrefix = "$FindBin::Bin/..";

# Find all the 'use MODULE*;' lines in the files and save the MODULE name.
sub wanted {
	local *fp;

	if ( -f $File::Find::name ) {
		return if ( $File::Find::name =~ m,/(core_dumps|logs|CVS|mason_cache)/, );
		open(fp, $File::Find::name) || die "Could not open file ($File::Find::name)\n";
		my $tempFileName = $File::Find::name;
		$tempFileName =~ s,$removePrefix/,,;
		while(<fp>) {
			chomp;
			if (/^require (\S+(::\S+)?)(.*)?;/) {
				$modules{$1}{$tempFileName}++ if ( length ($1) );
			}
			if (/^use (\S+(::\S+)?)(\s+qw\([^)]*\))?;/) {
				$modules{$1}{$tempFileName}++ if ( length ($1) );
			}
		}
		close fp;
	}
}

find(\&wanted, "$FindBin::Bin/..");

# Now do the eval { use MODULE; }' to make sure it works.
foreach my $module ( sort keys %modules ) {
	next if (
		$module =~ /^constant / ||
		$module =~ /^overload / ||
		$module =~ /^vars / ||
		$module =~ /^Win32::/ ||
		$module =~ /TUSK-Windows/
	);

	eval "use $module;";
	push @Missing, $module if ($@);
}

if(scalar @Missing > 0) {
	printf "Missing %d perl modules\n", scalar @Missing;
	foreach my $module (sort @Missing) {
		print "\t$module\t";
		print join(', ', sort keys %{$modules{$module}});
		print "\n";
	}

	printf "TUSK may not run with the the %d modules missing\n", scalar @Missing;
	print "\n";
}

