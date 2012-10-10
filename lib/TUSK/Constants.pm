package TUSK::Constants;

use strict;
use Sys::Hostname;

## Domain is used in outputting HTML and XML with pointers to resources on the server
our $Domain = 'TUSKFQDN';

## CookieSecret is used in creating the cookie hash
our $CookieSecret = 'mysecretword';
## CookieUsesUserID, if set, will put the userID directly into the Embperl cookie. If unset the cookie will use Apache::Session as a userID
our $CookieUsesUserID = '0';

## DefaultDB is the database specified when creating connections
our $DefaultDB = "hsdb4";

## ErrorEmail and PageEmail are used for alerts about server errors
our $ErrorEmail = 'error@hss.edu';
our $PageEmail = 'pager@hss.edu';
our $emailProgram = '/usr/lib/sendmail -t';

## SupportEmail is used for places were we list the email address to contact
our $SupportEmail = 'support@hss.edu';
our $FeedbackEmail = 'feedback@hss.edu';
our $SupportPhone = '123-456-7890';
#This is used on the contact us page
our @SupportAddress = ('Building One, Suite 1', 'One Science Road', 'Boston, MA 02134');

## Variables used for display on HTML pages
## SiteAbbr and SiteName are used throughout the site for display
our $SchoolShort = 'HS';
our $SchoolName = 'HS University';
our $SiteAbbr = 'HS';
our $SiteName = 'Health Sciences School';

## Forum Variables
our $MaxAttachLen = '10000000';
our $ForumAttachments = '/data/forum_data/';
our $ForumEmail = $SupportEmail;
our $ForumName = $SiteAbbr . ' Forum';
our $HomeUrl = ''; # leave this blank to disable the home link in the top forum bar
our $HomeTitle = $SiteAbbr;
our $AttachUrlPath = '/forum_attachments';
our $ScriptUrlPath = '/forum';
our $ForumPolicyTitle = $ForumName . ' Policy';
our $ForumPolicy = "Forum policy message";
our $ForumAnimatedAvatar = 0;
our $userTimezone = "-5";
our $Mailer = "sendmail";

## URLs control the top right blue button links
#THIS IS THE HELP URL FOR TUSK PROD
our $HelpURL = '/view/course/HSDB/1185';
#AND THIS IS THE ONE FOR THE LOCAL CONTENT
#our $HelpURL = '/view/course/HSDB/1443';
our %HelpMap = (
	'patientLogs' => '471802/490014',
	'printPDF' => '385575',
	'search' => '',	
	'evalPrinting' => '920118',
	'evalStatisticsDef' => '920119',
	'multiContentUpload' => '1247632',
);
our $ManageHelpURL = '/view/course/HSDB/1185';
our $FAQURL = '/view/content/135650';
our $PDAHelpURL = '/view/content/922403';
our $AboutURL = '/about/';
our $ContactURL = '/about/contact_us';
our $DeepHelpLinksOn = 1;
our $PPTServiceEnabled = 1;
our $TUSKdocServiceEnabled = 1;

## FLV Player values
our $flvplayer_skin_color  = "999999";

## Should the schedule be protected by a password?
our $schedulePasswordProtected = 1;
our $scheduleMonthsDisplayedAtOnce = 6;
our $scheduleDisplayMonthsInARow = 1;
## Whatever is set here must have a cooresponding file: addons/ics/${TUSK::Constants::icsTimeZoneFile}.tz
our $icsTimeZoneFile = "America.New_York";


## should LDAP be checked for new users?
our $UseLDAP = 1;
our $externalPasswordReset = "";

our $emailWhenNewUserLogsIn = 1;
# Set this to nothing if you do not want a new user notified if they do not have a group
our $emailUserWhenNoAffiliationOrGroup  = "Hello and thank you for using the $TUSK::Constants::SiteAbbr system.\nWe were unable to determine the school or group with which you are affiliated.\nPlease reply to this email and let us know your school affiliation and, if you are a student, please include your year of graduation.\n\n$TUSK::Constants::SiteAbbr Support\n$TUSK::Constants::SupportEmail\n$TUSK::Constants::SupportPhone\n" .  join("\n", @TUSK::Constants::SupportAddress);

## Paths to Files in File System
our $DownloadableFilePath = '/data/html/downloadable_file';
our $PDFPath = '/data/html/web-auth/pdf';

## Location of spacer gif
our $SpacerGIF = '/data/html/graphics/icons/spacer.gif';

## Location of user (student) images
our $userImagesPath = '/data/html/images/users';

## Text Extraction Utilities
our $WordTextExtract = '/usr/local/bin/antiword';
our $PDFTextExtract = '/usr/local/bin/pdftotext';

## UMLS executable for MMTx
our $mmtxExecutable = '/data/umls/nls/mmtx/bin/MMTx';

## mysql and mysqldump command location
#our $mysqlDir = '/usr/local/mysql/bin';
our $mysqlDir = '/usr/bin';

