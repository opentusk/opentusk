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


package TUSK::Application::FormBuilder::Export;

######################################################
# kludgy but we make an export object as a type of report 
# so it could inherit some behaviors
######################################################
use strict;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use HSDB4::SQLRow::User;
use TUSK::FormBuilder::EntryAssociation;


sub new {
    my ($class, $form_id, $course, $tp_params) = @_;
	die "Missing form_id, and/or course\n" unless ($form_id && $course);
    $class = ref $class || $class;

    return $class->SUPER::new( _course => $course, 
							   _form_id => $form_id, 
							   _tp_params => $tp_params,
							   );
}


sub getEntries {
	my ($self, $field_ids, $is_evaluated) = @_;
	return unless $field_ids;

	my $sql = qq(
				 select e.entry_id, e.user_id, e.created_on, complete_date, 
				 time_to_sec(timediff(e.complete_date, e.created_on)), date, a.user_id, 
				 e.time_period_id
				 from tusk.form_builder_entry as e
				 inner join tusk.form_builder_form as f on (e.form_id = f.form_id)
				 left outer join tusk.form_builder_entry_association as a on (e.entry_id = a.entry_id)
				 where e.form_id = $self->{_form_id} 
				 and time_period_id in ($self->{_time_period_ids_string})
	);

	my $sth = $self->{_form}->databaseSelect($sql);
	my (%data, %student_entries);  

	while (my($entry_id, $completor_id, $start_date, $complete_date, $entry_duration, $entry_date, $evaluatee_id, $time_period_id) = $sth->fetchrow_array()) {
		$data{$entry_id} = { completor_id => $completor_id,
							 start_date => $start_date,
							 complete_date => $complete_date,
							 entry_duration => $entry_duration,
							 entry_date => $entry_date,
							 evaluatee_id => $evaluatee_id, 
							 time_period => $time_period_id,
						 };

		if ($is_evaluated) {
			push @{$student_entries{$evaluatee_id}}, $entry_id;
		} else {
			push @{$student_entries{$completor_id}}, $entry_id;
		}
	}

	$sth->finish();

	return (undef, undef, undef, undef) unless (keys %student_entries);
	my $user_ids = join(",", map { "'$_'"} keys %student_entries);
	my @students = HSDB4::SQLRow::User->lookup_conditions("user_id in ($user_ids) order by lastname,firstname");

	my $field_ids_string = '';
	if (ref $field_ids eq 'ARRAY') {
		$field_ids_string = join(",", grep { /\d+/ } @{$field_ids});
	} else {
		$field_ids_string = $field_ids if ($field_ids =~ /^\d+$/);
	}

	my $fields = TUSK::FormBuilder::Field->lookup("field_id in ($field_ids_string)",['link_form_field.sort_order'],undef,undef, [TUSK::Core::JoinObject->new('TUSK::FormBuilder::LinkFormField', { origkey => 'field_id', joinkey => 'child_field_id', jointype => 'inner', joincond => "parent_form_id = $self->{_form_id}" }), ]);

	return (\%data, \@students, \%student_entries, $fields);
}


sub getCheckList {
	my ($self, $field_id) = @_;

	my $sql = qq(
				 SELECT e.entry_id, r.item_id, ai.item_name 
				 FROM tusk.form_builder_entry e, tusk.form_builder_response r, tusk.form_builder_response_attribute ra, tusk.form_builder_attribute_item ai 
				 WHERE e.entry_id = r.entry_id and r.response_id = ra.response_id and ai.item_id = ra.attribute_item_id
				 and form_id = $self->{_form_id} and time_period_id in ($self->{_time_period_ids_string}) and field_id = $field_id
	);

	my $sth = $self->{_form}->databaseSelect($sql);
	my %data;  
	### get a hash of responses keyed by entry_id, field_id and item_id
	while (my ($entry_id, $item_id, $attribute_item_name) = $sth->fetchrow_array()) {
		$data{$entry_id}{$item_id} = $attribute_item_name;
	}

	$sth->finish();
	return \%data;
}


=head3 getEssay
	expect a field_id
	return a hash of list keyed by entry_id and field_id
=cut

sub getEssay {
	my ($self, $field_id) = @_;

	my $sql = qq(
				 select e.entry_id, r.text
				 from tusk.form_builder_response as r
				 right outer join tusk.form_builder_entry as e on (r.entry_id = e.entry_id and e.form_id = $self->{_form_id} and time_period_id in ($self->{_time_period_ids_string}))
				 where field_id = $field_id
	);

	my $sth = $self->{_form}->databaseSelect($sql);
	my %data;  
	### get a hash of responses keyed by entry_id, field_id and item_id
	while (my ($entry_id, $text) = $sth->fetchrow_array()) {
		$data{$entry_id} = $text;
	}

	return \%data;
}

1;



