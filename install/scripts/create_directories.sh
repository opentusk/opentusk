#! /bin/bash

mytuskroot="$TUSKROOT"
if [ -z "$mytuskroot" ] ; then
    mytuskroot="/usr/local/tusk"
fi

# Filesystem hierarchy says put application data in /srv or /var.
mytuskdata="$TUSKDATA"
if [ -z "$mytuskdata" ] ; then
    mytuskdata="/data"
fi

mytusklogs="$TUSKLOGS"
if [ -z "$mytusklogs" ] ; then
    mytusklogs="/var/log/tusk"
fi

# eval data
mkdir --parents "$mytuskdata/eval_data"

# PPT processing
mkdir --parents "$mytuskdata/ppt/native-archive"
mkdir --parents "$mytuskdata/ppt/native"
mkdir --parents "$mytuskdata/ppt/error"
mkdir --parents "$mytuskdata/ppt/processed"
mkdir --parents "$mytuskdata/ppt/temp"
mkdir --parents "$mytuskdata/.ppt"

# forum data
mkdir --parents "$mytuskdata/forum_data"

# temp
mkdir --parents "$mytuskdata/temp"

# TUSKdoc
mkdir --parents "$mytuskdata/TUSKdoc/native-archive"
mkdir --parents "$mytuskdata/TUSKdoc/native"
mkdir --parents "$mytuskdata/TUSKdoc/processed"

# streaming media
mkdir --parents "$mytuskdata/streaming/flashpix"
mkdir --parents "$mytuskdata/streaming/smil"
mkdir --parents "$mytuskdata/streaming/code"
mkdir --parents "$mytuskdata/streaming/video"

# html and uploads
mkdir --parents "$mytuskdata/html/shockwave"
mkdir --parents "$mytuskdata/html/HSDB-doc"
mkdir --parents "$mytuskdata/html/ramfiles"
mkdir --parents "$mytuskdata/html/smil"
mkdir --parents "$mytuskdata/html/web"
mkdir --parents "$mytuskdata/html/downloadable_file"
mkdir --parents "$mytuskdata/html/fop--parentsdf"
mkdir --parents "$mytuskdata/html/fop-xml"
mkdir --parents "$mytuskdata/html/web-auth/pdf"
mkdir --parents "$mytuskdata/html/images"
mkdir --parents "$mytuskdata/html/slide/orig"
mkdir --parents "$mytuskdata/html/slide/small"
mkdir --parents "$mytuskdata/html/slide/icon"
mkdir --parents "$mytuskdata/html/slide/thumb"
mkdir --parents "$mytuskdata/html/slide/medium"
mkdir --parents "$mytuskdata/html/slide/large"
mkdir --parents "$mytuskdata/html/slide/xlarge"
mkdir --parents "$mytuskdata/html/slide/overlay/orig"
mkdir --parents "$mytuskdata/html/slide/overlay/small"
mkdir --parents "$mytuskdata/html/slide/overlay/medium"
mkdir --parents "$mytuskdata/html/slide/overlay/large"
mkdir --parents "$mytuskdata/html/slide/overlay/xlarge"

# configuration
mkdir --parents "$mytuskroot/conf"

# SSL
mkdir --parents "$mytuskroot/ssl_certificate"

# Mason cache
mymasoncache="$mytuskroot/current/mason_cache"
mkdir --parents "$mymasoncache/cache"
mkdir --parents "$mymasoncache/obj"

# logging
mkdir --parents "$mytusklogs"
ln --force --symbolic "$mytusklogs" "$mytuskroot/current/logs"

# permissions
chown --recursive tusk:tusk "$mytusklogs"
chown --recursive tusk:tusk "$mytuskroot"
chown --recursive apache:tusk "$mytuskdata"
chown --recursive apache:apache "$mymasoncache"
chmod 777 "$mytuskdata"
chmod 777 "$mytuskdata/TUSKdoc"
chmod 777 "$mytuskdata/temp"
chmod +t "$mytuskdata"
chmod +t "$mytuskdata/TUSKdoc"
chmod +t "$mytuskdata/temp"
