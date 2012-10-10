#!/usr/bin/perl
#
# This module adds a session method to the Mason Request object ($m
# inside components).  It can also handle setting and reading cookies
# containing the session id.
#


{
package TUSK::Mason;

# Bring in main Mason package.
use HTML::Mason 1.47;
use MasonX::Request::WithApacheSession;
use Apache::Constants qw(:common);

# Bring in ApacheHandler, necessary for mod_perl integration.
# Uncomment the second line (and comment the first) to use
# Apache::Request instead of CGI.pm to parse arguments.
use HTML::Mason::ApacheHandler;

use strict;

# List of modules that you want to use from components (see Admin
# manual for details)
{  package HTML::Mason::Commands;

   # use ...
   use Carp;
   use Data::Dumper; 
}


# Create ApacheHandler object
#
my $error_mode = "fatal";
my $error_format = "text";
my $use_object_files = 1;
if (Apache->define('DEV')){
	$error_mode = "output";
	$error_format = "html";
	$use_object_files = 0;
}

my $ah =
    new HTML::Mason::ApacheHandler
        ( request_class => 'MasonX::Request::WithApacheSession',
          session_class => 'Apache::Session::MySQL',
          # Let MasonX::Request::WithApacheSession automatically
          # set and read cookies containing the session id
          session_use_cookie => 1,
	  session_cookie_expires=>"",
	  session_cookie_name => "TUSKMasonCookie",
	  session_data_source => "DBI:mysql:hsdb4:$ENV{DATABASE_ADDRESS}",
	  session_user_name => $ENV{HSDB_DATABASE_USER},
	  session_password => $ENV{HSDB_DATABASE_PASSWORD},
          session_lock_data_source => "DBI:mysql:hsdb4:$ENV{DATABASE_ADDRESS}",
          session_lock_user_name => $ENV{HSDB_DATABASE_USER},
          session_lock_password => $ENV{HSDB_DATABASE_PASSWORD},
	  error_format=>$error_format, 
	  use_object_files => $use_object_files,
	  error_mode=>$error_mode, 
          comp_root => "$ENV{CODE_ROOT}/tusk",
	  data_dir => "$ENV{SERVER_ROOT}/mason_cache",
	  plugins=>['MasonX::Plugin::UTF8', 'MasonX::Plugin::Defang']);
          

sub handler
{
    my ($r) = @_;

    # If you plan to intermix images in the same directory as
    # components, activate the following to prevent Mason from
    # evaluating image files as components.
    #
    #return -1 if $r->content_type && $r->content_type !~ m|^text/|io;

    my $status = eval { $ah->handle_request($r); };
    if (my $err = $@) {
	$r->pnotes(error => $err );
	$r->log_error($err);
	return SERVER_ERROR;

    }
    return $status;
}

1;
}

__END__

In your httpd.conf, add something like this:

 PerlRequire /path/to/handler.pl
 <LocationMatch "\.html$">
   SetHandler perl-script
   PerlHandler MyApp::Mason
 </LocationMatch>
