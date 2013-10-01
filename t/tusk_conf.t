#!/usr/bin/env perl
# Test TUSK configuration and constants

use Test::More;
use Test::Files;

use TUSK::Constants;
use Sys::Hostname;

my $test_count = 0;

# Database
ok(defined $TUSK::Constants::MySQLDir, "MySQLDir defined");
dir_contains_ok($TUSK::Constants::MySQLDir, ['mysql'], "mysql command found");
ok(exists $TUSK::Constants::DatabaseUsers{ContentManager},
   "DatabaseUsers has ContentManager");
ok(exists $TUSK::Constants::DatabaseUsers{ContentManager}{readusername},
   "ContentManager has readusername");
ok(exists $TUSK::Constants::DatabaseUsers{ContentManager}{writeusername},
   "ContentManager has writeusername");
ok(exists $TUSK::Constants::DatabaseUsers{ContentManager}{readpassword},
   "ContentManager has readpassword");
ok(exists $TUSK::Constants::DatabaseUsers{ContentManager}{writepassword},
   "ContentManager has writepassword");
ok(exists $TUSK::Constants::Servers{Sys::Hostname::hostname},
  "Servers has entry for hostname " . Sys::Hostname::hostname);
$test_count += 8;

ok(exists $TUSK::Constants::Databases{mwforum},
   "mwforum database defined");
ok(exists $TUSK::Constants::Databases{fts},
   "fts database defined");
ok(exists $TUSK::Constants::Databases{hsdb4},
   "hsdb4 database defined");
ok(exists $TUSK::Constants::Databases{tusk},
   "tusk database defined");
$test_count += 4;

foreach my $dbhost (keys %TUSK::Constants::Servers) {
  ok(exists $TUSK::Constants::Servers{$dbhost}{ReadHost},
     "ReadHost defined for hostname " . $dbhost);
  ok(exists $TUSK::Constants::Servers{$dbhost}{WriteHost},
     "WriteHost defined for hostname " . $dbhost);
  ok(exists $TUSK::Constants::Servers{$dbhost}{SearchHost},
     "SearchHost defined for hostname " . $dbhost);
  ok(exists $TUSK::Constants::Servers{$dbhost}{VideoHost},
     "VideoHost defined for hostname " . $dbhost);
  ok(exists $TUSK::Constants::Servers{$dbhost}{AudioHost},
     "AudioHost defined for hostname " . $dbhost);
  ok(exists $TUSK::Constants::Servers{$dbhost}{FlashPixHost},
     "FlashPixHost defined for hostname " . $dbhost);
  $test_count += 6;
}
ok(defined $TUSK::Constants::DefaultDB, "DefaultDB defined");
$test_count++;

# Top-level definitions
ok(defined $TUSK::Constants::BaseStaticPath, "BaseStaticPath defined");
ok(defined $TUSK::Constants::flvplayer_skin_color,
   "flvplayer_skin_color defined");
ok(defined $TUSK::Constants::TempPath, "TempPath defined");
ok(defined $TUSK::Constants::BasePPTPath, "BasePPTPath defined");
ok(defined $TUSK::Constants::AdminEmail, "AdminEmail defined");
$test_count += 5;

ok(defined $TUSK::Constants::ErrorEmail, "ErrorEmail defined");
ok(defined $TUSK::Constants::SupportEmail, "SupportEmail defined");
ok(defined $TUSK::Constants::SupportPhone, "SupportPhone defined");
ok(defined $TUSK::Constants::PageEmail, "PageEmail defined");
ok(defined $TUSK::Constants::CookieSecret, "CookieSecret defined");
ok(defined $TUSK::Constants::CookieUsesUserID, "CookieUsesUserID defined");
$test_count += 6;

ok(defined $TUSK::Constants::Domain, "Domain defined");
ok(defined $TUSK::Constants::securePort, "securePort defined");
ok(defined $TUSK::Constants::ScheduleMonthsDisplayedAtOnce,
  "ScheduleMonthsDisplayedAtOnce defined");
ok(defined $TUSK::Constants::SiteAbbr, "SiteAbbr defined");
ok(defined $TUSK::Constants::SiteName, "SiteName defined");
$test_count += 5;

ok(defined $TUSK::Constants::SystemWideUserGroup,
   "SystemWideUserGroup defined");
ok(defined $TUSK::Constants::SystemWideUserGroupSchool,
   "SystemWideUserGroupSchool defined");
ok(defined $TUSK::Constants::UserImagesPath, "UserImagesPath defined");
ok(defined $TUSK::Constants::XMLRulesPath, "XMLRulesPath defined");
ok(defined $TUSK::Constants::emailWhenNewUserLogsIn,
   "emailWhenNewUserLogsIn defined");
$test_count += 5;

ok(defined $TUSK::Constants::EvalDTD,
   "EvalDTD defined");
ok(defined $TUSK::Constants::release_stamp_3_6_1,
   "release_stamp_3_6_1 defined");
ok(scalar(@TUSK::Constants::evalGraphicsFormats) > 0,
   "evalGraphicsFormats defined");
cmp_ok(scalar @TUSK::Constants::siteAdmins, '>', 0, "siteAdmins exist");
ok(defined $TUSK::Constants::ServerRoot,
   "ServerRoot defined");
$test_count += 5;

ok(defined $TUSK::Constants::LogRoot,
   "LogRoot defined");
ok(defined $TUSK::Constants::BaseStreamPath,
   "BaseStreamPath defined");
