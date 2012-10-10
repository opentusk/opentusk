$(document).ready(function() {
	// get maximum table dimensions
	var adjustedwidth = parseInt($(window).width()) - 50;
	var adjustedheight = parseInt($(window).height() - $('#reporttable1').offset().top - 50);

	// set number of header rows
	var headerRowSize = $('#reporttable1 tr.header').length;

	$("table.reporttable").each(function() {
		$(this).scrollableTable(adjustedwidth, adjustedheight, headerRowSize, 1);
	});
	
	showhidetable('reportdiv1');

	// now that rendering is done, remove the curtain
	$(".datatable fieldset").css("visibility", "visible");
	$(".reportdiv").css("visibility", "visible");
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
