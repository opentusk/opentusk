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


package TUSK::Search::Content;

=head1 NAME

B<TUSK::Search::Content> - Class for manipulating entries in table full_text_search_content in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use TUSK::Search::SearchQuery;
use TUSK::Search::FTSFunctions;
use HSDB4::Constants;
use Data::Dumper;
# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'full_text_search_content',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'full_text_search_content_id' => 'pk',
					'content_id' => '',
					'title' => '',
					'copyright' => '',
					'authors' => '',
					'courses' => '',
					'keywords' => '',
					'school' => '',
					'type'  => '',
					'body' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getContentID>

my $string = $obj->getContentID();

Get the value of the content_id field

=cut

sub getContentID{
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}

#######################################################

=item B<setContentID>

$obj->setContentID($value);

Set the value of the content_id field

=cut

sub setContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_id', $value);
}

#######################################################

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getCopyright>

my $string = $obj->getCopyright();

Get the value of the copyright field

=cut

sub getCopyright{
    my ($self) = @_;
    return $self->getFieldValue('copyright');
}

#######################################################

=item B<setCopyright>

$obj->setCopyright($value);

Set the value of the copyright field

=cut

sub setCopyright{
    my ($self, $value) = @_;
    $self->setFieldValue('copyright', $value);
}


#######################################################

=item B<getAuthors>

my $string = $obj->getAuthors();

Get the value of the authors field

=cut

sub getAuthors{
    my ($self) = @_;
    return $self->getFieldValue('authors');
}

#######################################################

=item B<setAuthors>

$obj->setAuthors($value);

Set the value of the authors field

=cut

sub setAuthors{
    my ($self, $value) = @_;
    $self->setFieldValue('authors', $value);
}


#######################################################

=item B<getCourses>

my $string = $obj->getCourses();

Get the value of the courses field

=cut

sub getCourses{
    my ($self) = @_;
    return $self->getFieldValue('courses');
}

#######################################################

=item B<setCourses>

$obj->setCourses($value);

Set the value of the courses field

=cut

sub setCourses{
    my ($self, $value) = @_;
    $self->setFieldValue('courses', $value);
}


#######################################################

=item B<getKeywords>

my $string = $obj->getKeywords();

Get the value of the keywords field

=cut

sub getKeywords{
    my ($self) = @_;
    return $self->getFieldValue('keywords');
}

#######################################################

=item B<setKeywords>

$obj->setKeywords($value);

Set the value of the keywords field

=cut

sub setKeywords{
    my ($self, $value) = @_;
    $self->setFieldValue('keywords', $value);
}


#######################################################

=item B<getSchool>

my $string = $obj->getSchool();

Get the value of the school field

=cut

sub getSchool{
    my ($self) = @_;
    return $self->getFieldValue('school');
}

#######################################################

=item B<setSchool>

$obj->setSchool($value);

Set the value of the school field

=cut

sub setSchool{
    my ($self, $value) = @_;
    $self->setFieldValue('school', $value);
}

#######################################################

=item B<getType>

my $string = $obj->getType();

Get the value of the type field

=cut

sub getType{
    my ($self) = @_;
    return $self->getFieldValue('type');
}

#######################################################

=item B<setType>

$obj->setType($value);

Set the value of the type field

=cut

sub setType{
    my ($self, $value) = @_;
    $self->setFieldValue('type', $value);
}


#######################################################

=item B<getBody>

my $string = $obj->getBody();

Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

$obj->setBody($value);

Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<search>

$obj->search($query_hashref, $user_id, $parent_query);

Method that searches full_text_search_content based on the query hashref that is passed in.
=cut

