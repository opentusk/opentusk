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


package TUSK::Application::FormBuilder::ReportBuilder;

use strict;
use TUSK::FormBuilder::Entry;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { @_ };

    bless $self, $class;
    return $self;
}

sub query{
    my ($self, $sql_builder) = @_;

    my @inner_statements = ();
    my $count = 1;

    my $delimiter = '';
    if(scalar @{$sql_builder->{statements}} > 1) {$delimiter = ',';}
    foreach my $inner (@{$sql_builder->{statements}}){
	push (@inner_statements, make_inner_query($inner, 'DerivedTable' . $count++, $delimiter));
    }

    my $sql;

    if ($sql_builder->{'type'} eq 'field'){
	$sql = "select *, sum(inner_count) as count from \n(" . join ("\n union all \n", @inner_statements) . ")\n as MainTable";
	
	$sql .= ' group by ' . join(",\n", @{$sql_builder->{'groupbys'}}) if (scalar(@{$sql_builder->{'groupbys'}}));
    }else{
	$sql = "select * from \n(" .$inner_statements[0] . ") as MainTable";
    }
    
    $sql .= ' order by ' . join(",\n", @{$sql_builder->{'orderbys'}}) if (scalar(@{$sql_builder->{'orderbys'}}));

    my $obj = TUSK::FormBuilder::Entry->new(); # we just need any sqlrow object that has contentmanager as its database user
    my $sth = $obj->databaseSelect($sql);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results;
}

sub make_inner_query{
    my ($statement, $name, $delimiter) = @_;
    my $sql = "select * from (";
    
    $sql .= "select " . join(',', @{$statement->{'fields'}}) . " from " . join("$delimiter\n", @{$statement->{'tables'}}) . "\n";
    $sql .= " where " . join(' and ', @{$statement->{'wheres'}}) . "\n" if (scalar(@{$statement->{'wheres'}}));
    $sql .= ' group by ' . join(",\n", @{$statement->{'groupbys'}}) if ($statement->{groupbys} and scalar(@{$statement->{'groupbys'}}));
    $sql .= ' order by ' . join(",\n", @{$statement->{'orderbys'}}) if ($statement->{orderbys} and scalar(@{$statement->{'orderbys'}}));
    
    return $sql . ") as $name";
}

sub processAdvanced{
    my ($self, $advanced) = @_;

    if (ref($advanced) eq "ARRAY"){

    }else{
	return ("r", "");
    }
}

sub getFormID(){
    my ($self) = @_;
    return $self->{_form_id};
}

sub setUserID(){
    my ($self, $value) = @_;
    $self->{_user_id} = $value;
}

sub getUserID(){
    my ($self) = @_;
    return $self->{_user_id};
}

sub setPersonalFlag(){
    my ($self, $value) = @_;
    $self->{_personal_flag} = $value;
}

sub getPersonalFlag(){
    my ($self) = @_;
    return $self->{_personal_flag};
}


1;
