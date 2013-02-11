#!/usr/bin/perl
#
# This module adds a session method to the Mason Request object ($m
# inside components).  It can also handle setting and reading cookies
# containing the session id.
#


{
    package TUSK::Mason;
	use strict;
	use Apache2::RequestRec;
	use Apache2::ServerUtil;
	use Apache2::Const -compile => qw(:common :http);
	use Apache2::Upload;
	use APR::Const;
	use Carp;
	use Data::Dumper;
	use HTML::Mason 1.47;
	use HTML::Mason::ApacheHandler;
	use MasonX::Request::WithApacheSession;
	use ModPerl::Const;
    use TUSK::Constants;
    use Sys::Hostname;

	# Define params for environment
	my $error_mode = "fatal";
	my $error_format = "text";
	my $use_object_files = 1;
	if (Apache2::ServerUtil::exists_config_define('DEV')) {
		$error_mode = "output";
		$error_format = "html";
		$use_object_files = 0;
	}

	# Check mason cache directory
    my $serverRoot = $TUSK::Constants::ServerRoot;
	my $dataDir = "$serverRoot/mason_cache";
    if (! -d $dataDir) {
        if (! (mkdir $dataDir)) {
            confess "Can't create mason cache dir $dataDir";
        }
    }
    if (! opendir(DIR, $dataDir)) {
        confess "Can't open mason cache dir $dataDir";
    }
	close(DIR);

    # Check for TUSK code root
	my $codeRoot = $TUSK::Constants::CodeRoot;
	my $tuskCodeRoot = "$codeRoot/tusk";
    if (! -d $tuskCodeRoot) {
        confess "Mason's code root does not exist ($tuskCodeRoot)";
    }
    if (! opendir(DIR, $dataDir)) {
        confess "Can't open mason code root dir $tuskCodeRoot";
    }
	close(DIR);

    # get database info
    # TODO: Encapsulate in TUSK::Constants or HSDB4::Constants
    my $db_info_ref = $TUSK::Constants::Servers{Sys::Hostname::hostname};
    my $database_address = $db_info_ref->{WriteHost};
    my $content_manager_ref = $TUSK::Constants::DatabaseUsers{ContentManager};
    my $db_user = $content_manager_ref->{writeusername};
    my $db_pw = $content_manager_ref->{writepassword};

	sub handler {
		my ($r) = @_;
		my $ah = HTML::Mason::ApacheHandler->new(
			comp_root => $tuskCodeRoot,
			data_dir => $dataDir,
			args_method   => "mod_perl",
			plugins=>['MasonX::Plugin::UTF8', 'MasonX::Plugin::Defang'],

			request_class => 'MasonX::Request::WithApacheSession',
			session_class => 'Apache::Session::MySQL',
			# Let MasonX::Request::WithApacheSession automatically
			# set and read cookies containing the session id
			session_use_cookie => 1,
			session_cookie_expires=>"session",
			session_cookie_name => "TUSKMasonCookie",
			session_data_source => "DBI:mysql:hsdb4:$database_address",
			session_user_name => $db_user,
			session_password => $db_pw,
			session_lock_data_source => "DBI:mysql:hsdb4:$database_address",
			session_lock_user_name => $db_user,
			session_lock_password => $db_pw,
			error_format=>$error_format, 
			use_object_files => $use_object_files,
			error_mode=>$error_mode, 
		);
		my $status = eval { $ah->handle_request($r); };
		if (my $err = $@) {
			$r->pnotes(error => $err );
			$r->log_error($err);
			return Apache2::Const::HTTP_INTERNAL_SERVER_ERROR;
		}
		return $status;
	}

1;
}

__END__
