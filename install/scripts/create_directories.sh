#! /bin/bash

sudo mkdir -p  /data/{eval_data,mysql}
sudo mkdir -p  /data/ppt/{native-archive,native,error,processed,temp}
sudo mkdir -p  /data/{.ppt,forum_data,temp}
sudo mkdir -p  /data/TUSKdoc/{native-archive,native,processed}
sudo mkdir -p  /data/streaming/{flashpix,smil,code,video}
sudo mkdir -p  /data/html/{shockwave,HSDB-doc,ramfiles,smil,web,downloadable_file,fop-pdf,fop-xml}
sudo mkdir -p  /data/html/web-auth/pdf
sudo mkdir -p  /data/html/images
sudo mkdir -p  /data/html/slide/{orig,small,icon,thumb,medium,large,xlarge}
sudo mkdir -p  /data/html/slide/overlay/{orig,small,medium,large,xlarge}
sudo mkdir -p  /usr/local/tusk/{conf,ssl_certificate}
sudo mkdir -p /var/log/tusk
sudo chown apache:apache /var/log/tusk
