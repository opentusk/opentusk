$(function() {
	imagePreview();
	$("input[name=selection]").click(changeSelection);
});


function changeSelection() {
	var cbox = $(this);
	var tokens = cbox.val().split('__');
	var choice = (cbox.attr('checked') == false) ? "do NOT" : '';
	var email_notification = ($('#email_notification').val())  ? 'An email will be sent to Director.' : '';
	if (confirm("Are you sure you " + choice + " want to assess this student?\n" + email_notification) == false) {
		var val = (cbox.attr('checked') == false) ? true : false;
		cbox.attr('checked', val);
		return;
	}

	var new_status = (cbox.attr('checked') == true) ? $("input[name=selected_by_assessor]").val() : $("input[name=deselected_by_assessor]").val();
	var target_id = 'action__' + tokens[0] + '__' + tokens[1];

    $.ajax({
		type		: 'POST',
		url			: tokens[3],
		dataType	: 'json',
		data		: { 
			'status' 		: new_status,
			'assessor_id'	: tokens[0],
			'student_id' 	: tokens[1],
			'form_id'		: tokens[2]
			
		},
        success		: function(response) {
			if (cbox.attr('checked') == true) {
				$('#' + target_id).show();
			} else {
				$('#' + target_id).hide();
			}
		},
		error		: function(xhr, ajaxOptions, thrownError) {
            alert('Error: ' + thrownError);
        }    
    });
}


this.imagePreview = function() {	
	xOffset = 18; // 10;
	yOffset = 10; // 30;

	$("img.imgPreview").hover(function(e){
		this.t = this.title;
		this.title = "";	
		var c = (this.t != "") ? "<br/>" + this.t : "";
		$("body").append("<p id='imgPreview'><img src='"+ this.src +"' alt='Image preview' width='100px' height='100px' />"+ c +"</p>");								 
		$("#imgPreview")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px")
			.fadeIn("fast");						
    },
	function(){
		this.title = this.t;	
		$("#imgPreview").remove();
    });	
	$("a.imgPreview").mousemove(function(e){
		$("#imgPreview")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px");
	});			
};
