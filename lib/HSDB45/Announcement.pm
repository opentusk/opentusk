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


package HSDB45::Announcement;

use strict;

BEGIN {
    use base qw/HSDB4::SQLRow/;
    require HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.16 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


require HSDB4::DateTime;

# File-private lexicals
my $tablename = "announcement";
my $primary_key_field = "announcement_id";
my @fields = qw(announcement_id
                created
		start_date
                expire_date
                username
                body);
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();

# Creation methods

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # Finish initialization...
    return $self;
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub current {
    my $self = shift();
    my $current_time = HSDB4::DateTime->new();

    if(($self->out_expire_date()->compare($current_time) >= 0) &&
       ($self->out_start_date()->compare($current_time) <= 0))
    {
	return 1;
    }
    else {
	return 0;
    }
}


sub starts_in_future {
    my $self = shift();
    my $current_time = HSDB4::DateTime->new();

    if(($self->out_start_date()->compare($current_time) >= 0))
    {
        return 1;
    }
    else {
        return 0;
    }
}


sub schoolwide_announcements {
    my ($school) = @_;
    my $usergroup = HSDB45::UserGroup::schoolwide_usergroup($school);
    return $usergroup->announcements();
}

sub all_schoolwide_announcements {
    my $school = shift();
    my $usergroup = HSDB45::UserGroup::schoolwide_usergroup($school);
    
    return $usergroup->announcement_link()->get_children($usergroup->primary_key)->children;
}

sub lookup_no_group {
    my $self = shift();
    my $school = shift() || 'hsdb';

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($school);
    my @announcements = ();
    
    eval {
	my $sth = $dbh->prepare("SELECT l.child_announcement_id " . 
				"FROM $db\.link_user_group_announcement l, " . 
				"$db\.announcement a " .
				"WHERE l.parent_user_group_id=0 " .
				"AND l.child_announcement_id=a.announcement_id " .
				"AND a.expire_date>=curdate() " .
				"ORDER BY a.created");
	$sth->execute();

	while(my @row = $sth->fetchrow_array()) {
	    push(@announcements, HSDB45::Announcement->new(_school         => $school,
							   announcement_id => shift(@row)));
	}
     $sth->finish;
    };

    return @announcements;
}



#
# >>>>> Linked objects <<<<<
#

sub user {
    #
    # Return the user object associated
    #
    
    my $self = shift;
    my $user = HSDB4::SQLRow::User->new();
    return $user->lookup_key ($self->field_value('username'));
}

#
# >>>>>  Input Methods <<<<<
#

sub in_xml {
    #
    # Suck in a bunch of XML and push it into the appropriate places
    #

    my $self = shift;
}

sub in_fdat_hash {
    #
    # Read in a hash of key => value pairs and make changes
    #

    my $self = shift;
    while (my ($key, $val) = splice(@_, 0, 2)) {
    }
}

#
# >>>>>  Output Methods  <<<<<
#

sub out_timestamp {
    #
    # Return a nice DateTime object of the modified time of this announcement
    #

    my $self = shift;
    unless ($self->{-timestamp}) {
	$self->{-timestamp} = HSDB4::DateTime->new ();
	$self->{-timestamp}->in_mysql_date ($self->field_value('created'));
    }
    return $self->{-timestamp};
}

sub out_start_date {
    my $self = shift;
    unless ($self->{-start_date}) {
	$self->{-start_date} = HSDB4::DateTime->new ();
	$self->{-start_date}->in_mysql_date ($self->field_value('start_date'));
    }
    return $self->{-start_date};
}

sub out_expire_date {
    #
    # Return a nice DateTime of the expiration date
    #

    my $self = shift;
    unless ($self->{-expire_date}) {
	$self->{-expire_date} = HSDB4::DateTime->new();
	$self->{-expire_date}->in_mysql_date ($self->field_value('expire_date'));
	$self->{-expire_date}->in_unix_time($self->{-expire_date}->out_unix_time() + 86400);
    }
    return $self->{-expire_date};
}
sub pretty_out_start_date{
    #
    # Return a pretty Date of the expiration date ## Paul wrote this
    #

    my $self = shift;
    unless ($self->{-pretty_start_date}){
	$self->{-pretty_start_date}=HSDB4::DateTime->new();
	$self->{-pretty_start_date}->in_mysql_date ($self->field_value('start_date'));
    }
    return $self->{-pretty_start_date}->out_string_date_short;
}

sub pretty_out_expire_date{
    #
    # Return a pretty Date of the expiration date ## Paul wrote this
    #

    my $self = shift;
    unless ($self->{-pretty_expire_date}){
	$self->{-pretty_expire_date}=HSDB4::DateTime->new();
	$self->{-pretty_expire_date}->in_mysql_date ($self->field_value('expire_date'));
    }
    return $self->{-pretty_expire_date}->out_string_date_short;
}

sub out_post_date{
	#
	# Return start date in MM DD format with 'Posted ' preceding it
	#

	my $self = shift;
	unless ($self->{-start_date}){
		$self->{-start_date}=HSDB4::DateTime->new();
		$self->{-start_date}->in_mysql_date ($self->field_value('start_date'));
	}
	return 'Posted ' . $self->out_start_date_md;
}

sub out_start_date_md{
	#
	# Return start date in MM DD format 
	#

	my $self = shift;
	unless ($self->{-start_date}){
		$self->{-start_date}=HSDB4::DateTime->new();
		$self->{-start_date}->in_mysql_date ($self->field_value('start_date'));
	}
	return $self->{-start_date}->out_string_date_short_short;
}


sub out_html_div {
    #
    # Formatted blob of HTML with the information
    #

    my $self = shift;
    my $outval = '';
    $outval .= sprintf ("<DIV CLASS=\"docinfo\"><B>%s</B></DIV>\n",
			$self->out_timestamp->out_string);
    
    $outval .= sprintf ("<DIV CLASS=\"docinfo\">%s</DIV>\n",
			$self->user->out_html_abbrev);

    $outval .= sprintf ("<DIV>%s</DIV>\n",
			$self->field_value('body'));
    
    return $outval;
}

sub out_html_row {
    #
    # Formatted blob of HTML with the information
    #

    my $self = shift;
    my $outval = '';
    $outval .= sprintf ("<TR><TD><DIV CLASS=\"docinfo\"><B>%s</B></DIV></TD>\n",
			$self->out_timestamp->out_string_date_short);
    
    $outval .= sprintf ("<TD ALIGN=\"RIGHT\"><DIV CLASS=\"docinfo\">%s</DIV></TD></TR>\n",
			$self->user->out_html_abbrev);

    $outval .= sprintf ("<TR><TD COLSPAN=2><DIV>%s</DIV></TD></TR>\n",
			$self->field_value('body'));
    
    return $outval;
}

sub out_xml {
    #
    # An XML representation of the row
    #
    return;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return "Announcement";
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return "Annoucement";
}

1;
__END__
