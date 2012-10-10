package HSDB4::Constants;

use strict;
use DBI;
use TUSK::Constants;
use Sys::Hostname;

BEGIN {
    use base qw(Exporter);

    use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS);
    
    @EXPORT = qw();
    @EXPORT_OK = qw(schools schedule_schools course_schools eval_schools survey_schools
		    user_group_schools school_codes code_by_school get_school_db school_code_regexp);
    %EXPORT_TAGS = ( 'school' => [ qw[schools schedule_schools course_schools 
				      eval_schools user_group_schools school_codes 
				      code_by_school get_school_db school_code_regexp] ],
		     );
    $VERSION = do { my @r = (q$Revision: 1.132 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

# Non-exported package globals go here
use vars qw(%URLs %EditURLs $LDAP_SERVER $LDAP_DN $LDAP_PASSWORD
            %School_Admin_Group %School_Edit_Group 
	    %Eval_Admin_Group %Forum_School_Category @Course_Admin_Roles @Course_Edit_Roles 
	    @Course_Add_Roles @Content_Edit_Roles @Content_Add_Roles @image_sizes %school_images);

# File-private lexicals
# my (...) = (...);
sub schools { 
    return qw(Default);
}

sub schedule_schools { 
    return qw/Default/;
}

sub course_schools { 
    return qw/Default/;
}

sub eval_schools { 
    return qw/Default/;
}

sub survey_schools { 
    return qw/Default/;
}

sub user_group_schools { 
    return qw/Default/;
}

sub forum_schools {
    return qw/Default/;
}
 
sub homepage_course_schools {
    return qw/Default/;
}

my %code_schools = ( D => 'Default',
		    );
sub school_code_regexp { return sprintf( '[%s]', join('', keys %code_schools) ) }

sub school_codes {
    my $code = shift;
    return $code_schools{ uc $code };
}

my %school_codes = ( 'default' => 'D',
		     );
sub code_by_school {
    my $school = lc shift;
    return $school_codes{$school};
}


my %school_dbs = ('default' => 'hsdb45_def_admin',
		  );

our %school_images = ('default' => 'DefaultSchool.gif',
		  );

sub get_school_db {
    my $school = lc shift;
    return $school_dbs{$school};
}

# Start defining lists of useful constants to be used in many HSDB4
# modules and programs.
%URLs = ( 'HSDB4::SQLRow::User' => '/view/user',
	  'HSDB4::SQLRow::Content' => '/view/content',
	  'HSDB4::SQLRow::Content::Slide' => '/view/content',
	  'HSDB4::SQLRow::Content::TUSKdoc' => '/view/content',
	  'HSDB4::SQLRow::Content::Document' => '/view/content',
	  'HSDB4::SQLRow::Content::Question' => '/view/content',
	  'HSDB4::SQLRow::Content::Flashpix' => '/view/content',
	  'HSDB4::SQLRow::Content::URL' => '/view/content',
	  'HSDB4::SQLRow::Content::Multidocument' => '/view/content',
	  'HSDB4::SQLRow::Content::PDF' => '/view/content',
	  'HSDB4::SQLRow::Content::Shockwave' => '/view/content',
	  'HSDB4::SQLRow::Content::Collection' => '/view/content',
	  'HSDB4::SQLRow::Content::DownloadableFile' => '/view/content',
	  'HSDB4::SQLRow::Content::Video' => '/view/content',
	  'HSDB4::SQLRow::Content::Audio' => '/view/content',
	  'HSDB4::SQLRow::Content::Quiz' => '/view/content',
	  'HSDB4::SQLRow::PersonalContent' => '/management/content/personalcontent',
	  'HSDB4::SQLRow::PersonalContent::Collection' => '/management/content/personalcontent',
	  'HSDB4::SQLRow::PersonalContent::Discussion' => '/management/content/personalcontent',
	  'HSDB4::SQLRow::Content::External' => '/view/content',
	  'HSDB45::Course' => '/view/course',
	  'HSDB45::Eval' => '/protected/eval/complete',
	  'HSDB45::UserGroup' => '/view/usergroup',
	  'HSDB45::ClassMeeting' => '/view/course',
	  'daygif' => '/daygif',
	  'thumbnail' => '/thumb',
	  'choose' => '/chooser_icon',
	  'data' => '/large',
	  'small_data' => '/medium',
	  'orig' => '/orig',
	  'xlarge' => '/xlarge',
	  'large' => '/large',
	  'medium' => '/medium',
	  'small' => '/small',
	  'thumb' => '/thumb',
	  'icon' => '/icon',
	  'binary' => '/binary',
	  'overlay' => '/overlay',
	  );

## hash of eval admin groups - users is the groups can manage evaluations
my %school_eags = ('default' => 2,
		   );

sub get_eval_admin_group {
    my $school = lc shift;
    return $school_eags{$school}
}


sub get_registrar_group {
    my $school = lc shift;
    ## hash of registrar groups - users in the groups can manage registrars/grades
	my %school_registrars = (
					   'medical' => 0,
					   'nutrition' => 0,
					   'dental' => 0,
					   'veterinary' => 0,
					   'veterinarygp' => 0,
					   'engineering' => 0,
					   'sackler' => 0,
					   'phpd' => 0,
					   'fletcher' => 0,
					   );
    return $school_registrars{$school}
}


%EditURLs = ('HSDB4::SQLRow::User' => '/protected/useredit',
	     'HSDB45::Eval' => '/protected/eval_edit',
	     'HSDB45::Eval::Question' => '/protected/eval_question_edit'
	     );

$LDAP_SERVER = "ldap.hss.edu";
$LDAP_DN = "required parameters";
$LDAP_PASSWORD = "pswd";

%School_Admin_Group = ('Default' => 1,
		       );

%School_Edit_Group = ('Default' => 1,
		      );

%Forum_School_Category = (
	'Default' => 1,
	 );

@Course_Admin_Roles = ('Director','Administrator');
@Course_Edit_Roles = ('Director','Administrator','Editor');
@Course_Add_Roles = ('Director','Administrator','Editor','Author');
@Content_Edit_Roles = ('Director','Author','Editor','Contact-Person');
@Content_Add_Roles = ('Director','Author');

@image_sizes = qw(orig xlarge large medium small thumb icon resize);

my ($db_name, $db_user, $db_pass);

sub set_user_pw {
    #
    # Set the user/password pair to use in the future
    #

    ($db_user, $db_pass) = @_;
}

sub set_db {
    ($db_name) = @_;
}

sub db_connect {
    #
    # Return the paramaters for connecting to the database
    #

    my $school = shift;
    my $school_db = get_school_db($school);
    my $db = $school_db || $db_name || $ENV{HSDB_DATABASE_NAME} || 'hsdb4';
# TUSK::Constants sets DATABASE_ADDRESS based upon the system host. 
# In HSDB4, if no address set, then we get empty string, and as a 
# result, localhost. The following was added to make HSDB4 in-line
# with TUSK. We selected WriteHost (as opposed to ReadHost). These
# are almost always the same. If we start using different servers for 
# each, we will need to address this.
    my $dbc = "DBI:mysql:$db:".($ENV{DATABASE_ADDRESS} ? $ENV{DATABASE_ADDRESS} : $TUSK::Constants::DBParameters{Sys::Hostname::hostname}->{'WriteHost'});
    my $user = $db_user || $ENV{HSDB_DATABASE_USER} || $TUSK::Constants::DatabaseUsers->{ContentManager}->{readusername};
    my $pw = $db_pass || $ENV{HSDB_DATABASE_PASSWORD} || '';

    return ($dbc, $user, $pw, {RaiseError => 1});
}

# The default DBH
my %def_dbh = ();

sub set_def_db_handle {
    #
    # Make as the default handle one that's been set up elsewhere
    #

    my $in_dbh = shift;
    # What are we going to look for here?
    my ($dbc, $user) = db_connect ();
    # Make sure it's the right type
    if ($in_dbh and ref $in_dbh eq 'DBI::db') { 
	$def_dbh{"$$:$dbc:$user"} = $in_dbh;
    }
    return $def_dbh{"$$:$dbc:$user"};
}

sub def_db_handle {
    #
    # Returns an actual database handle, creating it if necessary
    #
    my ($dbc, $user) = db_connect ();
    unless ($def_dbh{"$$:$dbc:$user"} and $def_dbh{"$$:$dbc:$user"}->ping) {
	$def_dbh{"$$:$dbc:$user"} = DBI->connect (db_connect());
	# warn "Initializing PROC $$ DB $dbc USER $user in HSDB4::Constants" if $ENV{MOD_PERL};
    }
    return $def_dbh{"$$:$dbc:$user"};
}

sub get_status {
    #
    # Get the status of the system
    #

    my @dbc = db_connect();
    $dbc[0] = 'DBI:mysql:test_status';
    my $dbh = DBI->connect (@dbc);
    my ($res) = $dbh->selectrow_array ('select * from status');
    $dbh->disconnect;
    return $res;
}

# When this package dies, disconnect
END { 
    while (my ($key, $dbh) = each %def_dbh) { 
	next unless $key =~ /^$$:/;
	# warn "Disconnecting $key" if $ENV{MOD_PERL};
	$dbh->disconnect if $dbh->ping;
    } 
}

sub is_guest {
    #
    # Return true if the username is a guest
    #

    my $user = shift;
    my $userName = '';
    if(ref($user)) {$userName=$user->primary_key;}
    else           {$userName=$user;}
    return 1 unless $userName;
    return 1 if $ENV{HSDB_GUEST_USERNAME} && 
	$userName eq $ENV{HSDB_GUEST_USERNAME};
    return 1 if $userName eq 'guest';
    return 0;
}

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

HSDB4::Constants - HSDB4 global-level definitions.

=head1 SYNOPSIS

  use HSDB4::Constants;

=head1 DESCRIPTION

Definitions of a large number of useful constants for things like filenames, sizes, directories, URL bases, etc.  

The joke, of course, is that these things aren't necessarily "constant" at all.

=head1 AUTHOR

Tarik K. Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HDSB4>.

=cut
