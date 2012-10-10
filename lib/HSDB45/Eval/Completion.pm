package HSDB45::Eval::Completion;

use strict;

BEGIN {
    use base qw/HSDB4::SQLRow/;
    require HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version {
    return $VERSION;
}

require HSDB45::Eval;
require HSDB45::Eval::Question::Response;
require HSDB4::DateTime;

# dependencies for things that relate to caching
my @mod_deps  = ();
my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# File-private lexicals
my $tablename = "eval_completion";
my $primary_key_field = [ 'user_id', 'eval_id' ];
my @fields = qw(user_id
                eval_id
                created
                status);
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();

sub user_id {
    my $self = shift();
    return $self->field_value('user_id');
}

sub eval_id {
    my $self = shift();
    return $self->field_value('eval_id');
}

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

sub split_by_school { return 1 }

#
# >>>>> Linked objects <<<<<
#

sub eval {
    #
    # Find the actual eval object
    #

    my $self = shift;

    # Check the cache
    unless ($self->{-eval}) {
	# Make the object
	$self->{-eval} = HSDB45::Eval->new( _school=>$self->school(),
					    _id=>$self->field_value('eval_id') );
    }
    return $self->{-eval};
}

sub completion_date {
    #
    # Get the DateTime object for the completion date
    #

    my $self = shift;

    # Check the cache
    unless ($self->{-completion_date}) {
	$self->{-completion_date} = HSDB4::DateTime->new;
	$self->{-completion_date}->in_mysql_timestamp ($self->field_value ('created'));
    }

    return $self->{-completion_date};
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

    # Add a label
    my $outval = "<tr><td>" . $self->out_label . "</td>\n";
    # Add the completion date
    $outval .= "<td>" . $self->completion_date->out_string_date . "</td>\n";
    $outval .= "</tr>\n";
    # And return the value
    return $outval;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->eval()->out_label;
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->eval()->out_abbrev;
}

1;
