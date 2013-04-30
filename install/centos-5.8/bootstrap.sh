#! /bin/bash

# Installing OpenTUSK and EPEL repos

sn=`basename $0`

echo "[$sn] Configuring from Vagrant bootstrap ..."

if [ -d /vagrant ] ; then
    sed -i 's/^nameserver\s*[0-9.]\+$/nameserver 8.8.8.8/g' /etc/resolv.conf
    mkdir --parents /usr/local/tusk
    ln -s /vagrant /usr/local/tusk/current
fi

echo "[$sn] Adding opentusk and epel repos ..."

cp /usr/local/tusk/current/install/centos-5.8/opentusk.repo /etc/yum.repos.d
yum install --quiet -y epel-release

echo "[$sn] Installing git ..."

yum install --quiet -y git

echo "[$sn] Installing yum packages ..."

# Installing yum packages
bash /usr/local/tusk/current/install/centos-5.8/install_yum_packages.bash
