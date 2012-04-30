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


package HSDB45::Eval::Completion::Formatter;

use strict;
use base qw(XML::Formatter);
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Eval;
use HSDB4::Constants;


sub version {
    return $VERSION;
}

my @mod_deps  = ('HSDB45::Eval',
		 'HSDB45::Eval::Results');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


BEGIN {
    require XML::Twig;
    require HSDB45::Eval;
    require HSDB4::Constants;
}

# Check size of this process; only works on Solaris
sub mem_size { return -s "/proc/$$/as"; }

# Description: Generic constructor
# Input: An HSDB45::Eval::Results object
# Output: Blessed, initialized HSDB45::Eval::Results::Formatter object
sub new {
    my $incoming = shift;
    my $class = ref $incoming || $incoming;
    my $object = shift();
    my $self = $class->SUPER::new($object);
    return $self;
}

sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    $path =~ s/^\///;
    my ($school, $id) = split(/\//, $path);
    my $object = class_expected()->new(HSDB45::Eval->new(_school => $school, _id => $id));
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = '';
    $self->{-dtd_decl} = '';
    $self->{-stylesheet_decl} = '';
    return $self;
}

sub class_expected {
    return 'HSDB45::Eval::Results';
}

sub object_id {
    my $self = shift();
    return $self->object()->parent_eval()->primary_key();
}

sub modified_since {
    my $self = shift;
    my $timestamp = shift;

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($self->object()->parent_eval()->school());
    my $sth = $dbh->prepare("SELECT COUNT(*) from $db.eval_completion WHERE eval_id=? AND created>?");
    $sth->execute($self->object_id(), $timestamp->out_mysql_timestamp());
    my ($count) = $sth->fetchrow_array();
    return $count ? 1 : 0;
}

sub get_xml_elt {
    my $self = shift();

    unless($self->{-xml_elt}) {
	my $eval = $self->object()->parent_eval();
	my $num_users = $eval->num_users();
	my $num_comps = $self->object()->total_user_codes() || 0;
	my $num_incomps = $num_users - $num_comps;

	$self->{-xml_elt} = XML::Twig::Elt->new("Enrollment", {"count" => $num_users});

	my $percent = 0;
	if ($num_users){
		$percent =  sprintf("%.2f", 100 * $num_comps / $num_users);
	}
	my $complete_users_elt = XML::Twig::Elt->new("CompleteUsers",
						     {"count"   => $num_comps,
						      "percent" => $percent });
	foreach my $complete_user ($eval->complete_users()) {
	    my $complete_user_elt = XML::Twig::Elt->new("user-ref",
							{"user-id" => $complete_user->primary_key()},
							make_pcdata($complete_user->out_full_name()));
	    $complete_user_elt->set_asis();
	    $complete_user_elt->paste('last_child', $complete_users_elt);
	}
	$complete_users_elt->paste('last_child', $self->{-xml_elt});

	$percent = 0; 
	if ($num_users){
		$percent = sprintf("%.2f", 100 * $num_incomps / $num_users);
	} 

	my $incomplete_users_elt = XML::Twig::Elt->new("IncompleteUsers",
						       {"count"   => $num_incomps,
							"percent" => $percent });
	foreach my $incomplete_user ($eval->incomplete_users()) {
	    my $incomplete_user_elt = XML::Twig::Elt->new("user-ref",
							  {"user-id" => $incomplete_user->primary_key()},
							  make_pcdata($incomplete_user->out_full_name()));
	    $incomplete_user_elt->set_asis();
	    $incomplete_user_elt->paste('last_child', $incomplete_users_elt);
	}
	$incomplete_users_elt->paste('last_child', $self->{-xml_elt});

	my $deficit =  $num_users - $self->object()->total_completions();
	if($deficit > 0) {
	    my $completion_token_deficit_elt = XML::Twig::Elt->new("CompletionTokenDeficit", {}, $deficit);
	    $completion_token_deficit_elt->paste('last_child', $self->{-xml_elt});
	}

	my $excess =  $num_comps - $num_users;
	if($excess > 0) {
	    my $excess_completions_elt = XML::Twig::Elt->new("ExcessCompletions", {}, $excess);
	    $excess_completions_elt->paste('last_child', $self->{-xml_elt});
	}
    }

    return $self->{-xml_elt};
}

1;
__END__
