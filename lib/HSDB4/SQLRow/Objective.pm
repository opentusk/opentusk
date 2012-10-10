
package HSDB4::SQLRow::Objective;

use strict;

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

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "objective";
my $primary_key_field = "objective_id";
my @fields = qw(objective_id
                modified
                body);
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();

sub objective_id {
    my $self = shift();
    return $self->field_value('objective_id');
}

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

sub parent_class_meetings {
    #
    # Return the class_meetings this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_class_meetings}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_class_meeting_objective'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_class_meetings} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_class_meetings}->parents();
}

sub parent_courses {
    #
    # Return the courses this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_courses}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_course_objective'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_courses} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_courses}->parents();
}

sub parent_objectives {
    #
    # Return the objectives this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_objectives}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_objective'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_objectives} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_objectives}->parents();
}

sub parent_content {
    #
    # Return the content this objective is linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_objective'};
        # And use it to get a LinkSet, if possible
        $self->{-parent_content} = 
            $linkdef->get_parents ($self->primary_key);
    }
    # Return the list
    return $self->{-parent_content}->parents();
}


sub child_objectives {
    #
    # Get the objective linked down from this objective
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_objectives}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_objective'};
        # And use it to get a LinkSet of users
        $self->{-child_objectives} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_objectives}->children();
}

sub child_content {
    #
    # Get the content linked down from this objective
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_content}) {
        # Get the link definition
        my $linkdef =
            $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_content'};
        # And use it to get a LinkSet of users
        $self->{-child_content} = 
            $linkdef->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_content}->children();
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
    # A four-column HTML row
    #

    my $self = shift;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value ('body');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;

}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::Objective> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::Objective;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects

B<parent_class_meetings()>

B<parent_courses()>

B<parent_objectives()>

B<parent_content()>

B<child_objectives()>

B<child_content()>

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