## fop command location
our $fopCmd = '/usr/local/fop/fop.sh';
#our $fopCmd = '/usr/bin/fop';

## For Apache::SizeLimit and Apache's MaxClient calculations, in KB
our $maxApacheProcSize = 92160;

## CopyrightOrg is inserted into CMS copyright boxes,
## pre-populated with 'Copyright <current year>, <CopyrightOrg>'
our $CopyrightOrg = 'HS University';

## SystemWideUserGroupSchool and SystemWideUserGroup are used for announcement broadcasting.
## Announcements in this school and group will appear for all users in the system
our $SystemWideUserGroupSchool = 'default';
our $SystemWideUserGroup = '666';

## $SchoolWideUserGroup is a school-based value that tells what usergroup
## is used for announcements to the whole school. If not present, the code should default
## to the value of the $SystemWideUserGroup
our $SchoolWideUserGroup = {'default' => 3,
			    };

## affiliations are used for the dropdown on CMS pages
our @Affiliations = ('Default');

our @Degrees = ('', 'M.D.', 'Ph.D.', 'M.D., M.P.H.', 'M.D., Ph.D.', 
		       'D.D.S.', 'D.M.D.',
		       	'D.V.M.', 'D.V.M., Ph.D.', 'D.V.M., D.Sc.',
	       		'R.N.', 'M.S.W.', 'Ed.D.', 'M.P.H');

## used in search pages where results can be limited by school
our @SearchSchools = ('Default');

## Define the user ids of the administrators of TUSK
our @siteAdmins = ('admin');

## Shibbioleth settings
our $shibSPSecurePort = "443";
our $shibbolethUserID = "shib_user";
our $useShibboleth = "0";
our $shibbolethSP = $TUSK::Constants::Domain;

# unfortunately, we need a disclaimer for the Case reports if the report was initiated
# before we released 3.6.1. For that reason, I am adding a variable to record the 
# date that 3.6.1 was released. Please update this for your system!
our $release_stamp_3_6_1 = '2009-09-02 06:05:00';

## default location to look for XML rules, can be overridden in method call
our $XMLRulesPath = "/usr/local/tusk/current/code/HSCML/Rules/";

## list IP addresses of machines that will automatically be authorized to get content
## this is used for XML requests during XSLT and FOP transformations
our $PermissableIPs = {
    '127.0.0.1' => 1,
};

## DatabaseUsers is a hash of user and password pairs used for specific parts of the site
our $DatabaseUsers = {
    ContentManager => {
	readusername => "CONTENT_MANAGER_USER",
	readpassword => "CONTENT_MANAGER_PASSWORD",
	writeusername => "CONTENT_MANAGER_USERcontent_mgr",
	writepassword => "CONTENT_MANAGER_PASSWORD",
    },
};


## DBParameters specify host-based variables for database connections
our %DBParameters = ("MYFQDN" => {"ReadHost" => "localhost",
				  "WriteHost" => "localhost",
				  "SearchHost" => "localhost",
				  "VideoHost" => "localhost",
				  "AudioHost" => "localhost",
                        },
                    );

our $privacy_notice="We refer you to the <a href=\"http://hss.edu/pnotice\" target=\"_blank\">Health Sciences Responsible Use Policy</a>.";

##This is displayed on XSL/Eval/db_based.xsl
our $evalErrorMessage = "Please contact your school's evaluation administrator to have a new evaluation created for you";
our $evalSaveDir="/data/eval";
## These are different formats that we try to export eval graphs in.
our @evalGraphicsFormats = ('png', 'jpeg', 'gif');


our $WebError = 
    "<p>The page you requested is having trouble getting from our server to your web browser.</p>" . 
    "<p>Your problem has been reported to $TUSK::Constants::SiteAbbr and we will do our best to help you with this issue." .
    "  If you would like to contact us with additional information please email ".
    "<a href=mailto:" . $TUSK::Constants::SupportEmail . ">" . $TUSK::Constants::SupportEmail . "</a>".
    " or call " . $TUSK::Constants::SupportPhone . ".  Thank you for your patience.";


our $EvalDTD = <<EOM;
<?xml version="1.0"?><!DOCTYPE question_text SYSTEM "http://$TUSK::Constants::Domain/DTD/eval.dtd">
EOM

our $HomepageMessage = "TUSK is a dynamic multimedia knowledge management system to support faculty and students in teaching and learning. TUSK provides a portal to an integrated body of knowledge and ways to personally organize the vast array of health information through its online curricular materials and related applications.";

# The following enables a google analytics account and uses a tracking string on their login
# page and all mobile pages.
# if your institution would like to enable a similar tracking mechanism, set "$UseTracking" to '1' and 
# place your tracking code as the value for $TrackingString. 
# IMPORTANT: DO NOT enable tracking without updating the value of $TrackingString. this will 
# mistakenly report your traffic to the Tufts Univ. account. -- Thank you!
our $UseTracking = 0;

our $TrackingString = "";


1;
