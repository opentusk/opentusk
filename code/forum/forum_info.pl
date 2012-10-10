#!/usr/bin/perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$m->checkBlock();

# Print header
$m->printHeader();

# Get CGI parameters
my $details = $m->paramBool('details');

# Print page bar
my @adminLinks = ();
push @adminLinks, { url => $m->url('forum_info', details => 1), txt => "Details", ico => 'info' }
	if $user->{admin} && !$details;
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{fifTitle}, navLinks => \@navLinks, adminLinks => \@adminLinks);

# Collect values
my $env = $m->{env};
my $email = $cfg->{adminEmail};
$email = "<a href='mailto:$cfg->{adminEmail}'>$cfg->{adminEmail}</a>" if $email =~ /\@/;
my $admins = $m->fetchAllArray("
	SELECT id, userName FROM $cfg->{dbPrefix}users WHERE admin = 1 ORDER BY userName");
my $userNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
my $topicNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}topics");
my $postNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}posts");
my $hitNum = $cfg->{topicHits} ? $m->fetchArray("
	SELECT SUM(hitNum) FROM $cfg->{dbPrefix}topics") : 0;
my $pollNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}polls");
my $voteNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}pollVotes");
my $banNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}userBans");
my $ignNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}userIgnores");
my $subsNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}boardSubscriptions");
my $hiddenNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}boardHiddenFlags");
my $todoNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}postTodos");
my $reportNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}postReports");
my $msgNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}messages");
my $logNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}log");
my $ticketNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}tickets");
my $attachNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}attachments");

my $languages = "";
for my $lang (sort keys %{$cfg->{languages}}) {
	my $module = $cfg->{languages}{$lang};
	if ($module =~ /^Mwf[a-zA-Z0-9_]+$/) {
		require "Forum/$module.pm";
		my $author = eval "\$${module}::lng->{author}";
		my $charset = eval "\$${module}::lng->{charset}";
		my $version = eval "\$${module}::VERSION";
		my $error = $charset ne $cfg->{charset} 
			? "<em>[Error: wrong charset, convert or remove]</em>" : "";
		$languages .= "$lang ($version, $charset), $author $error<br/>\n";
	}
}

# Print public info
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th colspan='2'>$lng->{fifGenTtl}</th>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifGenAdmEml}</td>\n",
	"<td>$email</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifGenAdmins}</td>\n",
	"<td>\n";

my $comma = 0;
for my $admin (@$admins) {
	print ",\n" if $comma; 
	$comma = 1;
	my $url = $m->url('user_info', uid => $admin->[0]);
	print "<a href='$url'>$admin->[1]</a>";
}

print
	"</td></tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifGenVer}</td>\n",
	"<td>$MwfMain::VERSION</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifGenLang}</td>\n",
	"<td>$languages</td>\n",
	"</tr>\n",
	"</table>\n\n";

# Print public statistics
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th colspan='2'>$lng->{fifStsTtl}</th>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifStsUsrNum}</td>\n",
	"<td>$userNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifStsTpcNum}</td>\n",
	"<td>$topicNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifStsPstNum}</td>\n",
	"<td>$postNum</td>\n",
	"</tr>\n";

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{fifStsHitNum}</td>\n",
	"<td>$hitNum</td>\n",
	"</tr>\n"
	if $cfg->{topicHits};

# Print admin statistics
print
	"<tr class='crw'>\n",
	"<td class='hco'>Banned Users</td>\n",
	"<td>$banNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Ignore Entries</td>\n",
	"<td>$ignNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Subscriptions</td>\n",
	"<td>$subsNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Hidden Boards</td>\n",
	"<td>$hiddenNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Messages</td>\n",
	"<td>$msgNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Polls</td>\n",
	"<td>$pollNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Poll Votes</td>\n",
	"<td>$voteNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Todo Entries</td>\n",
	"<td>$todoNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Post Reports</td>\n",
	"<td>$reportNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Tickets</td>\n",
	"<td>$ticketNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Log Entries</td>\n",
	"<td>$logNum</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Attachments</td>\n",
	"<td>$attachNum</td>\n",
	"</tr>\n",
	if $user->{admin};

