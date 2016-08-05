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
	showHideButtons();
	$("input:radio[class='compid']").click(showHideButtons);
});


function showHideButtons() {
	var show_notify_button = 0;
	var num_completions = 0;

	// loop through all the checked radio buttons
	$(':input.compid:checked').each(function(){

		if ($(this).val() == 0) {
			show_notify_button = 1;	
			return;
		} 

		if ($(this).val() == 1) {
			num_completions++;
		}
	});

	if (($('#assess_type').val() === 'partner') || ($('#assess_type').val() === 'faculty')) {
		$('#save_submit').hide(); // no save button for faculty/partner

		if (show_notify_button === 1) {
			$('#notify_template').show();
			$('#notify_submit').show();
		} 
	}

	// show complete and excellence buttons only when all radio buttons are checked
	if (num_completions == ($(':input.compid').length / 2)) {
		$('#complete_submit').show();
		$('#notify_submit').hide();		
		$('#notify_template').hide();
		$('#excellence').show();
		$('#excellence_text').show();
	} else {
		$('#complete_submit').hide();		
		$('#excellence').hide();
		$('#excellence_text').hide();
	}
}
