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
	/* SHOW/HIDE field comments setup */
	showHideFieldFeedback();
    $('#show_field_feedback').click(showHideFieldFeedback);
	
	$('#field_type_id').change(function() {
		var types = $(this).val().split('#');
		if (types[1] == 'Scaling') {
			$('#rubric_tr').show();
			if ($('input[name="no_rubric"]').length) {
				alert(_("Please create performance levels on the form page prior to adding data to this page.\n Otherwise, this criteria will NOT work properly."));
			}
		}
	});

});


function showHideFieldFeedback() {
	if ($('#show_field_feedback:checked').val() == undefined) {
       	$('#newfeedback').hide();  
       	$('#feedbackdiv').hide();  
	} else {
       	$('#newfeedback').show();  
       	$('#feedbackdiv').show();  
	}
}
