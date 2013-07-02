#!/usr/bin/perl 
BEGIN {
    if ($ENV{DEVELOPER}){
	use Apache2::Status;
    }

    use Carp;
    use CGI;
    use Apache2::Const();
    use Apache2::Log ();
    use Apache2::ServerUtil;
    use Apache2::SizeLimit ();
    use APR::Const();
    use APR::Table();
    use ModPerl::Const();
    use lib "/usr/local/tusk/current/lib";
    use HSDB4::SQLRow::Content;
    use HSDB45::Course;
    use HSDB4::SQLRow::User;
    use HSDB4::SQLRow::NonUser;
    use HSDB4::SQLRow::StatusHistory;
    use HSDB45::TimePeriod;
    use TUSK::Constants;
    use TUSK::Core::Logger;
    use TUSK::Apache2::I18N;
    $SIG{__WARN__} = \&Apache2::ServerRec::warn;

    # Limit size of the Apache processes
    $Apache2::SizeLimit::MAX_PROCESS_SIZE = $TUSK::Constants::maxApacheProcSize;
    $Apache2::SizeLimit::MAX_UNSHARED_SIZE = $TUSK::Constants::maxApacheProcSize;
    $Apache2::SizeLimit::CHECK_EVERY_N_REQUESTS = 10;
}
1;