sub search {
    my ($self, $query_hashref, $user_id, $parent_query) = @_;
    my $search_query = TUSK::Search::SearchQuery->new();
    $query_hashref = &split_search_string($query_hashref);
    my $dbh = $self->getDatabaseReadHandle();

    my $wheres = [];
    my $selects = [];

    if ($user_id) {
        $search_query->setUserID($user_id);
        $search_query->setSearchQuery($query_hashref->{query}) if ($query_hashref->{query});
        $search_query->save({user => $user_id});

        $search_query->saveQuery($query_hashref, $user_id);

        if ($parent_query) {
            my $link = TUSK::Search::LinkSearchQuerySearchQuery->new();
            $link->setParentSearchQueryID($parent_query->getPrimaryKeyID());
            $link->setChildSearchQueryID($search_query->getPrimaryKeyID());
            $link->save({ user => $user_id });
        }
    }

    foreach my $key (%$query_hashref) {
        $query_hashref->{$key} =~ s/\'/\\\'/g;
        next if ($key eq 'media_type' or $key eq 'school' or $key eq 'concepts' or $key eq 'limit' or $key eq 'start' or $key eq 'start_active_date' or $key eq 'end_active_date');
        $query_hashref->{$key} = &TUSK::Search::FTSFunctions::add_plusses_to_search_string($query_hashref->{$key});
    }

    if ($query_hashref->{query} or $query_hashref->{concepts}){

        my @where_pieces = ();

        my $match = $query_hashref->{query};

        if ($query_hashref->{concepts}){
            my $concepts = TUSK::Core::Keyword->new()->lookup("concept_id in (" . join(', ', map { "'" . $_ . "'" } @{$query_hashref->{concepts}}) . ")");

            my $concept_names = [];

            foreach my $concept (@$concepts){
                my $keyword = $concept->getKeyword();
                if ($keyword =~ / /){
                    push (@$concept_names, '"' . $keyword . '"');
                }else{
                    push (@$concept_names, $keyword);
                }
            }

            $match = '(' . $match . ') ' . join(' ', @{$query_hashref->{concepts}}) . ' ' . join(' ', @$concept_names);
        }

        push (@$wheres, "match(title, body, copyright, authors, keywords) against ('" . $match . "' in boolean mode)");

        push (@$selects, "match(title, body, copyright, authors, keywords) against ('". $match .  "')");
        push (@$selects, "3 * match(title) against ('". $query_hashref->{query} . "')");
        push (@$selects, "match(keywords) against ('". $query_hashref->{query} . "')");
        push (@$selects, "3 * match(keywords) against ('". join(' ' , @{$query_hashref->{concepts}}) . "')") if ($query_hashref->{concepts});

    }

    if ($query_hashref->{title}){
        push (@$wheres, "match(title) against ('". $query_hashref->{title} . "' in boolean mode)");
        push (@$selects, "match(title) against ('". $query_hashref->{title} . "')");
    }

    if ($query_hashref->{author}){
        push (@$wheres, "match(authors) against ('". $query_hashref->{author} . "' in boolean mode)");
        push (@$selects, "match(authors) against ('". $query_hashref->{author} . "')");
    }

    if ($query_hashref->{course}){
        push (@$wheres, "match(courses) against ('". $query_hashref->{course} . "' in boolean mode)");
        push (@$selects, "match(courses) against ('". $query_hashref->{course} . "')");
    }

    if ($query_hashref->{copyright}){
        push (@$wheres, "match(copyright) against ('". $query_hashref->{copyright} . "' in boolean mode)");
        push (@$selects, "match(copyright) against ('". $query_hashref->{copyright} . "')");
    }

    if ($query_hashref->{media_type}){
        if (ref($query_hashref->{media_type}) eq 'ARRAY'){
            push (@$wheres, "type IN (" . join(', ', map { "'" . $_ . "'" } @{$query_hashref->{media_type}}) . ")");
        }
        else{
            push (@$wheres, "type = '" . $query_hashref->{media_type} . "'");
        }
    }

    if ($query_hashref->{school}){
        if (ref($query_hashref->{school}) eq 'ARRAY'){
    	    push (@$wheres, "school IN (" . join(', ', map { "'" . $_ . "'" } @{$query_hashref->{school}}) . ")");
        }
        else{
            push (@$wheres, "school = '" . $query_hashref->{school} . "'");
        }
    }

    if ($query_hashref->{content_id}){
        if ($query_hashref->{content_id} =~ s/[\*\%]/\%/g){
            push (@$wheres, "content_id like '" . $query_hashref->{content_id} . "'");
        }
        else{
            $query_hashref->{content_id} =~ s/\D//g;
            push (@$wheres, "content_id = " . $query_hashref->{content_id});
        }

    }

    # Restrict content to courses active in the given date range.
    my $sqlHits;
    if ($query_hashref->{start_active_date}
        || $query_hashref->{end_active_date}) {
        # Build up content by schools.
        my @schools;
        if ($query_hashref->{school}) {
            if (ref($query_hashref->{school}) eq 'ARRAY') {
                my $school_ref = $query_hashref->{school};
                @schools = @$school_ref;
            }
            else {
                @schools = ($query_hashref->{school});
            }
        }
        else {
            @schools = HSDB4::Constants::schools();
        }
        my @schooldbs = map { HSDB4::Constants::get_school_db($_) } @schools;
        my @tpactives;
        my @hitactives;
        if ($query_hashref->{start_active_date}) {
            push(@tpactives,
                 "tp.end_date > DATE(" .
                 $dbh->quote($query_hashref->{start_active_date}) . ")");
            push(@hitactives,
                 "li.hit_date > DATE(" .
                 $dbh->quote($query_hashref->{start_active_date}) . ")");
        }
        if ($query_hashref->{end_active_date}) {
            push(@tpactives,
                 "tp.start_date < DATE(" .
                 $dbh->quote($query_hashref->{end_active_date}) . ")");
            push(@hitactives,
                 "li.hit_date < DATE(" .
                 $dbh->quote($query_hashref->{end_active_date}) . ")");
        }
        if ($query_hashref->{start_active_date} && $query_hashref->{end_active_date}) {
            @hitactives = ("li.hit_date BETWEEN DATE(" .
                           $dbh->quote($query_hashref->{start_active_date}) .
                           ") AND DATE(" .
                           $dbh->quote($query_hashref->{end_active_date}) .
                           ")");
        }
        my $sqlTimeConstraint = join(" AND ", @tpactives);
        my $sqlHitConstraint = join(" AND ", @hitactives);
        my @sqlUserQueries = map { qq{SELECT lugu.child_user_id as user_id
                FROM $_.link_user_group_user lugu
                INNER JOIN $_.link_course_user_group lcug
                ON lugu.parent_user_group_id = lcug.child_user_group_id
                INNER JOIN $_.time_period tp
                ON lcug.time_period_id = tp.time_period_id
                WHERE $sqlTimeConstraint
                GROUP BY lugu.child_user_id} } @schooldbs;
        $sqlHits = qq{SELECT li.content_id, COUNT(li.content_id) AS numhits
            FROM hsdb4.log_item li
            INNER JOIN (} .
            join(" UNION ", @sqlUserQueries) .
            qq{) user
            ON li.user_id = user.user_id
            WHERE $sqlHitConstraint
            GROUP BY li.content_id};
        push(@$selects, "LOG(hits.numhits)");
    }
    $selects = [ 1 ] unless (scalar(@$selects));

    my $sql = "SELECT content.content_id, (ROUND(" .
        join(' + ', @$selects) .
        ") + IF(STRCMP(type, 'Collection'), 0, 0.5)) AS computed_score FROM tusk.full_text_search_content content ";
    $sql .= "INNER JOIN ($sqlHits) hits ON content.content_id = hits.content_id " if ($sqlHits);
    $sql .= "INNER JOIN tusk.link_search_query_content search " .
        "ON content.content_id = search.child_content_id " if ($parent_query);
    $sql .= "WHERE " . join(' AND ', @$wheres) if (scalar(@$wheres));
    $sql .= (scalar(@$wheres) ? " AND " : " WHERE ") .
        "search.parent_search_query_id = " .
        $dbh->quote($parent_query->getPrimaryKeyID()) if ($parent_query);
    $sql .= " ORDER BY computed_score DESC" unless ($user_id);

    if ($user_id) {
        my $results = $search_query->databaseSelect($sql);
        # Save search results to tusk.link_search_query_content
        my $delete_save_sql = qq{DELETE FROM tusk.link_search_query_content
        WHERE parent_search_query_id = } . $search_query->getPrimaryKeyID();
        $search_query->databaseDo($delete_save_sql);
        my $results_ref = $results->fetchall_arrayref();
        # create list of (search_query_id, content_id, computed_score)
        my @insert_save_list = map {
            "(" .
                join(", ", $search_query->getPrimaryKeyID(), $_->[0], $_->[1]) .
                ")"
        } @$results_ref;
        # insert list into table
        my $insert_save_query = qq{INSERT INTO tusk.link_search_query_content
        (parent_search_query_id, child_content_id, computed_score)
        VALUES } . join(", ", @insert_save_list);
        $search_query->databaseDo($insert_save_query) if (scalar(@insert_save_list));
        return $search_query;
    }
    else {
    	if ($query_hashref->{limit}) {
			$sql .= " LIMIT ";
			if ($query_hashref->{start}) {
				$sql .= $query_hashref->{start}
			}
			else {
				$sql .= "0";
			}
			$sql .= ",";
			$sql .= $query_hashref->{limit};
    	}
		my $results = $search_query->databaseSelect($sql);
		my $array_ref = $results->fetchall_arrayref();
		my @ids = map { $_->[0] } @$array_ref;
		return \@ids;
    }
}

