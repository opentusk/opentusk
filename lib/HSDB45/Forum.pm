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



package HSDB45::Forum;

use strict;
use HSDB4::Constants;

BEGIN {
	use base qw/HSDB4::SQLRow/;
	require HSDB4::SQLLink;

	use vars qw($VERSION);

	$VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use HSDB4::Constants qw(:school);

use vars ();

my $tablename = "forum.boards";
my $primary_key_field = 'id';
my @fields = qw(id title categoryId pos expiration locking markup
	approve score private anonymous announce flat shortDesc longDesc
	postNum lastPostTime);
my %blob_fields = ();
my %numeric_fields = (
	id => 1,
	categoryId => 1,
	pos => 1,
	expiration => 1,
	locking => 1,
	markup => 1,
	approve => 1,
	score => 1,
	private => 1,
	anonymous => 1,
	announce => 1,
	flat => 1,
	postNum => 1,
	lastPostTime => 1,
);
my %cache = ();

sub new {
	my $incoming = shift;
	my $self = $incoming->SUPER::new ( _table => $tablename,
		_fields => \@fields,
		_blob_fields => \%blob_fields,
		_numeric_fields => \%numeric_fields,
		_primary_key_field => $primary_key_field,
		_cache => \%cache,
		@_);
	return $self;
}

sub split_by_school { return 0; }

sub table {
	return 'forum.boards';
}

sub lookup_by_school {
	my ($s, $school) = @_;

	return $s->lookup_conditions (sprintf ('forum.boards.categoryId = %d',
		$HSDB4::Constants::Forum_School_Category{$school}));
}

# A user can edit a forum if they are marked as an admin for the forum, if
# the forum is in a course that user can edit, or if the forum is in a user
# group the user can edit, including courses and user groups in schools the
# user is an admin for.
sub can_user_edit{
	my ($s, $user) = @_;

	return 1;
}

1;

