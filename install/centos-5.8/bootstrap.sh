#! /bin/bash

# Installing OpenTUSK and EPEL repos

echo "Configuring from Vagrant bootstrap ..."

if [ -d /vagrant ] ; then
    echo "Vagrant detected, removing kudzu ..."
    yum --quiet -y remove kudzu
    mkdir --parents /usr/local/tusk
    ln -s /vagrant /usr/local/tusk/current
fi

cp /usr/local/tusk/current/install/centos-5.8/opentusk.repo /etc/yum.repos.d
yum install --quiet -y epel-release
yum install --quiet -y git

# Installing yum packages
bash /usr/local/tusk/current/install/centos-5.8/install_yum_packages.bash