sub split_search_string{
    my ($query) = @_;

    while ($query->{'query'} =~ s/(\w+)\s*=\s*\[([^\]]+)\]//){
	my ($field, $string) = ($1, $2);
	if ($field eq 'media_type' or $field eq 'school'){
	    unless (ref($query->{$field})){
		if ($query->{$field}){
		    $query->{$field} = [ $query->{$field} ];
		}else{
		    $query->{$field} = [];
		}
		push (@{$query->{$field}}, split(/,\s*/, $string));
	    }
	}else{
	    if ($query->{$field}){
		$query->{$field} .= ' ' . $string;
	    }else{
		$query->{$field} = $string;
	    }
	}
    }
   
    # clean extra spaces
    $query->{'query'} =~ s/\s+/ /g;
    $query->{'query'} =~ s/\s*$//;
    $query->{'query'} =~ s/^\s*//;
    
    return $query;

}

sub show_full_search_string{
    my ($query) = @_;

    my $string = $query->{'query'};
    my $fields = ['title', 'author', 'course', 'content_id', 'copyright', 'media_type', 'school', 'start_active_date', 'end_active_date'];

    foreach my $field (@$fields){
	if (exists($query->{$field})){
	    if (ref($query->{$field}) eq 'ARRAY'){
		$string .= ' ' . $field . '=[' . join(',', @{$query->{$field}}) . ']';
	    }else{
		$string .= ' ' . $field . '=[' . $query->{$field} . ']';
	    }
	}
    }

    $string =~ s/^\s+//g;

    return $string;
}

sub get_content_that_needs_indexing {
	my $self = shift;
	my $lastRunTime = shift;
	my $currentRunTime = shift;
	# Give me all the content that
	#       (has modified since I last ran) OR
	#       (Has started since I last ran) OR
	#       (Has ended since I last ran)
	my $query = "
                    (
                      select content_id
                      from hsdb4.content
                      where modified > '$lastRunTime'
                     )
                     union
                     (
                       select c.content_id
                       from hsdb4.content c inner join tusk.full_text_search_content f on (f.content_id = c.content_id)
                       where end_date < '$currentRunTime'
                     )
                    union
                    (
                      select c.content_id
                      from hsdb4.content c inner join tusk.full_text_search_content f on (f.content_id = c.content_id)
                      where start_date > '$currentRunTime'
                    )
";
	my $search_query = TUSK::Search::SearchQuery->new();;
        my $results = $search_query->databaseSelect($query);
        my $array_ref = $results->fetchall_arrayref();
        my @content_ids = map { $_->[0] } @$array_ref; 
        return @content_ids;
}


=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

