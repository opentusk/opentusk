$(document).ready(function(){
	// shared variables
	var tps;
	var courses;
	var students;
	var display;
	
	// event handlers for form inputs
	$("nav .filter select").on('change', function() {
		if ($(this).val()) {
			populateNextOptions($(this));
		}
	});
	$("nav .getgradedata select, nav input[type=radio]").on('change', function() {
		if ($(this).val()) {
			getGradeData($(this));
		}
	});
	
	// functionality for 'reset' buttons
	$("input.reset").click(function() {
		var select = $(this).parent().siblings("select");
		$("div.processing").removeClass("processing");
		$("div.data").hide();
		$("div.data table").html('');
		if ($(select).val()) {
			deselectAll($(select));
			switch ($(select).attr("id")) {
				case "tp_id":
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					students = '';
					$("select#course").parent().removeClass("active");
					deselectAll($("select#course"));
					courses = '';
					break;
				case "course":
					$("fieldset.radio").parent().removeClass("active");
					$("fieldset.radio input").prop("checked", false);
					$("select#student").parent().removeClass("active");
					deselectAll($("select#student"));
					students = '';
					break;
				case "student":
					$("fieldset.radio").parent("div").removeClass("active");
					$("fieldset.radio input").attr("checked", false);
					break;
			}
		}
	});
	
	// functionality for 'select all' buttons
	$("input.all").click(function() {
		var select = $(this).parent().parent().children("select");
		if (!$(select).attr('disabled')) {
			selectAll($(select));
			$(select).trigger('change');
		}
	});

	// populate timestamp on page
	var d = new Date();
	var curr_date = d.getDate();
	var curr_month = d.getMonth();
	curr_month++;
	var curr_year = d.getFullYear();
	$(".timestamp").html("<p>as of " + curr_month + "/" + curr_date + "/" + curr_year + "</p>");
});

function populateNextOptions(select) {
	var url = "/tusk/grade/gradedata/" + encodeURI($("input[name=school_id]").val());
	var request = {};
	$("fieldset.radio input").prop("checked", false);
	$("div.data table").html('');
	$("div.data").hide();
	switch ($(select).attr("name")) {
		case "tp_id":
			tps = $(select).val();
			url += "/courses";
			request.tps = JSON.stringify(tps);
			target = 'select#course';
			$(target).html('');
			break;
		case "course":
			courses = $(select).val();
			url += "/students";
			request.tps = JSON.stringify(tps);
			request.courses = JSON.stringify(courses);
			target = 'select#student';
			$(target).html('');
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

	if (target != "fieldset") {
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
			$(target).parent().addClass("active");
		})
		.fail(function() { alert('no data available'); });
	}
	else {
		$(target).parent().addClass("active");
	}
}

function getGradeData(formObj) {
	students = $("select#student").val();
	var url = "/tusk/grade/gradedata/" + encodeURI($("input[name=school_id]").val());
	var request = {};
	request.tps = JSON.stringify(tps);
	request.courses = JSON.stringify(courses);
	request.students = JSON.stringify(students);
	$("div.data").hide();
	$("div.data .data").remove();
	$("div.data").addClass("processing");
	$("div.data").show();
	switch(formObj.get(0).type) {
		case "select-multiple":
			url += "/grades";
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				generateDataTable(data);
			})
			.done(function() { $("select#course").attr('disabled', 'disabled'); })
			.always(function () { $("div.data").removeClass("processing"); })
			.fail(function() { alert('no grade data available'); });
			break;
		case "radio":
			url += "/audit";
			display = $("input[type=radio][name=display]:checked").val();
			request.display = JSON.stringify(display);
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				generateAuditTrailTable(data);
			})
			.done(function() { $("select#course").attr('disabled', 'disabled'); })
			.always(function () { $("div.data").removeClass("processing"); })
			.fail(function() { alert('no grade data available'); });
			break;
	}
}

function generateDataTable(data) {
	if(data) {
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
		$("div.data").html($("div.data").html() + '<table class="tusk data" cellspacing="0">' + headers + rows + '</table>');
	}
	else {
		$("div.data").html($("div.data").html() + '<table class="tusk data" cellspacing="0"><tr><td>No grades found.</td></tr></table>');
	}
}

