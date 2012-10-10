# Here we have subs that are used by the httpd.conf file.
# Hopefully this will make the conf file more readable by breaking things out?

package httpdconf;
use Sys::Hostname;
use Sys::MemInfo;
use Apache;
use TUSK::Constants;
use TUSK::Core::ServerConfig;
use strict;

sub setVariablesForServerEnvironment($);
sub defineSSLLocations();
sub defineAliases($);
sub defineLocations($);

#location options useable anywhere
my $perlscripts = qq{
  SetHandler	perl-script
  PerlCleanupHandler	Apache::SizeLimit
  Options	+ExecCGI
};
 
my $embperl_handler = qq{
  $perlscripts
  PerlHandler	HTML::Embperl
  DefaultType	text/html
};
 
my $mason_handler = qq{
  SetHandler	perl-script
  PerlHandler     TUSK::Mason
  Options	+ExecCGI
  DefaultType     text/html
};

my $mason_no_session_handler = qq{
  SetHandler    perl-script
  PerlHandler     TUSK::MasonNoSession
  Options       +ExecCGI
  DefaultType     text/html
};
 
my $hsdbauth = qq{
  AuthType	HSDB
  AuthName	HSDB
  PerlAuthenHandler	Apache::TicketAccess
  PerlAuthzHandler	Apache::AuthzHSDB
  require valid-user
};


my %serverDesignations = (
  'MYFQDN'             => 'PROD', # or TEST or DEV
);



sub setVariablesForServerEnvironment($) {
  my $hashOfVariablesRef = shift;

  ## Environment variables - prod, test or dev
  my $hostname = Sys::Hostname::hostname;

  ${$hashOfVariablesRef}{'developer'}            = undef;
  ${$hashOfVariablesRef}{'hsdbDatabaseUser'}     = TUSK::Core::ServerConfig::dbReadUser();
  ${$hashOfVariablesRef}{'hsdbDatabasePassword'} = TUSK::Core::ServerConfig::dbReadPassword();
  ${$hashOfVariablesRef}{'data_location'}        = '/data';
  ${$hashOfVariablesRef}{'html_location'}        = "${$hashOfVariablesRef}{'data_location'}/html";
  ${$hashOfVariablesRef}{'tusk_base'}            = "/usr/local/tusk";
  ${$hashOfVariablesRef}{'main_port'}            = 80;
  ${$hashOfVariablesRef}{'secure_port'}          = 443;
  ${$hashOfVariablesRef}{'loglevel'}             = 'error';
  ${$hashOfVariablesRef}{'apacheUser'}           = 'apache';
  ${$hashOfVariablesRef}{'apacheGroup'}          = 'apache';
  ${$hashOfVariablesRef}{'server_admin'}         = $TUSK::Constants::SupportEmail;
  ${$hashOfVariablesRef}{'allowStatusFrom'}      = '127.0.0.1';
  ${$hashOfVariablesRef}{'embperl_mail_server'}  = 'smtp.tufts.edu';
  ${$hashOfVariablesRef}{'elephantLogo'}         = '/graphics/logo-prod.gif';
  ${$hashOfVariablesRef}{'database_address'}     = TUSK::Core::ServerConfig::dbReadHost();
  ${$hashOfVariablesRef}{'http_exec'}            = '/usr/local/apache/bin/httpd';
  ${$hashOfVariablesRef}{'use_shibboleth'}       = $TUSK::Constants::useShibboleth;
  ${$hashOfVariablesRef}{'embperlDebug'}         = 0;

  unless(exists($serverDesignations{$hostname})) {
    warn "Error: I do not know what type of machine $hostname is!\n\tPlease edit httpdconf.pm and set the machine name in %serverDesignations.\n";
    return(-1);
  } elsif ($serverDesignations{$hostname} eq 'PROD') {
    unless(exists($ENV{SILENT})) {warn "Setting up production environment!\n";}
    ## roxie is the production machine
    ## the server name is the address to redirect between secure and non-secure
    ${$hashOfVariablesRef}{'server_name'}      = $TUSK::Constants::Domain;
  }
  elsif ($serverDesignations{$hostname} eq 'TEST') {
    unless(exists($ENV{SILENT})) {warn "Setting up test environment!\n";}
    ${$hashOfVariablesRef}{'elephantLogo'}     = '/graphics/logo-test.gif';
    ${$hashOfVariablesRef}{'server_name'}      = 'test.' . $TUSK::Constants::Domain
      if ( $hostname eq 'bunter.tusk.tufts.edu' );
  }
  elsif ($serverDesignations{$hostname} eq 'DEV') {

    unless(exists($ENV{SILENT})) {warn "Setting up development environment!\n";}
    ${$hashOfVariablesRef}{'MaxClients'} = 10;
    my %developer_ports = (
     'devuser' => '####',
    );
    ## Determine if we are a developer
    ${$hashOfVariablesRef}{'developer'} = $ENV{'USER'};
    warn "Using $ENV{USER} as developer.\n";

    # If we are running in a non-global zone on Solaris 10, then
    # don't use the special ports, just use the defaults (80/443).
    # Need to make sure the user has net_privaddr ppriv(1) key set.
    my $zone;
    if ( -f '/sbin/zonename' ) {
      $zone = `/sbin/zonename`;
      chomp $zone;
    }
    if ( ! defined $zone || $zone eq 'global' ) {
      unless(exists($developer_ports{  ${$hashOfVariablesRef}{'developer'}  })) {
        warn "Error: DEV environment starting but could not find a developer to start the port.!\n" .
                   "\tTo fix look at your USER env variable and make sure there is a coorosponding developer_ports in httpdconf.pm\n\n";
        return(-2);
      }
      ${$hashOfVariablesRef}{'server_name'}      = 'dev.' . $TUSK::Constants::Domain;
      ${$hashOfVariablesRef}{'ip_address'}       = '127.0.0.1';
      ${$hashOfVariablesRef}{'ssl_cert_file'}    = "self.dev.cert";
      ${$hashOfVariablesRef}{'ssl_key_file'}     = "dev.key.pub";
      ${$hashOfVariablesRef}{'main_port'}        = $developer_ports{${$hashOfVariablesRef}{'developer'}};
      ${$hashOfVariablesRef}{'secure_port'}      = ${$hashOfVariablesRef}{'main_port'} + 100;
      ${$hashOfVariablesRef}{'secure_server'}    = "${$hashOfVariablesRef}{'server_name'}:${$hashOfVariablesRef}{'secure_port'}/";
      ${$hashOfVariablesRef}{'unsecure_server'}  = "${$hashOfVariablesRef}{'server_name'}:${$hashOfVariablesRef}{'main_port'}/";
    }

    ${$hashOfVariablesRef}{'tusk_base'}        = "$ENV{HOME}/tusk";
    ${$hashOfVariablesRef}{'loglevel'}         = 'debug';
    ${$hashOfVariablesRef}{'apacheUser'}       = ${$hashOfVariablesRef}{'developer'};
    ${$hashOfVariablesRef}{'elephantLogo'}     = '/graphics/logo-prod.gif';
  }

  if($ENV{'ALTERNATE_DB_ADDRESS'}) {
    warn "Using Database Address : ".$ENV{'ALTERNATE_DB_ADDRESS'};
    ${$hashOfVariablesRef}{'database_address'} = $ENV{'ALTERNATE_DB_ADDRESS'};
  }

  unless(${$hashOfVariablesRef}{'database_address'}) {
      warn "Error: environment starting but could not find a database to drive the system.!\n" .
                   "\tTo fix look at your ALTERNATE_DB_ADDRESS env variable or make sure there is a readHost in TUSK::Core::ServerConfig\n\n";
      return(-3);
  }

  # Setup some sane default values
  ${$hashOfVariablesRef}{'ip_address'}       = '*'
     if ( ! defined ${$hashOfVariablesRef}{'ip_address'} );
  ${$hashOfVariablesRef}{'server_name'}      = $hostname
     if ( ! defined ${$hashOfVariablesRef}{'server_name'} );

  ## Variables relative to the server_name
  ${$hashOfVariablesRef}{'ssl_cert_file'}    = ${$hashOfVariablesRef}{'server_name'} . '.cert'
     if ( ! defined ${$hashOfVariablesRef}{'ssl_cert_file'} );
  ${$hashOfVariablesRef}{'ssl_key_file'}     = ${$hashOfVariablesRef}{'server_name'} . '.key'
     if ( ! defined ${$hashOfVariablesRef}{'ssl_key_file'} );
  ${$hashOfVariablesRef}{'secure_server'}    = "${$hashOfVariablesRef}{'server_name'}/"
     if ( ! defined ${$hashOfVariablesRef}{'secure_server'} );
  ${$hashOfVariablesRef}{'unsecure_server'}  = "${$hashOfVariablesRef}{'server_name'}/"
     if ( ! defined ${$hashOfVariablesRef}{'unsecure_server'} );

  ## Variables relative to the server root.
  ${$hashOfVariablesRef}{'server_root'}           = "${$hashOfVariablesRef}{'tusk_base'}/current";
  ${$hashOfVariablesRef}{'ssl_root'}              = "${$hashOfVariablesRef}{'tusk_base'}/ssl_certificate";
  ${$hashOfVariablesRef}{'log_root'}              = "${$hashOfVariablesRef}{'server_root'}/logs";
  ${$hashOfVariablesRef}{'pid_file'}              = "${$hashOfVariablesRef}{'log_root'}/httpd.pid";
  ${$hashOfVariablesRef}{'config_file'}           = "${$hashOfVariablesRef}{'server_root'}/conf/httpd.conf";
  ${$hashOfVariablesRef}{'code_root'}             = "${$hashOfVariablesRef}{'server_root'}/code";
  ${$hashOfVariablesRef}{'embperlSessionArgs'}    = "\"DataSource=dbi:mysql:hsdb4:${$hashOfVariablesRef}{'database_address'} UserName=${$hashOfVariablesRef}{'hsdbDatabaseUser'} " .
                                                 "Password=${$hashOfVariablesRef}{'hsdbDatabasePassword'} LockDataSource=dbi:mysql:tusk:${$hashOfVariablesRef}{'database_address'} " .
                                                 "LockUserName=${$hashOfVariablesRef}{'hsdbDatabaseUser'} LockPassword=${$hashOfVariablesRef}{'hsdbDatabasePassword'}\"";
  ${$hashOfVariablesRef}{'embperlSessionClasses'} = "\"MySQL MySQL\"";
  ${$hashOfVariablesRef}{'secure_loc'}            = "https://${$hashOfVariablesRef}{'secure_server'}";
  ${$hashOfVariablesRef}{'unsecure_loc'}            = "http://${$hashOfVariablesRef}{'unsecure_server'}";

  # Try to interpolate a reasonable number of MaxClients for the apache configuration
  # based on the amount of total or free memory when we start the application.
  if ( ! exists ${$hashOfVariablesRef}{'MaxClients'} ||
  	! defined ${$hashOfVariablesRef}{'MaxClients'} ) {
	my ($mem, $free, $m);
	# Get our memory in KB...
	$mem = Sys::MemInfo::get('totalmem')/1024;
	$free = Sys::MemInfo::get('freemem')/1024;

	# If our free mem is a large percentage of our total mem, just use that
	# otherwise just guess at using up to 75% of all the memory.
	$m = ($free > ($mem / 2))? $free: $mem * .75;

	${$hashOfVariablesRef}{'MaxClients'} = int($m/$TUSK::Constants::maxApacheProcSize)
		if ( $TUSK::Constants::maxApacheProcSize );

	# Reset our number if we guessed way to low.
  	${$hashOfVariablesRef}{'MaxClients'} = 10
  		if ( ${$hashOfVariablesRef}{'MaxClients'} < 10 );
  }

  foreach (keys %{$hashOfVariablesRef}) {$ENV{uc($_)} = ${$hashOfVariablesRef}{$_};}
  return(1);
}



