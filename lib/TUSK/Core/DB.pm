package TUSK::Core::DB;

use strict;
use TUSK::Core::ServerConfig;
use Carp qw(cluck croak confess);
use DBI;

my $DBConnectAttr = {'RaiseError' => 1, 'mysql_enable_utf8' => 1};
my $alternateDBAddress = $ENV{'ALTERNATE_DB_ADDRESS'};

sub getReadHandle {
    my ($user_token) = @_;   
    my $user = &TUSK::Core::ServerConfig::dbReadUser($user_token);
    my $password = &TUSK::Core::ServerConfig::dbReadPassword($user_token);
    my $db = &TUSK::Core::ServerConfig::dbReadDefaultDB;
    my $host = $alternateDBAddress || &TUSK::Core::ServerConfig::dbReadHost;
    my $connection = DBI->connect("DBI:mysql:$db:$host",$user,$password,$DBConnectAttr) 
	|| confess "database connecton failed:".DBI->errstr();
    return $connection;
}

sub getWriteHandle {
    my ($user_token) = @_;
    my $user = &TUSK::Core::ServerConfig::dbWriteUser($user_token);
    my $password = &TUSK::Core::ServerConfig::dbWritePassword($user_token);
    my $db = &TUSK::Core::ServerConfig::dbWriteDefaultDB;
    my $host = $alternateDBAddress || &TUSK::Core::ServerConfig::dbWriteHost;
    my $connection = DBI->connect("DBI:mysql:$db:$host",$user,$password,$DBConnectAttr) 
	|| confess "database connecton failed:".DBI->errstr();
   return $connection;
}

sub getSearchReadHandle {
    my ($user_token) = @_;
    my $user = &TUSK::Core::ServerConfig::dbSearchUser($user_token);
    my $password = &TUSK::Core::ServerConfig::dbSearchPassword($user_token);
    my $db = &TUSK::Core::ServerConfig::dbSearchDefaultDB;
    my $host = $alternateDBAddress || &TUSK::Core::ServerConfig::dbSearchHost;
    my $connection = DBI->connect("DBI:mysql:$db:$host",$user,$password,$DBConnectAttr) 
	|| confess "database connecton failed".DBI->errstr();
    return $connection
}

# We should no longer need disconnects using Apache::DBI
1;
