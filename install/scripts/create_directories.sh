#! /bin/bash

mkdir -p  /data/{eval_data,mysql}
mkdir -p  /data/ppt/{native-archive,native,error,processed,temp}
mkdir -p  /data/{.ppt,forum_data,temp}
mkdir -p  /data/TUSKdoc/{native-archive,native,processed}
mkdir -p  /data/streaming/{flashpix,smil,code,video}
mkdir -p  /data/html/{shockwave,HSDB-doc,ramfiles,smil,web,downloadable_file,fop-pdf,fop-xml}
mkdir -p  /data/html/web-auth/pdf
mkdir -p  /data/html/images
mkdir -p  /data/html/slide/{orig,small,icon,thumb,medium,large,xlarge}
mkdir -p  /data/html/slide/overlay/{orig,small,medium,large,xlarge}
mkdir -p  /usr/local/tusk/{conf,ssl_certificate}
mkdir -p /var/log/tusk
chown tusk:tusk /var/log/tusk
ln -s /var/log/tusk /usr/local/tusk/current/logs
