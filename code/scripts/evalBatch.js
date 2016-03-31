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


var xRequest = null;
var containerDiv;
var create_by = '';
var tp_id = 0;

// take form inputs and make AJAX request for course info
function requestCourses(tp_field, url, school, create_by_field) {
	var i = 0;

	// do not update the course list when selecting additional time periods
	for (i = 0; i < tp_field.length; i++) {
		if (tp_field[i].selected && tp_field[i].value == tp_id) {
			return;
		}
	}

	// clear display
	$("#coursesInstruction").html("").hide();
	removeAllRows();

	// make the AJAX request
	tp_id = tp_field.value;
	if (tp_id) {
		$("#coursesInstruction").html("<p class='xsm'>please wait <img src='/graphics/icons/waiting_bar.gif' /></p>").show();
		for (i = 0; i < create_by_field.length; i++) {
			if (create_by_field[i].checked) {
				create_by = create_by_field[i].value;
				break;
			}
		}
		xRequest = new initXMLHTTPRequest();
		if (xRequest) {
			var params = 'time_period_id=' + tp_id + '&school=' + school + '&create_by=' + create_by;
			xRequest.open("POST", url, true);
			xRequest.onreadystatechange = showCourses;
			xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			xRequest.send(params);
		}
	}
}

// get course info from XML
function showCourses() {
	if (xRequest.readyState == 4) {
		var response = xRequest.responseXML;
		if (response) {
			var courses = response.getElementsByTagName('course');
			containerDiv = $("#coursesInner");

			if (courses.length == 0) {
				printNoResults();
			} else {
				printCourses(courses);
			}
		}
	}
}

// display course options in multi-select drop down
function printCourses(courses) {
	$(containerDiv).append('<select multiple="multiple" id="courses" name="courses">');
	var option, value, name;
	var label = "";
	$(courses).each(function() {
		value = 'course_id=' + $(this).attr('id');
		name = $(this).attr('title');
		if ($(this).attr('code')) {
			value += '&course_code=';
			value += escape($(this).attr('code'));
		}
		if ($(this).attr('teaching_site')) {
			value += '&teaching_site=';
			value += escape($(this).attr('teaching_site'));
			name += " - ";
			name += $(this).attr('teaching_site');
			label = "/site(s)";
		}
		if ($(this).attr('teaching_site_id')) {
			value += '&teaching_site_id=';
			value += $(this).attr('teaching_site_id');
			label = "/site(s)";
		}
		if ($(this).attr('faculty_names')) {
			value += '&faculty_names=';
			value += escape($(this).attr('faculty_names'));
		}
		value += "&course_title=";
		value += escape(name);
		option = '<option value="' + value + '"';
		if ($(this).attr('eval_exists') < 1) {
			option += ' selected="selected"';
		}
		option += '>';
		option += name;
		option += '</option>';
		$("#courses").append(option);
	});
	$(containerDiv).append('<input type="button" value="Select All" id="selectallbutton" onclick="selectAll(this.form.courses)" class="formbutton" />');
	$("#coursesInstruction").html('<br>Please select the course(s)' + label + ' for which you would like to generate evaluations: <span style="font-size:80%;color:red">*</span><ul class="xsm"><li>All eligible courses (students are enrolled in the selected time period and the course does not already have an associated evaluation)<br>are selected by default and displayed first.</li><li>Courses with existing evaluations can also be selected.</li></ul>').show();
	$(containerDiv).show();
}

function printNoResults() {
	var label = "";
	if (create_by == "course_site") {
		label = "/sites";
	}
	$("#coursesInstruction").html("<p>No available courses" + label + " for selected time period.</p>").show();
	$(containerDiv).show();
}

function removeAllRows() {
	$("#courses").remove();
	$("#selectallbutton").remove();
}

// validation for batch evaluation creation form
function verifyCreateByPeriod(formObj) {
	var msg = '';
	var create_by;

	if (multipleIsBlank(formObj.create_by)) {
		msg += "Please select whether to create evaluations by course or course and teaching site combination.\n";
	}

	if (isBlank(formObj.time_period_id)) {
		msg += "Please select a time period.\n";
	}

	if (formObj.courses == null || multipleIsBlank(formObj.courses)) {
		msg += "Please select at least one course.\n";
	}

	if (isBlank(formObj.title) && multipleIsBlank(formObj.t_cn) && multipleIsBlank(formObj.t_tp) && multipleIsBlank(formObj.t_ay) && multipleIsBlank(formObj.t_ts) && multipleIsBlank(formObj.t_faculty)) {
		msg += "Please put in a value for the Eval title.\n";
	}

	if (isBlank(formObj.available_date)) {
		msg += "Please enter a valid available date.\n";
	}

	if (isBlank(formObj.due_date)) {
		msg += "Please enter a valid due date.\n";
	}

	if (msg) {
		alert(msg);
		return false;
	}

	return true;
}

function selectAll(formElement) {
	for (var i = 0; i < formElement.options.length; i++) {
		if (!formElement.options[i].selected) {
			formElement.options[i].selected = true;
		}
	}
	formElement.focus();
}
