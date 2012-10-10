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


package HSDB4::SQLRow::StatusChange;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

#
# File-private lexicals
#
my $tablename         = 'status_change';
my $primary_key_field = 'status_change_id';
my @fields =       qw(status_change_id user_id content_id action date done modified);
my %numeric_fields = ();
my %blob_fields =    ();
my %cache = ();

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Do the default creation stuff
    #

    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

sub lookup_content {
    ## returns an array of status items based on the content_id
    my $self = shift;
    my $content_id = shift;
    return $self->lookup_conditions("content_id=$content_id");
}

sub lookup_user {
    ## returns an array of status items based on the user_id
    my $self = shift;
    my $user_id = shift;
    return $self->lookup_conditions("user_id=$user_id");
}

sub process_status {
    my $self = shift;
    my $un = shift;
    my $pw = shift;
    my $log;
    foreach my $status ($self->pending_now) {
	my $content = $status->content;
	next unless ($content->primary_key);
	my $action = $status->field_value("action");
	next unless ($action);
	if ($action =~ /Available/) {
	    $content->set_field_values("display" => 1);
	}
	elsif ($action =~ /Unavailable/) {
	    $content->set_field_values("display" => 0);
	}
	elsif ($action =~ /Archive/) {
	    $content->set_field_values("display" => 1);
	    ## enter archiving instructions here
	    ## this function should remove all links to the item, but keep it available in searches
	}
	elsif ($action =~ /Expire/) {
	    $content->set_field_values("display" => 0);
	    ## enter deleting instructions here
	    ## should remove all links and then move content to the deleted table
	}
	my ($r,$msg) = $content->save($un,$pw);
	$content->index;
	$log .= "Status of content ".$content->primary_key." not changed: ".$r.": ".$msg if ($msg);
	$status->field_value("done",1);
	($r,$msg) = $status->save($un,$pw);
	$log .= "Status change ".$status->primary_key." not completed: ".$r.": ".$msg if ($msg);
    }
    return $log;
}

sub pending_now {
    my $self = shift;
    return $self->lookup_conditions("done=0","date<=curdate()");
}

sub pending_all {
    my $self = shift;
    return $self->lookup_conditions("done=0","date>=curdate()");
}

sub can_edit {
    my $self = shift;
    my $user_id = shift;
    foreach (keys %HSDB4::Constants::School_Admin_Group) {
	my $ug = HSDB45::UserGroup->new(_school => $_,_id => $HSDB4::Constants::School_Admin_Group{$_});
	return 1 if $ug->contains_user($user_id);
    }
}

#
# >>>>> Ouput methods <<<<<
#
sub content {
    my $self = shift;
    return unless ($self->primary_key);
    my $content = HSDB4::SQLRow::Content->new->lookup_key($self->field_value('content_id'));
    return unless ($content->primary_key);
    return $content;
}

sub out_html_form {
    my $self=shift;
    my $out_html .= "<table><tr><td align=\"right\">";
    $out_html .= "Content ID: ";
    $out_html .= "</td><td>";    
    $out_html .= "<input type=\"text\" name=\"content_id\" value=\"".$self->field_value("content_id")."\">";
    $out_html .= "</td></tr><tr><td align=\"right\">";
    $out_html .= "Date: ";
    $out_html .= "</td><td>";    
    $out_html .= "<input type=\"text\" name=\"date\" value=\"".$self->field_value("date")."\"> (yyyy-mm-dd)";
    $out_html .= "</td></tr><tr><td align=\"right\">";
    $out_html .= "Action: ";
    $out_html .= "</td><td>";
    $out_html .= "<select name=\"action\">";
    my $selected;
    foreach ($self->action_types) {
	$selected = "";		  
	$selected = " SELECTED" if ($self->field_value("action") =~ /$_/);
	$out_html .= "<option value=\"".$_."\"".$selected.">".$_."</option>";
    }	     
    $out_html .= "</select>";
    $out_html .= "</td></tr><tr><td align=\"right\">";
    $out_html .= "Password: ";
    $out_html .= "</td><td>";
    $out_html .= "<input type=\"password\" name=\"password\">";
    $out_html .= "</td></tr><tr><td colspan=\"2\">"; 
   return $out_html .=	"<input type=\"submit\" value=\"Save\"></td></tr></table>";    
}

sub out_html_row {
    my $self=shift;
    my $out_html = "<tr><td>";
    $out_html .= "<a href=\"status/".$self->primary_key."?edit=1\">" if (!$self->done);
    $out_html .= $self->field_value("date");
    $out_html .= "</a>" if (!$self->done);
    $out_html .= "</td><td>";
    $out_html .= $self->content->field_value("title")." (".$self->field_value("content_id").")";
    $out_html .= "</td><td>";
    $out_html .= $self->field_value("action");
    $out_html .= "</td><td>";
    $out_html .= $self->done ? "Yes" : "No";
    $out_html .= "</td></tr>"
}

sub done {
    my $self = shift;
    return $self->field_value("done");
}

#
# >>>>> Input methods <<<<<
#
sub add {
    my $self = shift;
    my $un = shift;
    my $pw = shift;
    my $content_id = shift;
    my $action = shift;
    my $date = shift;
    $self->set_field_values('user_id' => $un,
			    'content_id' => $content_id,
			    'action' => $action,
			    'date' => $date,
			    );
    my ($r,$msg) = $self->save($un,$pw);
    return ($r,$msg);
}

sub action_types {
    my $self = shift;
    return ("Available","Unavailable","Archive","Expire");
}
#
# >>>>> Linked objects <<<<<
#


1;

__END__

=head1 NAME

B<HSDB4::SQLRow::StatusChange> - Instatiation of the B<SQLRow> to
provide ability to schedule availability of HSDB content.

=head1 SYNOPSIS

    use HSDB4::SQLRow::StatusChange;
    
    # Make a new object
    my $status = HSDB4::SQLRow::StatusChange->new();

    # run the update mechanism to update all content assigned a status change 
    # returns a log of any errors
    $log = $status->process_status($un,$pw);

    # or get an array of status items waiting to be processed
    my @status_items = $status->pending;

    # also can find look up a specific status item
    $status->lookup_key($key);

    # and can grab the content object of that status object
    my $content = $status->content;

    # or use the content or user id to find status items for a partucular content or user
    my @status_items = $status->lookup_content($content_id);
    my @status_items = $status->lookup_user($user_id);

    

=head1 AUTHOR

Michael Kruckenberg <michael.kruckenberg@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>, L<HSDB4::SQLLink>, L<HSDB4::XML>.

=cut



