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


package Apache::TUSKRSS;

use strict;
use Apache2::Const qw(:common);
use HSDB4::SQLRow::User;
use XML::RSS;
use Digest::MD5 qw(md5_hex);

my $secret="hh3te23"; ## used to calculate the token for the user

sub handler {
    my $r = shift;
    my $user_token = $r->path_info;
    ## a little check to make sure we've got an id
    $user_token =~ s/\///g;
    my ($user_id,$token) = split("-",$user_token);

    #return FORBIDDEN unless &check_token($token,$user_id);

    # Set up the header and send it
    $r->content_type("application/xml");
    $r->send_http_header;
    my $base_url = "http://tusk.tufts.edu";
    my $title = "TUSK";

    my $user = HSDB4::SQLRow::User->new;
    $user->lookup_key($user_id);
    $title .= " for ".$user->out_label if ($user_id);

    my $rss = new XML::RSS (version => '2.0');
    $rss->channel(title          => $title,
		  link           => $base_url,
		  language       => 'en',
		  description    => 'Tufts University Sciences Knowledgebase',
		  copyright      => 'Copyright 2004, TUSK',
		  pubDate        => 'Thu, 23 Aug 1999 07:00:00 GMT',
		  lastBuildDate  => 'Thu, 23 Aug 1999 16:20:26 GMT',
		  managingEditor => 'tusk@tufts.edu',
		  webMaster      => 'tusk@tufts.edu'
		  );

    foreach my $content ($user->recent_history) {
	$rss->add_item(title => "Content: ".$content->out_label,
		       permaLink  => $base_url.$content->out_url,
		       description => $content->out_label);
    }

    # And return the data
    $r->print($rss->as_string);
    return OK;
}

sub check_token {
    my ($token,$user_id) = @_;
    return 1 if md5_hex($secret.":".$user_id) eq "$token";
    return 0;
}

1;

__END__
