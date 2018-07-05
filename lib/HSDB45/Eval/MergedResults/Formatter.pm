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


package HSDB45::Eval::MergedResults::Formatter;

use strict;
use base qw(HSDB45::Eval::Results::Formatter);
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Results::Formatter',
		 'HSDB45::Eval::Results',
		 'HSDB45::Eval::Question::ResponseStatistics',
		 'HSDB45::Eval::MergedResults::BarGraphCreator',
		 'HSDB45::Eval::MergedResults',
		 'HSDB45::Eval::Question::MergedResults');

my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

BEGIN {
    require XML::Twig;
    require XML::Writer;
    require HSDB4::Constants;
    require HSDB45::Eval::Results;
    require HSDB45::Eval::Question::ResponseStatistics;
    require HSDB45::Eval::MergedResults::BarGraphCreator;
    require HSDB45::Eval::MergedResults;
    require HSDB45::Eval::Question::MergedResults;
    require TUSK::Constants;
}

# Check size of this process; only works on Solaris
sub mem_size { return -s "/proc/$$/as"; }

# Description: Generic constructor
# Input: An Eval::MergedResults object
# Output: Blessed, initialized HSDB45::Eval::Results::Formatter object
sub new {
    my $incoming = shift();
    my $object = shift();
    my $self = $incoming->SUPER::new($object);
    return $self->_init(@_);
}

sub object_id {
    my $self = shift();
    return $self->object()->primary_key();
}

sub new_from_path {
    my $incoming = shift();
    my $path = shift();

    $path =~ s/^\///;
    my ($school, $ids) = split(/\//, $path);
    my @ids = split(/\//, $ids);
    my $object = undef;

    if(scalar(@ids) > 1) {
	$object = class_expected()->new(_school => $school, @ids);
    }
    elsif(scalar(@ids) == 1) {
	my ($id) = /merged_id=(.*)/;
	$object = class_expected()->new(_school => $school, _id => $ids[0]);
    }
    else {
	die "Ack! Invalid URL format!";
    }


    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = 'Eval_Results';
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'/DTD/Eval_Results.dtd';
    $self->{-stylesheet_decl} = 'http://'. $TUSK::Constants::Domain .'/XSL/Eval/eval_results.xsl';
    return $self;
}

sub class_expected {
    return 'HSDB45::Eval::MergedResults';
}

sub modified_since {
    my $self = shift;
    my $timestamp = shift;

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($self->object()->parent_eval()->school());
    my $sth = $dbh->prepare("SELECT COUNT(*) from $db.eval_completion " .
			    "WHERE eval_id IN (" .
			    join("," =>
				 $self->object->primary_eval_id(),
				 $self->object()->secondary_eval_ids()) .
			    ") AND created>?");
    $sth->execute($timestamp->out_mysql_timestamp());
    my ($count) = $sth->fetchrow_array();

    $sth = $dbh->prepare("SELECT modified FROM $db.merged_eval_results " .
			 "WHERE merged_eval_results_id=?");
    $sth->execute($self->object()->primary_key());
    my ($modified) = $sth->fetchrow_array();
    $modified = HSDB4::DateTime->new()->in_mysql_timestamp($modified)->out_unix_time();

    return ($count || ($modified > $timestamp->out_unix_time())) ? 1 : 0;
}

sub do_bar_graphs {
    my $self = shift;
    my $merged = $self->object();
    my $bar_graph_creator = HSDB45::Eval::MergedResults::BarGraphCreator->new($merged->school(), $merged->primary_key(), $self->eval_results_elt()->sprint());
    $bar_graph_creator->save_svg_graphs();
}


1;
__END__
