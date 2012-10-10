package HSDB4::SQLRow::PersonalContent;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    require HSDB4::SQLRow::Content;
    require HSDB45::Course;
    require HSDB45::UserGroup;
    require HSDB4::SQLRow::User;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.19 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps  { return @mod_deps  }
sub get_file_deps { return @file_deps }

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "personal_content";
my $primary_key_field = "personal_content_id";
my @fields = qw(personal_content_id
                user_id
                type
                course_id
                content_id
                modified
                body);
my %blob_fields = (body => 1);
my %numeric_fields = ();

sub max_cache_age { return 0 }

my %cache = ();

# Creation methods

my %TypeClass = 
    ( 'Discussion Comment' => 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Discussion Answer'=> 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Discussion Question' => 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Discussion Suggestion' => 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Discussion Tip' => 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Discussion URL' => 'HSDB4::SQLRow::PersonalContent::Discussion',
      'Collection' => 'HSDB4::SQLRow::PersonalContent::Collection',
	  'Flash Card Deck' => 'HSDB4::SQLRow::PersonalContent::Collection',
      );

sub rebless {
    my $self = shift;
    my $type = $self->field_value('type');
    if ($type && $TypeClass{$type}) { bless $self, $TypeClass{$type} }
    return $self;
}

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
    return $self->rebless;
}

sub new_blank {
    #
    # Make a new personal content object and save it to the DB
    #

    # What class are we?
    my $class = shift;
    # Make a new object
    my $self = $class->new;

    # Now read in the arguemnts
    my %args = @_;
    # Set the type, if we have it, and to 'Note' otherwise
    if ($args{type}) { $self->field_value('type', $args{type}) }
    else { $self->field_value('type', 'Note') } 
    # Get the user_id, and forget it if we can't
    if ($args{user_id}) { $self->field_value('user_id', $args{user_id}) }
    else { return }
    # Set the body, if it's there
    if ($args{body}) { $self->field_value ('body', $args{body}) }

    # Make sure we're properly blessed, and return
    return $self->rebless;
}

sub lookup_key {
    my $self = shift;
    $self->SUPER::lookup_key (@_);
    return $self->rebless;
}

sub lookup_conditions {
    my $self = shift;
    my @results = $self->SUPER::lookup_conditions (@_);
    return map { $_->rebless } @results;
}



sub updateSortOrders {

	my ($self, $index, $newindex, $cond, $arrayref, $multiple) = @_;
	
	my $qry = "";
	

}



sub is_user_authorized {
    # 
    # Decide whether a named user is authorized to look at this item from
    # the database.
    #
    
    my ($self, $user) = @_;

    # Blank users are *not* authorized no matter what
    return 0 unless $user;

    # Make sure the author is the same as the user
    return 1 if $self->field_value('user_id') eq $user;
    return 0;
}

sub is_user_authorized_write {
    # 
    # Decide whether a named user is authorized to look at this item from
    # the database.
    #
    
    my ($self, $user) = @_;

    # Blank users are *not* authorized no matter what
    return 0 unless $user;

    # Make sure the author is the same as the user
    return 1 if $self->field_value('user_id') eq $user;
    return 0;
}

#
# >>>>> Linked objects <<<<<
#

sub parent_content {
    #
    # Return the content this personal_content is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_personal_content'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_content} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_content}->parents();
}

sub parent_courses {
    #
    # Return the courses this personal_content is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_courses}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_course_personal_content'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_courses} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_courses}->parents();
}

sub parent_user_groups {
    #
    # Return the user_groups this personal_content is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_user_groups}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_user_group_personal_content'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_user_groups} = 
            $linkdef->get_parents ($self->primary_key);

    }
    # Return the list
    return $self->{-parent_user_groups}->parents();
}

sub parent_personal_content {
    #
    # Return the personal_content this personal_content is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_personal_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_personal_content'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_personal_content} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_personal_content}->parents();
}


