use warnings;
use strict;

use Win32::Process::Info;
use Net::SMTP;
use FindBin;
use POSIX qw(strftime);

my $maxRunBeforeMail = 15;          ## Number of times I can yield to a running process before I send an email
my $email = 'tuskdev@elist.tufts.edu';  ## Who should email be from?
my $email_subject = 'No Subject';
my $email_start_message = '';
my $sendMail = 1;
my $smtp_server = 'smtp.tufts.edu'; ## What is the email server?

unless (-d 'log') {
	mkdir('log') or die "Could not make 'log' directory: $!";
}

my $date = strftime ("%Y-%m", localtime);
my $logFile .= "log\\$FindBin::Script\.$date\.log";

my $lockFile = "$0\.lock";
my $countFile = "$0\.count";

open(LOG_FILE, ">>$logFile") || sendMail("Unable to open log file for append : $!");

END{
	close(LOG_FILE);
}

sub setEmailSubject{
	my ($subject) = @_;
	$email_subject = $subject;
}

sub setEmailStartMessage{
	my ($message) = @_;
	$email_start_message = $message;
}

sub exitSystem {
  my $lastMessage = shift;

  if($lastMessage) {
  	logMessage($lastMessage);
  }
  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;
  $year++;
  $mon++;
  logMessage("ended at $mday-$mon-$year $hour:$min:$sec\n");
  close(LOG_FILE);
  unlink($lockFile) || logMessage("Unable to remove my lock file : $!");
  exit();
}

sub logMessage {
  my $message = shift;
  print LOG_FILE "$$: $message\n";
  print "$$: $message\n";
}

sub sendMail {
  my ($message) = @_;
  if($sendMail) {
    my $smtp = Net::SMTP->new($smtp_server);

    if(!defined($smtp)) {exitSystem("SMTP connect failed");}
    $smtp->mail($email);
    $smtp->to($email);

    $smtp->data();
    $smtp->datasend("From: $email\n");
    $smtp->datasend("To: $email\n");
    $smtp->datasend("Subject: $email_subject\n");
    $smtp->datasend("\n");
    $smtp->datasend("$email_start_message: \n");
    $smtp->datasend($message);
    $smtp->dataend();
    $smtp->quit;
    exitSystem("Sent Message with message:\n$message");
  } 
  else {
  	exitSystem("Error Message is:\n$message\n");
  }

}

sub checkIfRunning { 
  my $processInfo = Win32::Process::Info->new();
  my $running = 0;
  my %runningPIDs;
  my $oldPID = 0;

  #Read the running pid (if exists)
  if(-e $lockFile) {
    open(LOCK_FILE, $lockFile) || sendMail("Could not read existing lock file\n");
      $oldPID = <LOCK_FILE>;
      chomp $oldPID;
    close(LOCK_FILE);
  }

  #Read the windows process table
  foreach my $proc ($processInfo->GetProcInfo()) {
    foreach ($proc) {
      if ($proc->{Name} =~ /^PERL.EXE$/i && defined($proc->{CommandLine}) && $proc->{CommandLine} =~ /\Q$0\E/i) {
      	$running++;
      }
      $runningPIDs{$proc->{ProcessId}}++;
    }
  }
	
  #If an old process might have been running
  if($oldPID) {
    if(exists($runningPIDs{$oldPID})) {
      logMessage("Old process ($oldPID) still running");
      
      # Check to see if we have waited enough times (if so email)
      my $count = 0;
      open(COUNT, "$countFile") || sendMail("Unable to open count file to read : $!"); 
        
      $count = <COUNT>;
      close COUNT;
      if($count !~ /^\d*$/) {
      	$count = 0;
      }
      if($count > $maxRunBeforeMail) {
        printToCountFile(0);
        sendMail("ppt_batch has been run at least $maxRunBeforeMail times since the lock file was created.\nPlease check on this.");
      } 
      else {
        $count++;
        printToCountFile($count);
        exitSystem('');
      }
    }
    else {
    	logMessage("Old process $oldPID is no longer running... taking ownership");
    }
  }
  
  open(LOCK_FILE, ">$lockFile") || sendMail("Could not write to lock file ($lockFile) : $!");
  print LOCK_FILE $$;
  close(LOCK_FILE);
  
  if($running > 1) {
  	sendMail("Process is running!\n");
  }
}

sub printToCountFile {
  my $newNumber = shift;

  open(COUNT_FILE, ">$countFile") || sendMail("Unable to open count file to write : $!");

  print COUNT_FILE $newNumber;

  close(COUNT_FILE);
}
