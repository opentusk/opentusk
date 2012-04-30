#!/usr/local/bin/perl
use strict;
my $dir = "./vzic-1.3/zoneinfo";

unless(opendir(THE_DIR, $dir)) {die "Can't open $dir: $!\n";}
my @subDirs = grep {!/^\./ && !/Vzic/} readdir(THE_DIR);
closedir(THE_DIR);


foreach my $subDir (@subDirs) {
	unless(opendir(SUB_DIR, "$dir/$subDir")) {print "Unable to read $subDir: $!\n"; next;}
	print "Reading $subDir\n";
	my @files = grep !/^\./, readdir(SUB_DIR);
	closedir(SUB_DIR);
	foreach (@files) {
		my $readFileName = "$dir/$subDir/$_";
		my $fileName = "$subDir.$_";
		$fileName =~ s/\.ics$/\.tz/;
		print "\tGenerating $fileName";
		unless(open(NEW_FILE, ">../$fileName")) {print "Unable to open new file for write: $!\n";}
		elsif(!open(OLD_FILE, $readFileName)) {print "Unable to open $readFileName for read: $!\n"; close(NEW_FILE);}
		else {
			my $recording = 0;
			while(<OLD_FILE>) {
				if(/BEGIN:VTIMEZONE/) {$recording = 1;}
				elsif(/END:VTIMEZONE/) {$recording = 0;}
				elsif($recording) {
					if(!/TZID/) {
						print NEW_FILE $_;
					}
				}
			}
			close(OLD_FILE);
			close(NEW_FILE);
			print "\n";
		}
	}
}
