require HSDB4::Constants;

for my $school (HSDB4::Constants::schedule_schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_class_meeting_topic",
				   -parent_class => 'HSDB45::ClassMeeting',
				   -parent_id_field => 'parent_class_meeting_id',
				   -child_class => 'HSDB4::SQLRow::Objective',
				   -child_id_field => 'child_topic_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(sort_order relationship) ],
				   -school => $school
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_class_meeting_content",
				   -parent_class => 'HSDB45::ClassMeeting',
				   -parent_id_field => 'parent_class_meeting_id',
				   -child_class => 'HSDB4::SQLRow::Content',
				   -child_id_field => 'child_content_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(sort_order anchor_label
					link_class_meeting_content_id
					label class_meeting_content_type_id) ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_class_meeting_user",
				   -parent_class => 'HSDB45::ClassMeeting',
				   -parent_id_field => 'parent_class_meeting_id',
				   -child_class => 'HSDB4::SQLRow::User',
				   -child_id_field => 'child_user_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(sort_order roles) ],
				   -school => $school,
				   );
}

for my $school (HSDB4::Constants::schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_forum",
	-parent_class => 'HSDB45::Course',
	-parent_id_field => 'parent_course_id',
	-child_class => 'HSDB45::Forum',
	-child_id_field => 'child_forum_id',
	-link_fields => [qw(time_period_id)],
	-school => $school
    );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.homepage_course",
				   -parent_class => 'TUSK::HomepageCategory',
				   -parent_id_field => 'category_id',
				   -child_class => 'HSDB45::Course',
				   -child_id_field => 'course_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(label sort_order indent) ],
				   -school => $school,
				   );
}

# 
# --== LINK_FORUM_USER ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'hsdb4.link_forum_user',
	-parent_class => 'HSDB45::Forum',
	-parent_id_field => 'parent_forum_id',
	-child_class => 'HSDB4::SQLRow::User',
	-child_id_field => 'child_user_id',
	-link_fields => [ qw(roles modified) ],
	-order_by => ['child.lastname', 'child.firstname'],
	-school => $school
);
#
# --== LINK_CLASS_MEETING_USER ==--
#
# Class meetings are taught by someone, usually; these links connect a class
# meeting to the people in the user table responsible for it. (Formerly
# unit_faculty.)  The role specifies what the user does for this particular
# meeting.
#
#
  
#
# --== LINK_CONTENT_CONTENT ==--
#
# One piece of content can refer to another. These links specify the
# the originating content item (parent) and target item (child), and
# provide a sorting order and a label for the target from the referrer's
# context.
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_content_content',
			       -parent_class => 'HSDB4::SQLRow::Content',
			       -parent_id_field => 'parent_content_id',
			       -child_class => 'HSDB4::SQLRow::Content',
			       -child_id_field => 'child_content_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(sort_order label) ],
			       );
  
#
# --== LINK_CONTENT_OBJECTIVE ==--
#
# 
HSDB4::SQLLinkDefinition->new (-link_table => 'link_content_objective',
			       -parent_class => 'HSDB4::SQLRow::Content',
			       -parent_id_field => 'parent_content_id',
			       -child_class => 'HSDB4::SQLRow::Objective',
			       -child_id_field => 'child_objective_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(sort_order relationship) ],
			       );

#
# --== LINK_CONTENT_PERSONAL_CONTENT ==--
#
# Bits of personal content can be associated with particular content items,
# either as annotations or as discussions of a particular document. These link
# the content being referred to (parent) to the person content doing the 
# referring (child).
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_content_personal_content',
			       -parent_class => 'HSDB4::SQLRow::Content',
			       -parent_id_field => 'parent_content_id',
			       -child_class => 'HSDB4::SQLRow::PersonalContent',
			       -child_id_field => 'child_personal_content_id',
			       -order_by => [ ],
			       -link_fields => [  ],
			       );
  
#
# --== LINK_CONTENT_USER ==--
#
# Users are associated with bits of content to indicate responsibility, either
# for teaching the material or having written it.  This is an author list,
# essentially. It specifies the person who is responsible for the content
# being in HSDB.
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_content_user',
			       -parent_class => 'HSDB4::SQLRow::Content',
			       -parent_id_field => 'parent_content_id',
			       -child_class => 'HSDB4::SQLRow::User',
			       -child_id_field => 'child_user_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(roles sort_order) ],
			       );

#
# --== LINK_CONTENT_NON_USER ==--
#
# Non_users are associated with bits of content to indicate responsibility, either
# for teaching the material or having written it.  This is an author list,
# essentially. It specifies the person who is responsible for the content
# being in HSDB.
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_content_non_user',
			       -parent_class => 'HSDB4::SQLRow::Content',
			       -parent_id_field => 'parent_content_id',
			       -child_class => 'HSDB4::SQLRow::NonUser',
			       -child_id_field => 'child_non_user_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(roles sort_order) ],
			       );
  
