#! /bin/sh
#
# Install httpd, sometimes called Apache 2, and MySQL for our LAMP stack
# Note: This will create the 'apache' and 'mysql' users and groups we use later

yum install -q -y httpd mod_perl mod_perl-devel mod_ssl
yum install -q -y mysql mysql-server mysql-devel

# Install utility and helper packages

yum install -q -y ImageMagick-perl
yum install -q -y expat-devel
yum install -q -y gdbm-devel
yum install -q -y git
yum install -q -y lftp
yum install -q -y libXpm
yum install -q -y libapreq2
yum install -q -y perl-libapreq2
yum install -q -y poppler-utils
yum install -q -y ncftp
yum install -q -y xorg-x11-xauth
yum install -q -y wget

# Install Perl modules

yum install -q -y 'perl(Apache::DBI)'
yum install -q -y 'perl(Apache::Session::Wrapper)'
yum install -q -y 'perl(Apache2::Request)'
yum install -q -y 'perl(Archive::Zip)'
yum install -q -y 'perl(Date::Calc)'
yum install -q -y 'perl(Date::Manip)'
yum install -q -y 'perl(DBD::mysql)'
yum install -q -y 'perl(Email::Date::Format)'
yum install -q -y 'perl(GD)'
yum install -q -y 'perl(GD::Text)'
yum install -q -y 'perl(IO::Stringy)'
yum install -q -y 'perl(Image::ExifTool)'
yum install -q -y 'perl(Image::Size)'
yum install -q -y 'perl(JSON)'
yum install -q -y 'perl(Locale::TextDomain)'
yum install -q -y 'perl(Log::Log4perl)'
yum install -q -y 'perl(MIME::Lite)'
yum install -q -y 'perl(Mail::Sendmail)'
yum install -q -y 'perl(Parse::RecDescent)'
yum install -q -y 'perl(Net::LDAPS)'
yum install -q -y 'perl(Spreadsheet::WriteExcel)'
yum install -q -y 'perl(Term::ReadLine::Gnu)'
yum install -q -y 'perl(Term::ReadKey)'
yum install -q -y 'perl(Test::Base)'
yum install -q -y 'perl(Unicode::String)'
yum install -q -y 'perl(XML::Parser)'
yum install -q -y 'perl(XML::LibXSLT)'
yum install -q -y 'perl(Log::Any)'
yum install -q -y 'perl(Test::Deep)'
yum install -q -y 'perl(Linux::Pid)'
yum install -q -y 'perl(XML::SAX::Writer)'
yum install -q -y 'perl(YAML)'
yum install -q -y --nogpgcheck 'perl(HTML::Defang)'
yum install -q -y --nogpgcheck 'perl(HTML::Mason)'
yum install -q -y --nogpgcheck 'perl(MasonX::Request::WithApacheSession)'
yum install -q -y --nogpgcheck tusk-perl-XML-Twig
yum install -q -y --enablerepo=rpmforge 'perl(Devel::Size)'
yum install -q -y --enablerepo=rpmforge 'perl(HTML::Strip)'
yum install -q -y --enablerepo=rpmforge 'perl(Sys::MemInfo)'
yum install -q -y --enablerepo=rpmforge 'perl(File::Type)'
