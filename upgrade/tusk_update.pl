#!/usr/bin/perl
use strict;
use IO::Handle;
use Getopt::Long;
autoflush STDOUT 1;

my $revisionToUpgradeTo;
my $revisionToUpgradeFrom = ".5";
my $notesOnly;
my $displayHelp = 0;
my %possibleVersions;

sub printHelp();
sub searchForUpgradeFilesOnOS($);

GetOptions("revision"   =>\$revisionToUpgradeTo,
           "notes-only" =>\$notesOnly,
           "help"       =>\$displayHelp,
          );

if($displayHelp) {printHelp();}

searchForUpgradeFilesOnOS(\%possibleVersions);

#Check to see if the user told us what version to go to
while(! $revisionToUpgradeTo) {
  print "You did not specifiy a version to upgrade to.\n";
  print "Enter a version to upgrade to (l to list): ";
  $revisionToUpgradeTo = <STDIN>;
  chomp $revisionToUpgradeTo;
  if($revisionToUpgradeTo eq 'l') {
    foreach (sort {$a <=> $b} keys %possibleVersions) {print "\t1.$_\n";}
  }
}

#Check to make sure that version exists

#Check to see if we can figure out what version we are on
#If we did not get a version prompt the user

#Check for the TUSK libraries and an already installed DB.

foreach my $version (keys %possibleVersions) {
  open(A_FILE, $possibleVersions{$version}{'fileName'}) || die "Could not open upgrade file $possibleVersions{$version}{'fileName'} : $!\n";
    my $commentOrSub = 'comment';
    while(<A_FILE>) {
      if(/^__PERL__$/) {$commentOrSub = 'sub';}
      else             {push @{$possibleVersions{$version}{$commentOrSub}}, $_;}
    }
  close(A_FILE);
}


#Print out all of the release notes and get the sql functions
foreach my $version (sort {$a <=> $b} keys %possibleVersions) {
  if(($version > $revisionToUpgradeFrom) && ($version <= $revisionToUpgradeTo)) {
    unless($notesOnly) {system('clear');}
    print "Currently Upgrading to 1.$version:\n";
    foreach (@{$possibleVersions{$version}{'comment'}}) {print "\t$_";}
    print "\n-----------------------------------------------------------------------------------------------------\n";
  } elsif($version > $revisionToUpgradeTo) {
    print "You can upgrade to 1.$version\n";
  }
}

#Confirm the upgrade
#Execute any sql statements


sub printHelp() {
  print "$0 - program used to upgrade the sql database and display the release notes of TUSK\n";
  print "\n";
  print "Options:\n";
  print "\t--help\t\tPrint this message.\n";
  print "\t--notes-only\tOnly display the release notes (do not upgrade the database\n";
  print "\t--revision\tUpgrade to this revision\n";
  print "\n\n";
}

sub getMysqlInfo() {
  print "please enter the mysql servername: ";
  my $mysqlHost = <STDIN>;
  chmop $mysqlHost;

  print "Please enter the mysql username: ";
  my $username = <STDIN>;
  print "\n";
  chomp $username;

  print "Please enter the mysql password: ";
  system("stty -echo");
  my $password = <STDIN>;
  print "\n";
  system("stty echo");
  chomp $password;

  return ($mysqlHost, $username, $password);
}

sub searchForUpgradeFilesOnOS($) {
  my $hashRef = shift;

  opendir(THE_DIR, ".") || die "Could not read the current directory\n";
    my @upgrade_file = grep /\.txt/, readdir THE_DIR;
  closedir(THE_DIR);

  foreach my $fileName (@upgrade_file) {
    my $version = $fileName;
    $version =~ s/tusk-1_(.*)\.txt/$1/;
    $version =~ s/_/\./g;
    ${$hashRef}{$version}{'fileName'} = $fileName;
  }
}
