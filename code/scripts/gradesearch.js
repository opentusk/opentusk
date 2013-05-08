$(document).ready(function(){
	
	// shared variables
	var tps;
	var courses;
	var students;


	$("nav input[type=radio]").click(function() {
		$("#main").addClass("active");
		$(".current").removeClass('current');
		var matches = $(this).attr("id").match(/display-(.*)/);
		$("#" + matches[1] + "-tab").addClass("current");
	});
	
	$("nav .filter select").change(function() {
		if ($(this).val()) {
			populateNextOptions($(this));
			$(this).addClass("disable");
		}
	});
	
	$(".filter input[value=reset]").click(function() {
		var select = $(this).parent().siblings("select");
		if ($(select).val()) {
			deselectAll($(select));
			switch ($(select).attr("id")) {
				case "tp_id":
					$("#main").removeClass("active");
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					$("select#course").parent().removeClass("active");
					deselectAll($("select#course"));
					break;
				case "course":
					$("#main").removeClass("active");
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					break;
				case "student":
					$("#main").removeClass("active");
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					break;
			}
		}
	});
	
	$(".filter input[value=all]").click(function() {
		selectAll($(this).parent().parent().children("select"));
		$(this).parent().parent().children("select").trigger('change');
	});

	var d = new Date();
	var curr_date = d.getDate();
	var curr_month = d.getMonth();
	curr_month++;
	var curr_year = d.getFullYear();
	$(".timestamp").html("<p>as of " + curr_month + "/" + curr_date + "/" + curr_year + "</p>");
});

function populateNextOptions(select) {
	var url = "/tusk/grade/getData/" + $("input[name=school_id]").val();
	switch ($(select).attr("name")) {
		case "tp_id":
			tps = $(select).val();
			url += "/courses?tp_ids=" + tps;
			target = 'select#course';
			break;
		case "course":
			courses = $(select).val();
			url += "/students?tp_ids=" + tps + "&courses=" + courses;
			target = 'select#student';
			break;
		case "student":
			students = $(select).val();
			url += "/students?tp_ids=" + tps + "&courses=" + courses + "&students=" + students;
			target = 'fieldset';
			break;
	}

	var jqxhr = $.getJSON(url, function(data) {
		var items = [];
		$.each(data, function(key, val) {
			items.push('<option value="' + key + '">' + val + '</option>');
		});
		if (target != "fieldset" && $(items).size()) {
			$(target).html(items.join("\n"));
		}
	})
	.done(function() { $(target).parent().addClass("active"); })
	.fail(function() { alert('failed to get data'); });
}

function deselectAll(select) {
	$(select).val(null);
	$(select).children("option").prop('selected',false);;
}


function selectAll(select) {
	$(select).children("option").prop('selected',true);
}