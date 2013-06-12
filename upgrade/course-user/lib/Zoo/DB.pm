# Copyright 2013 Albert Einstein College of Medicine of Yeshiva University 
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

package Zoo::DB;

# EXPERIMENTAL

use strict;
use warnings;
use DBI;
use Zoo::Stash;

###
### CLASS METHODS
###

sub now_str
{
	return sprintf "%04d-%02d-%02d %02d:%02d:%02d", $_->[5]+1900, $_->[4]+1, @$_[3,2,1,0] for [localtime];
}

###
### CONSTRUCTORS
###

sub new # (%options)
{
	my ($this, %opt) = @_;
	$this = bless {
		opt => {
			driver => 'mysql',
			host => '127.0.0.1',
			port => 3306,
			uid  => undef,
			pwd  => undef,
			%opt,
			attr => {
				AutoCommit => 1,
				FetchHashKeyName => 'NAME_lc',
				PrintWarn  => 0,
				PrintError => 0,
				RaiseError => 0,
				ShowErrorStatement => 1,
				%{$opt{attr} || {}},
			},
		},
		error => '',
		stash => Zoo::Stash->new,
	}, ref $this || $this;
	{
		no warnings 'uninitialized';
		$this->_dbh = DBI->connect("dbi:$_->{driver}:host=$_->{host};port=$_->{port}", @{$_}{qw(uid pwd attr)}) for $this->_opt;
	}
	$this->_dbh or $this->_error = $DBI::errstr;
	return $this;
}

###
### ACCESSORS
###

BEGIN {
	# READ-ONLY accessors
	for my $x (qw(opt error stash dbh sth last_insert_id rows_affected))
	{ no strict 'refs'; *{$x} = sub { $_[0]->{$x} } }

#	# READ-WRITE accessors
#	for my $x (qw())
#	{ no strict 'refs'; *{$x} = sub { @_ > 1 and $_[0]->{$x} = $_[1]; $_[0]->{$x} } }

#	# READ-WRITE-CHAIN accessors
#	for my $x (qw())
#	{ no strict 'refs'; *{$x} = sub { if (@_ == 1) { $_[0]->{$x} } else { $_[0]->{$x} = $_[1]; $_[0] } } }

#	# LVALUE-CAHIN accessors
#	for my $x (qw())
#	{ no strict 'refs'; *{$x} = sub:lvalue { if (@_ == 1) { $_[0]->{$x} } else { $_[0]->{$x} = $_[1]; $_[0] } } }

	# private LVALUE-CAHIN accessors for public properties
	for my $x (qw(opt error dbh sth last_insert_id rows_affected))
	{ no strict 'refs'; *{"_$x"} = sub:lvalue { if (@_ == 1) { $_[0]->{$x} } else { $_[0]->{$x} = $_[1]; $_[0] } } }

	# private LVALUE-CAHIN accessors for private properties
	for my $x (qw(sql rv field_index_map result_array result_hash))
	{ no strict 'refs'; *{"_$x"} = sub:lvalue { if (@_ == 1) { $_[0]->{chr(1)}{$x} } else { $_[0]->{chr(1)}{$x} = $_[1]; $_[0] } } }
}

###
### DBH
###

sub table_info # ($schema, $table, $type, \%attr)
{
	my $this = shift;
	$this->_field_index_map = undef;
	$this->_sth = $this->_dbh->table_info(undef, @_); # ($catalog, $schema, $table, $type, \%attr)
	{
		$this->_error = $this->_dbh->errstr and last;
		$this->_field_index_map = { %{$this->_sth->{NAME_lc_hash}} };
	}
	return $this;
}

sub column_info # ($schema, $table)  
{
	my $this = shift; 
	$this->_field_index_map = undef;
	$this->_sth = $this->_dbh->column_info(undef, @_[0,1], '%'); # ($catalog, $schema, $table, $column) 
	{
		$this->_error = $this->_dbh->errstr and last;
		$this->_field_index_map = { %{$this->_sth->{NAME_lc_hash}} };
	}
	return $this;
}

