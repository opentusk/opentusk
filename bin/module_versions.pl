#!/usr/bin/perl
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Find;

my (%modules);

# Find all the 'use MODULE*;' lines in the files and save the MODULE name.
sub wanted {
	local *fp;

	if ( -f $File::Find::name ) {
		return if ( $File::Find::name =~ m,/(core_dumps|logs|CVS|mason_cache)/, );
		open(fp, $File::Find::name) || die "Could not open file ($File::Find::name)\n";
		while(<fp>) {
			chomp;
			s/\(\)//;
			if (/^require (\S+(::\S+)?)(.*)?;/) {
				$modules{$1}++ if ( length ($1) );
			}
			if (/^use (\S+(::\S+)?)(\s+qw\([^)]*\))?;/) {
				$modules{$1}++ if ( length ($1) );
			}
		}
		close fp;
	}
}

find(\&wanted, "$FindBin::Bin/..");

# Now do the eval { use MODULE; }' to extract the version number
foreach my $module ( sort keys %modules ) {
	next if (
		$module =~ /^HSDB4/ ||
		$module =~ /TUSK/ ||
		$module =~ /^Win32::/
	);

	if ( $module =~ /^[A-Z]+/ ) {
		eval "use $module;";
	
		if ( ! $@) {
			my $v = '$' . $module . '::VERSION';
			my $ver = eval $v;

			printf "%-40s %s\n", $module, $ver if ( defined $ver );
		}
	}
}
