// Copyright 2012 Tufts University 
//
// Licensed under the Educational Community License, Version 1.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//
// http://www.opensource.org/licenses/ecl1.php 
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and 
// limitations under the License.


$(function() {

	$('#copyusers').validate({
		rules: {
			source_tp_id: "required",
			target_tp_id: "required"
		},
		messages: {
			source_tp_id: "Please select a source time period.",
			target_tp_id: "Please select a target time period."
		}
	});
//	$('#copybutton').click(validate);
});

function validate() {

	if ($("input[name='source_tp_id']:checked").length == 0) {
		alert("Please select a source time period.");
		return false;
	}

	if ($("input[name='target_tp_id']:checked").length == 0) {
		alert("Please select a target time period.");
		return false;
	}

	return true;
}