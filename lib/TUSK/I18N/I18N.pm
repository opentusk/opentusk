package TUSK::I18N::I18N;
# Notes: turn on strict/warn
# Test if lang dir exists ?
# define defaults hash?

#use strict;
use warnings;
use Data::Dumper;
use Carp qw(longmess shortmess carp);
use TUSK::Constants;
use POSIX qw (setlocale LC_ALL);
use Apache2::RequestRec ();
#use base qw(Locale::TextDomain);
use Apache2::RequestUtil;
use Locale::TextDomain ();
##use Locale::Messages (:locale_h :libintl_h);
use Locale::Messages;
#require Exporter;
##use Exporter qw( import ); # avoid putting in @ISA
#my $r = Apache2::RequestUtil->request;
#@ISA = ('Exporter');
## need to forcefullfy export mason doesn't like the more polite EXPORT_OK
our @EXPORT = qw (__ __x __n __p __nx __xn  __px __np __npx $__ %__ 
             N__ N__n N__p N__np);
our @EXPORT_OK = qw (__ __x __n __p __nx __xn  __px __np __npx $__ %__ 
             N__ N__n N__p N__np);
             
# create some tags to limit name space pollution if desired
our %EXPORT_TAGS = (
		'basic'			=> [ qw(__ __x  __p)],
		'plurals'		=> [ qw( __n __nx __xn __np __npx) ],
		'context'		=> [ qw( __p ) ],
		'dummys'		=> [ qw( N__ N__n N__p N__np ) ]
		
);
# create a :all (from perldoc Export)
my %seen = ();
push @{$EXPORT_TAGS{all}}, grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;

# start by turning off gettext
BEGIN { $ENV{LANGUAGE} = $ENV{LANG} = "C"; }



=head1 NAME

TUSK::I18N::I18N - Internationalisation module.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

	This module extends the functionality of Locale::TextDomain and GNU's gettext.
	It basically exports macro functions into the caller's namespace. 
	These macro's act as interfaces to gettext's methods.
	Some common macros are:
	__()
	__x()

This class relys on Exporter's import method to get things going.

    use TUSK::I18N::I18N;    # exports all macro's
        or
    use TUSK::I18N::I18N qw(:all);
    
    use TUSK::I18N::I18N qw(:common);    # exports onli __() and __x()


=head1 EXPORT

	__() __x() __n() __p() __nx() __xn()  __px() __np() __npx() 
	$__() %__() N__() N__n() N__p() N__np()

=head1 SUBROUTINES/METHODS

=head2 new

	The new function called via the import method that is involked via 'use'.
	This method while not really needed for static localization will be needed
	for each child process in more dynamic language handling.

=cut
sub new {
	my $class = shift;
	my $self = {
			init		 	=> 0,
			debug			=> 0,
			serverObject	=> undef,  # apache2 server object
			requestObject	=> undef,	# apache2 request object
			catalogs		=> [],
			catalog		=> $TUSK::Constants::LexiconRoot,
			serverRoot		=> $TUSK::Constants::ServerRoot || '/usr/local/tusk/foo',
			localeDomain	=> 'messages', 	# default for gettext
			lang			=> 'en_US',
			localeMethod	=> 'static' # statis = sitewide, dynamin = user/header choice
	};
	bless $self, $class;
	$self->init();
	
	return $self;
}

=head2 init

	This method attempts to resolve POSIX setlocal language settings and
	the important defining of paths to the language specific mo (machine object)
	files.
	
=cut
sub init {
	my $self = shift;	
	$self->serverObject(Apache2::ServerUtil->server);
	$self->setLocaleDomain();
	$self->setCatalog();
	$self->setLanguage();
	$ENV{'LANG'} = $ENV{'LANGUAGE'} = $self->language;
	my $catalog = $self->catalog;
	my $domain = $self->localeDomain();
	Locale::TextDomain->import($domain,$catalog);
	Locale::Messages->textdomain($domain);
	Locale::Messages::bindtextdomain $domain => $catalog ;
	Locale::Messages->select_package('gettext_pp');
#	Locale::Messages->bind_textdomain_codeset $domain => 'utf-8';
	$self->{init} = 1;
}

=head2 import

	This is called when involking the 'use' statement.
	It is invollked as follows.
	
		use TUSK::I18N::I18N;  	# imports all @EXPORT methods/variables
		use TUSK::I18N::I18N (); # ignores this function
		use TUSK::I18N::I18N qw(:common) # exports a tag from %EXPORT_TAGS
	
	We redifine out gettext methods and export them into the callers namespace.
	
	Note:  I'm not sure yet why this nessessary when using base, perhaps it is needed 
			to get into the Mason command/component namespace.

