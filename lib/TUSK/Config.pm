################
# * TUSK::Config
################

# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package TUSK::Config;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;
use Sys::Hostname;

use JSON;

use Types::Standard -types;

use TUSK::Constants;            # for now, get statics

use Moose;

####################
# * Class attributes
####################

has filename => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_filename',
);

has SiteWide => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_SiteWide',
);

has Domain => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_Domain',
);

has SiteAbbr => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteAbbr',
);

has SiteName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteName',
);

has Institution => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Institution',
);

has ShortName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ShortName',
);

has LongName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_LongName',
);

has Address => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_Address',
);

has Email => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_Email',
);

has Phone => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_Phone',
);

has CopyrightOrg => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_CopyrightOrg',
);

has UniqueID => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_UniqueID',
);

has Logo => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Logo',
);

has LargeLogo => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_LargeLogo',
);

has SmallLogo => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SmallLogo',
);

has flvplayer_skin_color => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_flvplayer_skin_color',
);

has GuestUserName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_GuestUserName',
);

has siteAdmins => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_siteAdmins',
);

has Default => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Default',
);

has DefaultDB => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_DefaultDB',
);

has DefaultSchool => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_DefaultSchool',
);

has Degrees => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_Degrees',
);

has Affiliations => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_Affiliations',
);

has Schools => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Schools',
);

has Path => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Path',
);

has MasonCacheRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_MasonCacheRoot',
);

has ServerRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ServerRoot',
);

has CodeRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_CodeRoot',
);

has LogRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_LogRoot',
);

has XSLRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_XSLRoot',
);

has XMLRulesPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_XMLRulesPath',
);

has MySQLDir => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_MySQLDir',
);

has Communication => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Communication',
);

has ErrorEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ErrorEmail',
);

has PageEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_PageEmail',
);

has FeedbackEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_FeedbackEmail',
);

has SupportEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SupportEmail',
);

has SupportPhone => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SupportPhone',
);

has AdminEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_AdminEmail',
);

has HomepageMessage => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_HomepageMessage',
);

has PrivacyNotice => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_PrivacyNotice',
);

has sendEmailUserWhenNoAffiliationOrGroup => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_sendEmailUserWhenNoAffiliationOrGroup',
);

has emailWhenNewUserLogsIn => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_emailWhenNewUserLogsIn',
);

has ExternalPasswordReset => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_ExternalPasswordReset',
);

has User => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_User',
);

has UserImagesPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_UserImagesPath',
);

has Content => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Content',
);

has PDFTextExtract => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_PDFTextExtract',
);

has PPTServiceEnabled => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_PPTServiceEnabled',
);

has TUSKdocServiceEnabled => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_TUSKdocServiceEnabled',
);

has BasePPTPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_BasePPTPath',
);

has BaseTUSKDocPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_BaseTUSKDocPath',
);

has FeedPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_FeedPath',
);

has TempPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_TempPath',
);

has BaseStaticPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_BaseStaticPath',
);

has BaseStreamPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_BaseStreamPath',
);

has FOPXMLPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_FOPXMLPath',
);

has FOPPDFPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_FOPPDFPath',
);

has Schedule => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Schedule',
);

has ScheduleMonthsDisplayedAtOnce => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_ScheduleMonthsDisplayedAtOnce',
);

has ScheduleDisplayMonthsInARow => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_ScheduleDisplayMonthsInARow',
);

has icsTimeZoneFile => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_icsTimeZoneFile',
);

has Evaluation => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Evaluation',
);

has EvalSaveDir => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_EvalSaveDir',
);

has evalErrorMessage => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_evalErrorMessage',
);

has Forum => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Forum',
);

has AttachUrlPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_AttachUrlPath',
);

has EmailProgram => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_EmailProgram',
);

has ForumAnimatedAvatar => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_ForumAnimatedAvatar',
);

has ForumAttachments => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ForumAttachments',
);

