package Apache::HSDBLogger;

use strict;
use Apache::Constants qw(:common);
use HSDB4::SQLRow::LogItem;
use POSIX qw(strftime);

# Send log information to the database.  We can get much of the
# information from the output headers.

# userid, hitdate, type, course_id, content_id, personal content id.

sub handler {
  my $r = shift;
  my $user = $r->connection->user;
  my $date = strftime "%Y-%m-%d %X",localtime;
  my ($type, $course_id, $content_id, $p_content_id);
  
  # get most information from the X-Log-Info;
  my $info = $r->header_out('X-Log-Info');
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

