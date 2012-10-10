package Forum::ForumKey;

=head1 NAME

B<Forum::forumkey> - Class for linking a TUSK school/group/course to the forum

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

use HSDB4::SQLRow::User;
use TUSK::Core::School;
use TUSK::Constants;
use Forum::MwfMain;
use Data::Dumper;

#######################################################

=item B<parseKey>

    ($school, $group, $course) = parseKey($key);

    Separate a key into its 3 components. 
    The key must be passed as a string, otherwise perl will
    convert the $key into scientific notation..
=cut


sub parseKey
{
    my $key = shift();
    
    $_ = $key;
    print $key . "\n";
    (my $school, my $group, my $course) = /(\d+)(\d{10})(\d{10}\z)/;
    my @ids = /(\d+)(\d{10})(\d{10}\z)/;
    print $school . "\n" . $group . "\n" . $course . "\n";
    return @ids;
}
#######################################################

=item B<getBoardKeys>

    @board_keys = getBoardKeys($utln);

    Returns a list of keys into the mwforum.boards table that
    user $utln can view.  Some boards have the same key (ex.
    if they are in the same category, unless it is a course,
    then it has a time period value (and thus a different key
    but will be in the same category).

=cut


sub getBoardKeys
{

    my $user = shift();
    my $current_courses = shift();

    my $pad_char = 0;
    my @list = ();

    # Create a TUSK user object using username;
    my $user_object = (ref $user and $user->isa('HSDB4::SQLRow::User')) ? $user : HSDB4::SQLRow::User->new()->lookup_key($user);

    my $school_lookup = get_school_lookup_hash();
    
    my $user_school_id = $school_lookup->{ $user_object->affiliation() };
    push @list, createBoardKey($user_school_id,0,0,0);

    my $courses = $user_object->user_group_courses();

    foreach my $course (@$courses){
        push @list, createBoardKey($course->{ school_id }, $course->{ course_id }, $course->{ time_period_id }, $course->{ sub_group_id });
    }

    unless ($current_courses){
	$current_courses = [ $user_object->current_courses( {'all_courses' => 1} ) ];
    }

    foreach  my $course (@$current_courses){
	# for adding the time variable to courses, add another foreach that cycles through
	# the time periods for the current course,
	my $course = createBoardKey($school_lookup->{ $course->school() }, $course->primary_key(), $course->aux_info('time_period_id'),0);
	push @list, $course;
    }

    return @list;
    
}

#######################################################

=item B<getBoardIds>

    $list = getBoardIds($MwfMain object, @boardKeys)
    
    Given an MwfMain object and list of board keys,
    returns an array of mwforum board ids.

=cut

sub getBoardIds
{
    my $m = shift();
    my $cfg = $m->{cfg};
    my $list = formatKeyList(@_);

    my $categories = $m->fetchAllArray("
       SELECT id FROM $cfg->{dbPrefix}boards WHERE boardkey IN ($list)");

    return map {$_->[0]} @$categories;
}

#######################################################

=item B<formatKeyList>

    $list = formatKeyList(@keys)
    
    Given a list of category keys,
    returns a string list of mwforum category ids.

=cut


sub formatKeyList {
    my $list = "'". (shift()) ."'";
    foreach my $key (@_)
    {
	$list = $list . ", '" . $key . "'";
    }
    return $list;
}


#######################################################

=item B<createBoardKey>

    $list = createBoardKey(@keys)
    
    Given a list of TUSK ids (school, course, timeperiod, group),
    returns a string representation of the boardKey.

=cut


sub createBoardKey {
    my $schoolId = shift;
    my $courseId = shift;
    my $timeperiod = shift;
    my $group = shift;

    return "$schoolId-$courseId-$timeperiod-$group";
}


#######################################################

=item B<getViewableBoardsHash>

    $boards = getViewableBoardsHash($MwfMain object, $user)
    
    Given an MwfMain object and a user, returns an sql hash of all boards
    that the user can view.  If we have not calculated this yet, also store
    it in the $m object, so that we can just retrieve it in the future instead
    of repeating the query.

=cut


sub getViewableBoardsHash {

    my $m = shift();
    my $user = shift();
    my $cfg = $m->{cfg};
    if ($m->{boardHash}) {
	return $m->{boardHash};
    }
    else {
my $sql = "
SELECT boards.*, categories.title AS categTitle
                             FROM ( $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables )
                             INNER JOIN $cfg->{dbPrefix}categories AS categories
			     ON categories.id = boards.categoryId
                             WHERE variables.userId = $user->{id}
                             AND variables.value = 'viewableBoard'
                             AND variables.name = boards.id
                             AND boards.private = '0'
			     ORDER BY boards.boardKey, boards.pos";
#print $sql;
	$m->{boardHash} = $m->fetchAllHash($sql);
	return $m->{boardHash};
    }

=pod  This query only returns board info, there are no category titles.
    return $m->fetchAllHash("SELECT boards.* FROM $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables
                             WHERE variables.userId = $user->{id}
                             AND variables.value = 'viewableBoard'
                             AND variables.name = boards.id
                             AND boards.private = '0'
                             ORDER BY boards.boardKey, boards.pos");
=cut

}

#######################################################

=item B<getBoardsHashnoHidden>

    $boards = getBoardsHashnoHidden($MwfMain object, $user)
    
    Given an MwfMain object and a user, returns an sql hash of all boards
    that the user can view, minus the hidden boards that are set in user options.  
    If we have not calculated this yet, also store it in the $m object, 
    so that we can just retrieve it in the future instead of repeating the query.

=cut


sub getBoardsHashnoHidden {

    my $m = shift();
    my $user = shift();
    my $course_key = shift();
    my $start_date = shift();
    my $end_date = shift();

    my $cfg = $m->{cfg};

    if ($course_key or $start_date or $end_date){
	my @results = $m->fetchArray("select * from " . $cfg->{dbPrefix} . "variables where userId = " . $user->{id} . " and name ='CheckedAllCourses'");
	
	if (! scalar @results == 0){
	    getOlderBoardKeys($m, $user);
	    $m->dbDo("insert into " . $cfg->{dbPrefix} . "variables (userId, name, value) values (" . $user->{id} . "', 'CheckedAllCourses', '1')");
	}
    }

    if ($course_key){
	return $m->fetchAllHash(
				"SELECT boards.*, 'Courses' as categTitle
                                 FROM $cfg->{dbPrefix}boards as boards, $cfg->{dbPrefix}variables as variables
                                 WHERE boardkey like '$course_key'
                                 AND variables.userId = $user->{id}
                                 AND variables.value = 'viewableBoard'
                                 AND variables.name = boards.id
                                 AND boards.private = '0'
                                 ORDER BY boards.pos");
    }
    elsif ($m->{boardHash}) {
	return $m->{boardHash};
    }
    else {
	$m->{boardHash} = $m->fetchAllHash("SELECT boards.*, categories.title AS categTitle
                             FROM ( $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables )
                             INNER JOIN $cfg->{dbPrefix}categories AS categories
			     ON categories.id = boards.categoryId
                             WHERE variables.userId = $user->{id}
                             AND variables.value = 'viewableBoard'
                             AND variables.name = boards.id
                             AND boards.private = '0'
                             AND (boards.start_date <= " . ( $start_date ? "'$start_date'" : "now()") . "
                                  AND boards.end_date >= " . ( $end_date ? "'$end_date'" : "now()") . ")
                             AND boards.id NOT IN (SELECT boardId FROM $cfg->{dbPrefix}boardHiddenFlags WHERE userId = $user->{id})
                             ORDER BY boards.boardKey, boards.pos");
	return $m->{boardHash};
    }

}
#######################################################

=item B<getViewableBoardsArray>

    $boards = getViewableBoardsArray($MwfMain object, $user)
    
    Given an MwfMain object and a user, returns an array of all boards
    that the user can view.

=cut


sub getViewableBoardsArray {

    my $m = shift();
    my $user = shift();
    my $cfg = $m->{cfg};
    return $m->fetchAllArray("SELECT boards.* FROM $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables
                              WHERE variables.userId = $user->{id}
                              AND variables.value = 'viewableBoard'
                              AND variables.name = boards.id
                              AND boards.private = '0'
                              ORDER BY boards.boardKey, boards.pos");

}



#######################################################

=item B<getNewPosts>

    $boards = getNewPosts($MwfMain object, $user)
    
    Given an MwfMain object and a user, returns an sql array ref
    of new topics since the users last login time.

=cut

sub getNewPosts {
    my $self = shift();
    my $m = shift();
    my $user = shift();
    my $cfg = $m->{cfg};

    my $boards = getViewableBoardsHash($m, $user);
    
    
    my @list = map ($_->{id}, @$boards);
    if (@list == 0) {
	return undef;
    }

    my $approvedStr = $user->{admin} ? "" : "AND approved = 1";

    my $lowestUnreadTime = $m->max($user->{fakeReadTime}, $m->{now} - $cfg->{maxUnreadDays} * 86400);

    # This select statement counts every individual post and returns the count of new and unread posts.
#    my $superSelect = $m->fetchAllHash("
my $sql = "
 SELECT boards.id AS bid,  boards.title, categories.title AS category, count(topics.id) AS numNew, boardkey, boards.pos, categorykey, categories.pos as categorypos
        FROM ( $cfg->{dbPrefix}categories AS categories, $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}topics AS topics )                                                                                                                                              
        INNER JOIN $cfg->{dbPrefix}posts AS posts ON posts.boardId = boards.id                                                                                                                                              
        LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes                                                                                                                                                          
        ON topicReadTimes.userId = $user->{id} AND topicReadTimes.topicId = posts.topicId                                                                                                                                   
        WHERE boards.id IN (".join(",",@list).")                   
        AND  boards.categoryId = categories.id                                                                                                                                                          
        AND topics.id = posts.topicId                                                                                                                                                                                       
        AND topics.lastPostTime > $lowestUnreadTime                                                                                                                                                                         
        AND (posts.postTime > topicReadTimes.lastReadTime OR posts.editTime > topicReadTimes.lastReadTime OR topicReadTimes.topicId IS NULL)                                                                                
        GROUP BY boards.id
       ORDER BY categorypos ASC, categorykey ASC, boardkey ASC, pos ASC";
    my $superSelect = $m->fetchAllHash($sql);
#    print $sql;


    return $superSelect;
}

#######################################################

=item B<setCfg>

    setCfg($m)
    
    Given a forum object, set all the static variables 
    from TUSK::Constants

=cut

sub setCfg {
    my $m = shift();
    my $cfg = $m->{cfg};
    
    # Existing cfg options
    $cfg->{forumAttachments} = $TUSK::Constants::ForumAttachments;
    $cfg->{forumEmail} = $TUSK::Constants::ForumEmail;
    $cfg->{adminEmail} = $TUSK::Constants::AdminEmail;
    $cfg->{forumName} = $TUSK::Constants::ForumName;
    $cfg->{homeUrl} = $TUSK::Constants::HomeUrl;
    $cfg->{homeTitle} = $TUSK::Constants::HomeTitle;
    $cfg->{attachUrlPath} = $TUSK::Constants::AttachUrlPath;
    $cfg->{scriptUrlPath} = $TUSK::Constants::ScriptUrlPath;
    $cfg->{policy} = $TUSK::Constants::ForumPolicy;
    $cfg->{policyTitle} = $TUSK::Constants::ForumPolicyTitle;
    $cfg->{mailer} = $TUSK::Constants::Mailer;

    # TUSK custom cfg options
    # These are config options that were added by TUSK
    $cfg->{animatedAvatar} = $TUSK::Constants::ForumAnimatedAvatar;

}

####################################################### 

=item B<new_post_forums>

    $new_post_forums = new_post_forums($forum_admin);

    function that returns a data structure of the new/unread post info for a particular user.  Uses apache request to figure out the user.

=cut

sub new_post_forums {
    my $user_object = shift;
    my $forum_admin = shift;
    my $courses = shift;
    
    my $keys = [ Forum::ForumKey::getBoardKeys($user_object, $courses) ];
    
    my $r = Apache->request;
    
    my ($m, $cfg, $lng, $user) = MwfMain->new($r, $forum_admin, 1, $keys);
    
    my $notes = $m->fetchAllHash("
		SELECT id, body, sendTime
		FROM $cfg->{dbPrefix}notes
		WHERE userId = '" . $user->{id} .
				 "' ORDER BY id DESC");
    
    if (@$notes) {
	
	for my $note (@$notes) {
	    $note->{body} =~ s!$m->{ext}\?!$m->{ext}?sid=$m->{sessionId};! if $m->{sessionId};
	    $note->{body} =~ s/(message|topic)_show\.pl/$TUSK::Constants::ScriptUrlPath\/$1_show\.pl/g;
	    my $timeStr = $m->formatTime($note->{sendTime}, $user->{timezone});
	    $note->{timeStr} = $timeStr;
	}
	
    }
    
    return (Forum::ForumKey->getNewPosts($m, $user), $notes, $m->url('user_posts_mark', act => 'read', time => $m->{now}, auth => 1));
}

#######################################################                                                                                

=item B<blog_url>

    $blog_url = blog_url();

Returns the url of the user's blog if he/she has one.  Uses apache request to figure out the user.

=cut

sub blog_url {
    my $r = Apache->request;
    
    my ($m, $cfg, $lng, $user) = MwfMain->new($r, 0, 1);
    
    my $blog_exists = $m->fetchArray("SELECT count(*) FROM $cfg->{dbPrefix}topics WHERE boardId= '-". $user->{id} . "'");
    if ($blog_exists) {
	return $TUSK::Constants::ScriptUrlPath . '/' . $m->url('blog_show', bid => '-'.$user->{id});
    }
    else {
	return 0;
    }
}

sub getOlderBoardKeys{
    my $m = shift;
    my $user = shift;

    my $cfg = $m->{cfg};

    # Create a TUSK user object using username;
    my $user_object = (ref $user and $user->isa('HSDB4::SQLRow::User')) ? $user : HSDB4::SQLRow::User->new()->lookup_key($user);
    
    my $old_courses = $user->current_courses("t.end_date < now()");
    
    my @list = ();

    my $school_lookup = get_school_lookup_hash();

    foreach  my $old_course (@$old_courses){
	# for adding the time variable to courses, add another foreach that cycles through
	# the time periods for the current course,
	my $course = createBoardKey($school_lookup->{ $old_course->school() }, $old_course->primary_key(), $old_course->aux_info('time_period_id'),0);
	push @list, $course;
    }
    return if (scalar @list == 0);
    my $sql = "select id from boards where boardkey in (" . formatKeyList(@list) . ")";

    my @rows = $m->fetchArray($sql);

    foreach my $row (@rows){
	$m->dbDo("INSERT INTO $cfg->{dbPrefix}variables (name, userId, value) values('" . $row->[0] . "','" . $user->{id} . "','viewableboard')");
    }

    return;

}

sub get_school_lookup_hash{
    # Create a lookup table for the different schools
    my $schools = TUSK::Core::School->new()->lookup();
    my $school_lookup = {};
    foreach my $school (@$schools){
	$school_lookup->{ $school->getSchoolName() } = $school->getPrimaryKeyID();
    }
    return $school_lookup;
}
1;
