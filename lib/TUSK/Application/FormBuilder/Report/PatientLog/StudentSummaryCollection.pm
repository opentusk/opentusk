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


package TUSK::Application::FormBuilder::Report::PatientLog::StudentSummaryCollection;

use strict;
use base qw(TUSK::Application::FormBuilder::Report);
use TUSK::Core::School;
use HSDB4::SQLRow::User;


sub new {
    my ($class, $form_id, $course, $tp_params) = @_;
	die "Missing form_id, and/or course\n" unless ($form_id && $course);
    $class = ref $class || $class;

    return $class->SUPER::new( _course => $course, 
							   _form_id => $form_id, 
							   _tp_params => $tp_params,
							   _report_flags => join(",", @{$TUSK::FormBuilder::Constants::report_flags_by_report_type->{4}}),
							   );
}

sub getStudentSummary {
	my ($self, $user_id) = @_;

	if ($user_id) {
		return TUSK::Application::FormBuilder::Report::PatientLog::StudentSummary->new($self->{_form_id}, $self->{_course}, $user_id, $self->getTimePeriodIDs());
	}
}

1;
