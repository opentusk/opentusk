# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::UserGroupMigrate;

use strict;

use HSDB4::Constants;
use TUSK::Constants;

use TUSK::Core::HSDB45Tables::Course;
use TUSK::Core::HSDB45Tables::LinkCourseStudent;

sub new {
    my $self  = {};

	# Setup the table structure
	$self->{course_table}                    = TUSK::Core::HSDB45Tables::Course->new();
	$self->{course_ids}     = [];
	$self->{school_db_name} = undef;

	bless $self, "TUSK::Application::UserGroupMigrate";

	return $self;
}

sub init {
	my $self = shift;

	$self->{school_db_name}  = HSDB4::Constants::get_school_db( shift );
	@{ $self->{course_ids} } = @_;

	# Hook up all the database connections
	$self->{course_table}->setDatabase( $self->{school_db_name} );
}

sub migrate_course {
	my ($self, $debugging, $school, @course_ids) = @_;
	my @failed_ids;
	my $ret_val = "";
	my $dbh;

	eval {
		$dbh = HSDB4::Constants::def_db_handle();
	};
	die "$@\t...failed to obtain database handle!" if $@;

	$self->init( $school, @course_ids );

	my $courses = $self->{course_table}->lookup( "course_id in (" . join(",", @{ $self->{course_ids} }) . ")" );

	foreach my $course (@$courses) {
		if ( $course->getAssociateUsers() eq "User Group" ) {
			print '===== COURSE ' . $course->getFieldValue('course_id') . " =====\n" if ($debugging);
			
			my $ug_query = sprintf( 'select child_user_group_id, time_period_id from ' . $self->{school_db_name} . '.link_course_user_group where parent_course_id = ' . $course->getFieldValue("course_id"));
			eval {
				my $ug_query_handle = $dbh->prepare($ug_query);
				my ($child_user_group_id, $time_period_id);

				$ug_query_handle->execute();
				$ug_query_handle->bind_columns(\$child_user_group_id, \$time_period_id);

				while($ug_query_handle->fetch()) {
					sleep(1);
					print '----- USERGROUP ' . $child_user_group_id .  "-----\n" if ($debugging);
					my $u_query = sprintf( 'select child_user_id from ' . $self->{school_db_name} . '.link_user_group_user where parent_user_group_id = ' . $child_user_group_id);
					eval {
						my $u_query_handle = $dbh->prepare($u_query);
						my ($child_user_id);

						$u_query_handle->execute();
						$u_query_handle->bind_columns(\$child_user_id);

						while($u_query_handle->fetch()) {
							my $new_link_course_student = TUSK::Core::HSDB45Tables::LinkCourseStudent->new();

							$new_link_course_student->setDatabase( $self->{school_db_name} );

							my $already_exists = $new_link_course_student->lookup( "parent_course_id = '" . $course->getFieldValue("course_id") . "' and " .
		                                                                           "child_user_id    = '" . $child_user_id . "' and " .
		                                                                           "time_period_id   = '" . $time_period_id . "'" );

							if ( scalar(@$already_exists) ) {
								$ret_val .= "   ! Warning: " . $course->getFieldValue("course_id") . "-" . 
								                               $child_user_id . "-" .
								                               $time_period_id . "-0 already exists!\n";
								next;
							}

							$new_link_course_student->setFieldValue("parent_course_id", $course->getFieldValue("course_id") );
							$new_link_course_student->setFieldValue("child_user_id",    $child_user_id );
							$new_link_course_student->setFieldValue("time_period_id",   $time_period_id );

							if ( $debugging ) {
								print $new_link_course_student->saveDebug( $debugging ) . "\n";
							}
							else {
								$new_link_course_student->saveDebug();
							}
						}
					};
					die "$@\t...query failed: " . $u_query if $@;
				}
			};
			die "$@\t...query failed: " . $ug_query if $@;
		}
		else {
			push @failed_ids, $course->getFieldValue("course_id");
		}
	}
	
	if ( scalar( @failed_ids ) > 0 ) {
		if ( scalar( @failed_ids ) == 1 ) {
			$ret_val .= "Course " . $failed_ids[0] . " is enrollment!\n";
		}
		else {
			$ret_val .= "Courses " . join( ",", @failed_ids ) . " are enrollment!\n"
		}
	}

	if (defined($dbh)){
		$dbh->disconnect;
	}

	return $ret_val;
}

1;
