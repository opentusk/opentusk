#!/bin/bash

# Install OpenTUSK from Github repository. Very much a work in
# progress! Run as root.

# Run with:
# curl -O https://raw.github.com/mprentice/Opentusk/installer6/install/scripts/bootstrap_from_github.bash
# bash bootstrap_from_github.bash

mycwd="$PWD"

myrepo="https://github.com/mprentice/Opentusk.git"
mybranch="installer6"

echo
echo "##########"
echo "# Installing OpenTUSK and EPEL repos ..."
echo "##########"

cd /etc/yum.repos.d
curl -O https://raw.github.com/mprentice/Opentusk/$mybranch/install/opentusk.repo
yum install --quiet -y epel-release

echo
echo "##########"
echo "# Installing git ..."
echo "##########"

yum install --quiet -y git

echo
echo "##########"
echo "# Getting OpenTUSK branch $mybranch from $myrepo ..."
echo "##########"

mkdir --parents /usr/local/tusk
cd /usr/local/tusk
if [ ! -d Opentusk ] ; then
    git clone --branch $mybranch $myrepo
else
    echo
    echo "##########"
    echo "# Existing Opentusk found, skipped"
    echo "# (You can update later with \`git pull' if needed)"
    echo "##########"
    mv Opentusk "$mytmp"
fi

echo
echo "##########"
echo "# Installing opentusk.repo ..."
echo "##########"

cd Opentusk/install
cp opentusk.repo /etc/yum.repos.d/opentusk.repo

echo
echo "##########"
echo "# Installing yum packages ..."
echo "##########"

cd scripts
./install_yum_packages.bash

cd "$mycwd"
