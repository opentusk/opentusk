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



package HSDB4::SQLRow::StatusHistory;

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

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "status_history";
my $primary_key_field = "content_id";
my @fields = qw(content_id
                status_type
                status
		assigner
		status_date
                status_note);
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

#
# >>>>>  Input Methods <<<<<
#
sub save_status {
    my $self = shift;
    my $un = shift;
    my $pw = shift;
    my $content_id = shift;
    my $status = shift;
    my $status_note = shift;
    my $user = shift;
    $user = $un unless ($user);
    $self->{_primary_key_field} = ""; ## must empty this to bypass the UPDATE and make this an INSERT
    $self->set_field_values (content_id => $content_id,
				       status_type => 'Draft',
				       status => $status,
				       assigner => $user,
				       status_date => $self->format_sql_date($self->get_now_sql_date()),
				       status_note => $status_note
				       );
    my ($r, $msg) = $self->save($un,$pw);
    return ($r,$msg);
}

#
# >>>>>  Output Methods <<<<<
#

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value('status');
}

sub get_now_sql_date {
    my $self = shift;
    my ($secs,$mins,$hours,$mo_day,$mo,$yr) = (localtime)[0,1,2,3,4,5];
    $yr += 1900;
    $mo += 1;
    ## prepend 0 if single numbers
    $mo = "0$mo" if (length($mo) < 2);
    $mo_day = "0$mo_day" if (length($mo_day) < 2);
    $secs = "0$secs" if (length($secs) < 2);
    $hours = "0$hours" if (length($hours) < 2);
    $mins = "0$mins" if (length($mins) < 2);
    return "$yr-$mo-$mo_day $hours:$mins:$secs";
}

sub format_sql_date {
    my $self = shift;
    my $time = shift;
    $time =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3\ $4:$5:$6/;
    return $time;
}

1;
__END__

=head1 NAME

B<HSDB4::SQLRow::StatusHistory> - 

=head1 SYNOPSIS

    use HSDB4::SQLRow::StatusHistory;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects

=head2 Input Methods

=head2 Output Methods

B<out_label()> 

=head1 AUTHOR

Mike Kruckenberg <michael.kruckenberg@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut

