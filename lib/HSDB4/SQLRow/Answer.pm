
package HSDB4::SQLRow::Answer;

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

use vars @EXPORT_OK;

require HSDB4::SQLRow::Content;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "answer";
my $primary_key_field = [ 'user_id', 'content_id' ];
my @fields = qw(user_id
                content_id
                modified
                answer
                correct);
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

sub new_fdat_hash {
    #
    # Take in a fdat hash and make all the appropriate answers from it
    #

    # Figure out what class we're talking about
    my $class = shift;
    $class = ref $class || $class;

    # Get the user object and make sure it's good
    my $user = shift;
    $user->can ('primary_key') && $user->primary_key or return;

    # Now go through the list we get
    my ($q_id, $response, $count) = (undef, undef, 0);
    while (($q_id, $response) = splice (@_, 0, 2)) {
	# Get the question ID
	my ($question_id) = $q_id =~ /^Q-(\d+)/;
	# And skip it unless we have a good question ID and an answer
	next unless $question_id && $response;

	# Get the question object and figure out whether this is the right
	# answer
	my $question = HSDB4::SQLRow::Content->new->lookup_key ($question_id);
	my $correct = 'Unknown';
	# If it's a multiple choice question
	if (length($question->correct_answer) == 1) {
	    # We can figure out whether the answer is right
	    if (uc ($response) eq uc ($question->correct_answer)) {
		$correct = 'Correct';
	    }
	    else { $correct = 'Incorrect' }
	}

	# Make a new answer object
	my $answer = $class->new;
	# See if there's one there already
	$answer->lookup_key ($user->primary_key, $question_id);
	unless ($answer->primary_key()) {
	    $answer->primary_key($user->primary_key, $question_id);
	}

	# Either way, set the answer field anew
	$answer->set_field_values (answer => $response,
				   correct => $correct);

	# Now save: either update a pre-existing answer
	$count += ($answer->save() ? 1 : 0);
    }
    # Return the number of questions we saved
    return $count;
}

#
# >>>>> Linked objects <<<<<
#



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

B<HSDB4::SQLRow::Answer> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::Answer;
    
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

