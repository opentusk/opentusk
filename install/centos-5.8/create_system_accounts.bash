#!/bin/bash

/usr/sbin/groupadd -g 1100 tusk
/usr/sbin/useradd -c 'Tusk' -u 1100 -g tusk -d /usr/local/tusk tusk
/usr/sbin/usermod -a -G tusk apache
chmod 755 /usr/local/tusk
