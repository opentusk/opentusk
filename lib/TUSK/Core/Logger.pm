package TUSK::Core::Logger;

=head1 NAME

B<TUSK::Core::Logger> - Integration class for Perls Log4Perl

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Log::Log4perl qw(:easy);

BEGIN {
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
	@ISA = qw(Exporter);
	@EXPORT = qw( );
	@EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

my $config = '/usr/local/tusk/current/conf/log4perl.conf';

sub new {
	# Find out what class we are
	my $class = shift;
	$class = ref $class || $class;
	# Call the super-class's constructor and give it all the values
	my $self = {};
	bless $self, $class;
	# Finish initialization...
	return $self;
}

### Get/Set methods

#######################################################

=item B<initalize>

$obj->initalize();
    
This is mostly an internal method which will initalize the Log4Perl interface
    
=cut
    
sub initalize {
	my $self = shift;
	unless(Log::Log4perl->initialized()) {
		if(-f $config) {
			eval {
				Log::Log4perl->easy_init($ERROR);
				Log::Log4perl::init_and_watch($config, 2);
			};
			if($@) {
				warn("[TUSK::Core::Logger] Failed to initalize Log4Perl : $@\n");
			}
		} else {
			warn("[TUSK::Core::Logger] $config does not exist, unable to initalize Log::Log4perl\n");
		}
	}
}

sub logDebug {
	my $self = shift;
	my $message = shift;
	my $facility = shift;
	$self->logMessage($self->checkMessage($message), 'debug', $facility);
}

sub logInfo {
	my $self = shift;
	my $message = shift;
	my $facility = shift;
	$self->logMessage($self->checkMessage($message), 'info', $facility);
}

sub logWarn {
	my $self = shift;
	my $message = shift;
	my $facility = shift;
	$self->logMessage($self->checkMessage($message), 'warn', $facility);
}

sub logError {
	my $self = shift;
	my $message = shift;
	my $facility = shift;
	$self->logMessage($self->checkMessage($message), 'error', $facility);
}

sub logFatal {
	my $self = shift;
	my $message = shift;
	my $facility = shift;
	$self->logMessage($self->checkMessage($message), 'fatal', $facility);
}

sub checkMessage {
	my $self = shift;
	my $message = shift;
	if($message) {return $message;}
	return 'Requested to log blank message';
}

sub logMessage {
	my $self = shift;
	my $message = shift;
	my $level = shift;
	my $facility = shift;

	$self->initalize();
	my $tuskLogger;
	$facility ||= 'tusk';
	unless(Log::Log4perl->initialized()) {
		warn("[TUSK::Core::Logger] Unable to initalize Log::Log4perl to log message at level $level:\n\t$message\n");
	} else {
		$tuskLogger = Log::Log4perl->get_logger($facility);
		$message = $self->checkMessage($message);
		if($tuskLogger) {
			if($level eq 'debug')		{ $tuskLogger->debug($message); }
			elsif($level eq 'info')		{ $tuskLogger->info($message); }
			elsif($level eq 'warn')		{ $tuskLogger->warn($message); }
			elsif($level eq 'error')	{ $tuskLogger->error($message); }
			elsif($level eq 'fatal')	{ $tuskLogger->fatal($message); }
			else {
				# an invalid level was passed, not it and print to fatal
				warn("[TUSK::Core::Logger] Log level $level is invalid, logging to fatal.");
				$tuskLogger->fatal($message);
			}
		} else {
			warn("[TUSK::Core::Logger] Unable to get logger for facility $facility to log message at level $level:\n\t$message\n");
		}
	}
}

1;
