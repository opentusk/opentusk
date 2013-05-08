#!/bin/bash

# Create a self-signed SSL certificate for OpenTUSK

basedir="/usr/local/tusk/ssl_certificate"

mkdir --parents "$basedir"

openssl req -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=MA/L=Boston/O=Tufts University/CN=`hostname`" \
    -keyout "$basedir/server.key"  \
    -out "$basedir/server.crt" \
    &> /dev/null