sub do # ($sql, \%attr, @bind_values)
{
	my $this = shift;
	$this->_sql = $_[0];
	$this->_rows_affected = $this->_dbh->do(@_); 
	$this->_error = $this->_dbh->errstr;
	return $this;
}

###
### SELECT
###

sub select # ($sql, \@param) # FIXME: allow SQL pieces and build full statement
{
	my ($this, $sql, $param) = @_;
	$param ||= [];
	$this->_sql = $sql;
	$this->_field_index_map = undef;
	{
		$this->_sth = $this->_dbh->prepare($sql);
		$this->_error = $this->_dbh->errstr and last;
		$this->_sth->execute(@$param);
		$this->_error = $this->_sth->errstr and last;
		$this->_field_index_map = { %{$this->_sth->{NAME_lc_hash}} };
	}
	return $this;
}

###
### INSERT
###

sub insert_array # ($table, \@field_name, \@field_value) # FIXME: allow multiple value arrays
{
	my ($this, $table, $field, $value) = @_;
	$this->_sql = "INSERT $table (" . join(',', map "`$_`", @$field) . ') VALUES (' . join(',', map { '?' } @$field) . ')';
	$this->_last_insert_id = undef;
	{
		$this->_rows_affected = $this->_dbh->do($this->_sql, {}, @$value);
		$this->_error = $this->_dbh->errstr and last;
		$this->_rows_affected and $this->_last_insert_id = $this->_dbh->last_insert_id(undef, undef, undef, $table, undef);
	}
	return $this;
}

sub insert_hash # ($table_name, \%field_name_value) # FIXME: allow multiple hashes
{
	$_[0]->insert($_[1], [keys %{$_[2]}], [values %{$_[2]}]);
}

BEGIN { *insert = \&insert_array }

###
### VALID AFTER SUCCESSFUL QUERY THAT SETS RELEVANT PROPERTIES
###

sub field_index # (@field_name)
{
	my $this = shift;
	return @{$this->_field_index_map}{map lc, @_} if wantarray;
	return ${$this->_field_index_map}{lc shift};
}

# note that resultset retrieval methods eats records

sub result_arrayref { return shift->_sth->fetchall_arrayref(@_) } # array of arrays
sub result_hashref  { return shift->_sth->fetchall_hashref(@_)  } # hash of hashes

BEGIN { *result_array_of_arrays = \&result_arrayref }
BEGIN { *result_hash_of_hashes  = \&result_hashref  }

sub result_array_of_hashes # maintains the retrival order
{
	my $this = shift;
	my $index = $this->_sth->{NAME_lc};
	my $last = $#$index;
	my $result = [];
	for my $r (@{$this->_sth->fetchall_arrayref(@_)})
	{
		push @$result, { map { ($index->[$_] => $r->[$_]) } 0..$last };
	}
	return $result;
}

###
### NOT FOR PRODUCTION
###

sub dump_resultset
{
	my $this = shift;
	$this->_sth->dump_results(@_); # max_len, line_sep, field_sep, fh
	return $this;
}

sub show_result_vertical # ([\@field_name, \@@result])
{
	my $this = shift;
	my ($name, $result) = @_ ? @_ : ($this->_sth->{NAME_lc}, $this->_sth->fetchall_arrayref);
	my $width = (sort { $a <=>$b } map { length } @$name)[-1];
	my @format = ("%${width}s = NULL\n", "%${width}s = [%s]\n");
	my $count = 0;
	for my $r (@$result) {
		print "\n" if $count;
		printf "### Record %04d\n", ++$count;
		for my $i (0..$#$r) {
			no warnings 'uninitialized';
			my $v = $r->[$i];
			printf $format[defined $v ? 1 : 0], $name->[$i], $v;
		}
	}
	return $this;
}

1;
