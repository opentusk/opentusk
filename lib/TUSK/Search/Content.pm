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
    my ($self, $query_ref, $user_id, $parent_query) = @_;
    $query_ref = &split_search_string($query_ref);
    my $dbh = $self->getDatabaseReadHandle();
    my @selects;
    my @select_args;
    my @wheres;
    my @where_args;

    # useful constants
    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    my $COMMASEP = q{, };
    my $LPAREN = '(';
    my $RPAREN = ')';

    # setup TUSK::Search::SearchQuery for user
    my $search_query = TUSK::Search::SearchQuery->new();
    if ($user_id) {
        $search_query->setUserID($user_id);
        if ($query_ref->{query}) {
            $search_query->setSearchQuery($query_ref->{query});
        }
        $search_query->save({user => $user_id});
        $search_query->saveQuery($query_ref, $user_id);

        # add parent query if exists
        if ($parent_query) {
            my $link = TUSK::Search::LinkSearchQuerySearchQuery->new();
            $link->setParentSearchQueryID($parent_query->getPrimaryKeyID());
            $link->setChildSearchQueryID($search_query->getPrimaryKeyID());
            $link->save({ user => $user_id });
        }
    }

    # massage search string for full text search by adding + operator
    foreach my $key (%$query_ref) {
        next if ($key eq 'media_type'
                     or $key eq 'school'
                     or $key eq 'concepts'
                     or $key eq 'limit'
                     or $key eq 'start'
                     or $key eq 'start_active_date'
                     or $key eq 'end_active_date');
        $query_ref->{$key}
            = TUSK::Search::FTSFunctions::add_plusses_to_search_string(
                $query_ref->{$key}
            );
    }

    if ($query_ref->{query} or $query_ref->{concepts}) {
        my $match = $query_ref->{query};

        # add concepts to match clause if they are in query
        if ($query_ref->{concepts}){
            # quote concept IDs
            my $concept_lookup = 'concept_id in ('
                . join($COMMASEP,
                       map { $dbh->quote($_) } @{ $query_ref->{concepts} })
                . ')';

            my $concepts = TUSK::Core::Keyword->new()->lookup($concept_lookup);
            my @concept_names;
            foreach my $concept (@$concepts){
                my $keyword = $concept->getKeyword();
                if ($keyword =~ / /){
                    push (@concept_names, qq("$keyword"));
                }else{
                    push (@concept_names, $keyword);
                }
            }
            $match = "($match) "
                . join($SPACE, @{ $query_ref->{concepts} })
                . $SPACE
                . join($SPACE, @concept_names);
        }

        push @wheres, "match(title, body, copyright, authors, keywords) "
            . "against (? in boolean mode)";
        push @where_args, $match;

        push @selects, "match(title, body, copyright, authors, keywords) "
            . "against (?)";
        push @select_args, $match;

        push @selects, "3 * match(title) against (?)";
        push @select_args, $query_ref->{query};
        push @selects, "match(keywords) against (?)";
        push @select_args, $query_ref->{query};
        if ($query_ref->{concepts}) {
            push @selects, '3 * match(keywords) against (?)';
            push @select_args, join($SPACE, @{ $query_ref->{concepts} });
        }
    }

    foreach my $key (qw(title author course copyright)) {
        if ($query_ref->{$key}) {
            # kludge for author -> authors, course -> courses
            my $col = $key;
            $col .= 's' if ($key eq 'author' || $key eq 'course');
            push @wheres, "match($col) against (? in boolean mode)";
            push @where_args, $query_ref->{$key};
            push @selects, "match($col) against (?)";
            push @select_args, $query_ref->{$key};
        }
    }

    if ($query_ref->{media_type}) {
        if (ref($query_ref->{media_type}) eq 'ARRAY') {
            push @wheres, 'type in ('
                . join($COMMASEP,
                       ('?',) x scalar(@{ $query_ref->{media_type} }))
                . ')';
            push @where_args, @{ $query_ref->{media_type} };
        }
        else {
            push @wheres, 'type = ?';
            push @where_args, $query_ref->{media_type};
        }
    }

    if ($query_ref->{school}) {
        if (ref($query_ref->{school}) eq 'ARRAY') {
            push @wheres, 'school in ('
                . join($COMMASEP,
                       ('?',) x scalar(@{ $query_ref->{school} }))
                . ')';
            push @where_args, @{ $query_ref->{school} };
        }
        else {
            push @wheres, 'school = ?';
            push @where_args, $query_ref->{school};
        }
    }

    if ($query_ref->{content_id}){
        if ($query_ref->{content_id} =~ s/[\*\%]/\%/g) {
            push @wheres, 'content_id like ?';
            push @where_args, $query_ref->{content_id};
        }
        else {
            $query_ref->{content_id} =~ s/\D//g;
            push @wheres, 'content_id = ?';
            push @where_args, $query_ref->{content_id};
        }

    }

    # Restrict content to courses active in the given date range.
    my $sqlHits = 0;
    if ($query_ref->{start_active_date}
        || $query_ref->{end_active_date}) {
        $sqlHits = 1;
        push @selects, 'LOG(COUNT(li.content_id))';
        push @wheres, 'li.log_item_type_id = 2';
        if ($query_ref->{start_active_date}
            && $query_ref->{end_active_date}) {
            push @wheres, 'li.hit_date BETWEEN ? AND ?';
            push @where_args, ($query_ref->{start_active_date},
                               $query_ref->{end_active_date});
        }
        elsif ($query_ref->{start_active_date}) {
            push @wheres, 'li.hit_date > ?';
            push @where_args, $query_ref->{start_active_date};
        }
        else {
            push @wheres, 'li.hit_date < ?';
            push @where_args, $query_ref->{end_active_date};
        }
    }
    @selects = ( 1, ) unless (scalar(@selects));

    # build SQL query string
    my $sql = 'SELECT content.content_id, (ROUND(';
    $sql .= join(' + ', @selects);
    $sql .= ") + IF(STRCMP(type, 'Collection'), 0, 0.5)) AS computed_score ";
    $sql .= "FROM tusk.full_text_search_content content ";
    if ($sqlHits) {
        $sql .= "INNER JOIN hsdb4.log_item li ";
        $sql .= "ON content.content_id = li.content_id ";
    }
    if ($parent_query) {
        $sql .= "INNER JOIN tusk.link_search_query_content search " .
            "ON content.content_id = search.child_content_id ";
    }
    $sql .= "WHERE " . join(' AND ', @wheres) if (scalar(@wheres));
    if ($parent_query) {
        $sql .= scalar(@wheres) ? " AND " : " WHERE ";
        $sql .= "search.parent_search_query_id = ?";
        push @where_args, $parent_query->getPrimaryKeyID();
    }
    $sql .= " GROUP BY li.content_id " if ($sqlHits);
    $sql .= " ORDER BY computed_score DESC" if (! $user_id);
    my @sql_args = (@select_args, @where_args);

    if ($user_id) {
        my $results = $search_query->databaseSelect($sql, @sql_args);
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
        if ($query_ref->{limit}) {
            $sql .= " LIMIT ";
            if ($query_ref->{start}) {
                $sql .= 0 + $query_ref->{start};
            }
            else {
                $sql .= "0";
            }
            $sql .= ",";
            $sql .= 0 + $query_ref->{limit};
        }
        my $results = $search_query->databaseSelect($sql, @sql_args);
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

# Really should use prepared statements for this sort of thing
sub _get_content_update_query {
  my ($lastRunTime, $currentRunTime) = @_;
  return <<"END_QUERY";
(
  select content_id
  from hsdb4.content
  where
    modified > '$lastRunTime'
    or
    start_date between '$lastRunTime' and '$currentRunTime'
)
union
(
  select c.content_id
  from
    hsdb4.content c
    inner join
    tusk.full_text_search_content f
    on f.content_id = c.content_id
  where end_date < '$currentRunTime'
)
union
(
  select c.content_id
  from
    hsdb4.content c
    inner join
    tusk.full_text_search_content f
    on f.content_id = c.content_id
  where start_date > '$currentRunTime'
)
END_QUERY
}

sub get_content_that_needs_indexing {
    my $self = shift;
    my $lastRunTime = shift;
    my $currentRunTime = shift;
    # Give me all the content that
    #       (has modified since I last ran) OR
    #       (Has started since I last ran) OR
    #       (Has ended since I last ran)
    my $query = _get_content_update_query($lastRunTime, $currentRunTime);
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

