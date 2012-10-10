$(function() {
	scoreDisplayChange(); // default setting
    $('#addrubric').click(scoreDisplayChange); 
    $('#score_display').click(scoreDisplayChange); // user makes some change

	scoreRangeChange(); // default setting
    $('#score_range').click(scoreRangeChange); // user makes some change

	showHideUA();
	$('#addrubric').click(showHideUA);	
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
