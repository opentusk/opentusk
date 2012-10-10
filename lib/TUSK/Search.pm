package TUSK::Search;

use strict;
use HSDB4::Constants;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { _results =>[],
		 _title=>shift,
		 _table=>shift,
		 _conditions=>shift,
		 _keys=>shift,
		 _display=>shift
		 };

    bless $self, $class;
    
    return $self;  
}

sub select{
    my $self = shift;
    my $bind_params = shift;
    my $sql = shift;

    $self->{_results}=[]; # empty the results

    $bind_params=~s/\t/,/g; # needed cause of embperl
    my $dbh = HSDB4::Constants::def_db_handle;
    $sql = $self->generate_sql unless ($sql);
    my $sth = $dbh->prepare($sql);

    eval { $sth->execute($bind_params) };
    if ($@){ return wantarray ? (0,$@) : 0; }
    $self->{_results} = $sth->fetchall_arrayref;
    $sth->finish;	  
}

# generate the magical select statement
sub generate_sql{
    my $self = shift;
    my $table = $self->{_table};
    my $select = $self->select_part;
    my $cond = $self->cond_part;
    return "select $select from $table where $cond";
}

sub display_names{
    my $self = shift;
    return (values %{$self->{_display}});
}

sub results{
    my $self = shift;
    return @{$self->{_results}};
}

sub result_count{
    my $self = shift;
    return scalar @{$self->{_results}};
}

sub title{
    my $self = shift;
    return $self->{_title};
}

# get back the conditional part of the sql statement
sub cond_part{
    my $self = shift;
    return join(' and ', map {"$_ ".$self->{_conditions}->{$_} ." ? " } keys %{$self->{_conditions}});
}

# get back the select part of the sql statement
sub select_part{
    my $self = shift;
    return join(',',(keys %{$self->{_display}}));
}

1;
