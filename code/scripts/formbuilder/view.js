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
	updateCommentBox();
	$("#myform").before("<div id=\"error-container\">\n" + _("Some required data is missing.") + "&nbsp; " + _("See details below.") + " </div>");
	$('#error-container').hide();

	$('#form_submit').click(function() {
		$('#gTrafficLight').hide();

	    $('#myform').validate({
			errorClass: "field-error",
		 	highlight: function(element, errorClass) {
		     	$(element.form).find("label[for=" + element.name + "]").addClass(errorClass);
		     	$(element.form).find("label[for=comment_" + element.name + "]").addClass(errorClass);
			},
			unhighlight: function(element, errorClass) {
    			$(element.form).find("label[for=" + element.id + "]").removeClass(errorClass);
		     	$(element.form).find("label[for=comment_" + element.name + "]").removeClass(errorClass);
			},
		    invalidHandler: function(form, validator) {
	    	  	var errors = validator.numberOfInvalids();
				if (errors) {
    	   			$("#error-container").show();
					$('html, body').animate({scrollTop:0}, 'slow');
		      	} else {
    	   			$("#error-container").hide();
	    	  	}
		    }
		});

		if ($('#myform').valid()) {

			var min_score = $("#myform input[name='min_score']").val();
			if ( min_score && min_score > $('#total_score').val()) {
				if (confirm(
					_("The minimum score to pass is {minimum_score}.",{minimum_score : min_score}) +  "\n " + 
					_("The calculated score is {total_score}.",{total_score : $('#total_score').val()}) + "\n " + 
					_("Are you sure you want to submit?")) == false ) {
					return false;
				}
			} else {
				if (confirm(_("Are you sure you want to submit?")) == false ) {
					return false;
				}
			}
 		} 


	});

	$('#save_submit').click(function() {
		$("#myform").validate().cancelSubmit = true;
	});

	/* DISABLE the whole form */
	if ($('#disable_form').val()) {
		$("#myform input[type='radio']").attr('disabled','disabled');
		$("#myform input[type='text'], textarea, select").addClass('formGrayOut').attr('readonly','readonly');
		$("#myform input[type='submit']").hide();
		$('#calendar-encounter_date').hide();
		$('.comment').hide();
	}

	$('#total_score').val($('input:radio').sumUpScores());

	$('input:radio').click(function() {
		$('#total_score').val($('input:radio').sumUpScores());
	});

	/* Setup drag and drop for text area */
	$(".dragdrop").dragAndDrop();
});


$.fn.dragAndDrop = function() {
	this.each(function() {
		var object_id = $(this).attr('title');
	    var options = {
    	    accept: "span.placeholder_" + object_id,       
        	drop: function(ev, ui) {
            	insertAtCaret($("textarea#comment_" + object_id).get(0), ui.draggable.eq(0).text());
	        }
    	};

    	$("span.placeholder_" + object_id).draggable({
			cursorAt: { cursor: 'pointer' },
	        helper: 'clone',
    	    start: function(event, ui) {
            	var txta = $("textarea#comment_" + object_id);
            	$("div#pseudodroppable_" + object_id).css({
                	position:"absolute",
                	top:txta.position().top,
                	left:txta.position().left,
                	width:txta.width(),
                	height:txta.height()
            	}).droppable(options).show();
        	},
        	stop: function(event, ui) {
            	$("div#pseudodroppable_" + object_id).droppable('destroy').hide();
        	}
	   	});
	});
}


function insertAtCaret(area, text) {
    var scrollPos = area.scrollTop;
    var strPos = 0;
    var br = ((area.selectionStart || area.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );
    if (br == "ie") {
        area.focus();
        var range = document.selection.createRange();
        range.moveStart('character', -(area.value.length));
        strPos = range.text.length;
    } else if (br == "ff")
        strPos = area.selectionStart;
	    var front = (area.value).substring(0, strPos);  
	    var back = (area.value).substring(strPos, area.value.length); 
	    area.value = front + text + back + "\n";
	    strPos = strPos + text.length;
    if (br == "ie") { 
        area.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -(area.value.length));
        range.moveStart ('character', strPos);
        range.moveEnd ('character', 0);
        range.select();
    } else if (br == "ff") {
        area.selectionStart = strPos;
        area.selectionEnd = strPos;
        area.focus();
    }
    area.scrollTop = scrollPos;
}


$.fn.sumUpScores = function() {
	var sum = 0;
	var total_max_score = 0;
	this.each(function() {
		if ($(this).is(':checked')) {
			$(this).parent().addClass('selected-radio');
			var vals = ($(this).val()).split('_');		
			if (vals[1] && vals[1] > 0) {
				var field_key = ($(this).attr('name')).split('_');
				var weight = $('#weight_' + field_key[1]).val();
				var maxval = $('#maxval_' + field_key[1]).val();
				if (weight) {
					var temp = (vals[1] / maxval) * weight;
					sum += parseFloat(temp.toFixed(2));
					total_max_score += parseFloat(weight);
				} else {
				 	sum += parseFloat(vals[1]);
					total_max_score += parseFloat(maxval);
				}
			}
		} else {
			$(this).parent().removeClass('selected-radio');
		}
	});
	$('#total_max_score').val(total_max_score);
	return sum.toFixed(2);
}


function updateCommentBox() {
	// set up required comment boxes
	$("input[name='comment_required_field']").each(function(field_index, field_elem) {
		var comment_box = $("textarea[name='comment_" + field_elem.value + "']");
		var item = $("input[name='id_" + field_elem.value + "']:checked").val();
		if (item) {
			var item_id = item.split('_');
			if (!comment_box.val()) {
				if ($("input[name='comment_required_item_" + item_id[0] + "']").length) {
					comment_box.addClass('required');
			     	$('#myform').find("label[for=comment_" + field_elem.value + "]").show();
				}
			}
		}
	});

	if ($("input[name='comment_required_field']").length) {
		$("input[type='radio']").click(function() {
			var field_id = $(this).attr('name').split('_');
			var item_id = $(this).val().split('_');
			var comment_box = $("textarea[name='comment_" + field_id[1] + "']");
			if ($("input[name='comment_required_item_" + item_id[0] + "']").length) {
				if (comment_box.val()) {
					comment_box.removeClass('required');	
			     	$('#myform').find("label[for=comment_" + field_id[1] + "]").hide();
				} else {
					comment_box.addClass('required');	
			     	$('#myform').find("label[for=comment_" + field_id[1] + "]").show();
				}
			} else {
				comment_box.removeClass('required');	
		     	$('#myform').find("label[for=comment_" + field_id[1] + "]").hide();
			}	
		});

		$("textarea[name^='comment_']").bind('keyup mouseover mouseleave', function() {
			if ($(this).hasClass('required')) {
				if ($(this).val()) {
			     	$('#myform').find("label[for=" + $(this).attr('name') + "]").hide();
				} else {
			     	$('#myform').find("label[for=" + $(this).attr('name') + "]").show();
				}
			}
		});
	}
}
