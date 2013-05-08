#!/bin/bash

# Create a self-signed SSL certificate for OpenTUSK

basedir="/usr/local/tusk/ssl_certificate"

mkdir --parents "$basedir"

openssl genpkey \
    -out "$basedir/server.key" \
    -algorithm rsa -pkeyopt rsa_keygen_bits:1024
openssl req -new \
    -key "$basedir/server.key" \
    -out "$basedir/server.csr"
openssl x509 -req -days 365 \
    -in "$basedir/server.csr" \
    -signkey "$basedir/server.key" \
    -out "$basedir/server.crt"
