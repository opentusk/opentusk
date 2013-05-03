#!/bin/bash

/usr/sbin/groupadd -g 1100 tusk &> /dev/null
/usr/sbin/useradd -c 'Tusk' -u 1100 -g tusk -d /usr/local/tusk tusk \
    &> /dev/null
/usr/sbin/usermod -a -G tusk apache &> /dev/null
chmod 755 /usr/local/tusk
