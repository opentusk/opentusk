package HSDB4::test::setup;
use TUSK::Constants;

$ENV{HSDB_DATABASE_NAME} = "hsdb4";
$ENV{HSDB_DATABASE_USER} = $TUSK::Constants::DatabaseUsers->{DefaultUser}->{readusername};
$ENV{HSDB_DATABASE_PASSWORD} = $TUSK::Constants::DatabaseUsers->{DefaultUser}->{readpassword};
$ENV{HSDB_GUEST_USERNAME} = "HSDB-Guest";
$ENV{EMBPERL_LIB} = "$ENV{HOME}/HSDB/apache/embperl";
$ENV{EMBPERL_LOG} = "$ENV{HOME}/HSDB/apache/lib/perl/HSDB4/test/embperl.log";
$ENV{XSL_ROOT} = "$ENV{HOME}/HSDB/apache/XSL";

1;
