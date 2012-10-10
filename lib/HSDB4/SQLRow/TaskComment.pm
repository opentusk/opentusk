package HSDB4::SQLRow::TaskComment;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

require HSDB4::SQLRow::User;
require HSDB45::UserGroup;
require HSDB4::SQLRow::Task;

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "hsdb_tasks.task_comment";
my $primary_key_field = "comment_id";
my @fields = qw/comment_id task_id user_id created subject comment/;
my %blob_fields = (comment => 1);
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

sub created {
    #
    # Return a date object which is the start date
    #

    my $self = shift;
    unless ($self->{-created}) {
	return unless $self->field_value ('created') =~ /[1-9]+/;
	my $dt = HSDB4::DateTime->new ();
	$dt->in_mysql_date ($self->field_value ('created'));
	$self->{-created} = $dt;
    }
    return $self->{-created};
}

sub user {
    # 
    # Return the user who created the comment
    #

    my $self = shift;
    unless ($self->{-user}) {
	$self->{-user} = HSDB4::SQLRow::User->new;
	$self->{-user}->lookup_key ($self->field_value ('user_id'));
	delete $self->{-user} unless $self->{-user}->primary_key;
    }
    return $self->{-user};
}


#
# >>>>>  Input Methods <<<<<
#

#
# >>>>>  Output Methods  <<<<<
#

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
    my $outval = '<div>';
    $outval .= '<b>Re: ' . $self->field_value ('subject') . '</b><br>';
    $outval .= 'Author: ' . $self->user->out_label . '<br>';
    $outval .= 'Date: ' . $self->created->out_string_date . '<br>';
    $outval .= $self->field_value ('comment');
    $outval .= '</div>';
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
    my $outval = sprintf ('<tr><td><b>%s</b></td><td>%s</td><td>%s</td></tr>',
			$self->field_value ('subject'),
			$self->user->out_label,
			$self->created->out_string_date
			);
    $outval .= '<tr><td colspan="3">' . $self->field_value ('comment') 
      . '</td></tr>';
    return $outval;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value ('subject');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->field_value ('subject');
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

