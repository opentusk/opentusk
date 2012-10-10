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

# Check if user is admin
$user->{admin} or $m->adminError();

# Check if admin is among admins that may edit configuration
$cfg->{cfgAdmins} =~ /(?:^|,)\s*$userId\s*(?:,|$)/ 
	or $m->adminError() if $cfg->{cfgAdmins};

# Get CGI parameters
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			# Save options
			for my $opt (@$MwfDefaults::options) {
				next if $opt->{section};

				# Skip advanced forum options
				next if $opt->{adv} && !$cfg->{advForumOpt};

				# Get values
				my $name = $opt->{name};
				my $value = $m->paramStr($name);
				$value = "" if !defined($value);
				
				# Normalize values
				if ($opt->{type} eq 'checkbox') { 
					$value = $value ? 1 : 0;
				}
				elsif ($opt->{type} eq 'array') {
					$value = join("\n", split(/[\r\n]+/, $value));
				}
				elsif ($opt->{type} =~ /^text/) {
					$value =~ s!\r!!g;
					$value =~ s!\t! !g;
				}

				# Save value if different from default
				if ($value ne $cfg->{$name}) {
					my $valueQ = $m->dbQuote($value);
					$m->dbDo("
						DELETE FROM $cfg->{dbPrefix}config WHERE name = '$name'");
					$m->dbDo("
						INSERT INTO $cfg->{dbPrefix}config (name, value, parse)	
						VALUES ('$name', $valueQ, '$opt->{parse}')");
				}
			}

			# Replace last change time
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}config WHERE name = 'lastUpdate'");
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}config (name, value) 
				VALUES ('lastUpdate', '$m->{now}')");
		};
		$@ ? $m->dbRollback() : $m->dbCommit();

		# Log action
		$m->logAction(1, 'forum', 'options', $userId);

		# Redirect
		$m->redirect('forum_options', msg => 'CfgChange');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Forum", navLinks => \@navLinks);

	# Shortcuts
	my $checked = "checked='checked'";
	my $selected = "selected='selected'";
	
	# Print form
	print
		"<form class='cfg' action='forum_options$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Forum Options</span>\n",
		"</div>\n",
		"<div class='ccl'>\n\n";

	# Print advanced options checkbox
	my $check = $cfg->{advForumOpt} ? "checked='checked'" : "";
	print 
		"<label><input type='checkbox' name='advForumOpt' $check/>",
		" Show additional and advanced options</label>\n\n";

	# Print contents
	print "<ul style='-moz-column-count: 3'>\n";
	for my $opt (@$MwfDefaults::options) {
		next if !$opt->{section};
		next if $opt->{adv} && !$cfg->{advForumOpt};
		print "<li><a href='#$opt->{id}'>$opt->{section}</a></li>\n";
	}
	print "</ul>\n";

	# Print options
	for my $opt (@$MwfDefaults::options) {
		# Shortcuts
		my $name = $opt->{name};
		my $value = $cfg->{$name};

		# Skip advanced forum options
		next if $opt->{adv} && !$cfg->{advForumOpt};
		next if $name eq 'advForumOpt';

		# Print section title
		if ($opt->{section}) {
			print "<h3 id='$opt->{id}'>$opt->{section}</h3>\n\n";
			next;
		}
		next if !$name;
		
		# Print advanced option background
		print "<div class='afo'>\n" if $opt->{adv};

		# Print title
		print "<h4>$opt->{title} <dfn>($name)</dfn></h4>\n";

		# Print help
		print "<p class='chl'>$opt->{help}</p>\n" if $opt->{help};

		# Print examples
		if ($opt->{example} && $opt->{example}[0]) {
			print "<p><samp>";
			print "Example: $_<br/>" for @{$opt->{example}};
			print "</samp></p>\n";
		}

		# Print input elements
		if ($opt->{type} eq 'text') {
			# Print text input option
			$value = $m->escHtml($value);
			print	"<p><input type='text' class='ctx' name='$name' value='$value'/></p>\n";
		}
		elsif ($opt->{type} eq 'textarea') {
			# Print textarea options
			if (!$opt->{parse}) {
				# Print simple textarea option
				$value = $m->escHtml($value, 1);
				print "<p><textarea name='$name' cols='80' rows='3'>$value</textarea></p>\n";
			}
			elsif ($opt->{parse} eq 'array') {
				# Print array textarea option
				print "<p><textarea name='$name' cols='80' rows='3'>";
				print $m->escHtml($_, 1) . "\n" for @$value;
				print "</textarea></p>\n";
			}
			elsif ($opt->{parse} eq 'hash') {
				# Print hash textarea option
				$value = $m->escHtml($value, 1);
				print "<p><textarea name='$name' cols='80' rows='3'>";
				for my $key (sort keys %$value) {
					my $val = $m->escHtml($value->{$key}, 1);
					print "$key=$val\n";
				}
				print "</textarea></p>\n";
			}
		}
		elsif ($opt->{type} eq 'checkbox') {
			# Print checkbox option
			$check = $value ? $checked : "";
			print	"<p><label><input type='checkbox' name='$name' $check/> Yes</label></p>\n";
		}
		elsif ($opt->{type} eq 'radio') {
			# Print radio buttons option
			print "<p>\n";
			for (my $i = 0; $i < @{$opt->{radio}} - 1; $i += 2) {
				my $key = $opt->{radio}[$i];
				my $check = $key eq $value ? $checked : "";
				print
					"<label><input type='radio' name='$name' value='$key' $check/>",
					" $opt->{radio}[$i+1]</label><br/>\n";
			}

			print "</p>\n";
		}
		elsif ($opt->{type} eq 'displaytext') {
		    $value = $m->escHtml($value);
		    print "<p style='color:grey'>$name = $value  <br><i> Edit this value in TUSK::Constants. </i></p>\n";
		}

		# Print advanced option background
		print "</div>\n\n" if $opt->{adv};
	}

	print
		"\n<br/><br/>\n",
		$m->submitButton("Change", 'edit'),
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'forum', 'options', $userId);

	# Print footer
	$m->printFooter();
}
