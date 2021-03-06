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


package HSDB45::Eval::Results::BarGraph;

use strict;

BEGIN {
    use vars qw($VERSION);
    use base qw(HSDB4::SQLRow);

    $VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

    use HSDB4::DateTime;
}

sub version {
    return $VERSION;
}

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# File-private lexicals
my $tablename = "eval_results_graphics";
my $primary_key_field = "eval_results_graphics_id";
my @fields = qw(eval_results_graphics_id eval_id eval_question_id categorization_question_id categorization_value mime_type width height graphic graphic_text modified);
my %blob_fields = (graphic => 1, graphic_text => 1);
my %numeric_fields = (width => 1, height => 1);

my %cache = ();

# Description: creates a new HSDB45::Eval::Results::BarGraph object
# Input: _school => school, _id => id
# Output: newly created object
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
    return $self;
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub new_from_variables {
    my $incoming = shift;
    my $school = shift;
    my $evalID = shift;
    my $questionID = shift;
    my $blank = $incoming->new(_school => $school);
    my $id = $blank->get_id($evalID, $questionID);
    return $blank->new(_id => $id);
}

sub new_from_path {
    my $incoming = shift;
    my $path = shift;
    my @path = grep { /\S/ } split '/', $path;
    my $blank = $incoming->new(_school => $path[0]);
    my $id = $blank->get_id($path[1], $path[2]);
    return $blank->new(_id => $id);
}

# Description: Gets the eval_results_graphics ID
# Input: question_id
# Output: The eval_results_graphics_id
sub get_id {
    my $self = shift;
    my $eval_id = shift;
    my $question_id = shift;
    my $dbh = HSDB4::Constants::def_db_handle();
    my $school_db = $self->school_db();
    my $sth = $dbh->prepare(qq[SELECT eval_results_graphics_id 
			       FROM $school_db\.eval_results_graphics 
			       WHERE eval_id=? AND eval_question_id=?]);
    $sth->execute($eval_id, $question_id);
    my ($id) = $sth->fetchrow_array();
    return $id;
}

sub get_graphic {
    my $self = shift;
    return $self->field_value('graphic');
}

sub get_graphic_text {
	my $self = shift;
	return $self->field_value('graphic_text');
}

sub get_width {
    my $self = shift;
    return $self->field_value('width');
}

sub get_height {
    my $self = shift;
    return $self->field_value('height');
}

sub get_mime_type {
    my $self = shift;
    return $self->field_value('mime_type');
}

sub get_modified {
    # 
    # Return a DateTime object of the modified date of the binary data
    #

    my $self = shift;
    # Return a cached object if it's there
    return $self->{-modified} if $self->{-modified};
    my $t = HSDB4::DateTime->new;
    $t->in_mysql_timestamp ($self->field_value ('modified'));
    return $self->{-modified} = $t;
}

1;