#
# --== LINK_COURSE_CONTENT ==--
#
# Link between a course and the content associated with it at the top level.
#
for my $school (HSDB4::Constants::course_schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
}
#
# --== LINK_COURSE_COURSE ==--
#
# Courses can have sub-courses... the higher-level course (parent) and the
# lower level course (child) are tied by this table.
#
#
# --== LINK_COURSE_OBJECTIVE ==--
#
# A course is associated with many objectives, potentially. This establishes
# these relationships, as well as classifying them (pre-req or goal of the 
# course).
#
#
# --== LINK_COURSE_PERSONAL_CONTENT ==--
#
# Links courses to personal content for the purpose of course-centered
# user discussion.
#
#
# --== LINK_COURSE_USER ==--
#
# Links a course to its faculty.  Roles indicates special things, link course
# directors, etc.
#
for my $school (HSDB4::Constants::course_schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_user",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB4::SQLRow::User',
				   -child_id_field => 'child_user_id',
				   -order_by => [qw(link.sort_order child.lastname child.firstname)],
				   -link_fields => [ qw(sort_order roles teaching_site_id) ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_student",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB4::SQLRow::User',
				   -child_id_field => 'child_user_id',
				   -order_by => [qw(link.time_period_id child.lastname child.firstname)],
				   -link_fields => [ qw(time_period_id modified teaching_site_id elective) ],
				   -school => $school,
				   );


    if (grep /$school/, HSDB4::Constants::user_group_schools()) {
        HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_user_group",
				       -parent_class => 'HSDB45::Course',
				       -parent_id_field => 'parent_course_id',
				       -child_class => 'HSDB45::UserGroup',
				       -child_id_field => 'child_user_group_id',
				       -order_by => ['upper(label)' ],
				       -link_fields => [ 'time_period_id' ],
				       -school => $school,
				       );
    }
	  
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_announcement",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB45::Announcement',
				   -child_id_field => 'child_announcement_id',
				   -order_by => [],
				   -link_fields => [ ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_personal_content",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB4::SQLRow::PersonalContent',
				   -child_id_field => 'child_personal_content_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ 'sort_order' ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_content",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB4::SQLRow::Content',
				   -child_id_field => 'child_content_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(sort_order label) ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_course",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB45::Course',
				   -child_id_field => 'child_course_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ 'sort_order' ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_objective",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB4::SQLRow::Objective',
				   -child_id_field => 'child_objective_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(sort_order relationship) ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_course_teaching_site",
				   -parent_class => 'HSDB45::Course',
				   -parent_id_field => 'parent_course_id',
				   -child_class => 'HSDB45::TeachingSite',
				   -child_id_field => 'child_teaching_site_id',
				   -order_by => [ 'child.site_name' ],
				   -link_fields => [ qw(max_students modified) ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_teaching_site_user",
				   -child_class => 'HSDB4::SQLRow::User',
				   -child_id_field => 'child_user_id',
				   -parent_class => 'HSDB45::TeachingSite',
				   -parent_id_field => 'parent_teaching_site_id',
				   -order_by => [],
				   -link_fields => [ qw(modified) ],
				   -school => $school,
				   );
}

#
# --== LINK_OBJECTIVE_CONTENT ==--
#
# 
HSDB4::SQLLinkDefinition->new (-link_table => 'link_objective_content',
			       -parent_class => 'HSDB4::SQLRow::Objective',
			       -parent_id_field => 'parent_objective_id',
			       -child_class => 'HSDB4::SQLRow::Content',
			       -child_id_field => 'child_content_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(sort_order relationship) ],
			       );
  
#
# --== LINK_OBJECTIVE_OBJECTIVE ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_objective_objective',
			       -parent_class => 'HSDB4::SQLRow::Objective',
			       -parent_id_field => 'parent_objective_id',
			       -child_class => 'HSDB4::SQLRow::Objective',
			       -child_id_field => 'child_objective_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ qw(sort_order relationship) ],
			       );
  
#
# --== LINK_PERSONAL_CONTENT_CONTENT ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_personal_content_content',
			       -parent_class => 'HSDB4::SQLRow::PersonalContent',
			       -parent_id_field => 'parent_personal_content_id',
			       -child_class => 'HSDB4::SQLRow::Content',
			       -child_id_field => 'child_content_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ 'sort_order' ],
			       );
  
#
# --== LINK_PERSONAL_CONTENT_PERSONAL_CONTENT ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_personal_content_personal_content',
			       -parent_class => 'HSDB4::SQLRow::PersonalContent',
			       -parent_id_field => 'parent_personal_content_id',
			       -child_class => 'HSDB4::SQLRow::PersonalContent',
			       -child_id_field => 'child_personal_content_id',
			       -order_by => ['link.sort_order'],
			       -link_fields => [ 'sort_order' ],
			       );
  
  
#
# --== LINK_SMALL_GROUP_USER ==--
#
# Users are assigned to small groups using this table.
#
# HSDB4::SQLLinkDefinition->new (-link_table => 'link_small_group_user',
# 			       -parent_class => 'HSDB4::SQLRow::SmallGroup',
# 			       -parent_id_field => 'parent_small_group_id',
# 			       -child_class => 'HSDB4::SQLRow::User',
# 			       -child_id_field => 'child_user_id',
# 			       -order_by => [ ],
# 			       -link_fields => [ 'roles' ],
# 			       );
  