sub defineSSLLocations() {
  my @order = qw(
	/temp/
	/manage/
	/tusk/
	/home
	/login
	/webtest/
	/style/
	/cms
	/icons/
	/import_enroll_listing
	/scripts/
	/graphics/
	/addons/
	/code/
	/eval45
	/public/
	/nosession/
    );
  my %locations = ();

  $locations{'/favicon.ico'} = qq { SetHandler default-handler };
  $locations{'/public/'} = qq { $mason_handler };
  $locations{'/nosession/'} = qq { $mason_no_session_handler };
  foreach my $d (qw(/icons/ /style/ /code/ /scripts/ /graphics/ /addons/ /xsd/))	{  $locations{$d} = qq{ SetHandler default-handler };  }
  foreach my $d (qw(/eval45 /cms /import_enroll_listing))				{  $locations{$d} = qq{ $embperl_handler $hsdbauth };  }
  foreach my $d (qw(/manage/))								{  $locations{$d} = qq{ $hsdbauth };  }
  foreach my $d (qw(/tusk/)) {  
      $locations{$d} = qq{ 
	  $mason_handler 
	      $hsdbauth   	
	      require valid-user	
	      PerlSetVar AuthzDefault Permissive
	      ErrorDocument 403 /
	      PerlLogHandler Apache::HSDBLogger
	  };  
  }
  $locations{'/login'} = qq {
                SetHandler perl-script
                Options +ExecCGI
                PerlHandler Apache::TicketMaster
  };

  $locations{'/home'} = qq {
                SetHandler perl-script
                Options ExecCGI
                ErrorDocument 404 /redirect_to_insecure
                ErrorDocument 403 /redirect_to_insecure
  };

  # handler for testing framework reset
  $locations{'/webtest/'} = qq {
                $perlscripts
                PerlHandler TestDataInitializer::Setup
  };

  return(join "\n", map { "\n<Location $_>\n$locations{$_}\n</Location>" } @order);
}


