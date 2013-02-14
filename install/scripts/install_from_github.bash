#!/bin/bash

# Install OpenTUSK from Github repository. Very much a work in
# progress! Run as root.

mycwd="$PWD"

myrepo="https://github.com/mprentice/Opentusk.git"
mybranch="installer6"

echo "Installing OpenTUSK and EPEL repos ..."

cd /etc/yum.repos.d
curl -O https://raw.github.com/mprentice/Opentusk/$mybranch/install/opentusk.repo
yum install epel-release

echo "Installing git ..."

yum install git

echo "Getting OpenTUSK branch $mybranch from $myrepo ..."

mkdir -p /usr/local/tusk
cd /usr/local/tusk
git clone --branch $mybranch $myrepo

echo "Installing opentusk.repo ..."

cd Opentusk/install
cp opentusk.repo /etc/yum.repos.d/opentusk.repo

echo "Installing yum packages ..."

cd scripts
./install_yum_packages.bash

cd "$mycwd"