ok(defined $TUSK::Constants::BaseTUSKDocPath,
   "BaseTUSKDocPath defined");
ok(defined $TUSK::Constants::FOPXMLPath,
   "FOPXMLPath defined");
ok(defined $TUSK::Constants::XSLRoot,
   "XSLRoot defined");
$test_count += 5;

ok(defined $TUSK::Constants::FOPPDFPath,
   "FOPPDFPath defined");
ok(defined $TUSK::Constants::icsTimeZoneFile,
   "icsTimeZoneFile defined");
dir_contains_ok($TUSK::Constants::ServerRoot . "/addons/ics",
                [$TUSK::Constants::icsTimeZoneFile . '.tz'],
                "icsTimeZoneFile file found");
$test_count += 3;

# Indexer
# Some of these are optional components.
# TODO: Find a graceful way to test presence/absence of optional components.
if (defined $TUSK::Constants::MMTxExecutable) {
    ok(-e $TUSK::Constants::MMTxExecutable, "MMTxExecutable file found");
    cmp_ok($TUSK::Constants::MMTxIndexerTimeout, '>=', 1,
           "MMTxIndexerTimeout >= 1 second");
    $test_count+= 2;
}
if (defined $TUSK::Constants::WordTextExtract) {
    ok(-e $TUSK::Constants::WordTextExtract,
       "WordTextExtract executable found");
    $test_count++;
}
ok(defined $TUSK::Constants::PDFTextExtract, "PDFTextExtract defined");
ok(-e $TUSK::Constants::PDFTextExtract, "PDFTextExtract executable found");
$test_count += 2;

# LDAP
ok(exists $TUSK::Constants::LDAP{UseLDAP}, "LDAP has UseLDAP");
$test_count++;
if ($TUSK::Constants::LDAP{UseLDAP}) {
    ok(defined $TUSK::Constants::SendEmailUserWhenNoAffiliationOrGroup,
       "SendEmailUserWhenNoAffiliationOrGroup defined");
    ok(defined $TUSK::Constants::EmailUserWhenNoAffiliationOrGroupText,
       "EmailUserWhenNoAffiliationOrGroupText defined");
    $test_count += 2;
}

# Shibboleth
ok(defined $TUSK::Constants::useShibboleth, "useShibboleth defined");
$test_count++;
if ($TUSK::Constants::useShibboleth) {
    ok(defined $TUSK::Constants::shibbolethUserID, "shibbolethUserID defined");
    ok(defined $TUSK::Constants::shibbolethSP,
       "shibbolethSP defined");
    ok(defined $TUSK::Constants::shibSPSecurePort,
       "shibSPSecurePort defined");
    $test_count += 3;
}

# Institution
ok(exists $TUSK::Constants::Institution{Email}, "Institution{Email}");
ok(exists $TUSK::Constants::Institution{Phone}, "Institution{Phone}");
ok(exists $TUSK::Constants::Institution{Address}, "Institution{Address}");
ok(exists $TUSK::Constants::Institution{ShortName}, "Institution{ShortName}");
$test_count += 4;

# Forum
ok(defined $TUSK::Constants::EmailProgram, "EmailProgram defined");
ok(defined $TUSK::Constants::AttachUrlPath, "AttachUrlPath defined");
ok(defined $TUSK::Constants::ForumAnimatedAvatar, 
   "ForumAnimatedAvatar defined");
ok(defined $TUSK::Constants::ForumAttachments, "ForumAttachments defined");
ok(defined $TUSK::Constants::ForumPolicy, "ForumPolicy defined");
$test_count += 5;

ok(defined $TUSK::Constants::ForumName, "ForumName defined");
ok(defined $TUSK::Constants::HomeUrl, "HomeUrl defined");
ok(defined $TUSK::Constants::HomeTitle, "HomeTitle defined");
ok(defined $TUSK::Constants::ScriptUrlPath, "ScriptUrlPath defined");
ok(defined $TUSK::Constants::ForumPolicyTitle, "ForumPolicyTitle defined");
$test_count += 5;

ok(defined $TUSK::Constants::Mailer, "Mailer defined");
ok(defined $TUSK::Constants::MaxAttachLen, "MaxAttachLen defined");
ok(defined $TUSK::Constants::ForumEmail, "ForumEmail defined");
ok(defined $TUSK::Constants::WebError, "WebError defined");
ok(defined $TUSK::Constants::WebError, "WebError defined");
$test_count += 5;

ok(defined $TUSK::Constants::FeedPath, "FeedPath defined");
$test_count++;

ok(scalar(@TUSK::Constants::PermissibleIPs) > 0, "Items in PermissibleIPs list");
$test_count++;

# Schools
ok(%TUSK::Constants::Schools, "Schools defined");
$test_count++;
foreach my $school (keys %TUSK::Constants::Schools) {
  ok(exists $TUSK::Constants::Schools{$school}{Initial},
     "Initial defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{ShortName},
     "ShortName defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{DisplayName},
     "DisplayName defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{Groups},
     "Groups defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{Groups}{SchoolWideUserGroup},
     "SchoolWideUserGroup defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{Groups}{SchoolAdmin},
     "SchoolAdmin defined for school $school");
  ok(exists $TUSK::Constants::Schools{$school}{Groups}{EvalAdmin},
     "EvalAdmin defined for school $school");
  $test_count += 7;
}

done_testing($test_count);
