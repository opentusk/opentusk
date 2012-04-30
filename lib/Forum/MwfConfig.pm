package MwfConfig;

use TUSK::Constants;
use Sys::Hostname;

use strict;
use warnings;
our ($VERSION, $cfg);
$VERSION = "2.11.1";

#-----------------------------------------------------------------------------
# Basic options
# These configuration options are required by the forum before it can load
# the rest of the configuration from the database.

# Base URL without path (no trailing /)
$cfg->{baseUrl}        = "http://" . $TUSK::Constants::Domain;

# URL path to data directory (no trailing /)
$cfg->{dataPath}       = "/addons/forums";

# Database server host
$cfg->{dbServer}       = $ENV{DATABASE_ADDRESS} ? $ENV{DATABASE_ADDRESS} : $TUSK::Constants::Servers{Sys::Hostname::hostname}->{'WriteHost'};

# Database name
$cfg->{dbName}         = "hsdb4";

# Database user
$cfg->{dbUser}         = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

# Database password
$cfg->{dbPassword}     = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};

# Database table prefix or schema (usually not required)
$cfg->{dbPrefix}       = "mwforum.";

# DBI driver. Either "mysql", "mysqlPP", "Pg" or "SQLite".
$cfg->{dbDriver}       = "mysql";

# Additional DBI DSN parameters (usually not required)
# Example: "port=321;mysql_socket=/tmp/mysql.sock;mysql_ssl=1"
$cfg->{dbParam}        = "";

# Hide database error message details from normal users?
$cfg->{dbHideError}    = 0;

# Max. size of attachments 
# Also limits general CGI input. Don't set it below a few thousand byte.
$cfg->{maxAttachLen}   = $TUSK::Constants::MaxAttachLen;

#-----------------------------------------------------------------------------
# These configuration options can only be changed here and not in
# the online form for security reasons.

# Sendmail executable (only used with sendmail mailer)
$cfg->{sendmail}       = $TUSK::Constants::emailProgram;

# Filesystem path for attachments
$cfg->{attachFsPath}   = $TUSK::Constants::ForumAttachments;

# Limit forum_options to specific admins (comma-sep. list of user IDs)
# Example: "1,2,3"
$cfg->{cfgAdmins}      = "";

# Log errors/warnings into this file in addition to the webserver log
# Example: "/var/log/forum.log"
$cfg->{errorLog}       = "";

# Additional GnuPG options
$cfg->{gpgOptions}     = [];

#------------------------------------------------------------------------------
# Custom options go here


#-----------------------------------------------------------------------------
# Return OK
1;
