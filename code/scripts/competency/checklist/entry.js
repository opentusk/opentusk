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
	$("input[name=notify_show]").click(showEmailForm);
//	$("input[name=complete_submit]").click(validate);

	showHideButtons();
	$("input:radio[class='compid']").click(showHideButtons);
});

function showEmailForm() {
	$('#notify_student').show('slow');
}

function hideEmailForm() {
	$('#notify_student').hide('slow');
}

function showHideButtons() {
	var show_notify_button = 0;
	var num_completions = 0;

	// loop through all the checked radio buttons
	$(':input.compid:checked').each(function(){

		if ($("input[name=show_notify]")) {
			if ($(this).val() == 0) {
				show_notify_button = 1;	
				return;
			} 
		}

		if ($(this).val() == 1) {
			num_completions++;
		}
	});

	if (show_notify_button == 1) {
		$('#notify_show').show('slow');
	} else {
		$('#notify_show').hide('slow');
	}

	// show complete button when all radio buttons are checked
	if (num_completions == ($(':input.compid').length / 2)) {
		$('#complete_submit').show('slow');		
	} else {
		$('#complete_submit').hide('slow');		
	}
}

function notifyStudent() {
	$.ajax({
		type		: 'POST',
		url		: '/competency/checklist/tmpl/notifystudent/' + $("input[name=url_paths]").val(),
		dataType	: 'json',
		data		: { 
			'to'			: $("input[name=to_email]").val(),
			'notify_comments'	: $("textarea[name=notify_comments]").val(),
			
		},
	        success		: function(response) {
					$('#notify_show').hide('slow');
					$('#notify_student').hide('slow');
					alert('Email successfully sent');

		},
		error		: function(xhr, ajaxOptions, thrownError) {
			            alert(_('Error: ') + thrownError);
	        }    
	});
}