has ForumPolicy => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ForumPolicy',
);

has Tracking => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Tracking',
);

has UseTracking => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_UseTracking',
);

has TrackingString => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_TrackingString',
);

has Links => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Links',
);

has AboutURL => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_AboutURL',
);

has LoginPage => (
    is => 'ro',
    isa => HashRef[ ArrayRef[ HashRef[Str] ] ],
    lazy => 1,
    builder => '_build_LoginPage',
);

has Footer => (
    is => 'ro',
    isa => ArrayRef[ HashRef[Str] ],
    lazy => 1,
    builder => '_build_Footer',
);

has Authentication => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Authentication',
);

has LDAP => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_LDAP',
);

has UseLDAP => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_UseLDAP',
);

has LDAPServer => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_LDAPServer',
);

has DN => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_DN',
);

has LDAPPassword => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_LDAPPassword',
);

has useShibboleth => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_useShibboleth',
);

has PermissibleIPs => (
    is => 'ro',
    isa => ArrayRef[Str],
    lazy => 1,
    builder => '_build_PermissibleIPs',
);

has Authorization => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Authorization',
);

has DatabaseUsers => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_DatabaseUsers',
);

has ContentManager => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_ContentManager',
);

has readusername => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_readusername',
);

has readpassword => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_readpassword',
);

has writeusername => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_writeusername',
);

has writepassword => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_writepassword',
);

has Security => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_Security',
);

has CookieSecret => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_CookieSecret',
);

has CookieUsesUserID => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_CookieUsesUserID',
);

has RssSecret => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_RssSecret',
);

has Integration => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Integration',
);

    has Kaltura => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_Kaltura',
);

has Help => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_Help',
);

has HelpURLRoot => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_HelpURLRoot',
);

has Middleware => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Middleware',
);

has Servers => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Servers',
);

has HTTPD => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_HTTPD',
);

has maxApacheProcSize => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_maxApacheProcSize',
);

has securePort => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_securePort',
);

has Internationalization => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_Internationalization',
);

has I18N => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_I18N',
);

has SiteLanguage => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteLanguage',
);

has SiteDomain => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteDomain',
);

has SiteEnCoding => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteEnCoding',
);

has SiteLocale => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_SiteLocale',
);

has I18NDebug => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_I18NDebug',
);

has MaxAttachLen => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_MaxAttachLen',
);

has ForumEmail => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ForumEmail',
);

has ForumName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ForumName',
);

has HomeUrl => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_HomeUrl',
);

has HomeTitle => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_HomeTitle',
);

has ScriptUrlPath => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ScriptUrlPath',
);

has ForumPolicyTitle => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ForumPolicyTitle',
);

has useTimezone => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_useTimezone',
);

has Mailer => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_Mailer',
);

has release_stamp_3_6_1 => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_release_stamp_3_6_1',
);

has ContactURL => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ContactURL',
);

has evalGraphicsFormats => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_evalGraphicsFormats',
);

has EvalDTD => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_EvalDTD',
);

has WebError => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_WebError',
);

has EmailUserWhenNoAffiliationOrGroupText => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_EmailUserWhenNoAffiliationOrGroupText',
);

has Databases => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_Databases',
);


######################
# * Private Attributes
######################

has _json => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build__json',
);


#################
# * Class methods
#################

sub SchoolInitial {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return $self->Schools->{$school_name}{Initial};
}

sub SchoolShortName {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return $self->Schools->{$school_name}{ShortName};
}

sub SchoolDisplayName {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return $self->Schools->{$school_name}{DisplayName};
}

sub SchoolGroups {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return $self->Schools->{$school_name}{Groups};
}

sub SchoolWideUserGroup {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return 0 + $self->SchoolGroups($school_name)->{SchoolWideUserGroup};
}

sub SchoolAdmin {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return 0 + $self->SchoolGroups($school_name)->{SchoolAdmin};
}

