# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

package TUSK::Application::FormBuilder::Assessment;

use TUSK::FormBuilder::Entry;

sub new {
	my ($class, $arg_ref) = @_;

	my $self = {
		user_id => $arg_ref->{user_id},
		current_time_period => $arg_ref->{current_time_period}
	};

	bless($self, $class);

	return $self;
}

sub changeEntry {
	my ($self, $args) = @_;
	warn "Entry change requested and being processed. \n";
	if (TUSK::FormBuilder::Entry->exists("time_period_id = '$self->{current_time_period}' 
		and user_id = '$self->{user_id}'")) {
		warn "Existing entry found";
		my $entry = TUSK::FormBuilder::Entry->lookup("time_period_id = '$self->{current_time_period}' 
		and user_id = '$self->{user_id}'");
	}	
}


1;