sub child_content {
    #
    # Get the content linked down from this personal_content
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_content'};
        # And use it to get a LinkSet of users
        $self->{-child_content} = 
            $linkdef->get_children($self->primary_key, @_);
        my $path = sprintf("%dP", $self->primary_key);
        foreach my $child ($self->{-child_content}->children) {
            $child->set_aux_info ('uri_path', $path);
        }
    }
    # Return the list
    return $self->{-child_content}->children();
}

sub child_flash_cards{
  
	my $self = shift;
	my $cards = HSDB4::SQLRow::FlashCard->new()->lookup("parent_personal_content_id = ".$self->primary_key);
    return $cards;
}


sub active_child_content{
    #
    # only get active content
    #

    my ($self) = @_;
    return $self->child_content("(start_date <= now() or start_date is null) and (end_date >= now() or end_date is null)");
}

sub add_child_content {
    #
    # Make a new link
    #

    my $self = shift;
    # Get the right link definition
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_content'};
    # Get the object to add in, and make sure it's good
    my $doc = shift;
    $doc and $doc->primary_key or return;
    # Make sure it's the right class
    $doc->isa ($linkdef->child_class) or return;
    # Get the sort order of the last item, and add 10 to it
    my @content = $self->child_content;
    # Don't add it twice!
    foreach (@content) { return if $_->primary_key == $doc->primary_key }
    my $last_sort = @content ? $content[-1]->aux_info ('sort_order') + 10 : 10;
    # Now do the insert
    my ($r, $msg) = $linkdef->insert (-parent_id => $self->primary_key,
				      -child_id => $doc->primary_key,
				      sort_order => $last_sort);
    # Clear the cache so we read from the DB next time we ask for this list
    if ($r) { $self->{-child_content} = undef; }
    # And return the results
    return wantarray ? ($r, $msg) : $r;
}

sub delete_child_content {
    #
    # Delete a link
    #

    my $self = shift;
    # Get the right link definition
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_content'};
    # Get the object to add in, and make sure it's good
    my $doc = shift;
    $doc and $doc->primary_key or return;
    # Make sure it's the right class
    $doc->isa ($linkdef->child_class) or return;
    my ($r, $msg) = $linkdef->delete (-parent_id => $self->primary_key,
				      -child_id => $doc->primary_key);
    # Clear the cache so we read from the DB next time we ask for this list
    if ($r) { $self->{-child_content} = undef; }
    # And return the results
    return wantarray ? ($r, $msg) : $r;
}

sub child_personal_content {
    #
    # Get the personal_content linked down from this personal_content
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_personal_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_personal_content'};
        # And use it to get a LinkSet of users
        $self->{-child_personal_content} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_personal_content}->children();
}

sub add_child_personal_content {
    #
    # Make a new link to some personal content
    #

    my $self = shift;
    # Get the right link definition
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_personal_content'};
    # Get the object to add in, and make sure it's good
    my $pc = shift;
    $pc and $pc->primary_key or return;
    # Make sure it's the right class
    $pc->isa ($linkdef->child_class) or return;
    # Get the sort order of the last item, and add 10 to it
    my @pcs = $self->child_personal_content;
    # Don't add it twice!
    foreach (@pcs) { return if $_->primary_key == $pc->primary_key }
    my $last_sort = @pcs ? $pcs[-1]->aux_info ('sort_order') + 10 : 10;
    # Now do the insert
    my ($r, $msg) = $linkdef->insert (-parent_id => $self->primary_key,
				      -child_id => $pc->primary_key,
				      sort_order => $last_sort);
    # Clear the cache so we read from the DB next time we ask for this list
    if ($r) { $self->{-child_personal_content} = undef; }
    # And return the results
    return wantarray ? ($r, $msg) : $r;
}

sub delete_child_personal_content {
    #
    # Delete a child personal contentlink
    #

    my $self = shift;
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_personal_content_personal_content'};
    # Get the object to add in, and make sure it's good
    my $pc = shift;
    $pc and $pc->primary_key or return;
    # Make sure it's the right class
    $pc->isa ($linkdef->child_class) or return;

    # Delete the link
    my ($r, $msg) = $linkdef->delete (-parent_id => $self->primary_key,
				      -child_id => $pc->primary_key);
    
    # Now, delete the object
    ($r, $msg) = $pc->delete if $r;

    # Clear the cache so we read from the DB next time we ask for this list
    if ($r) { $self->{-child_personal_content} = undef; }
    # And return the results
    return wantarray ? ($r, $msg) : $r;
}