sub EvalAdmin {
    my $self = shift;
    my $school_name = shift || $self->DefaultSchool;
    return 0 + $self->SchoolGroups($school_name)->{EvalAdmin};
}

sub ReadHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{ReadHost};
}

sub WriteHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{WriteHost};
}

sub SearchHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{SearchHost};
}

sub VideoHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{VideoHost};
}

sub AudioHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{AudioHost};
}

sub FlashPixHost {
    my $self = shift;
    my $server = shift || hostname;
    return $self->Servers->{$server}{FlashPixHost};
}

############
# * Builders
############

sub _build_filename {
    return $ENV{TUSKRC} || '/usr/local/tusk/conf/tusk.conf';
}

sub _build__json {
    my $self = shift;
    my $file = $self->filename;
    open my $fh, '<:utf8', $file or confess "Cannot read config file: $file";
    my $config = do { local $/; <$fh> };
    close $fh;
    my $json = decode_json $config;
    return $json;
}

sub _build_SiteWide {
    return shift->_json->{SiteWide};
}

sub _build_Domain {
    return shift->SiteWide->{Domain};
}

sub _build_SiteAbbr {
    return shift->SiteWide->{SiteAbbr};
}

sub _build_SiteName {
    return shift->SiteWide->{SiteName};
}

sub _build_Institution {
    return shift->SiteWide->{Institution};
}

sub _build_ShortName {
    return shift->Institution->{ShortName};
}

sub _build_LongName {
    return shift->Institution->{LongName};
}

sub _build_Address {
    return shift->Institution->{Address};
}

sub _build_Email {
    return shift->Institution->{Email};
}

sub _build_Phone {
    return shift->Institution->{Phone};
}

sub _build_CopyrightOrg {
    return shift->SiteWide->{CopyrightOrg};
}

sub _build_UniqueID {
    return shift->SiteName->{UniqueID};
}

sub _build_Logo {
    return shift->SiteName->{Logo};
}

sub _build_LargeLogo {
    return shift->Logo->{Large};
}

sub _build_SmallLogo {
    return shift->Logo->{Small};
}

sub _build_flvplayer_skin_color {
    return shift->SiteWide->{flvplayer_skin_color};
}

sub _build_GuestUserName {
    return shift->SiteWide->{GuestUserName};
}

sub _build_siteAdmins {
    return shift->SiteWide->{siteAdmins};
}

sub _build_Default {
    return shift->SiteWide->{Default};
}

sub _build_DefaultDB {
    return shift->Default->{DB};
}

sub _build_DefaultSchool {
    return shift->Default->{School};
}

sub _build_Degrees {
    return shift->SiteWide->{Degrees};
}

sub _build_Affiliations {
    return shift->SiteWide->{Affiliations};
}

sub _build_Schools {
    return shift->SiteWide->{Schools};
}

sub _build_Path {
    return shift->_json->{Path};
}

sub _build_MasonCacheRoot {
    return shift->Path->{MasonCacheRoot};
}

sub _build_ServerRoot {
    return shift->Path->{ServerRoot};
}

sub _build_CodeRoot {
    return shift->Path->{CodeRoot};
}

sub _build_LogRoot {
    return shift->Path->{LogRoot};
}

sub _build_XSLRoot {
    return shift->Path->{XSLRoot};
}

sub _build_XMLRulesPath {
    return shift->Path->{XMLRulesPath};
}

sub _build_MySQLDir {
    return shift->Path->{MySQLDir};
}

sub _build_Communication {
    return shift->_json->{Communication};
}

sub _build_ErrorEmail {
    return shift->Communication->{ErrorEmail};
}

sub _build_PageEmail {
    return shift->Communication->{PageEmail};
}

sub _build_FeedbackEmail {
    return shift->Communication->{FeedbackEmail};
}

sub _build_SupportEmail {
    return shift->Communication->{SupportEmail};
}

sub _build_SupportPhone {
    return shift->Communication->{SupportPhone};
}

sub _build_AdminEmail {
    return shift->Communication->{AdminEmail};
}

sub _build_HomepageMessage {
    return shift->Communication->{HomepageMessage};
}

sub _build_PrivacyNotice {
    return shift->Communication->{PrivacyNotice};
}

sub _build_sendEmailUserWhenNoAffiliationOrGroup {
    return
        shift->Communication->{sendEmailUserWhenNoAffiliationOrGroup} eq "1";
}

sub _build_emailWhenNewUserLogsIn {
    return shift->Communication->{emailWhenNewUserLogsIn} eq "1";
}

sub _build_ExternalPasswordReset {
    return shift->Communication->{ExternalPasswordReset} eq "1";
}

sub _build_User {
    return shift->_json->{User};
}

sub _build_UserImagesPath {
    return shift->User->{UserImagesPath};
}

sub _build_Content {
    return shift->_json->{Content};
}

sub _build_PDFTextExtract {
    return shift->Content->{PDFTextExtract};
}

sub _build_PPTServiceEnabled {
    return shift->Content->{PPTServiceEnabled} eq "1";
}

sub _build_TUSKdocServiceEnabled {
    return shift->Content->{TUSKdocServiceEnabled} eq "1";
}

sub _build_BasePPTPath {
    return shift->Content->{BasePPTPath};
}

sub _build_BaseTUSKDocPath {
    return shift->Content->{BaseTUSKDocPath};
}

sub _build_FeedPath {
    return shift->Content->{FeedPath};
}

sub _build_TempPath {
    return shift->Content->{TempPath};
}

sub _build_BaseStaticPath {
    return shift->Content->{BaseStaticPath};
}

sub _build_BaseStreamPath {
    return shift->Content->{BaseStreamPath};
}

sub _build_FOPXMLPath {
    return shift->Content->{FOPXMLPath};
}

sub _build_FOPPDFPath {
    return shift->Content->{FOPPDFPath};
}

sub _build_Schedule {
    return shift->_json->{Schedule};
}

sub _build_ScheduleMonthsDisplayedAtOnce {
    return 0 + shift->Schedule->{ScheduleMonthsDisplayedAtOnce};
}

sub _build_ScheduleDisplayMonthsInARow {
    return 0 + shift->Schedule->{ScheduleDisplayMonthsInARow};
}

sub _build_icsTimeZoneFile {
    return shift->Schedule->{icsTimeZoneFile};
}

sub _build_Evaluation {
    return shift->_json->{Evaluation};
}

sub _build_EvalSaveDir {
    return shift->Evaluation->{EvalSaveDir};
}

sub _build_evalErrorMessage {
    return shift->Evaluation->{evalErrorMessage};
}

sub _build_Forum {
    return shift->_json->{Forum};
}

sub _build_AttachUrlPath {
    return shift->Forum->{AttachUrlPath};
}

sub _build_EmailProgram {
    return shift->Forum->{EmailProgram};
}

sub _build_ForumAnimatedAvatar {
    return shift->Forum->{ForumAnimatedAvatar} eq "1";
}

sub _build_ForumAttachments {
    return shift->Forum->{ForumAttachments};
}

sub _build_ForumPolicy {
    return shift->Forum->{ForumPolicy};
}

sub _build_Tracking {
    return shift->_json->{Tracking};
}

sub _build_UseTracking {
    return shift->Tracking->{UseTracking} eq "1";
}

sub _build_TrackingString {
    return shift->Tracking->{TrackingString};
}

sub _build_Links {
    return shift->_json->{Links};
}

sub _build_AboutURL {
    return shift->Links->{AboutURL};
}

sub _build_LoginPage {
    return shift->Links->{LoginPage};
}

sub _build_Footer {
    return shift->Links->{Footer};
}

sub _build_Authentication {
    return shift->_json->{Authentication};
}

sub _build_LDAP {
    return shift->Authentication->{LDAP};
}

sub _build_UseLDAP {
    return shift->LDAP->{UseLDAP} eq "1";
}