function generateAuditTrailTable(data) {
	var html = '';
	switch(display) {
		case "tp_id":
			// data{$time_period_id}{$course_id}{$user_id}
			$.each(data, function(tp_id, course_ids) {
				html += "<h1 class='data'>" + $("option[value='" + tp_id + "']").text() + "</h1>";	
				$.each(course_ids, function(course_id, user_ids) {
					html += "<h2 class='data'>" + $("option[value='" + course_id + "']").text() + "</h2>";	
					var rows = '';
					html += '<table class="data tusk audit" cellspacing="0">';
					var headers = ['<th class="header-left">Grade History</th>'];
					$.each(user_ids, function(user_id, grades) {
						var prevGrade = '';
						var prevUser = '';
						rows += "<tr>";
						rows += "<td class='layers-left'>" + $("option[value='" + user_id + "']").text() + "</td>";
						var cols = 1;
						$.each(grades, function() {
							rows += "<td class='layers-left'>";
							if (cols > headers.length) {
								headers.push('<th class="header-left">&nbsp;</th>');
							}
							if (this.grade != prevGrade) {
								rows += this.grade + " <em class='xsm'>(" + this.modified_by + " " + this.modified_on + ")</em>";

								prevGrade = this.grade;
								prevUser = this.modified_by;
							}
							cols++;
							rows += '</td>';
						});
						rows += "</tr>";
					});
					html += '<tr class="header"><th class="header-left">' + _('Student') + '</th>' + headers.join(' ') + "</tr>" + rows + '</table>';
				});
			});
			break;
		case "course":
			// data{$course_id}{$time_period_id}{$user_id}
			$.each(data, function(course_id, tp_ids) {
				html += "<h1 class='data'>" + $("option[value='" + course_id + "']").text() + "</h1>";	
				$.each(tp_ids, function(tp_id, user_ids) {
					html += "<h2 class='data'>" + $("option[value='" + tp_id + "']").text() + "</h2>";	
					var rows = '';
					html += '<table class="data tusk audit" cellspacing="0">';
					var headers = ['<th class="header-left">Grade History</th>'];
					$.each(user_ids, function(user_id, grades) {
						var prevGrade = '';
						var prevUser = '';
						rows += "<tr>";
						rows += "<td class='layers-left'>" + $("option[value='" + user_id + "']").text() + "</td>";
						var cols = 1;
						$.each(grades, function() {
							rows += "<td class='layers-left'>";
							if (cols > headers.length) {
								headers.push('<th class="header-left">&nbsp;</th>');
							}
							if (this.grade != prevGrade) {
								rows += this.grade + " <em class='xsm'>(" + this.modified_by + " " + this.modified_on + ")</em>";

								prevGrade = this.grade;
								prevUser = this.modified_by;
							}
							cols++;
							rows += '</td>';
						});
						rows += "</tr>";
					});
					html += '<tr class="header"><th class="header-left">' + _('Student') + '</th>' + headers.join(' ') + "</tr>" + rows + '</table>';
				});
			});
			break;
		case "user":
			// data{$user_id}{$time_period_id}{$course_id}
			$.each(data, function(user_id, tp_ids) {
				html += "<h1 class='data'>" + $("option[value='" + user_id + "']").text() + "</h1>";	
				$.each(tp_ids, function(tp_id, course_ids) {
					html += "<h2 class='data'>" + $("option[value='" + tp_id + "']").text() + "</h2>";	
					var rows = '';
					html += '<table class="data tusk audit" cellspacing="0">';
					var headers = ['<th class="header-left">Grade History</th>'];
					$.each(course_ids, function(course_id, grades) {
						var prevGrade = '';
						var prevUser = '';
						rows += "<tr>";
						rows += "<td class='layers-left'>" + $("option[value='" + course_id + "']").text() + "</td>";
						var cols = 1;
						$.each(grades, function() {
							rows += "<td class='layers-left'>";
							if (cols > headers.length) {
								headers.push('<th class="header-left">&nbsp;</th>');
							}
							if (this.grade != prevGrade) {
								rows += this.grade + " <em class='xsm'>(" + this.modified_by + " " + this.modified_on + ")</em>";

								prevGrade = this.grade;
								prevUser = this.modified_by;
							}
							cols++;
							rows += '</td>';
						});
						rows += "</tr>";
					});
					html += '<tr class="header"><th class="header-left">' + _('Course') + '</th>' + headers.join(' ') + "</tr>" + rows + '</table>';
				});
			});
			break;
	}
	$("div.data").html($("div.data").html() + html);
	$("div.data").show();
}

// functions for select-related buttons
function deselectAll(select) {
	$(select).val(null);
	$(select).removeAttr('disabled');
	$(select).children("option").prop('selected',false);;
	$(select).trigger('change');
}


function selectAll(select) {
	if (!$(select).attr('disabled')) {
		$(select).children("option").prop('selected',true);
	}
}