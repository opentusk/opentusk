#!/usr/bin/perl
#
# This module adds a session method to the Mason Request object ($m
# inside components).  It can also handle setting and reading cookies
# containing the session id.
#


{
    package TUSK::MasonNoSession;

    # Bring in main Mason package.
    use HTML::Mason 1.47;
    use MasonX::Request::WithApacheSession;
    use Apache2::Const -compile => qw(:common :http);

    # Bring in ApacheHandler, necessary for mod_perl integration.
    # Uncomment the second line (and comment the first) to use
    # Apache::Request instead of CGI.pm to parse arguments.
    use HTML::Mason::ApacheHandler;

    use strict;

    # List of modules that you want to use from components (see Admin
    # manual for details)
    {
        package HTML::Mason::Commands;

        # use ...
        use Carp;
        use Data::Dumper;
    }


    # Create ApacheHandler object
    #
    my $error_mode = "fatal";
    my $error_format = "text";
    my $use_object_files = 1;
    if (Apache2::ServerUtil::exists_config_define('DEV')) {
	$error_mode = "output";
	$error_format = "html";
	$use_object_files = 0;
    }

    my $dataDir = defined $TUSK::Constants::MasonCacheRoot ?
        $TUSK::Constants::MasonCacheRoot : "/var/cache/mason";
    my $ah =
        new HTML::Mason::ApacheHandler
        ( request_class => 'HTML::Mason::Request::ApacheHandler',
	  error_format=>$error_format, 
	  use_object_files => $use_object_files,
	  error_mode=>$error_mode, 
          comp_root => "$ENV{CODE_ROOT}/tusk_no_session",
	  data_dir => $dataDir);

    sub handler {
        my ($r) = @_;

        # If you plan to intermix images in the same directory as
        # components, activate the following to prevent Mason from
        # evaluating image files as components.
        #
        #return -1 if $r->content_type && $r->content_type !~ m|^text/|io;

        my $status = eval { $ah->handle_request($r); };
        if (my $err = $@) {
            if ( $err !~ /Software caused connection abort/ ) {
                $r->pnotes(error => $err );
                $r->log_error($err);
                return Apache2::Const::HTTP_INTERNAL_SERVER_ERROR;
            }
        }
        return $status;
    }

    1;
}

__END__
