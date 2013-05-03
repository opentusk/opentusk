#!/bin/bash

# Start MySQL if stopped
if [[ `/sbin/service mysqld status` =~ stopped ]] ; then
    /sbin/service mysqld start
fi

# Setup root
/usr/bin/mysql_secure_installation

# Load OpenTUSK databases and tables
cd /usr/local/tusk/current/install/sql
mysql -u root -p < tusk.sql