print "</table>\n\n";

# Print policy text
if ($cfg->{policy}) {
# TUSK begin
# removing the $m->escHtml for the policy title and policy
	my $policyTitle = $cfg->{policyTitle};
	my $policy = $cfg->{policy};
# TUSK end
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$policyTitle</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$policy\n",
		"</div>\n",
		"</div>\n\n";
}

# Print admin info
my $perlVersion = $^V ? sprintf("%vd", $^V) : $];
($perlVersion) = $perlVersion =~ /(\d+\.\d+\.\d+)/;
my ($mysqlEngine, $mysqlVersion, $mysqlUser, $mysqlDatabase, $pgsqlVersion);
if ($m->{mysql}) {
        my $stat = $m->fetchHash("
		SHOW TABLE STATUS LIKE '$cfg->{dbPrefix}posts'");
	if ($stat->{Engine} eq "InnoDB" || $stat->{Type} eq "InnoDB") { $mysqlEngine = "(InnoDB)" }       
        elsif ($stat->{Engine} eq "Falcon") { $mysqlEngine = "(Falcon)" }
	($mysqlVersion, $mysqlUser, $mysqlDatabase) = $m->fetchArray("
		SELECT VERSION(), USER(), DATABASE()");
	($mysqlVersion) = $mysqlVersion =~ /(\d+\.\d+\.\d+)/;
}
elsif ($m->{pgsql}) {
	($pgsqlVersion) = $m->fetchArray("SELECT VERSION()") =~ /(\d+\.\d+\.\d+)/;
}
my $sqliteVersion = $m->{dbh}->{sqlite_version};
my ($webserverVersion) = $m->{env}{server} =~ /(\d+\.\d+\.\d+)/;
my ($modperlVersion) = $ENV{MOD_PERL} =~ /(\d+\.\d+\.?\d*)/;

if ($user->{admin}) {
	# Collect values
	my $perlIncStr = join("<br/>\n", @INC);
	my $perlIncModStr = "<table class='tiv'>\n";
	my $perlEnvStr = "";
	my $apEnvStr = "";
	my $apNotesStr = "";
	my $apHeadersStr = "";
	my $mwfEnvStr = "";

	if ($details) {
		# Perl %INC
		for (sort keys %INC) {
			next if /^\// || /\.pl$/;
			my $mod = $_;
			$mod =~ s!/!::!g;
			$mod =~ s!\.pm!!g;
			my $ver = eval "\$${mod}::VERSION";
			$perlIncModStr .= "<tr><td>$mod</td><td>$ver</td><td>$INC{$_}</td></tr>\n";
		}
		$perlIncModStr .= "</table>\n";
	
		# Perl %ENV
		for (sort keys %ENV) { 
			next if /^HTTP_COOKIE$/;
			my $value = $ENV{$_};
			$value =~ s/([:;,])(?![\s\\])/$1 /g;
			$value = $m->escHtml($value);
			$perlEnvStr .= "$_ = $value<br/>\n";
		}
	
		# Apache subprocess environment
		my $ap = $m->{ap};
		if (MwfMain::MP) {
			my $subEnv = $ap->subprocess_env;
			for (sort keys %$subEnv) { 
				next if /^HTTP_COOKIE$/;
				my $value = $subEnv->{$_};
				$value =~ s/([:;,])(?![\s\\])/$1 /g;
				$value = $m->escHtml($value);
				$apEnvStr .= "$_ = $value<br/>\n";
			}
	
			# Apache notes table
			my $notes = $ap->notes;
			for (sort keys %$notes) { 
				my $value = $m->escHtml($notes->{$_});
				$apNotesStr .= "$_ = $value<br/>\n";
			}

			# Apache headers
			my $headers = $ap->headers_in;
			for (sort keys %$headers) { 
				my $value = $m->escHtml($headers->{$_});
				$apHeadersStr .= "$_ = $value<br/>\n";
			}
		}

		# mwForum $m->{env}
		for (sort keys %$env) { 
			next if /^cookie$/;
			my $value = $m->escHtml($env->{$_});
			$mwfEnvStr .= "$_ = $value<br/>\n";
		}
	}

	print
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='2'>Admin: MySQL</th>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>Version</td>\n",
		"<td>$mysqlVersion</td>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>User</td>\n",
		"<td>$mysqlUser</td>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>Database</td>\n",
		"<td>$mysqlDatabase</td>\n",
		"</tr>\n",
		"</table>\n\n"
		if $m->{mysql};

	print
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='2'>Admin: Perl</th>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>Perl</td>\n",
		"<td>$perlVersion</td>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>mod_perl</td>\n",
		"<td>$modperlVersion</td>\n",
		"</tr>\n";
		
	print
		"<tr class='crw'>\n",
		"<td class='hco'>\@INC</td>\n",
		"<td>\n",
		$perlIncStr, "\n",
		"</td>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>\%INC</td>\n",
		"<td>\n",
		$perlIncModStr, "\n",
		"</td>\n",
		"</tr>\n",
		"<tr class='crw'>\n",
		"<td class='hco'>\%ENV</td>\n",
		"<td>\n",
		$perlEnvStr, "\n",
		"</td>\n",
		"</tr>\n"
		if $details;
		
	print
		"</table>\n\n";

	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Admin: Apache Env</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$apEnvStr",
		"</div>\n",
		"</div>\n\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Admin: Apache Notes</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$apNotesStr",
		"</div>\n",
		"</div>\n\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Admin: Apache Headers</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$apHeadersStr",
		"</div>\n",
		"</div>\n\n"
		if MwfMain::MP && $details;

	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Admin: mwForum Env</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$mwfEnvStr",
		"</div>\n",
		"</div>\n\n"
		if $details;

	if ($details) {
		# Collect browser stats of users online in last 100 days
		my $users = 0;
		my $opera = 0;
		my $khtml = 0;
		my $gecko = 0;
		my $msiex = 0;
		my $other = 0;
	
		my $userAgents = $m->fetchAllArray("
			SELECT userAgent 
			FROM $cfg->{dbPrefix}users 
			WHERE userAgent <> ''
				AND lastOnTime > $m->{now} - 100 * 86400");
		$users = @$userAgents;
		
		for my $userAgent (@$userAgents) {
			my $ua = $userAgent->[0];
			if ($ua =~ /Opera/) { $opera++ }
			elsif ($ua =~ /KHTML|Konqueror/) { $khtml++ }
			elsif ($ua =~ /Gecko/) { $gecko++ }
			elsif ($ua =~ /MSIE/) { $msiex++ }
			else { $other++ }
		}
		
		my $operaPc = sprintf("%.1f%%", ($opera / $users) * 100);
		my $khtmlPc = sprintf("%.1f%%", ($khtml / $users) * 100);
		my $geckoPc = sprintf("%.1f%%", ($gecko / $users) * 100);
		my $msiexPc = sprintf("%.1f%%", ($msiex / $users) * 100);
		my $otherPc = sprintf("%.1f%%", ($other / $users) * 100);
		
		# Print browser stats
		print
			"<table class='tbl'>\n",
			"<tr class='hrw'>\n",
			"<th colspan='2'>Admin: Browser Stats</th>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>Users</td>\n",
			"<td>$users</td>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>MSIE</td>\n",
			"<td>$msiexPc ($msiex)</td>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>Gecko</td>\n",
			"<td>$geckoPc ($gecko)</td>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>Opera</td>\n",
			"<td>$operaPc ($opera)</td>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>KHTML</td>\n",
			"<td>$khtmlPc ($khtml)</td>\n",
			"</tr>\n",
			"<tr class='crw'>\n",
			"<td class='hco'>Other</td>\n",
			"<td>$otherPc ($other)</td>\n",
			"</tr>\n",
			"</table>\n\n";
	}
}

# This section MUST NOT be removed or rendered unreadable
# Doing so would be a violation of the GPL, section 2c
print 
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>Legal</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"<p>Powered by <a href='http://www.mwforum.org/'>mwForum</a>", 
	" &copy; 1999-2007 Markus Wichitill</p>\n",
	"<p>This program is free software; you can redistribute it and/or modify",
	" it under the terms of the GNU General Public License as published by",
	" the Free Software Foundation; either version 3 of the License, or",
	" (at your option) any later version.</p>\n",
	"<p>This program is distributed in the hope that it will be useful,",
	" but WITHOUT ANY WARRANTY; without even the implied warranty of",
	" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the",
	" <a href='http://www.gnu.org/copyleft/gpl.html'>GNU General Public License</a>",
	" for more details.</p>\n",
	"</div>\n",
	"</div>\n\n";

# Print mini banners
if ($m->{contentType} eq "application/xhtml+xml") {
	print
		"<div class='bni'>\n",
		"<img src='$cfg->{dataPath}/valid_xhtml11.png' title='XHTML 1.1'",
		" alt='XHTML 1.1'/>\n";
}
else {
	print
		"<div class='bni'>\n",
		"<img src='$cfg->{dataPath}/valid_html401.png' title='HTML 4.01 Strict'",
		" alt='HTML 4.01'/>\n";
}

print
	"<img src='$cfg->{dataPath}/valid_css.png' title='CSS 2.1'",
	" alt='CSS 2.1'/>\n";

print
	"<img src='$cfg->{dataPath}/valid_atom.png' title='Atom 1.0'",
	" alt='Atom 1.0'/>\n",
	if $cfg->{rssLink};

print
	"<a href='http://www.perl.org/'>",
	"<img src='$cfg->{dataPath}/pwrd_perl.png' title='Powered by Perl $perlVersion'",
	" alt='Perl'/></a>\n";

print
	"<a href='http://www.mysql.com/'>",
        "<img src='$cfg->{dataPath}/pwrd_mysql.png' title='Powered by MySQL $mysqlVersion $mysqlEngine'",
	" alt='MySQL'/></a>\n"
	if $m->{mysql};

print
	"<a href='http://www.postgresql.org/'>",
	"<img src='$cfg->{dataPath}/pwrd_pgsql.png' title='Powered by PostgreSQL $pgsqlVersion'",
	" alt='PostgreSQL'/></a>\n"
	if $m->{pgsql};

print
	"<a href='http://www.sqlite.org/'>",
	"<img src='$cfg->{dataPath}/pwrd_sqlite.png' title='Powered by SQLite $sqliteVersion'",
	" alt='SQLite'/></a>\n"
	if $m->{sqlite};

print
	"<a href='http://www.apache.org/'>",
	"<img src='$cfg->{dataPath}/pwrd_apache.png' title='Powered by Apache $webserverVersion'",
	" alt='Apache'/></a>\n",
	if $m->{env}{server} =~ /Apache/;

print
	"<a href='http://www.lighttpd.net/'>",
	"<img src='$cfg->{dataPath}/pwrd_lighttpd.png' title='Powered by lighttpd $webserverVersion'",
	" alt='lighttpd'/></a>\n",
	if $m->{env}{server} =~ /lighttpd/;

print	
	"<a href='http://perl.apache.org/'>",
	"<img src='$cfg->{dataPath}/pwrd_modperl.png' title='Powered by mod_perl $modperlVersion'",
	" alt='mod_perl'/></a>\n",
	if $ENV{MOD_PERL};

print "</div>\n\n";

# Log action
$m->logAction(3, 'forum', 'info', $userId);

# Print footer (without normal (c) message and board jump list)
$m->printFooter(1, 1);