sub _build_LDAPServer {
    return shift->LDAP->{SERVER};
}

sub _build_DN {
    return shift->LDAP->{DN};
}

sub _build_LDAPPassword {
    return shift->LDAP->{PASSWORD};
}

sub _build_useShibboleth {
    return shift->Authentication->{useShibboleth} eq "1";
}

sub _build_PermissibleIPs {
    return shift->Authentication->{PermissibleIPs};
}

sub _build_Authorization {
    return shift->_json->{Authorization};
}

sub _build_DatabaseUsers {
    return shift->Authorization->{DatabaseUsers};
}

sub _build_ContentManager {
    return shift->DatabaseUsers->{ContentManager};
}

sub _build_readusername {
    return shift->ContentManager->{readusername};
}

sub _build_readpassword {
    return shift->ContentManager->{readpassword};
}

sub _build_writeusername {
    return shift->ContentManager->{writerusername};
}

sub _build_writepassword {
    return shift->ContentManager->{writepassword};
}

sub _build_Security {
    return shift->_json->{Security};
}

sub _build_CookieSecret {
    return shift->Security->{CookieSecret};
}

sub _build_CookieUsesUserID {
    return shift->Security->{CookieUsesUserID} eq "1";
}

sub _build_RssSecret {
    return shift->Security->{RssSecret};
}

sub _build_Integration {
    return shift->_json->{Integration};
}

sub _build_Kaltura {
    return shift->Integration->{Kaltura};
}

sub _build_Help {
    return shift->_json->{Help};
}

sub _build_HelpURLRoot {
    return shift->Help->{HelpURLRoot};
}

sub _build_Middleware {
    return shift->_json->{Middleware};
}

sub _build_Servers {
    return shift->Middleware->{Servers};
}

sub _build_HTTPD {
    return shift->_json->{HTTPD};
}

sub _build_maxApacheProcSize {
    return 0 + shift->HTTPD->{maxApacheProcSize};
}

sub _build_securePort {
    return 0 + shift->HTTPD->{securePort};
}

sub _build_Internationalization {
    return shift->_json->{Internationalization};
}

sub _build_I18N {
    return shift->Internationalization->{I18N};
}

sub _build_SiteLanguage {
    return shift->I18N->{SiteLanguage};
}

sub _build_SiteDomain {
    return shift->I18N->{SiteDomain};
}

sub _build_SiteEnCoding {
    return shift->I18N->{SiteEnCoding};
}

sub _build_SiteLocale {
    return shift->I18N->{SiteLocale};
}

sub _build_I18NDebug {
    return shift->I18N->{Debug} eq "1";
}

sub _build_MaxAttachLen {
    return 0 + $TUSK::Constants::MaxAttachLen;
}

sub _build_ForumEmail {
    return $TUSK::Constants::ForumEmail;
}

sub _build_ForumName {
    return $TUSK::Constants::ForumName;
}

sub _build_HomeUrl {
    return $TUSK::Constants::HomeUrl;
}

sub _build_HomeTitle {
    return $TUSK::Constants::HomeTitle;
}

sub _build_ScriptUrlPath {
    return $TUSK::Constants::ScriptUrlPath;
}

sub _build_ForumPolicyTitle {
    return $TUSK::Constants::ForumPolicyTitle;
}

sub _build_useTimezone {
    return $TUSK::Constants::userTimezone;
}

sub _build_Mailer {
    return $TUSK::Constants::Mailer;
}

sub _build_release_stamp_3_6_1 {
    return $TUSK::Constants::release_stamp_3_6_1;
}

sub _build_ContactURL {
    return $TUSK::Constants::ContactURL;
}

sub _build_evalGraphicsFormats {
    return \@TUSK::Constants::evalGraphicsFormats;
}

sub _build_EvalDTD {
    return $TUSK::Constants::EvalDTD;
}

sub _build_WebError {
    return $TUSK::Constants::WebError;
}

sub _build_EmailUserWhenNoAffiliationOrGroupText {
    return $TUSK::Constants::EmailUserWhenNoAffiliationOrGroupText;
}

