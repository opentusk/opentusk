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


$(document).ready(function() {
	// shared variables
	var tps;
	var courses;
	var students;
	var display;
	var export_file_name;
	
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
	var url = "/admin/grade/gradedata/" + encodeURI($("input[name=school_id]").val());
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
	if (getType() == "statement") {
		request.statement = true;
	}
	$(target).parent().addClass("processing");

	if (target != "fieldset") {
		$.ajax({
			type: "POST",
			url: url,
			data: request
		}).done(function(data) {
			var items = [];	
			$("#export").data("students", data);
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
		}).fail(function() { alert('no data available'); });
	}
	else {
		$(target).parent().addClass("active");
	}
}

function getGradeData(formObj) {
	students = $("select#student").val();
	var url = "/admin/grade/gradedata/" + encodeURI($("input[name=school_id]").val());
	var request = {};
	request.tps = JSON.stringify(tps);
	request.courses = JSON.stringify(courses);
	request.students = JSON.stringify(students);
	if (window.location.pathname.indexOf("statement") > -1) {
		request.statement = true;
	}
	$("div.data").hide();
	$("div.data .data").remove();
	$("div.data").addClass("processing");
	$("div.data").show();

	switch (getType()) {
		case "report":
			url += "/grades";
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				$("#export").attr("disabled", false);				
				$("#export").data("grades", data);				
				generateDataTable(data);
			}).done(function() {
				$("select#course").attr('disabled', 'disabled');
			}).always(function() {
				$("div.data").removeClass("processing");
			}).fail(function() {
				alert('no grade data available'); 
			});
			break;
		case "statement":
			url += "/statement";
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				generateStatementTable(data);
			}).done(function() {
				$("select#course").attr('disabled', 'disabled');
			}).always(function() {
				$("div.data").removeClass("processing");
			}).fail(function() {
				alert('no grade data available'); 
			});
			break;
		case "audit":
			url += "/audit";
			display = $("input[type=radio][name=display]:checked").val();
			request.display = JSON.stringify(display);
			$.ajax({
				type: "POST",
				url: url,
				data: request
			}).done(function(data) {
				generateAuditTrailTable(data);
			}).done(function() {
				$("select#course").attr('disabled', 'disabled'); 
			}).always(function () {
				$("div.data").removeClass("processing"); 
			}).fail(function() {
				alert('no grade data available'); 
			});
			break;
	}
}

