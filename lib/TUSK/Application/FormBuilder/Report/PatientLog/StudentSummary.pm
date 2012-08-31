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


package TUSK::Application::FormBuilder::Report::PatientLog::StudentSummary;

use strict;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use HSDB4::SQLRow::User;


sub new {
    my ($class, $form_id, $course, $user_id, $tp_params) = @_;
	die "Missing form_id, course_id and/or user_id\n" unless ($form_id && $course && $user_id);
    $class = ref $class || $class;

    return $class->SUPER::new( _course => $course, 
							   _form_id => $form_id, 
							   _user_id => $user_id, 
							   _user => HSDB4::SQLRow::User->new()->lookup_key($user_id),
							   _tp_params => $tp_params,
							   _report_flags => join(",", @{$TUSK::FormBuilder::Constants::report_flags_by_report_type->{4}}),
							   );
}

sub getReport {
	my ($self, $private) = @_;

	my %data = ();

	my $sth = $self->{_form}->databaseSelect(qq(
			select a.field_id, count(*) as total, 
			count(distinct item_id) as distinct_items, 
			count(distinct b.entry_id) as patients 
			from tusk.form_builder_response a, tusk.form_builder_entry b, tusk.form_builder_field c
			where a.entry_id = b.entry_id 
			and form_id = $self->{_form_id}
			and user_id = '$self->{_user_id}' 
			and default_report in ($self->{_report_flags})
			and a.field_id = c.field_id 
			and active_flag = 1
			group by a.field_id
	));

	while (my ($field_id, $total, $distinct, $patients) = $sth->fetchrow_array()) {
		$data{$field_id} = [ $total, $distinct, $patients ];
	}

	$sth->finish();

	my $fields = $self->{_form}->getAllFormFields("token not in ('FillIn', 'Essay')");
	my $patients = $self->getTotalNumberPatients();

	return { rows => [keys %data],  data => \%data, fields => $fields, fullname => $self->{_user}->out_full_name(), num_patients => $patients };
}


sub getTotalNumberPatients {
	my $self = shift;

	return scalar @{TUSK::FormBuilder::Entry->lookup("user_id = '$self->{_user_id}' AND time_period_id in ($self->{_time_period_ids_string}) AND form_id = $self->{_form_id}")};
}


sub getReportByField {
	my ($self, $field_id) = @_;
	my %data = ();
	my ($attribute_items, $aids) = $self->getAttributeItems($field_id);
	my $sql = qq(
				 select item_id, attribute_item_id, count(*) 
				 from tusk.form_builder_response a
				 inner join tusk.form_builder_entry b on (a.entry_id = b.entry_id)
				 left outer join tusk.form_builder_response_attribute c on (a.response_id = c.response_id)
				 where b.time_period_id in ($self->{_time_period_ids_string})
				 and form_id = $self->{_form_id} and user_id = '$self->{_user_id}'
				 and field_id = $field_id
				 and active_flag = 1
				group by item_id, attribute_item_id);

	my $sth = $self->{_form}->databaseSelect($sql);

	while (my ($item_id, $attr_item_id, $count) = $sth->fetchrow_array()) {
		my $i = (defined $attr_item_id) ? $aids->{$attr_item_id} : 0;
		$data{$item_id}[$i] = $count;
	}
	$sth->finish();

	my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
	my $user = HSDB4::SQLRow::User->new()->lookup_key($self->{_user_id});
	my $patients = $self->getTotalNumberPatients();

	return { rows => $items, attribute_items => $attribute_items, data => \%data, fullname => $self->{_user}->out_full_name(), items_with_category => $self->isCategory($items->[0]), num_patients => $patients };
}


sub getCommentSummary  {
	my ($self, $fields_condition) = @_;

	return $self->SUPER::getCommentSummary($fields_condition, " AND user_id = '$self->{_user_id}'");
}


sub getLogSummary {
	my ($self, $private) = @_;
	$private = 0 unless defined $private;

	my $responses = TUSK::FormBuilder::Response->lookup("time_period_id in ($self->{_time_period_ids_string})", ['response_id'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::Entry", { origkey => 'entry_id', joinkey => 'entry_id', joincond => "user_id = '$self->{_user_id}' and form_id = $self->{_form_id}"}), TUSK::Core::JoinObject->new("TUSK::FormBuilder::Field", { origkey => 'field_id', joinkey => 'field_id', joincond => "private = $private"}), TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldItem", { origkey => 'item_id', joinkey => 'item_id'}), ]);

	my ($data, $num_reports) = $self->processLogSummary($responses);
	my $fields = $self->{_form}->getAllFormFields();

	return { rows => [sort keys %$data],  data => $data, fields => $fields, fullname => $self->{_user}->out_full_name(), num_reports => $num_reports };
}


1;
