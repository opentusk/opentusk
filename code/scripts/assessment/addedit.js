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
	scoreDisplayChange(); // default setting
    $('#addrubric').click(scoreDisplayChange); 
    $('#score_display').click(scoreDisplayChange); // user makes some change

	scoreRangeChange(); // default setting
    $('#score_range').click(scoreRangeChange); // user makes some change

	showHideUA();
	$('#addrubric').click(showHideUA);	

	$('a[id^="remove_"]').click(deletePerformanceLevel);
});

function scoreDisplayChange() {
	if ($('#score_display').attr('checked') == false) {
		$('#weight').hide();
		$('.use_score').hide();
		$("input[name='score_range'], input[name='show_grade_to_assessor'], input[name='show_grade_to_subject'], input[name='show_grade_to_registrar']").each(function() {
			$(this).attr('checked', false);
		});
		$("input[name='min_score']").val('');
   		$('#rubrictab th:nth-child(2)').hide();  
   		$('#rubrictab td:nth-child(2)').hide();
		$('input[name=score_range]').attr('checked', false);
   		$('#rubrictab th:nth-child(3)').hide();  
   		$('#rubrictab td:nth-child(3)').hide();
		
	} else {
		$('#weight').show();
		$('.use_score').show();
       	$('#rubrictab th:nth-child(2)').show();
   		$('#rubrictab td:nth-child(2)').show();
		scoreRangeChange();
	}	
}

function scoreRangeChange() {
	if ($('#score_range').attr('checked') == false) {
   		$('#rubrictab th:nth-child(3)').hide();  
   		$('#rubrictab td:nth-child(3)').hide();
		$('#score_label').html('Score');
	} else {
       	$('#rubrictab th:nth-child(3)').show();
   		$('#rubrictab td:nth-child(3)').show();
		$('#score_label').html('Min Score');
	}	
}

function showHideUA() {
	if ($('input[name*=rubricdiv_]').length > 0) {
		if ($('#ua_checkbox:hidden')) {
			$('#ua_checkbox').show();
		}
	} else {
		$('#ua_checkbox').hide();
	}
}


function deletePerformanceLevel() {
	if ($('#num_performance_criteria_id').val() > 0) {
		return confirm(_("Deleting a Performance Level will remove the level and its associated comments from each criteria in this assessment.\nAre you sure you want to continue?"));
	}
}