sub user {
    #
    # Return the user object associated with this personal content
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-user}) {
	# Make the user object, and put it in the cache
	$self->{-user} = HSDB4::SQLRow::User->new();
	# And lookup the name we have
	$self->{-user}->lookup_key ($self->field_value('user_id'));
    }
    # And return the cached object
    return $self->{-user};
}

sub delete_from_user {
    #
    # Delete this object from the user's connection
    #

    my $self = shift;
    # Get the link definition
    my $linkdef = 
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_user_personal_content'};
    # And do the deletion!
    return $linkdef->delete (-parent_id => $self->field_value('user_id'),
			     -child_id => $self->primary_key);
}

#
# >>>>>  Input Methods <<<<<
#

sub edit_body {
    #
    # Rename the collection
    #

    my $self = shift;
    my $newname = shift;
    $self->field_value('body', $newname);
    $self->save;
}

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

sub out_log_item {
    #
    # Return an item for logging
    #

    my $self = shift;
    my $id = $self->primary_key;
    my $course_id = $self->field_value('course_id') || '';
    my $content_id = $self->field_value('content_id') || '';
    return "Personal Content:$course_id:$content_id:$id";
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_html_row {
    #
    # A two-column row for showing stuff
    #

    my $self = shift;
    my $outval = "<TR><TD>&nbsp;</TD>\n";
    $outval .= "<DIV CLASS=\"docinfo\">" . $self->field_value('body') 
	. "</DIV>\n";
    return $outval;
}

sub out_html_edit {
    ##################################################################################################################
    #
    #
    #       THIS HAS A MASON COMPONENT THAT CAN BE USED   tusk/tmpl/objects/PersonalContent:edit_PersonalContent
    #
    #
    ##################################################################################################################
    # 
    # A two-column nested HTML for editing
    #

    my $self = shift;
    my $parent_id = shift;
    # The header row
    my $outval = "<TR VALIGN=\"TOP\"><TD>&nbsp;</TD>\n";
    my $del = sprintf ("del_p_content_%s_%s", $parent_id, $self->primary_key);
    my $text_name = "rename_val_" . $self->primary_key;
    $outval .= "<TD>&nbsp;</TD>\n";
    $outval .= "<TD VALIGN=\"TOP\">\n";
    $outval .= sprintf ("<TEXTAREA NAME=\"%s\" COLS=60 WRAP=\"VIRTUAL\" ROWS=4>", $text_name);
    $outval .= $self->field_value('body') . "</TEXTAREA></TD>\n";
    $outval .= "<TD ALIGN=\"LEFT\" VALIGJN=\"TOP\"><INPUT TYPE=SUBMIT VALUE=\"Save Note\"></TD>\n";
    $outval .= "<TD ALIGN=\"RIGHT\"><INPUT TYPE=\"SUBMIT\" NAME=\"$del\" VALUE=\"Delete\"</TD>\n";
    $outval .= "</TR>\n";

    return $outval;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return sprintf ("%s: %s", $self->user->out_abbrev, 
		    $self->field_value('type'));
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return substr($self->out_label, 0, 15);
}

package HSDB4::SQLRow::PersonalContent::Collection;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::PersonalContent');


sub out_url{
    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::URLs{$class};
    return $url;
}

sub delete {
    #
    # Delete the object and its associated links
    #

    my $self = shift;
    # Clean up the links to all the child content objects
    foreach ($self->child_content) {
	$self->delete_child_content ($_);
    }

    # Clean up the links to all the child personal_content objects
    foreach ($self->child_personal_content) {
	$self->delete_child_personal_content ($_);
    }

    # Clean up the link from the user to this collection
    $self->delete_from_user;

    # Now delete the actual object
    return $self->SUPER::delete();
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value('body');
}

sub out_html_row {
    ##################################################################################################################
    #
    #
    #       THIS HAS A MASON COMPONENT THAT CAN BE USED   tusk/tmpl/objects/PersonalContent:edit_PersonalContentCollection
    #
    #
    ##################################################################################################################
    # 
    # A two-column nested HTML row
    #

    my $self = shift;
    # The header row
    my $thumbnail = 
	"<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
    my $outval = "<TR BGCOLOR=\"#cccccc\"><TD>$thumbnail</TD>\n";
    $outval .= "<TD COLSPAN=3 ALIGN=LEFT>";
    my $text_name = "rename_val_" . $self->primary_key;
    my $add_note_name = "add_note_" . $self->primary_key;
    my $delete_name = "delete_" . $self->primary_key;
    $outval .= sprintf ("<INPUT NAME=\"%s\" TYPE=TEXT SIZE=40 VALUE=\"%s\">\n",
			$text_name, $self->out_label);
    $outval .= "<INPUT TYPE=SUBMIT VALUE=\"Rename\">\n";
    $outval .= 
	"<INPUT TYPE=SUBMIT NAME=\"$add_note_name\" VALUE=\"Add Note\"></TD>\n";
    $outval .= "<TD ALIGN=RIGHT><INPUT TYPE=SUBMIT NAME=\"$delete_name\" VALUE=\"Delete\">\n";
    $outval .= "</TD></TR>";
    foreach my $doc ($self->active_child_content()) { 
	$outval .= "<TR><TD>&nbsp;</TD>\n";
	my $delname = sprintf ("del_content_%d_%d", $self->primary_key,
			       $doc->primary_key);
	$outval .= sprintf ("<TD ALIGN=\"CENTER\">%s</TD>\n", $doc->out_html_thumbnail);
	$outval .= sprintf ("<TD>%s</TD>\n", $doc->out_html_label);
	my $authors = join ("; ", map { $_->out_abbrev } $doc->child_users);
	$outval .= "<TD>$authors</TD>\n";
	$outval .= "<TD ALIGN=\"RIGHT\"><INPUT TYPE=SUBMIT NAME=\"$delname\" VALUE=\"Delete\"></TD>\n";
	$outval .= "</TR>\n";
	foreach ($doc->child_personal_content($self->field_value('user_id'))) {
	    $outval .= "<TR><TD>&nbsp;</TD>\n";
	    $outval .= "<TD>&nbsp;</TD>\n";
	    $outval .= "<TD>";
            my @lines = split /[\cA-\cZ]{2}/, $_->field_value('body');
	    foreach my $l (@lines) {
		$outval.= "<DIV CLASS=\"docinfo\"><I>$l</I></DIV>\n";
	    }
	    $outval .= "</TD>\n";
	    $outval .= "<TD>&nbsp;</TD>\n";
	    $outval .= "<TD>&nbsp;</TD></TR>\n";
	}

    }
    foreach my $pc ($self->child_personal_content) { 
	$outval .= $pc->can('out_html_edit') ? 
	    $pc->out_html_edit ($self->primary_key) : $pc->out_html_row;
    }
    return $outval;
}


package HSDB4::SQLRow::PersonalContent::Discussion;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::PersonalContent');

sub is_user_authorized {
    # 
    # Decide whether a named user is authorized to look at this item from
    # the database.
    #
    
    my ($self, $user) = @_;

    # No for guests...
    return 0 if HSDB4::Constants::is_guest($user);

    # No for shib users...
    return 0 if(TUSK::Shibboleth::User->isShibUser($user) != -1);

    # ...yes for everyone else
    return 1;
}

sub is_user_authorized_write {
    # 
    # Decide whether a named user is authorized to look at this item from
    # the database.
    #
    
    my ($self, $user) = @_;

    # You can't edit a discussion bit once you've submitted it
    return 0;
}


1;
__END__

=head1 NAME

B<HSDB4::SQLRow::PersonalContent> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::PersonalContent;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects

B<parent_content()>

B<parent_courses()>

B<parent_user_groups()>

B<parent_personal_content()>

B<child_content()>

B<child_personal_content()>

B<user()>

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