sub defineLocations($) {
  my $hashOfVariablesRef = shift;

  my %locations = ();
  # The top level directory has embperls:
  $locations{'/'} = $embperl_handler ;
 
  # FOR TESTING ONLY, PLEASE REMOVE 
#  $locations{'/ocw/'} = qq{ SetHandler default-handler };
  
  foreach my $d (qw(/hsdb4/ /hsdb45/ /auth/)) {
 	# The main HSDB4 handler: Embperl, permissive auth, and some extras.
    	$locations{$d} = qq{
      		$embperl_handler
      		$hsdbauth
      		PerlSetVar AuthzDefault Permissive
      		ErrorDocument 403 /
      		PerlLogHandler Apache::HSDBLogger
  	};
  }

  $locations{'/favicon.ico'} = qq { SetHandler default-handler };
  $locations{'/about/'} = qq { $mason_handler };
  $locations{'/public/'} = qq { $mason_handler };
  $locations{'/nosession/'} = qq { $mason_no_session_handler };
  
  foreach my $d ('/view/', '/tusk/', '/mobi/') {
  	$locations{$d} = qq{
  		$mason_handler
  		$hsdbauth
  		PerlSetVar AuthzDefault Permissive
  		ErrorDocument 403 /
  		PerlLogHandler Apache::HSDBLogger
  	};
  }

  $locations{"/home"} = qq{
	  $perlscripts
	  PerlHandler Apache::Homepage
  };

 
  foreach my $d ('/hsdb45/eval/', '/hsdb45/user_group', '/hsdb4/quiz', '/external_link') {
  	$locations{$d} = qq {
  		$embperl_handler
  		$hsdbauth
  		PerlSetVar AuthzDefault Restrictive			
  	};
  }
   
  # Subdirectories of hsdb4 which use SQLRow subclasses:
  my %rowclasses = (
  	'content'          => 'Content',
  	'query'            => 'Query',
  	'personal_content' => 'PersonalContent',
  );
  foreach my $d (keys %rowclasses) {
  	$locations{"/hsdb4/$d/"} = qq{ 
  		PerlSetVar RowClass HSDB4::SQLRow::${rowclasses{$d}}
  	};
  }
  	
  $locations{"/view/urlTopFrame/"} = qq{ 
  	PerlSetVar RowClass HSDB4::SQLRow::Content
  };
  $locations{"/view/url/"} = qq{ 
  	PerlSetVar RowClass HSDB4::SQLRow::Content
  };
  $locations{"/view/content/"} = qq{ 
  	PerlSetVar RowClass HSDB4::SQLRow::Content
  };
  $locations{"/mobi/view/content/"} = qq{ 
  	PerlSetVar RowClass HSDB4::SQLRow::Content
  };
  $locations{"/mobi/view/course/"} = qq{ 
  	PerlSetVar RowClass HSDB45::Course
  };
  $locations{"/view/course/"} = qq{ 
  	PerlSetVar RowClass HSDB45::Course
  };
  $locations{"/management/content/personalcontent/"} = qq{
  	PerlSetVar RowClass HSDB4::PersonalContent
  };
  $locations{"/auth/"} .= qq{
  	PerlSetVar RowClass HSDB4::SQLRow::Content
  };
  $locations{"/hsdb45/course/"} = qq{ 
  	PerlSetVar RowClass HSDB45::Course
  };
  

  $locations{"/mobi/home"} = qq{
	  $perlscripts
	  PerlHandler Apache::Homepage
  };

  $locations{"/bigscreen"} = qq{
	  $perlscripts
	  PerlHandler Apache::Homepage
  };

  $locations{"/smallscreen"} = qq{
	  $perlscripts
	  PerlHandler Apache::Homepage
  };


  # Areas which just have the default handler:
  foreach my $d (qw(graphics addons icons style code symbols ramfiles shockwave video smil XSL scripts xsd)) {
  	$locations{"/$d/"} = qq{ SetHandler default-handler };
  }	
  
  # Areas which have the default handler and restricted access
  foreach my $d (qw(learninglib apps)) {
  	$locations{"/$d/"} = qq{ 
  		SetHandler default-handler 
  		IndexOptions FancyIndexing IgnoreCase
  	};
  }
  
  # Server status page -- this has special access permissions, because
  # the information that Apache::Status gives is dangerous.
  if (${$hashOfVariablesRef}{'developer'}){
  	$locations{'/status'} = qq{
  		$perlscripts
  		PerlHandler Apache::Status
  		order deny,allow
  		deny from all
  		allow from ${$hashOfVariablesRef}{'allowStatusFrom'}
  	};
  }
  
  # Handle logging out
  $locations{'/dologout'} = qq{
  	$perlscripts
  	PerlHandler Apache::TicketRemove
  };
  	
  # restricted binary data areas
  foreach my $d (qw(binary data thumb small_data thumbnail orig xlarge large medium small icon chooser_icon/image overlay)) {
  	$locations{"/$d/"} = qq{
  	   $hsdbauth
       SetHandler	perl-script
       PerlHandler  Apache::HSDBSlide
  	   PerlSetVar AuthzDefault Permissive 

  	   AddType image/gif	.gif
  	   AddType image/jpeg	.jpg
  	   AddType image/x-png	.png
  	};
  }

  foreach my $d (qw(media)) {
  	$locations{"/$d/"} = qq{
		PerlSetVar AuthzDefault Permissive 
		SetHandler default-handler

 		AddType video/x-flv	.flv
  	};
  }

  #Restricted download areas
  $locations{"/download/"} = qq{
	$perlscripts
	PerlHandler Apache::TUSKDownload
  };

  $locations{"/evalgraph/"} = qq{
  	$perlscripts
  	PerlHandler Apache::HSDBEvalGraph
  };
  
  $locations{"/mergedevalgraph/"} = qq{
  	$perlscripts
  	PerlHandler Apache::HSDBMergedEvalGraph
  };
  
  $locations{"/XMLObject/"} = qq{
  	$perlscripts
  	PerlHandler Apache::XMLObject
  };
  
  $locations{"/rss"} = qq{
  	$perlscripts
  	PerlHandler Apache::TUSKRSS
  };
  
  foreach my $d (qw(eval_results merged_eval_results eval_completions eval_saved_answers)) {
  	$locations{"/XMLObject/$d/"} = qq{
  		PerlAccessHandler Apache::HSDBHostsOnly
  	};
  }
  
  $locations{"/XMLLister/"} = qq{
  	$perlscripts
  	PerlHandler Apache::XMLLister
  	PerlAccessHandler Apache::HSDBHostsOnly
  };
  
  # access-restricted script directories
  foreach my $d (qw(cgi-auth)) {
  	$locations{"/$d/"} = qq{
  		$perlscripts
  		$hsdbauth
  		PerlHandler Apache::Registry
  		PerlSetVar AuthzDefault Restrictive
  	};
  }
  
  foreach my $d (qw(perl)){
  	$locations{"/$d/"} = qq{
  		$perlscripts
  		$hsdbauth
  		require valid-user
  		PerlHandler Apache::Registry
  		PerlSetVar AuthzDefault Permissive
  	};
  }
  
  foreach my $d (qw(forum)) {
  	$locations{"/$d/"} = qq{
  		$perlscripts	
  		$hsdbauth
  		PerlHandler Apache::Registry
  		PerlSendHeader On
  		PerlSetVar AuthzDefault Restrictive
  	};
  }
  
  # access-restricted data directories
#  foreach my $d (qw(images auth orca)) {
  foreach my $d (qw(images orca)) {
  	$locations{"/$d/"} = qq{
  		$hsdbauth
  		SetHandler default-handler
  		PerlSetVar AuthzDefault Restrictive
  	};
  }
  	
# the auth data directory is not restrictive.
# this is intended as a temporary fix for phpd.
# this is motivated by their accredidation, and the fact that they want pdf's to have
# unrestricted access. by removing 'auth' to this block from one above, we ensure that the directory
# is not more restrictive than the content object.
  foreach my $d (qw(auth)) {
  	$locations{"/$d/"} = qq{
  		$hsdbauth
  		SetHandler default-handler
  		PerlSetVar AuthzDefault Permissive
  	};
  }
  	
  foreach my $d (qw(downloadable_file streaming)) {
     $locations{"/$d/"} = qq{
  	   $hsdbauth
  	   SetHandler default-handler
  	   PerlSetVar AuthzDefault Restrictive
  
  	   # add more AddTypes here:
  	   AddType application/type	.sav
  	   AddType video/mp4	.mp4
  	   AddType video/quicktime	.mov
  	   AddType video/x-ms-wmv	.wmv
  	   AddType audio/mp3	.mp3
       AddType video/x-flv	.flv
     };
  }
  
  foreach my $d (qw(temp)) {
     $locations{"/$d/"} = qq{
  	   SetHandler default-handler
  	   PerlSetVar AuthzDefault Permissive
  
  	   # add more AddTypes here:
  	   AddType application/type	.sav
  	   AddType video/mp4	.mp4
  	   AddType video/quicktime	.mov
  	   AddType video/x-ms-wmv	.wmv
  	   AddType audio/mp3	.mp3
       AddType video/x-flv	.flv
     };
  }

  $locations{"/forum_attachments/"} = qq{
        $hsdbauth
        SetHandler default-handler
        PerlSetVar AuthzDefault Restrictive
  
        # add more AddTypes here:
        AddType application/type .sav
    };

  
  # create a location match hash
  my %location_matches = ();
  foreach my $d (qw(/chooser_icon/text(.*) /chooser_icon/table(.*))) {$location_matches{"$d"} = "SetHandler default-handler";}
  

  #Combine the locations and the location_matches
  my $loc_list = join "\n", map { "\n<Location $_>\n$locations{$_}\n</Location>" } sort keys %locations;
  # add location matches to loc_list
  $loc_list .= join "\n", map { "\n<LocationMatch $_>\n$location_matches{$_}\n</LocationMatch>" } sort keys %location_matches;

  return($loc_list);
}


sub defineAliases($) {
  my $hashOfVariablesRef = shift;

  # Create a bunch of aliases for this virtual host
  my %aliases = (
 	'/cgi-auth/'          => "${$hashOfVariablesRef}{'code_root'}/perl/",
 	'/icons/'             => "${$hashOfVariablesRef}{'server_root'}/graphics/icons/",
 	'/graphics/'          => "${$hashOfVariablesRef}{'server_root'}/graphics/",
 	'/addons/'            => "${$hashOfVariablesRef}{'server_root'}/addons/",
 	'/css/'               => "${$hashOfVariablesRef}{'html_location'}/css/",
 	'/symbols/'           => "${$hashOfVariablesRef}{'server_root'}/graphics/icons/",
 	'/auth/'              => "${$hashOfVariablesRef}{'html_location'}/web-auth/",
	'/forum_attachments/' => $TUSK::Constants::ForumAttachments,
 	'/downloadable_file/' => "${$hashOfVariablesRef}{'html_location'}/downloadable_file/",
 	'/media/'             => "${$hashOfVariablesRef}{'code_root'}/media/",
	'/streaming/'         => "${$hashOfVariablesRef}{'data_location'}/streaming/video/",
 	'/images/'            => "${$hashOfVariablesRef}{'html_location'}/images/",
 	'/apps/'              => "${$hashOfVariablesRef}{'html_location'}/apps/",
 	'/DTD/'               => "${$hashOfVariablesRef}{'code_root'}/HSCML/Rules/",
 	'/CSS/'               => "${$hashOfVariablesRef}{'code_root'}/HSCML/Display/",
 	'/learninglib/'       => "${$hashOfVariablesRef}{'html_location'}/learninglib/",
 	'/shockwave/'	      => "${$hashOfVariablesRef}{'html_location'}/shockwave/",
 	'/code/'              => "${$hashOfVariablesRef}{'html_location'}/web/code/",
 	'/forum/'             => "${$hashOfVariablesRef}{'code_root'}/forum/",
 	'/error/'             => "${$hashOfVariablesRef}{'code_root'}/htdocs/",
 	'/about/'             => "${$hashOfVariablesRef}{'code_root'}/tusk/about/",
	'/nosession/'         => "${$hashOfVariablesRef}{'code_root'}/tusk_no_session/",
 	'/view/'              => "${$hashOfVariablesRef}{'code_root'}/tusk/view/",
 	'/mobi/'              => "${$hashOfVariablesRef}{'code_root'}/tusk/mobi/",
	'/manage/'            => "${$hashOfVariablesRef}{'code_root'}/secure/manage/",
	'/temp/'              => "${$hashOfVariablesRef}{'data_location'}/temp/",
 	'/thumb/'             => "${$hashOfVariablesRef}{'html_location'}/slide/thumb/",
 	'/thumbnail/'         => "${$hashOfVariablesRef}{'html_location'}/slide/thumb/",
	'chooser_icon/image/' => "${$hashOfVariablesRef}{'html_location'}/slide/thumb/",
 	'/small/'             => "${$hashOfVariablesRef}{'html_location'}/slide/small/",
 	'/small_data/'        => "${$hashOfVariablesRef}{'html_location'}/slide/small/",
 	'/binary/'            => "${$hashOfVariablesRef}{'html_location'}/slide/orig/",
 	'/orig/'              => "${$hashOfVariablesRef}{'html_location'}/slide/orig/",
 	'/xlarge/'            => "${$hashOfVariablesRef}{'html_location'}/slide/xlarge/",
 	'/large/'             => "${$hashOfVariablesRef}{'html_location'}/slide/large/",
 	'/data/'              => "${$hashOfVariablesRef}{'html_location'}/slide/large/",
 	'/medium/'            => "${$hashOfVariablesRef}{'html_location'}/slide/medium/",
 	'/icon/'              => "${$hashOfVariablesRef}{'html_location'}/slide/icon/",
 	'/overlay/'           => "${$hashOfVariablesRef}{'html_location'}/slide/overlay/",
  );
 
  foreach my $d (qw(scripts perl tusk hsdb4 style api hsdb45 XSL xsd)) {$aliases{"/$d/"} = "${$hashOfVariablesRef}{'code_root'}/$d/";}
  foreach my $d (qw(smil ramfiles))                                {$aliases{"/$d/"} = "${$hashOfVariablesRef}{'html_location'}/$d/";}
 
  # Create alias matches for this host
  my %alias_matches = (
 	'^/chooser_icon/text(.*)' => "${$hashOfVariablesRef}{'server_root'}/graphics/icons/text.gif",
 	'^/chooser_icon/table(.*)' => "${$hashOfVariablesRef}{'server_root'}/graphics/icons/tablesmall.gif",
  );

  my $alias_list = join "\n", map { "Alias $_ ".$aliases{$_} } keys %aliases;
  # add alias matches to alias_list
  $alias_list .= join "\n", map { "\nAliasMatch $_ ".$alias_matches{$_} } keys %alias_matches;

  return $alias_list;
}


1;
