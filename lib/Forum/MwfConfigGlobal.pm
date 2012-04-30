package MwfConfigGlobal;
use strict;
use warnings;
our ($VERSION, $gcfg);
$VERSION = "2.11.1";

#------------------------------------------------------------------------------
# Multi-forum options 
# Only touch if you want to use the multi-forum support. See FAQ.html.

# Map hostnames or URL paths to forums
#$gcfg->{forums} = {
#  'foo.example.com' => 'MwfConfigFoo',
#  'bar.example.com' => 'MwfConfigBar',
#};
#$gcfg->{forums} = {
#  '/perl/foo'       => 'MwfConfigFoo',
#  '/perl/bar'       => 'MwfConfigBar',
#};

# Database name of one of the used databases under MySQL
#$gcfg->{dbName}         = "";

#-----------------------------------------------------------------------------
# Advanced options

# Use UTF-8 mode? See FAQ.html.
# Only use if DBMS is UTF-8-capable and tables are marked as UTF-8.
$gcfg->{utf8}           = 0;

# Print page creation time? Requires Time::HiRes.
# Measures runtime, not CPU-time and not overhead like compilation time.
$gcfg->{pageTime}       = 0;

#-----------------------------------------------------------------------------
# Return OK
1;
