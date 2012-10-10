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


package HSDB45::TimePeriod;

use strict;

BEGIN {
    use base qw(HSDB4::SQLRow);
    use HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.16 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "time_period";
my $primary_key_field = "time_period_id";
my @fields = qw(time_period_id
                academic_year
                period
                start_date
		end_date);
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

sub split_by_school { return 1; }

sub nonpast_time_periods {
    my $self = shift;
    return $self->lookup_conditions('end_date >= curdate()',
				    'ORDER BY start_date DESC, end_date DESC');
}

sub time_periods_for_date {
    my $self = shift;
    my $date = shift;
    return $self->lookup_conditions("\"$date\" between start_date and end_date");
}

#######
# insure that school has an eternity time period with standard end date.
# if it does, return it, if not, return undef.
#######
sub get_eternity_period {
	my $self = shift;
	return ($self->lookup_conditions('period="eternity" and end_date="2036-10-31"'))[0];
}

sub period {
	my $self = shift;
	return $self->field_value('period');
}

sub start_date {
    my $self = shift;
    unless ($self->{-start_date}) {
	$self->{-start_date} = HSDB4::DateTime->new()->in_mysql_date($self->field_value('start_date'));
    }
    return $self->{-start_date};
}

sub end_date {
    my $self = shift;
    unless ($self->{-end_date}) {
	$self->{-end_date} = HSDB4::DateTime->new()->in_mysql_date($self->field_value('end_date'));
    }
    return $self->{-end_date};
}

sub raw_start_date {
    my $self = shift;
    return $self->field_value('start_date');
}

sub raw_end_date {
    my $self = shift;
    return $self->field_value('end_date');
}


# give me an array of time_periods and I will tell you the first one that is nonpast (useful for figuring out the default in a time period dropdown)
sub get_current_time_period {
    my ($tps) = @_;

    foreach my $period (@$tps){
	my $dt = HSDB4::DateTime->new()->in_mysql_date($period->field_value('end_date'));

	if ($dt->out_unix_time > time()){
	    return $period->primary_key;
	}
    }

    return -1;
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
    return $self->field_value('period');
}

sub out_display {
    #
    # Output method that shows the period and the year
    #

    my $self = shift;
    my $string = $self->field_value('period');
    if ($self->field_value('academic_year')){
	$string.=" (".$self->field_value('academic_year').")";
    }
    return $string;
}

sub out_date_range {
    #
    # Output method that shows the dates
    #

    my $self = shift;
    return $self->start_date->out_string_date_short_year . " - " . $self->end_date->out_string_date_short_year;
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;

}

package HSDB45::TimePeriod::Lister;

use base qw(XML::Lister);
use XML::Twig;

sub sqlrow_class {
    return 'HSDB45::TimePeriod';
}

sub list_element_name {
    return 'TimePeriodList';
}

sub get_element_elt {
    my $lister = shift;
    my $tp = shift;
    my $elt = XML::Twig::Elt->new('time_period', 
				  { time_period_id => $tp->primary_key(),
				    school => ucfirst($tp->school()),
				  });
    my $title = XML::Twig::Elt->new('title', $tp->out_label());
    $title->paste('last_child', $elt);
    my $start_date = XML::Twig::Elt->new('start_date', $tp->field_value('start_date'));
    $start_date->paste('last_child', $elt);
    my $end_date = XML::Twig::Elt->new('end_date', $tp->field_value('end_date'));
    $end_date->paste('last_child', $elt);
    return $elt;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::TimePeriod> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::TimePeriod;
    
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

