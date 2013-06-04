#! /bin/bash

# IMPORTANT: In order for the following to work, first copy
# the file install/opentusk.repo to /etc/yum.repos.d/opentusk.repo

# Utility functions

function _os_release {
    local _os_value=`grep -o '[Rr]elease [[:digit:]]\.\?[[:digit:]]*' /etc/redhat-release`
    echo "$_os_value"
}
function _os_major_version {
    local _os_maj=$(_os_release)
    echo `echo "$_os_maj" | sed 's/^[Rr]elease \([0-9]\).*$/\1/'`
}
myversion=$(_os_major_version)

function _yum_install {
    # --assumeyes not available in CentOS 5.x
    yum install --quiet -y "$1"
}

function _yum_install_nocheck {
    yum install --nogpgcheck --quiet -y "$1"
}

function _yum_install_rpmforge {
    yum install --quiet -y --enablerepo=rpmforge "$1"
}

# Install repos

_yum_install_nocheck opentusk-release
_yum_install_nocheck epel-release
_yum_install_nocheck rpmforge-release
_yum_install epel-release
_yum_install_rpmforge rpmforge-release

# Disable rpmforge to avoid unexpected upgrades

if [ "$myversion" = 5 ] ; then
    # yum-config-manager not available in CentOS 5.8
    sed -i 's/^enabled\s*=\s*1/enabled = 0/g' /etc/yum.repos.d/rpmforge.repo
elif [ "$myversion" = 6 ] ; then
    _yum_install yum-utils
    yum-config-manager --disable rpmforge
else
    echo "Unrecognized OS major version: $myversion"
    exit 1
fi

# Install httpd, sometimes called Apache 2, and MySQL for our LAMP stack
# Note: This will create the 'apache' and 'mysql' users and groups we use later

_yum_install httpd
_yum_install mod_perl
_yum_install mod_perl-devel
_yum_install mod_ssl
_yum_install mysql
_yum_install mysql-server
_yum_install mysql-devel

# Install utility and helper packages

_yum_install ImageMagick-perl
_yum_install expat-devel
_yum_install gdbm-devel
_yum_install git
_yum_install lftp
_yum_install libXpm
_yum_install libapreq2
_yum_install perl-libapreq2
_yum_install poppler-utils
_yum_install ncftp
_yum_install xorg-x11-xauth
_yum_install wget
_yum_install python-demjson
_yum_install gd
_yum_install gd-devel

# Install Perl modules

_yum_install 'perl(Readonly)'
_yum_install 'perl(IPC::Run3)'
_yum_install 'perl(Moose)'
_yum_install 'perl(Apache::DBI)'
_yum_install 'perl(Apache::Session::Wrapper)'
_yum_install 'perl(Apache2::Request)'
_yum_install 'perl(Archive::Zip)'
_yum_install 'perl(Date::Calc)'
_yum_install 'perl(Date::Manip)'
_yum_install 'perl(DBD::mysql)'
_yum_install 'perl(Email::Date::Format)'
_yum_install 'perl(GD)'
_yum_install 'perl(GD::Text)'
_yum_install 'perl(GD::Graph)'
_yum_install 'perl(IO::Stringy)'
_yum_install 'perl(Image::ExifTool)'
_yum_install 'perl(Image::Size)'
_yum_install 'perl(JSON)'
_yum_install 'perl(Locale::TextDomain)'
_yum_install 'perl(Log::Log4perl)'
_yum_install 'perl(MIME::Lite)'
_yum_install 'perl(Mail::Sendmail)'
_yum_install 'perl(Parse::RecDescent)'
_yum_install 'perl(Proc::ProcessTable)'
_yum_install 'perl(Net::LDAPS)'
_yum_install 'perl(Spreadsheet::WriteExcel)'
_yum_install 'perl(Term::ReadLine::Gnu)'
_yum_install 'perl(Term::ReadKey)'
_yum_install 'perl(Test::Base)'
_yum_install 'perl(Unicode::String)'
_yum_install 'perl(XML::Parser)'
_yum_install 'perl(XML::LibXSLT)'
_yum_install 'perl(Log::Any)'
_yum_install 'perl(Test::Deep)'
_yum_install 'perl(Linux::Pid)'
_yum_install 'perl(XML::SAX::Writer)'
_yum_install 'perl(YAML)'
_yum_install 'perl(Statistics::Descriptive)'
_yum_install_nocheck 'perl(HTML::Defang)'
_yum_install_nocheck 'perl(HTML::Mason)'
_yum_install_nocheck 'perl(MasonX::Request::WithApacheSession)'
_yum_install_nocheck tusk-perl-XML-Twig
_yum_install_rpmforge 'perl(Devel::Size)'
_yum_install_rpmforge 'perl(HTML::Strip)'
_yum_install_rpmforge 'perl(Sys::MemInfo)'
_yum_install_rpmforge 'perl(File::Type)'
