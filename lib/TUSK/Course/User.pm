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

package TUSK::Course::User;

use strict;

####################################################################################################
# DO NOT MODIFY BELOW -- coreate_object compatability section
####################################################################################################

BEGIN
{
	require TUSK::Core::SQLRow;
	our @ISA = qw(TUSK::Core::SQLRow);
}

sub new
{
	my $class = shift;
	$class = ref $class || $class;
	my $this = $class->SUPER::new( 
		_datainfo => {
			'database' => 'tusk',
			'tablename' => 'course_user',
			'usertoken' => '',
			'database_handle' => '',
		},
		_field_names => {
			'course_user_id' => 'pk',
			'school_id' => '',
			'course_id' => '',
			'user_id' => '',
			'time_period_id' => '',
			'sort_order' => '',
		},
		_attributes => {
			save_history => 1,
			tracking_fields => 1,	
		},
		_levels => {
			reporting => 'cluck',
			error => 0,
		},
		@_
	);
	return $this;
}

BEGIN
{
	for my $field (qw(school_id course_id user_id time_period_id sort_order))
	{
		no strict 'refs';
		my $xxx = join '', map { /^id$/ ? (uc) : (ucfirst) } split /_/, $field;
		*{"get$xxx"} = sub { $_[0]->getFieldValue($field) };
		*{"set$xxx"} = sub { $_[0]->setFieldValue($field, $_[1]) };
	}
}

####################################################################################################
# DO NOT MODIFY ABOVE -- coreate_object compatability section
####################################################################################################




1;
