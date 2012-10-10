package HSDB4::SQLRow::SmallGroup;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

require HSDB4::SQLRow::User;
require HSDB4::SQLRow::LocationException;
require HSDB4::SQLRow::Course;

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "small_group";
my $primary_key_field = "small_group_id";
my @fields = qw(small_group_id
                course_id
                label
                meeting_type
                instructor
                location
                max_students
                modified);
my %blob_fields = ();
my %numeric_fields = ();

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


sub child_users {
    #
    # Get the user linked down from this small_group
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_users}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_small_group_user'};
        # And use it to get a LinkSet of users
        $self->{-child_users} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_users}->children();
}

sub students {
    #
    # Get specifically the students
    #

    my $self = shift;
    return sort { $a cmp $b } grep { $_->field_value('type') == 'Student' } 
    $self->child_users;
}

sub location_exceptions {
    #
    # Get the small_group assignments for this class
    #

    my $self = shift;

    # Check the cache
    unless ($self->{-location_exceptions}) {
	# Make the condition
	my $condition = sprintf ("small_group_id='%s'", $self->primary_key);
	my $order = 'ORDER BY meeting_date';
	$self->{-location_exceptions} = 
	    [ HSDB4::SQLRow::LocationException->lookup_conditions ($condition, 
								   $order) ];
    }
    return @{$self->{-location_exceptions}};
}

sub course {
    #
    # Get the course with which this small group is associated
    #
    
    my $self = shift;

    # Check the cache
    unless ($self->{-course}) {
	# What ID?
	my $course_id = $self->field_value('course_id');
	# Now get the object
	$self->{-course} = HSDB4::SQLRow::Course->new->lookup_key ($course_id);
    }
    # And return the object
    return $self->{-course};
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

my %type_labels = ('Small Group' => 'Small Group',
		   'Conference' => 'Conference Group',
		   'Laboratory' => 'Lab Group',
		   );

sub out_type_label {
    #
    # Return a formatted version of the label for the group
    #
    
    my $self = shift;
    my $type = $type_labels{$self->field_value('meeting_type')};
    return sprintf "%s %s", $type, $self->field_value('label');
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
    my $username = shift;
    my $outval = '';

    # The main information
    $outval .= sprintf("<DIV CLASS=\"title\">%s %s</DIV>\n", 
		       $self->out_type_label);
    $outval .= sprintf ("<DIV CLASS=\"groupinfo\">%s</DIV>\n",
			$self->field_value('instructor'));
    $outval .= sprintf ("<DIV CLASS=\"groupinfo\">%s</DIV>\n",
			$self->field_value('location'));

    # The list of exceptions
    foreach my $ex ($self->location_exceptions) {
	$outval .= sprintf ("<DIV CLASS=\"grouplist\"><B>Except on %s</B>:\n",
			    $ex->meeting_date ()->out_string_date_short ());
	my ($loc, $ins) = ($ex->field_value('new_location'),
			   $ex->field_value('new_instructor'));
	$loc = "go to $loc" if $loc;
	$ins = "with $ins" if $ins;
	if ($loc && $ins) { $outval .= "$loc, $ins" }
	else { $outval .= "$loc$ins" }
	$outval .= "</DIV>\n";
    }
    
    # The list of students
    $outval .= join ("\n", 
		     map { 
			 my $color = $_->primary_key eq $username ?
			     ' STYLE="color: red;"' : '';
			 sprintf "<DIV$color CLASS=\"grouplist\">%s</DIV>",
			 $_->out_label } $self->students );
    
    return $outval;
}

sub out_html_row {
    #
    # Return some rows where the course name is assumed
    #

    my $self = shift;
    # Do the main row
    my $outval = sprintf ("<TR><TD><DIV CLASS=\"title\">%s</DIV></TD>\n", 
			  $self->out_type_label);
    $outval .= sprintf "<TD>%s</TD>", $self->field_value('instructor');
    $outval .= sprintf "<TD>%s</TD></TR>", $self->field_value('location');

    # Now add a row for each of the location exceptions
    foreach my $ex ($self->location_exceptions) {
	$outval .= sprintf ("<TR><TD ALIGN=\"RIGHT\"><B>Except on %s</B></TD>\n",
			    $ex->meeting_date ()->out_string_date_short ());
	my ($loc, $ins) = ($ex->field_value('new_location'),
			   $ex->field_value('new_instructor'));
	$outval .= sprintf "<TD>go to %s</TD>\n", $loc ? $loc : '&nbsp;';
	$outval .= sprintf "<TD>with %s</TD>\n", $ins ? $ins : '&nbsp;';
	$outval .= "</TR>\n";
    }
    return $outval;
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->out_type_label;
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->out_type_label;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::SmallGroup> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::SmallGroup;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects

B<child_users()>

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

