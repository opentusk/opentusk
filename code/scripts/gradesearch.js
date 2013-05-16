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
		$("div.processing").removeClass("processing");

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
	var request = {};
	switch ($(select).attr("name")) {
		case "tp_id":
			tps = $(select).val();
			url += "/courses";
			request.tps = JSON.stringify(tps);
			target = 'select#course';
			break;
		case "course":
			courses = $(select).val();
			url += "/students";
			request.tps = JSON.stringify(tps);
			request.courses = JSON.stringify(courses);
			target = 'select#student';
			$("select#tp_id").attr('disabled', 'disabled');			
			break;
		case "student":
			students = $(select).val();
			url += "/grades";
			request.tps = JSON.stringify(tps);
			request.courses = JSON.stringify(courses);
			request.students = JSON.stringify(students);
			target = 'fieldset';
			$("select#course").attr('disabled', 'disabled');			
			break;
	}
	$(target).parent().addClass("processing");
	$(target).html('');

	$.ajax({
		type: "POST",
		url: url,
		data: request
	}).done(function(data) {
		var items = [];
		$.each(data, function() {
			$.each(this, function(id, name) {
				if ($("option[value='" + id + "']").size() == 0) {
					items.push('<option value="' + id + '">' + name + '</option>');
				}
			});
		});
		if (target != "fieldset" && $(items).size()) {
			$(target).html(items.join("\n"));
		}
	})
	.done(function() { $(target).parent().addClass("active"); })
	.fail(function() { alert('no data available'); });
}

function getGradeData(formObj) {
	students = $("select#student").val();
	var url = "/tusk/grade/getData/" + encodeURI($("input[name=school_id]").val()) + "/grades";
	var request = {};
	request.tps = JSON.stringify(tps);
	request.courses = JSON.stringify(courses);
	request.students = JSON.stringify(students);
	switch(formObj.get(0).type) {
		case "select-multiple":
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				generateDataTable(data);
			})
			.done(function() { $("select#course").attr('disabled', 'disabled'); })
			.fail(function() { alert('no grade data available'); });
			break;
	}
}

function generateDataTable(data) {
	$("table.data").html();
	var headers = '<tr class="header"><th class="header-left">Student</th>';
	var rows = '</tr>'
	var counter = 0;
	$.each(students, function(index, user_id) {
		rows += "<tr class='" + ((counter%2 == 0)? "even" : "odd" ) + "'>";
		rows += "<td class='line-left'>" + $("option[value='" + user_id + "']").text() + "</td>";
		$.each(data, function(tp_id, course_ids) {
			$.each(course_ids, function(course_id, user_ids) {
				if (data[tp_id][course_id]) {
					// make header row
					if (!counter) {
						headers += "<th class='header-left'>" + $("option[value='" + course_id + "']").text() + "<br/>" + $("option[value='" + tp_id + "']").text().replace(/\(.*\)/,'') + "</th>";
					}
					// made grade cell
					rows += "<td class='line-center'>"
					if (data[tp_id][course_id][user_id]) {
						rows += data[tp_id][course_id][user_id];
					}
					rows += "</td>";
				}
			});
		});
		rows += "</tr>";
		counter++;
	});
	$("table.data").html(headers + rows).show();
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