#
# --== LINK_USER_GROUP_PERSONAL_CONTENT ==--
#
#
# --== LINK_USER_GROUP_USER ==--
#
for my $school (HSDB4::Constants::schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
    next if ($school eq 'NEMC');
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_user_group_forum",
	-parent_class => 'HSDB45::UserGroup',
	-parent_id_field => 'parent_user_group_id',
	-child_class => 'HSDB45::Forum',
	-child_id_field => 'child_forum_id',
	-link_fields => [],
	-school => $school
    );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_user_group_user",
				   -parent_class => 'HSDB45::UserGroup',
				   -parent_id_field => 'parent_user_group_id',
				   -child_class => 'HSDB4::SQLRow::User',
				   -child_id_field => 'child_user_id',
				   -order_by => ['child.lastname','child.firstname'],
				   -link_fields => [  ],
				   -school => $school,
				   );

    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_user_group_announcement",
				   -parent_class => 'HSDB45::UserGroup',
				   -parent_id_field => 'parent_user_group_id',
				   -child_class => 'HSDB45::Announcement',
				   -child_id_field => 'child_announcement_id',
				   -order_by => [],
				   -link_fields => [],
				   -school => $school,
				   );
}
  
#
# --== LINK_USER_PERSONAL_CONTENT ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'link_user_personal_content',
			       -parent_class => 'HSDB4::SQLRow::User',
			       -parent_id_field => 'parent_user_id',
			       -child_class => 'HSDB4::SQLRow::PersonalContent',
			       -child_id_field => 'child_personal_content_id',
			       -order_by => [ 'link.sort_order' ],
			       -link_fields => [ 'sort_order' ],
			       );

##################################
#                                #
#           Task Links           #
#                                #
##################################

#
# --== LINK_TASK_TASK ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'hsdb_tasks.link_task_task',
			       -parent_class => 'HSDB4::SQLRow::Task',
			       -child_class => 'HSDB4::SQLRow::Task',
			       -parent_id_field => 'parent_task_id',
			       -child_id_field => 'child_task_id',
			       -order_by => [ ],
			       -link_fields => [ 'relationship' ],
			       );

#
# --== LINK_TASK_USER ==--
#
HSDB4::SQLLinkDefinition->new (-link_table => 'hsdb_tasks.link_task_user',
			       -parent_class => 'HSDB4::SQLRow::Task',
			       -child_class => 'HSDB4::SQLRow::User',
			       -parent_id_field => 'task_id',
			       -child_id_field => 'user_id',
			       -order_by => [ ],
			       -link_fields => [ 'role' ],
			       );

##################################
#                                #
#          ePharm Links          #
#                                #
##################################

#
# --== LINK_OBJECTIVE_CONTENT ==--
#
# 
# HSDB4::SQLLinkDefinition->new (-link_table => 'epharm.link_objective_content',
# 			       -parent_class => 
# 			       'HSDB4::SQLRow::Objective::PharmCategory',
# 			       -parent_id_field => 'parent_objective_id',
# 			       -child_class => 
# 			       'HSDB4::SQLRow::Content::PharmAgent',
# 			       -child_id_field => 'child_content_id',
# 			       -order_by => ['link.sort_order'],
# 			       -link_fields => [ qw(sort_order relationship) ],
# 			       );

#
# --== LINK_OBJECTIVE_OBJECTIVE ==--
#
# HSDB4::SQLLinkDefinition->new (-link_table => 
# 			       'epharm.link_objective_objective',
# 			       -parent_class => 
# 			       'HSDB4::SQLRow::Objective::PharmCategory',
# 			       -parent_id_field => 'parent_objective_id',
# 			       -child_class => 
# 			       'HSDB4::SQLRow::Objective::PharmCategory',
# 			       -child_id_field => 'child_objective_id',
# 			       -order_by => ['link.sort_order'],
# 			       -link_fields => [ qw(sort_order relationship) ],
# 			       );

#
# --== LINK_EVAL_EVAL_QUESTION ==--
#

for my $school (HSDB4::Constants::eval_schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_eval_eval_question",
				   -parent_class => "HSDB45::Eval",
				   -parent_id_field => 'parent_eval_id',
				   -child_class => "HSDB45::Eval::Question",
				   -child_id_field => 'child_eval_question_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(label sort_order required grouping graphic_stylesheet) ],
				   -school => $school,
				   );

}

for my $school (HSDB4::Constants::survey_schools()) {
    my $db = HSDB4::Constants::get_school_db($school) or next;
    HSDB4::SQLLinkDefinition->new (-link_table => "$db\.link_survey_eval_question",
				   -parent_class => "HSDB45::Survey",
				   -parent_id_field => 'parent_survey_id',
				   -child_class => "HSDB45::Eval::Question",
				   -child_id_field => 'child_eval_question_id',
				   -order_by => ['link.sort_order'],
				   -link_fields => [ qw(label sort_order required grouping graphic_stylesheet) ],
				   -school => $school,
				   );

}





1;