sub _build_Databases {
    return \%TUSK::Constants::Databases;
}


###################
# * Private Methods
###################

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::Config - Configuration settings for TUSK

=head1 VERSION

This documentation refers to L<TUSK::Config> v0.0.1.

=head1 SYNOPSIS

  # For regular use, will load from $ENV{TUSKRC} if it exists,
  # or /usr/local/tusk/conf/tusk.conf if not.
  use TUSK::Config;
  my $cfg = TUSK::Config->new;
  print $cfg->Domain . "\n";

  # Specify filename to load from:
  my $custom = TUSK::Config->new(filename => "/path/to/my/conf.json");

=head1 DESCRIPTION

This file is a closely name-compatible translation of
L<TUSK::Constants> using L<Moose>. What this means is that where
possible, L<TUSK::Config> attribute names are the same as the
``variable'' names in L<TUSK::Constants>.

This file is meant to eventually replace L<TUSK::Constants> with a
more sane configuration system with optional local configurations and
global defaults, like that used in L<Poet> projects.

=head1 ATTRIBUTES

Please refer to install/templates/conf/tusk/tusk.conf.explain for
documentation of the tusk.conf JSON configuration file.

Further attributes are from the static initialization section of
L<TUSK::Constants>.

The differences between names in tusk.conf and L<TUSK::Config>
attributes are:

=over 4

=item * DefaultDB

Equivalent to $L<TUSK::Constants>::Default{DB}.

=item * DefaultSchool

Equivalent to $L<TUSK::Constants>::Default{School}.

=item * LDAPServer

Equivalent to $L<TUSK::Constants>::LDAP{SERVER}.

=item * LDAPPassword

Equivalent to $L<TUSK::Constants>::LDAP{PASSWORD}.

=back

=head1 METHODS

L<TUSK::Config> provides several convenience functions for access to
school-specific and server-specific settings in tusk.conf.

=over 4

=item * School methods

The school methods accept an optional school name argument. Uses
DefaultSchool if no argument given.

$cfg->School<key>(<school_name>) is equivalent to
$L<TUSK::Constants>::Schools{<school_name>}->{<key>}.

For example, $cfg->SchoolInitial('Medical') is equivalent to
$L<TUSK::Constants>::Schools{Medical}->{Initial}.

=over 4

=item * SchoolInitial

=item * SchoolShortName

=item * SchoolDisplayName

=item * SchoolGroups

=item * School group methods

The following methods are equivalent to
$L<TUSK::Constants>::Schools{<school_name>}->{Groups}{<key>}, where
<key> is the method name.

=over 4

=item * SchoolWideUserGroup

=item * SchoolAdmin

=item * EvalAdmin

=back

=back

=item * Server methods

The server methods accept an optional server name argument. Uses
L<Sys::Hostname>::hostname if no argument given.

$cfg-><method>(<host>) is equivalent to
$L<TUSK::Constants>::Servers{<host>}->{<method>}.

For example, $cfg->ReadHost() is equivalent to
$L<TUSK::Constants>::Servers{hostname()}->{ReadHost}.

=over 4

=item * ReadHost

=item * WriteHost

=item * SearchHost

=item * VideoHost

=item * AudioHost

=item * FlashPixHost

=back

=back

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

TUSK modules depend on properly set constants in the configuration
file loaded by L<TUSK::Constants>. See the documentation for
L<TUSK::Constants> for more detail.

L<TUSK::Config> loads most settings directly from tusk.conf rather
than delegating to L<TUSK::Constants>. L<TUSK::Config> will load from
the file specified by $ENV{TUSKRC} if the environment variable is set.
L<TUSK::Config> falls back on loading /usr/local/tusk/conf/tusk.conf
if $ENV{TUSKRC} is not set.

=head1 INCOMPATIBILITIES

This module has no known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please report problems to the
TUSK development team (tusk@tufts.edu) Patches are welcome.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tufts University

Licensed under the Educational Community License, Version 1.0 (the
"License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