=cut
sub import {
	use Carp;
    my $caller = caller;
    my $pkg = __PACKAGE__->new();
    my $r = Apache2::RequestUtil->request;
    my $s = Apache2::ServerUtil->server;
    my $port   = $r->get_server_port();
    $s->log_error("2 caller = $caller port $port");
    #	__() __x() __n() __p() __nx() __xn()  __px() __np() __npx() 
	#$__() %__() N__() N__n() N__p() N__np()
    my %methods = (
      __ 		=> sub {  return &Locale::TextDomain::__; },
      __x 		=> sub {  return &Locale::TextDomain::__x; },
      __n 		=> sub {  return &Locale::TextDomain::__n; }, 
      __p 		=> sub {  return &Locale::TextDomain::__p; }, 
      __nx 		=> sub {  return &Locale::TextDomain::__nx; }, 
      __xn 		=> sub {  return &Locale::TextDomain::__xn; }, 
      __px 		=> sub {  return &Locale::TextDomain::__px; }, 
      __np 		=> sub {  return &Locale::TextDomain::__np; }, 
      N__ 		=> sub {  return &Locale::TextDomain::N__;  }, 
      N__n 		=> sub {  return &Locale::TextDomain::N__n; }, 
      N__p 		=> sub {  return &Locale::TextDomain::N__p; }, 
      N__np 	=> sub {  return &Locale::TextDomain::N__np; } 
      # we currently don't support the below constructs for description see: man gettext
#      $__ 	=> sub {  return Locale::TextDomain::$__(shift); }, # perhaps manually prototype
#      %__ 	=> sub {  return Locale::TextDomain::%__(shift); }, 
     
    );
    
# figure out a way to get this working
#    foreach my $m (@EXPORT) {
#    	my $ref = &{Locale::TextDomain->$m;
#    	*{$caller.'::'.$m} = sub {  return $ref; };
#    } 
{
    no strict 'refs'; 
    foreach my $i (keys %methods) {
      *{$caller.'::'.$i} = $methods{$i};
    }
}
  
    
  }
=head2 logger

	Define our own logger function for debugging. Under mod_perl this should
	output to error_log using the server object or carp if from command line.

=cut

sub logger {
	my ($self,$msg) = @_;
	return unless($msg);
	if( $self->serverObject) {
		$self->serverObject->log_error($msg);
	} else {
		carp($msg);
	}
	
}
=head2 setLanguage

	Module to abstract how we set the language. There are typicaly three methods for 
	setting language.
		1) One glocale language for entire site
		2) Users browser controlled via HTTP Accept-Language header value.
		3) User choice using some pulldown menu.
	Currently we only support option #1 set in tusk.conf
=cut
sub setLanguage {
	my $self = shift;
	my $constKey = "SiteLang";
	my $lang = $self->_getI18NConstant($constKey) || 'C';
	if( $lang ) {
		$self->language($lang);
	}
}

=head2 language

	This is the setter and getter for the current language locale.

=cut
sub language {
	my $self = shift;
	my $key = 'lang';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
=head2 setCatalog

=cut

sub setCatalog {
	my $self = shift;
	my $constKey = "SiteLocale";
	
	my $catalog = $self->_getI18NConstant($constKey) || "lib/LocalData";
	my $docRoot = $self->serverRoot();
	$docRoot = $1 if( $docRoot =~ /(.*)\/$/ ); # strip trailing slash for concat below.
	if( $catalog !~ /^\// ) {
			$catalog = $self->serverRoot() . '/' . $catalog; 
		}
	$self->logger("setCatalog ($catalog)");
	return($self->catalog($catalog));
			
	}
=head2 setCatalogs

=cut
sub setCatalogs {
	my $self = shift;
	my $constKey = "SiteLocales";
	$self->logger("setCatalogs");
	my $catalogs = $self->_getI18NConstant($constKey) || [];
	my $docRoot = $self->serverRoot();
	$docRoot = $1 if( $docRoot =~ /(.*)\/$/ ); # strip trailing slash for concat below.
	foreach my $path (@$catalogs) {
		# concider all paths with leading '/' explicit all othere relitive to doc root
		if( $path !~ /^\// ) {
			$path = $self->serverRoot() . '/' . $path; 
		}
		$self->addCatalog($path);
	}
	$self->logger(Dumper($self->{catalogs}));
	return($self->catalogs());			
	}
=head2 addCatalog

=cut
sub addCatalog {
	my ($self,$path) = @_;
carp(Dumper($path));
	my $key = 'catalogs';
	$self->{$key} = [] unless(exists($self->{$key}));
	if( $path ) {
		push(@{$self->{$key}},$path);
	}
	$self->logger(Dumper($self->{$key}));
	$self->logger("ref = " . ref $self->{$key});
}
=head2 catalog

	This is the setter and getter for the current language locale.

=cut
sub catalog {
	my $self = shift;
	my $key = 'catalog';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
sub catalogs {
	my $self = shift;
	my $key = 'catalogs';
	$self->{$key} = shift if(@_);
#	$self->logger("test");
	#carp("catalogs: " . ref $self->{$key});
	return($self->{$key});
}
sub setLocaleDomain {
	my $self = shift;
	my $constKey = "SiteDomain";	
	my $domain = $self->_getI18NConstant($constKey) || 'messages';
	return($self->localeDomain($domain));			
	}
	
sub _getI18NConstant {
	my ($self,$key) = @_;
	return undef unless(defined($key));
	return undef unless ( exists($TUSK::Constants::Locale{$key}));
	return($TUSK::Constants::Locale{$key});
}
sub serverObject {
	my $self = shift;
	my $key = 'serverObject';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
sub serverRoot {
	my $self = shift;
	my $key = 'serverRoot';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
sub localeDomain {
	my $self = shift;
	my $key = 'localeDomain';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}


=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

your name here, C<< <your_email at somewhere.com> >>

=head1 BUGS



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TUSK::I18N::I18N


You can also look for information at:

=over 4

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 your name here.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of TUSK::I18N::I18N

__END__




package TUSK::I18N::I18N;
#use strict;
#use warnings;







1;
