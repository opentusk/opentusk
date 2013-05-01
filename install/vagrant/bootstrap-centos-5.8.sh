#! /bin/bash

# Installing OpenTUSK and EPEL repos

set -e

sn=`basename $0`

echo "[$sn] Configuring from Vagrant bootstrap ..."
if [ -d /vagrant ] ; then
    # Fix /etc/resolv.conf on base CentOS box:
    /sbin/dhclient -q eth0
    mkdir --parents /usr/local/tusk
    [[ -L /usr/local/tusk/current ]] || ln -s /vagrant /usr/local/tusk/current
    if [[ -z "`grep vagrant-c5-x86_64 /etc/hosts`" ]]; then
        echo -e "192.168.56.150\tvagrant-c5-x86_64" >> /etc/hosts
    fi
    mkdir --parents /var/www/mason_cache
    chown --recursive apache:apache /var/www/mason_cache
fi

PERL5LIB="/usr/local/tusk/current/lib:$PERL5LIB"

echo "[$sn] Adding opentusk repo ..."
cp /usr/local/tusk/current/install/centos-5.8/opentusk.repo /etc/yum.repos.d

echo "[$sn] Installing yum packages (takes a while) ..."
bash /usr/local/tusk/current/install/centos-5.8/install_yum_packages.bash

echo "[$sn] Setting SELinux to permissive ..."
sed -i 's/^\s*SELINUX=.*$/SELINUX=permissive/g' /etc/selinux/config

echo "[$sn] Setting up TUSK system account ..."
bash /usr/local/tusk/current/install/centos-5.8/create_system_accounts.bash

echo "[$sn] Creating TUSK directories and data tree ..."
bash /usr/local/tusk/current/install/scripts/create_directories.sh

echo "[$sn] Creating a self-signed SSL certificate ..."
bash /usr/local/tusk/current/install/centos-5.8/create_ssl_cert.bash

echo "[$sn] Setting up tusk.conf ..."
mkdir --parents /usr/local/tusk/conf
perl /usr/local/tusk/current/install/vagrant/setup_tusk_conf.pl \
    /usr/local/tusk/current/install/templates/conf/tusk/tusk.conf \
    > /usr/local/tusk/conf/tusk.conf

echo "[$sn] Setting up MySQL and loading TUSK databases ..."
if [[ `/sbin/service mysqld status` =~ "stopped" ]] ; then
    /sbin/service mysqld start 2>&1 >/dev/null
fi
/sbin/chkconfig mysqld on
printf "grant all on *.* to '%s'@'%s' identified by '%s' with grant option;\n" \
    'vagrant' '%' 'vagrant' \
    | mysql -u root
printf "grant all on *.* to '%s'@'%s' identified by '%s' with grant option;\n" \
    'vagrant' 'localhost' 'vagrant' \
    | mysql -u root
printf "grant all on *.* to '%s'@'%s' identified by '%s';\n" \
    'content_mgr' 'localhost' 'vagrant' \
    | mysql -u root
printf "grant all on *.* to '%s'@'%s' identified by '%s';\n" \
    'tusk' 'localhost' 'vagrant' \
    | mysql -u root
perl /usr/local/tusk/current/install/bin/baseline.pl \
    --create-admin --create-school --dbuser=root
perl /usr/local/tusk/current/bin/upgrade.pl --all --dbuser=root
cat <<EOF > /usr/local/tusk/.my.cnf
[client]
user=tusk
password=vagrant
EOF
chown tusk:tusk /usr/local/tusk/.my.cnf
chmod 600 /usr/local/tusk/.my.cnf

echo "[$sn] Setting up Apache ..."
sed -i 's/^LoadModule mime_magic_module/#LoadModule mime_magic_module/g' \
    /etc/httpd/conf/httpd.conf
cp /etc/httpd/conf.d/ssl.conf /tmp
sh -c "sed -n '/<VirtualHost _default_:443>/q;p' /tmp/ssl.conf > /etc/httpd/conf.d/ssl.conf"
cp /usr/local/tusk/current/install/templates/conf/apache2/tusk_* \
    /etc/httpd/conf.d
find /etc/httpd/conf.d/ -name "*.conf" -exec \
    sed -i "s/MYFQDN/`hostname`/g" {} \;
find /etc/httpd/conf.d/ -name "*.conf" -exec \
    sed -i "s/TUSKFQDN/`hostname`/g" {} \;
/sbin/service httpd start 2>&1 >/dev/null
/sbin/chkconfig httpd on

echo "[$sn] Setting up crontabs ..."
su tusk -c "perl /usr/local/tusk/current/bin/fts_index --all 2>&1 >/dev/null"
cat <<EOF > /usr/local/tusk/crontab
### Session Tracking
1 1 * * * /usr/local/tusk/current/bin/clean_session_table 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Old Session Cleaner"
0 3 * * * /usr/local/tusk/current/bin/update_tracking 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Daily Tracking updater"

### Misc cleanup
25 4 * * * /usr/bin/find /data/temp/ -type f -ctime +2 -exec /bin/rm {} \; 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Temp file cleanup"

### Forum Crons
10 3 * * * /usr/local/tusk/current/code/forum/cron_jobs.pl 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Forums: cron_jobs"
20 3 * * * /usr/local/tusk/current/code/forum/cron_subscriptions.pl 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Forums: cron_subscriptions"
30 * * * * /usr/local/tusk/current/code/forum/cron_rss.pl 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Forums: cron_rss"

### Eval fts index
5 2 * * 1-5 /usr/local/tusk/current/bin/eval_fts_index --changes_update --school=all 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "Eval FTS Indexer"

### fts index
0,15,30,45 * * * * TZ="US/Eastern";export TZ;/usr/local/tusk/current/bin/fts_index --recent --noprint 2>&1 | /usr/local/tusk/current/bin/mail_cron_error "FTS Indexer"
EOF
crontab -u tusk /usr/local/tusk/crontab

echo "[$sn] Finished setup."
echo "[$sn] Add `hostname` to /etc/hosts on your VM host."
printf "[%s] Mac: sudo bash -c \"%s >> /private/etc/hosts\"\n" \
    "$sn" \
    "printf \\\"%s\\\t%s\\\n\\\" \\\"192.168.56.150\\\" \\\"`hostname`\\\""
echo "[$sn] (Only needed once.)"
echo "[$sn] Then connect to http://`hostname` to test."
