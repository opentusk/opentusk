$(document).ready(function() {
	$(window).bind("load", function() {
		showhidetable('reportdiv1');
	});
});

// variable and function to show/hide category tables
var visible = "reportdiv1";

function showhidetable(id) {
	if (visible == "all") {
		$('.reportdiv').hide();
		$("#reportdiv1").show();
		$("#showhidebutton").attr("value","show all");
		$("#showhidetable").attr("disabled", "");
		id = "reportdiv1";
	}
	else if (id == "all") {
		$("#showhidebutton").attr("value","show only one");
		$('.reportdiv').show();
		$("#showhidetable").val("reportdiv1")
		$("#showhidetable").attr("disabled", "disabled");
	}
	else {
		$('.reportdiv').hide();
		$("#" + id).show();
		$("#showhidebutton").attr("value","show all");
		$("#showhidetable").attr("disabled", "");
	}
	visible = id;
	return false;
}
