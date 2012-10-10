#!/usr/bin/perl 
BEGIN {
    if ($ENV{DEVELOPER}){
	use Apache::Status;
    }

    use Apache ();
    use Apache::Server;
    use Apache::File ();
    use Apache::Constants ();
    use Apache::Table ();
    use Apache::Log ();
    use Apache::SizeLimit ();
    use lib Apache->server_root_relative('lib');
    use Carp;
    use HSDB4::SQLRow::Content;
    use HSDB45::Course;
    use HSDB4::SQLRow::User;
    use HSDB4::SQLRow::NonUser;
    use HSDB4::SQLRow::StatusHistory;
    use HSDB45::TimePeriod;
    use TUSK::Constants;
    use TUSK::Core::Logger;

    # Limit size of the Apache processes
    $Apache::SizeLimit::MAX_PROCESS_SIZE = $TUSK::Constants::maxApacheProcSize;
    $Apache::SizeLimit::MAX_UNSHARED_SIZE = $TUSK::Constants::maxApacheProcSize;
    $Apache::SizeLimit::CHECK_EVERY_N_REQUESTS = 10;
}
1;

