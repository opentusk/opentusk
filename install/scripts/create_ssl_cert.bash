#!/bin/bash

# Create a self-signed SSL certificate for OpenTUSK

mycwd="$PWD"

mkdir --parents /usr/local/tusk/ssl_certificate
cd /usr/local/tusk/ssl_certificate
openssl genpkey -out server.key -algorithm rsa -pkeyopt rsa_keygen_bits:1024
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

cd "$mycwd"
