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


package TUSK::ImportRecord;

sub new {
    my ($class, @fields) = @_;

    die "Cannot create a TUSK::ImportRecord without fields" unless (scalar(@fields));

    my %fields_hash = map { $_ => undef } @fields;

    $class = ref $class || $class;
    my $self = { _fields_order => \@fields, _fields => \%fields_hash, };
    return bless $self, $class;
}

sub set_field_values {
    my $self = shift;
    my @field_values = @_;
    my @field_names = $self->get_fields_order();

    # unless (scalar @field_values == scalar @field_names){
	#return (0, "Incorrect number of fields (got ".scalar @field_values.", expecting ".scalar @field_names.")");
    #}
    
    $i = 0;
    foreach (@field_values) {
	$self->{_fields}{$field_names[$i]} = $field_values[$i];
	$i++;
    }
    return (1);
}

sub get_field_values{
    my ($self) = @_;

    return $self->{_fields};
}

sub get_field_value {
    my $self = shift;
    my $name = shift;
    unless (exists($self->{_fields}{$name})) { die "Cannot find field $name in TUSK::Import fields"};
    return $self->{_fields}{$name};
}

sub get_field_count {
    my $self = shift;
    return scalar keys %{$self->{_fields}}
}

sub set_field_value {
    my $self = shift;
    my $name = shift;
    my $value = shift;
    unless (exists($self->{_fields}{$name})) { die "Cannot find field $name in TUSK::Import fields"};
    $self->{_fields}{$name} = $value;
}

sub get_fields_order{
    my ($self) = @_;
    return @{$self->{_fields_order}};
}

sub clone {
    my $self = shift;
    my $record = TUSK::ImportRecord->new($self->get_fields_order());

    foreach my $field ($self->get_fields_order()){
	$record->set_field_value($field, $self->get_field_value($field));
    }

    return $record;
}

1;
