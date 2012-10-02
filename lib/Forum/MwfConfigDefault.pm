package MwfConfig;
use strict;
use warnings;
our ($VERSION, $cfg);
$VERSION = "2.11.1";

#-----------------------------------------------------------------------------
# Basic options
# These configuration options are required by the forum before it can load
# the rest of the configuration from the database.

# Base URL without path (no trailing /)
$cfg->{baseUrl}        = "http://www.example.com";

# URL path to data directory (no trailing /)
$cfg->{dataPath}       = "/mwf";

# Database server host
$cfg->{dbServer}       = "localhost";

# Database name
$cfg->{dbName}         = "mwforum";

# Database user
$cfg->{dbUser}         = "user";

# Database password
$cfg->{dbPassword}     = "password";

# Database table prefix or schema (usually not required)
$cfg->{dbPrefix}       = "";

# DBI driver. Either "mysql", "mysqlPP", "Pg" or "SQLite".
$cfg->{dbDriver}       = "mysql";

# Additional DBI DSN parameters (usually not required)
# Example: "port=321;mysql_socket=/tmp/mysql.sock;mysql_ssl=1"
$cfg->{dbParam}        = "";

# Hide database error message details from normal users?
$cfg->{dbHideError}    = 0;

# Max. size of attachments 
# Also limits general CGI input. Don't set it below a few thousand byte.
$cfg->{maxAttachLen}   = "1000000";

#-----------------------------------------------------------------------------
# These configuration options can only be changed here and not in
# the online form for security reasons.

# Sendmail executable and options (only used with sendmail mailer)
$cfg->{sendmail}       = "/usr/sbin/sendmail -oi -oeq -t";

# Filesystem path for attachments
$cfg->{attachFsPath}   = "";

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
