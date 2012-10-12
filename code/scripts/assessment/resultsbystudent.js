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
	var criteria_update = 0;

	if ($("input[name=edit_mode]").val() == 0) {
		$("#calendar-encounter_date").hide();
		$(".comment_section").hide();
		$("#resultsbystudent input[type='text'], textarea").addClass('formGrayOut').attr('disabled','disabled');
	} 

	$("#post_submit").click(function() {
		var min_score = $("#resultsbystudent input[name='min_score']").val();
		var score = ($("#resultsbystudent input[name='total_override_score']").val()) ? $("#resultsbystudent input[name='total_override_score']").val() : $("#resultsbystudent input[name='total_final_score']").val();

		var msg = ''; 
		if (criteria_update && $("input[name='db_total_override_score']").val()) {
			msg = _("Previous Override Score was {previous_score}", {previous_score : $("input[name='db_total_override_score']").val()}) + ".\n\n";
		}

		if (min_score && min_score > score) {
			msg += _("The minimum score to pass is {minimum_score}.",{minimum_score : min_score}) + "\n "+ _("Final score is {final_score}", {final_score : score}) + "\n\n";
		} 

		msg += _("Are you sure you want to {perform_action}?",{ perform_action : $("#post_submit").val()});

		if (confirm(msg) == false) {
			return false;
		}
	});

	$("#expandable tr.line-bgcolor").hide();
	$("#expandable tr:first-child").show();

	$("#expandable div.row").click(function() {
		// IE bug so we can't use toggle here
		// $(this).parent().parent().next("tr").toggle();

		var tr = $(this).parent().parent().next("tr");
		if (tr.css("display") == "none") {
	        tr.css("display", "table-row");
    	} else {
	        tr.css("display", "none"); 
		}

		$(this).find(".arrow").toggleClass("updown");
	});

	$("#expandable div.allrows").click(function() {
	 	var trs = $("#expandable div.row");
		for (i = 0; i < trs.length; i++) {
			var tr = $(trs[i]).parent().parent().next("tr");
			if (tr.css("display") == "none") {
	    	    tr.css("display", "table-row");
	    	} else {
		        tr.css("display", "none"); 
			}
			$(tr).find(".arrow").toggleClass("updown");
		}
		$(this).find(".arrow").toggleClass("updown");
	});


	$('#students').change(function() {
		var strings = $('#students').val().split('__');
		var word = /\w+/;  
		var result = strings[0].match(word);
		$('#students').selectedIndex = 0;
		if (result == null) {
			return false;
		}
		location.href = strings[0];
	});

	$('.inlinebar').sparkline('html', {type: 'bar', barColor: 'green', barWidth: 9, barSpacing: 5, height: 28 } );

	$('#total_avg_score').html($('input.field-average').sumValues());
	$('input.field-average').bind('keyup', function() {
		criteria_update = 1;
		$('#total_avg_score').html($('input.field-average').sumValues(criteria_update));
	});
});


$.fn.sumValues = function(criteria_update) {
 	var sum = 0;
	var weighted_sum = 0; 
	var has_weight = ($('#total_weight').text()) ? 1 : 0;

	this.each(function() {
		var val = ($(this).is(':input')) ? $(this).val() : $(this).text();
		sum += parseFloat( ('0' + val).replace(/[^0-9-\.]/g, ''), 10 );

		if (has_weight) {
			var field_id = $(this).attr('name');
			var weighted_average = parseFloat($("input[name='" + field_id + "']").val() / $("input[name='range_" + field_id + "']").val() * $('#weight_' +  field_id).text()).toFixed(2);
			$('#weighted_avg_' + field_id).html(weighted_average);
			weighted_sum += parseFloat( ('0' + weighted_average).replace(/[^0-9-\.]/g, ''), 10 );
		} 

	});

	var current_final_score = (has_weight) ? weighted_sum : sum;
	$("input[name='total_final_score']").val(current_final_score.toFixed(2));	

	// adjust the override score reflecting calculated score when needed
	if (parseFloat($("input[name='total_override_score']").val()) > 0) {
		if (criteria_update) {
			if (has_weight && weighted_sum) {
				$("input[name='total_override_score']").val(weighted_sum);	
			} else {
				if (sum) {
					$("input[name='total_override_score']").val(sum);	
				}
			}
		}
	}

	// clear out the same value. sometimes override score from db; others from calculation
	if (parseFloat($("input[name='total_final_score']").val()) == parseFloat($("input[name='total_override_score']").val())) {
			$("input[name='total_override_score']").val('');	
	} 

	return sum;
}





