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


	# Define params for environment
	#
	my $error_mode = "fatal";
	my $error_format = "text";
	my $use_object_files = 1;
#	if (Apache2::ServerUtil::exists_config_define('DEV')) {
		$error_mode = "output";
		$error_format = "html";
		$use_object_files = 0;
#	}

	# Check the directories
	my ($serverRoot) = ($ENV{SERVER_ROOT} =~ /^(.*)$/g);
	my $dataDir = "$serverRoot/mason_cache";
	unless(-d $dataDir) {   unless(mkdir $dataDir) {die "Can't create mason cache dir $dataDir\n";} }
	unless(opendir(DIR, $dataDir)) { die "Can't open mason cache dir $dataDir\n"; }
	close(DIR);

	my ($codeRootEnv) = ($ENV{CODE_ROOT} =~ /^(.*)$/g);
	my $codeRoot = "$codeRootEnv/tusk";
	unless(-d $codeRoot) {	die "Masons code root does not exist ($codeRoot)\n"; }
	unless(opendir(DIR, $dataDir)) { die "Can't open mason code root dir $codeRoot\n"; }
	close(DIR);

	sub handler {
		my ($r) = @_;
		my $ah = HTML::Mason::ApacheHandler->new(
			comp_root => $codeRoot,
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
			session_data_source => "DBI:mysql:hsdb4:$ENV{DATABASE_ADDRESS}",
			session_user_name => $ENV{HSDB_DATABASE_USER},
			session_password => $ENV{HSDB_DATABASE_PASSWORD},
			session_lock_data_source => "DBI:mysql:hsdb4:$ENV{DATABASE_ADDRESS}",
			session_lock_user_name => $ENV{HSDB_DATABASE_USER},
			session_lock_password => $ENV{HSDB_DATABASE_PASSWORD},
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
