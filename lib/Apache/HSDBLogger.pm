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


package Apache::HSDBLogger;

use strict;
use Apache2::Const qw(:common);
use HSDB4::SQLRow::LogItem;
use HSDB4::DateTime;

# Send log information to the database.  We can get much of the
# information from the output headers.

# userid, hitdate, type, course_id, content_id, personal content id.

sub handler {
  my $r = shift;
  my $user = $r->user;
  my $date = HSDB4::DateTime->new()->out_mysql_timestamp();
  my ($type, $course_id, $content_id, $p_content_id);
  
  # get most information from the X-Log-Info;
  my $info = $r->headers_out->get('X-Log-Info');
  if ($info) {
    ($type, $course_id, $content_id, $p_content_id) = split ':', $info;
  }

  if ($type) {
      my $li = HSDB4::SQLRow::LogItem->new();
      $li->save_loglist( [ $user, $date, $type, $course_id, 
			   $content_id, $p_content_id ] );
      $li = HSDB4::SQLRow::RecentLogItem->new();
      $li->save_loglist( [ $user, $date, $type, $course_id, 
			   $content_id, $p_content_id ] );
  }

  return OK;
}

1;
__END__

