$(function() {
	/* SHOW/HIDE field comments setup */
	showHideFieldFeedback();
    $('#show_field_feedback').click(showHideFieldFeedback);
	
	$('#field_type_id').change(function() {
		var types = $(this).val().split('#');
		if (types[1] == 'Scaling') {
			$('#rubric_tr').show();
			if ($('input[name="no_rubric"]').length) {
				alert("Please create performance levels on the form page prior to adding data to this page.\n Otherwise, this criteria will NOT work properly.");
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
