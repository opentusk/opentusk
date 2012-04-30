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



package HSDB4::SQLRow::PPTUpload;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;
require HSDB4::DateTime;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "ppt_upload_status";
my $primary_key_field = "ppt_upload_status_id";
my @fields = qw(ppt_upload_status_id
		username
                course_id
                status
                statustime
                copyright
                school
                content_id
                author
                title
               	);
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

sub lookup_user_ppt {
	#
	# Do a lookup for all ppts for a particular user
	#

	my $self = shift;
	my $un = shift;
	my $in_last_days = shift;

	my $cond_ppt= "username='$un'";

	my $time_cond = '';
	if (defined $in_last_days) {
		my $compare_date = HSDB4::DateTime->new();
		$compare_date->subtract_days($in_last_days);

		$time_cond = "statustime > '" . $compare_date->out_mysql_timestamp() . "'";
	}

	
	my @conds = ($cond_ppt, $time_cond, 'ORDER BY ppt_upload_status_id DESC');
	return $self->lookup_conditions (@conds);
}

sub lookup_ppt{
    #
    # Do a lookup for a particular saved_filename
    #

    my ($self, $filename) = @_;
    my $content_id = $filename;
    $content_id =~ s/\.zip//;
    my $cond_ppt = "content_id = '$content_id'";
    my @conds = ($cond_ppt,'ORDER BY ppt_upload_status_id');
    my @objects = $self->lookup_conditions(@conds);
    return $objects[0]; # we only want the first object
}

sub update_status{

    my $self = shift;
    my $new_status = shift;
    
    $self->field_value('status', $new_status);
    
    # Save to the database
    return $self->SUPER::save;
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
    # Formatted blob of HTML with the information
    #
    return;
}

sub out_html_row {
    #
    # Formatted blob of HTML with the information
    #

    return;
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
    return "PPT_upload";
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return "ppt_upload";
}

sub return_date {
    #
    # Return a date object which is the start date
    #

    my $self = shift;
    my $date = shift;
    my $dt = HSDB4::DateTime->new ();
	
	$dt->in_mysql_date ($date);
	
	return $dt;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::PPT_upload> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::PPT_upload;
    
=head1 DESCRIPTION

=head1 METHODS

B<lookup_user_ppt($username)> returns ppt_upload rows associated with the inputted username.

=head2 Linked Objects

=head2 Input Methods

B<in_xml()> is not yet implemenented.

B<in_fdat_hash()> is not yet implemented.

=head2 Associated Objects

B<

=head2 Output Methods

B<out_html_div()> is not yet implemented.

B<out_xml()> is not yet implemented.

B<out_html_row()> is not yet implemented.

B<out_label()>

B<out_abbrev()> 

=head1 AUTHOR

Paul Silevitch <paul@silevitch.com>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut

