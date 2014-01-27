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
	$("input[name=selection]").click(changeSelection);
});


function changeSelection() {
	var cbox = $(this);
	var tokens = cbox.val().split('__');
	var target_id = 'action__' + tokens[5] + '__' + tokens[4];  /* action__role_id__evaluatee_uid */

	$.ajax({
		type		: 'POST',
		url		: tokens[6],
		dataType	: 'json',
		data		: { 
					'school_id'	: tokens[0],
					'eval_id'	: tokens[1],
					'evaluator_id'	: tokens[2],
					'evaluatee_id' 	: tokens[3],
					'action'	: (cbox.is(':checked') == true) ? 'insert' : 'delete'
				},
        	success		: function(response) {
					if (response.status == 1) {
						if (cbox.is(':checked') == true) {
							$('#' + target_id).show();
						} else {
							$('#' + target_id).hide();
						}
					} else if (response.status == 2) {
						if (cbox.isr(':checked') == true) {
							cbox.removeAttr('checked');
						}
						alert("You have already picked " + response.evaluatee);
					}
				},
		error		: function(xhr, ajaxOptions, thrownError) {
					console.log("readyState: " + xhr.readyState);
					console.log("responseText: "+ xhr.responseText);
					console.log("status: " + xhr.status);
					console.log("text status: " + ajaxOptions);
					console.log("error: " + err);
			        }    
	});
}
