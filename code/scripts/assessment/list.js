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
	imagePreview();
	$("input[name=selection]").click(changeSelection);
});


function changeSelection() {
	var cbox = $(this);
	var tokens = cbox.val().split('__');
	var choice = (cbox.is(':checked')) ?  _("Are you sure you want to assess this student?") : _("Are you sure you do NOT want to assess this student?");
	var email_notification = ($('#email_notification').val())  ? _('An email will be sent to Director.') : '';
	if (confirm( choice + "\n" + email_notification) == false) {
		cbox.prop("checked", (cbox.is(':checked')) ? false : true);
		return;
	}

	var new_status = (cbox.is(':checked')) ? $("input[name=selected_by_assessor]").val() : $("input[name=deselected_by_assessor]").val();
	var target_id = 'action__' + tokens[0] + '__' + tokens[1];

	$.ajax({
		type		: 'POST',
		url		: tokens[3],
		dataType	: 'json',
		data		: { 
			'status'	: new_status,
			'assessor_id'	: tokens[0],
			'student_id' 	: tokens[1],
			'form_id'	: tokens[2]
			
		},
	        success		: function(response) {
					if (cbox.is(':checked')) {
						$('#' + target_id).show();
					} else {
						$('#' + target_id).hide();
					}
		},
		error		: function(xhr, ajaxOptions, thrownError) {
            alert(_('Error: ') + thrownError);
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
		$("body").append("<p id='imgPreview'><img src='" + this.src + "' alt='Image preview' width='100px' height='100px' />" + c + "</p>");								 
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