function generateDataTable(data) {
	$("#export").css("visibility","visible");
	if (data) {
		var headers = '<tr class="header"><th class="header-left">Student</th>';
		var rows = '</tr>'
		var counter = 0;
		$.each(students, function(index, user_id) {
			rows += "<tr class='" + ((counter % 2 == 0) ? "even" : "odd" ) + "'>";
			rows += "<td class='line-left'>" + abbr($("option[value='" + user_id + "']").text()) + "</td>";
			$.each(data, function(tp_id, course_ids) {
				$.each(course_ids, function(course_id, user_ids) {
					if (data[tp_id][course_id]) {
						// make header row
						if (!counter) {
							var course_title = $("option[value='" + course_id + "']").text();
							headers += "<th class='header-left'>" + abbr(course_title) + "<br/><span class='gray'>" + abbr($("option[value='" + tp_id + "']").text().replace(/\(.*\)/,'')) + "</span></th>";
						}
						// make grade cell
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
		$("div.data").html($("div.data").html() + "<table class='tusk data' cellspacing='0'>" + headers + rows + "</table>");
	}
	else {
		$("div.data").html($("div.data").html() + "<table class='tusk data' cellspacing='0'><tr><td>No grades found.</td></tr></table>");
	}
}

function generateStatementTable(data) {
	if (data) {
		var html = '';
		$.each(data, function(tp_id, course_ids) {
			$.each(course_ids, function(course_id, events) {
				var counter = 0;
				var course_title = $("option[value='" + course_id + "']").text();
				html += "<h2 class='data'>" + course_title + "<br>";
				html += "<span class='gray'>" + $("option[value='" + tp_id + "']").text() + "</span></h2>";
				html += "<table class='tusk data' cellspacing='0'><tr class='header'>";
				html += "<th class='header-left' style='width:150px'>Grade Event</th>";
				$.each(students, function(index, user_id) {
					html += "<th class='header-left'>" + abbr($("option[value='" + user_id + "']").text()) + "</th>";
				});
				html += "</tr>";
				if (events["events"]) {
					$.each(events["events"], function(category_order, category_ids) {
						$.each(category_ids, function(category_id, sort_orders) {
							$.each(sort_orders, function(sort_order, event_ids) {
								$.each(event_ids, function(event_id, event_name) {
									html += "<tr class='" + ((counter % 2 == 0) ? "even" : "odd" ) + "'>";
									html += "<td class='line-left'>" + abbr(event_name) + "</td>"; 
									// make grade cells
									$.each(students, function(index, user_id) {
										html += "<td class='line-center'>";
										if (events["grades"] && events["grades"][event_id] && events["grades"][event_id][user_id]) {
											html += events["grades"][event_id][user_id];
										}
										html += "</td>";
									});
									html += "</tr>";
									counter++;
								});
							});
						});
					});
				}
				html += "</table>";
			});
		});
		$("div.data").html($("div.data").html() + html);
	}
	else {
		$("div.data").html($("div.data").html() + "<table class='tusk data' cellspacing='0'><tr><td>No grades found.</td></tr></table>");
	}
}

function generateAuditTrailTable(data) {
	var arr1 = students;		// data{$user_id}{$time_period_id}{$course_id}
	var arr2 = tps;
	var arr3 = courses;
	var title = 'Course';

	if (display == "tp_id") {  	// data{$time_period_id}{$course_id}{$user_id}
		arr1 = tps;
		arr2 = courses;
		arr3 = students;
		title = 'Student';
	} else if (display == "course") {  // data{$course_id}{$time_period_id}{$user_id}
		arr1 = courses;
		arr2 = tps;
		arr3 = students;
		title = 'Student';
	}

	var html = '';
	$.each(arr1, function(id1, val1) {
		html += "<h1 class='data'>" + $("option[value='" + val1 + "']").text() + "</h1>";	
		if (typeof(data[val1]) != 'undefined') {
			$.each(arr2, function(id2, val2) {
				var rows = '';
				var total_cols = 1;
				if (typeof(data[val1][val2]) != 'undefined') {
					$.each(arr3, function(id3, val3) {
						if (typeof(data[val1][val2][val3]) != 'undefined') {
							rows += "<tr><td class='line-left cellpad'>" + $("option[value='" + val3 + "']").text() + "</td>";
							var cols = 1;
							$.each(data[val1][val2][val3], function(id4, history) {
								rows += "<td class='line-left'><b>" 
							     	+ history.grade + "</td><td class='line-left cellpad'> &nbsp;</b><span class='xsm'>(<em>By:</em> " + history.modified_by 
								+ " &nbsp; <em>On:</em> " + history.modified_on + ")</span></td>";
							cols += 2;
							if (cols > total_cols) {
								total_cols = cols;
							}
							});
							rows += "</tr>";
						}
					});

					html += "<h2 class='data'>" + $("option[value='" + val2 + "']").text() + "</h2>";	
					html += '<table class="data tusk audit" cellspacing="0">';
					html += '<tr class="header"><th class="header-left">' + _(title) + '</th><th class="header-center" colspan="' + total_cols + '">Grade History</th>'  + "</tr>" + rows + '</table>';
				}
			});
		}
	});
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

// get type from the page address
function getType() {
	var path = window.location.pathname.split('/');
	return path[3];
}

// abbreviate long strings
function abbr(text) {
	if (text.length > 20) {
		text = "<span style='cursor:pointer' title='" + text + "'>" + text.substring(0, 19) + "&hellip;</span>";
	}
	return text;
}
