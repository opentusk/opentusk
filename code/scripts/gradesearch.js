$(document).ready(function(){
	// shared variables
	var tps;
	var courses;
	var students;
	
	$("nav input[type=radio]").click(function() {
		getGradeData($(this));
	});
	
	$("nav .filter select").not(':last').change(function() {
		if ($(this).val()) {
			populateNextOptions($(this));
		}
	});
	
	$("nav .filter select:last").change(function() {
		if ($(this).val()) {
			getGradeData($(this));
		}
	});
	
	$(".filter input[value=reset]").click(function() {
		var select = $(this).parent().siblings("select");
		if ($(select).val()) {
			deselectAll($(select));
			switch ($(select).attr("id")) {
				case "tp_id":
					$("table.data").hide();
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					$("select#course").parent().removeClass("active");
					deselectAll($("select#course"));
					break;
				case "course":
					$("table.data").hide();
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					break;
				case "student":
					$("table.data").hide();
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					break;
			}
		}
	});
	
	$(".filter input[value='select all']").click(function() {
		var select = $(this).parent().parent().children("select");
		if (!$(select).attr('disabled')) {
			selectAll($(select));
			$(select).trigger('change');
		}
	});

	var d = new Date();
	var curr_date = d.getDate();
	var curr_month = d.getMonth();
	curr_month++;
	var curr_year = d.getFullYear();
	$(".timestamp").html("<p>as of " + curr_month + "/" + curr_date + "/" + curr_year + "</p>");
});

function populateNextOptions(select) {
	var url = "/tusk/grade/getData/" + encodeURI($("input[name=school_id]").val());
	switch ($(select).attr("name")) {
		case "tp_id":
			tps = encodeURI($(select).val());
			url += "/courses?tp_ids=" + tps;
			target = 'select#course';
			break;
		case "course":
			courses = encodeURI($(select).val());
			url += "/students?tp_ids=" + tps + "&courses=" + courses;
			target = 'select#student';
			break;
		case "student":
			students = encodeURI($(select).val());
			url += "/grades?tp_ids=" + tps + "&courses=" + courses + "&students=" + students;
			target = 'fieldset';
			break;
	}
	$(target).parent().addClass("processing");

	var ajax = $.getJSON(url, function(data) {
		var items = [];
		$.each(data, function() {
			$.each(this, function(id, name) {
				items.push('<option value="' + id + '">' + name + '</option>');
			});
		});
		if (target != "fieldset" && $(items).size()) {
			$(target).html(items.join("\n"));
		}
	})
	.done(function() { 	$(target).parent().removeClass("processing"); $(target).parent().addClass("active"); $(select).attr('disabled', 'disabled'); })
	.fail(function() { alert('failed to get data'); });
}

function getGradeData(formObj) {
	students = encodeURI($("select#student").val());
	var url = "/tusk/grade/getData/" + encodeURI($("input[name=school_id]").val()) + "/grades?tp_ids=" + tps + "&courses=" + courses + "&students=" + students;
	switch(formObj.get(0).type) {
		case "select-multiple":
			var ajax = $.getJSON(url, function(data) {
				generateDataTable(data);
			})
			.fail(function() { alert('failed to get data'); });
			break;
	}
}

function generateDataTable(data) {
	$("table.data").html();
	var rows;
	var html = "";
	$.each(data, function() {
		html += "<tr>";
		html += "<td>" + this.firstname + " " + this.lastname + "</td>";
		html += "</tr>";		
	});
	$("table.data").html(html).show();
}

function deselectAll(select) {
	$(select).val(null);
	$(select).removeAttr('disabled');
	$(select).children("option").prop('selected',false);;
}


function selectAll(select) {
	if (!$(select).attr('disabled')) {
		$(select).children("option").prop('selected',true);
	}
	return false;
}