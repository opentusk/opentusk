
package TUSK::I18N::WrapperI18N;
use strict;
use warnings;
use Carp;
use Apache2::Const -compile => 'OK';
use Apache2::ServerUtil ();
sub post_config {
      my ($conf_pool, $log_pool, $temp_pool, $s) = @_;
      my $count = Apache2::ServerUtil::restart_count();
      carp("configuration is completed ($$) count [$count]");
      {
	# from http://search.cpan.org/~jswartz/HTML-Mason-1.50/lib/HTML/Mason/Admin.pod#External_Modules_Revisited
	# "Explicitly setting the package to HTML::Mason::Commands makes sure that any symbols that the loaded 
	# modules export (constants, subroutines, etc.) get exported into the namespace under which components run. 
	# Of course, if you've changed the component namespace, make sure to change the package name here as well.
	#Alternatively, you might consider creating a separate piece of code to load the modules you need. For example, 
	# you might create a module called MyApp::MasonInit::
	#
	# 
      package HTML::Mason::Commands;      
      use utf8;
      use TUSK::I18N::I18N qw(:basic);
  
    } 
      return Apache2::Const::OK;
  }

1;
