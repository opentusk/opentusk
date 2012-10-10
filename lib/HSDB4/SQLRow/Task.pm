package HSDB4::SQLRow::Task;

use strict;
use overload
  'cmp' => \&task_cmp,
  '<=>' => \&task_cmp,
  '""' => \&task_string,
  ;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

require HSDB4::SQLRow::User;
require HSDB45::UserGroup;
require HSDB4::SQLRow::TaskComment;

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "hsdb_tasks.task";
my $primary_key_field = "task_id";
my @fields = qw/task_id category title complete_percent priority modified
                created start_date end_date/;
my %blob_fields = ();
my %numeric_fields = ();

my @categories = ('Administration','Data Model','Documentation','Dynamic page','Eval','Housekeeping', 
		  'HSDB45','HSDB Libraries','HSDB Tools','XMetaL');
my @priorities = ('very low', 'low', 'medium', 'high', 'very high', 
		  'critical');
my %priority_map = ();
{
    my $count = 0;
    for (@priorities) { $priority_map{$_} = $count++ }
}

my %cache = ();

# Creation methods

sub new {
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

#
# >>>>> Linked objects <<<<<
#

sub task_comments {
    #
    # Return the associated comments
    #

    my $self = shift;
    # Check the cache
    unless ($self->{-task_comments}) {
	# Make the conditions
	my @conds = (sprintf "task_id='%s'", $self->primary_key,
		     'ORDER BY created DESC');
	# Get the list
	my @list = HSDB4::SQLRow::TaskComment->lookup_conditions (@conds);
	# Put it in the cache
	$self->{-task_comments} = \@list;
    }
    # Return the list from the cache
    return @{$self->{-task_comments}};
}

sub child_users {
    #
    # Return the child users associated with the task
    #

    my $self = shift;
    # Get the linkdef
    my $linkdef = 
	  $HSDB4::SQLLinkDefinition::LinkDefs {'hsdb_tasks.link_task_user'};

    my $child_links = $linkdef->get_children ($self->primary_key);
    return $child_links->children;
}

sub add_child_user {
    my $self = shift;
    my ($u, $p, $username, @roles) = @_;
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs {'hsdb_tasks.link_task_user'};
    ## look up to see if user is already linked, then need to get, delete, and reinsert
    if ($self->child_user_roles($username)) {
	push (@roles,$self->child_user_roles($username));
	$linkdef->delete(-user => $u, 
				   -password => $p,
				   -child_id => $username,
				   -parent_id => $self->primary_key);
    }
    my ($r, $msg) = $linkdef->insert (-user => $u, -password => $p,
					     -child_id => $username,
					     -parent_id => $self->primary_key,
					     role => join (',', @roles));
    return ($r, $msg);
}

sub child_user_roles {
    #
    # Get the roles of a child user
    #
    my $self = shift;
    my $user_id = shift;
    my @users = grep { $_->primary_key =~ /$user_id/  } $self->child_users;
    return split(",",$users[0]->aux_info('role')) if (@users);
}

sub primary_users {
    #
    # Get the list of primary users
    #

    my $self = shift;
    return grep { $_->aux_info('role') =~ /Primary/ } $self->child_users;
}

sub child_tasks {
    #
    # Return the child tasks associated with the task
    #

    my $self = shift;
    # Check the cache
    unless ($self->{-child_tasks}) {
	# Get the linkdef
	my $linkdef = 
	  $HSDB4::SQLLinkDefinition::LinkDefs {'hsdb_tasks.link_task_task'};
	#
	$self->{-child_tasks} = $linkdef->get_children ($self->primary_key);
    }
    # Return the cached result
    return $self->{-child_tasks}->children;
}

sub parent_tasks {
    #
    # Return the parent tasks associated with the task
    #

    my $self = shift;
    # Check the cache
    unless ($self->{-parent_tasks}) {
	# Get the linkdef
	my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs {link_task_task};
	# Get the parents
	$self->{-parent_tasks} = $linkdef->get_parents ($self->primary_key);
    }
    # Return the cached result
    return $self->{-parent_tasks}->parents;
}

sub task_group {
    #
    # Return the admin group for the HSL Staff
    #
    my $group = HSDB45::UserGroup->new(_school => 'HSDB');
    $group->lookup_key(2);
    return $group;
}

sub task_group_users {
    my $self = shift;
    my $group = task_group;
    return $group->child_users;
}

sub start_date {
    #
    # Return a date object which is the start date
    #

    my $self = shift;
    unless ($self->{-start_date}) {
	return unless $self->field_value ('start_date') =~ /[1-9]+/;
	my $dt = HSDB4::DateTime->new ();
	$dt->in_mysql_date ($self->field_value ('start_date'));
	$self->{-start_date} = $dt;
    }
    return $self->{-start_date};
}

sub end_date {
    #
    # Return a date object which is the end date
    #
    
    my $self = shift;
    unless ($self->{-end_date}) {
	return unless $self->field_value ('end_date') =~ /[1-9]+/;
	my $dt = HSDB4::DateTime->new ();
	$dt->in_mysql_date ($self->field_value ('end_date'));
	$self->{-end_date} = $dt;
    }
    return $self->{-end_date};
}

#
# >>>>>  Input Methods <<<<<
#

#
# >>>>>  Output Methods  <<<<<
#

sub out_future_date {
    my $self = shift;
    my $dt = HSDB4::DateTime->new();
    $dt->add_days(60);
    return $dt->out_mysql_date;
}

sub out_now_date {
    my $self = shift;
    my $dt = HSDB4::DateTime->new();
    return $dt->out_mysql_date;
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
    my $outval = '<p>';
    $outval .= sprintf ("<b>Category</b>: %s<br>",
			$self->field_value ('category')
		       ) if $self->field_value ('category');
    $outval .= sprintf ("<p><b>Priority</b>: %s<br>",
			$self->field_value ('priority')
		       ) if $self->field_value ('priority');
    $outval .= sprintf ("<b>Percent Complete</b>: %s %%<br>",
			$self->field_value ('complete_percent')
		       );
    $outval .= sprintf ("<b>Start Date</b>: %s<br>", 
			$self->start_date->out_string_date
		       ) if $self->start_date;

    $outval .= sprintf ("<b>End Date</b>: %s<br>",
			$self->end_date->out_string_date
		       ) if $self->end_date;
    $outval .= "</p>\n";
    return $outval;
}

sub out_categories {
    my $self = shift;
    return @categories;
}

sub out_html_form {
    #
    # Blob of HTML for modification
    #

    my $self = shift;

    my $outval = $self->out_html_form_mod();
    $outval .= $self->out_html_form_password("Make Changes");

    $outval .= "</table></form>\n";
    return $outval;
}

sub out_html_form_add {
    my $self = shift;

    my $outval = $self->out_html_form_mod();
    $outval .= $self->out_html_form_comment();    
    $outval .= $self->out_html_form_password("Add Task");
    $outval .= "<input type=\"hidden\" name=\"add\" value=\"1\">";
    $outval .= "</table></form>\n";
    return $outval;
}

sub out_html_form_comment {
    my $self = shift;
    my $outval = "<tr><td><b>Subject:</b></td>";
    $outval .= "<td><input type=\"text\" name=\"subject\" size=\"60\"></td></tr>";
    $outval .= "<tr><td><b>Comment:</b></td>";
    $outval .= "<td><textarea name=\"comment\" cols=\"60\" wrap=\"virtual\" rows=\"4\">";
    $outval .= "</textarea></td></tr><tr><td>&nbsp;</td><td><i>Please include specifics about steps needed to produce the error and/or desired behavior.</i></td></tr>";
    return $outval;
}

sub out_html_form_mod {
    #
    # Blob of HTML for modification
    #

    my $self = shift;
    my $outval = '<form method="post"><table>';

    # The title
    $outval .= "<tr><td><b>Title</b></td>\n";
    $outval .= "<td><input type=\"text\" name=\"title\" size=\"50\" value=\"".$self->field_value('title')."\"></td></tr>\n";

    # The categorie
    $outval .= "<tr><td><b>Category</b></td>\n";
    $outval .= "<td><select name=\"category\">\n";
    foreach (@categories) {
	$outval .= sprintf ("<option value=\"%s\"%s>$_\n",
			    $_, 
			    $_ eq $self->field_value ('category') &&
			    ' selected');
    }
    $outval .= "</select></td></tr>\n";

    # The priorities
    $outval .= "<tr><td><b>Priority</b></td>\n";
    $outval .= "<td><select name=\"priority\">\n";
    foreach (@priorities) {
	$outval .= sprintf ("<option value=\"%s\"%s>\u$_\n",
			    $_, 
			    $_ eq $self->field_value ('priority') &&
			    ' selected');
    }
    $outval .= "</select></td></tr>\n";

    # The percent complete
    $outval .= "<tr><td><b>Percent Complete</b></td>\n";
    $outval .= "<td><select name=\"complete_percent\">\n";
    foreach (0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100) {
	$outval .= sprintf ("<option value=\"%s\"%s>$_\n",
			    $_, 
			    $_ eq $self->field_value ('complete_percent') &&
			   ' selected');
    }
    $outval .= "</select></td></tr>\n";

    # The start date
    $outval .= "<tr><td><b>Start date:</b></td>\n";
    $outval .= sprintf ("<td><input name=\"start_date\" size=\"30\" type=\"text\" value=\"%s\"></td></tr>\n",
			$self->start_date ? $self->start_date->out_mysql_date : $self->out_now_date
		       );

    # The end date
    $outval .= "<tr><td><b>End date:</b></td>\n";
    $outval .= sprintf ("<td><input name=\"end_date\" size=\"30\" type=\"text\" value=\"%s\"></td></tr>\n",
			$self->end_date ? $self->end_date->out_mysql_date : $self->out_future_date
		       );

    my @users = $self->task_group_users;
    # the user list
    $outval .= "<tr><td><b>Primary user:</b></td>\n";
    $outval .= "<td><select name=\"primary_user\">";
    my $user_list = join(",",map { $_->primary_key } $self->child_users);
    $outval .= "<option value=\"\"></option>";
    foreach (@users) {
	my $user_id = $_->primary_key;
	$outval .= sprintf ("<option value=\"%s\"%s>".$_->out_label."</option>\n",
			    $user_id, 
			    $user_list =~ /$user_id/ &&
			    ' selected');
    }
    $outval .= "</select></td></tr>";
    return $outval;
}

sub out_html_form_password {
    my $self = shift;
    my $submit_phrase = shift;

    my $outval = "<tr><td><b>DB Password</b></td>\n";
    $outval .= "<td><input name=\"password\" size=\"30\" type=\"password\">\n";
    $outval .= "<input type=\"submit\" name=\"Modify\" value=\"".$submit_phrase."\">\n";
    $outval .= "</td></tr>\n";
    return $outval;
}

sub out_xml {
    #
    # An XML representation of the row
    #
    return;
}

sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
    my $outval = sprintf ("<tr><td>%s</td>\n", $self->primary_key);
    $outval .= sprintf ("<td>%s</td>\n", $self->out_html_label);
    $outval .= sprintf ("<td>%s</td>\n", 
			   $self->field_value ('priority'));
    $outval .= sprintf ("<td>%s %%</td>\n", 
			   $self->field_value ('complete_percent'));
    my $end_date;
    if ($self->field_value('end_date') && $self->field_value('end_date') !~ /0000\-00\-00/) {
	$end_date = $self->end_date->out_mysql_date;
    }
    $outval .= sprintf ("<td>%s</td>\n", 
			    $end_date);
    $outval .= sprintf ("<td>%s</td></tr>\n",
			   join ("<br>\n", map { $_->out_html_label }
				 $self->primary_users
				)
			  );
    return $outval;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value ('title');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->field_value ('title');
}

sub new_comment {
    #
    # Create a new comment for this task
    #

    my $self = shift;
    my ($user, $password, $subject, $text) = @_;
    my $comment = HSDB4::SQLRow::TaskComment->new;
    $comment->set_field_values (task_id => $self->primary_key,
				user_id => $user,
				subject => $subject,
				comment => $text );
    delete $self->{-task_comments};
    return $comment->save ($user, $password);
}

sub task_cmp {
    #
    # Compare two tasks
    #

    my ($task_a, $task_b) = @_;
    my ($pri_a, $pri_b) = 
      map { $priority_map{$_->field_value ('priority')} } ($task_a, $task_b);
    return $pri_b <=> $pri_a || $task_b->end_date <=> $task_a->end_date;
}

sub task_string {
    #
    # Return a string of the task
    #

    my $task = shift;
    return $task->out_label;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::Task> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::Task;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects



=head2 Input Methods

B<in_xml()> is not yet implemenented.

B<in_fdat_hash()> is not yet implemented.

=head2 Output Methods

B<out_html_div()> 

B<out_xml()> is not yet implemented.

B<out_html_row()> 

B<out_label()> 

B<out_abbrev()> 

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut

