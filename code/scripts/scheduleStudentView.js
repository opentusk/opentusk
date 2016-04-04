var currentRowIndex = 0;
var currentTimePeriod;
var currentTeachingSite; 
var addRequested = false;
var noteTakingInProgress = false;
var noteSavingWarning = 'Please finish saving your current note.';
var currentNoteColumnBackgroundColor = '';

function setCourse(rowIndex)
{
	currentRowIndex = rowIndex;
	constructDropdowns();
}

function setIndex(rowIndex)
{
	currentRowIndex = rowIndex;
}

function saveNote(current)
{	
	$(current).closest('tr').prev('tr').find('div#note').show();
	$(current).closest('tr').prev('tr').find("td:nth-child(8)").css( "background-color", currentNoteColumnBackgroundColor);
	$(current).closest('tr').prev('tr').find("td:nth-child(8)").css( "border", "none");
	$.ajax({
		url: "/tusk/schedule/clinical/admin/ajax/note/input",
		data: {
			note: ($("#saveNote").closest('tr').find('textarea#note'))[0].value,
			user_id: user_id,
			course_id: $("#saveNote").closest('tr').prev('tr').find('span#courseId').text(),
			school_id: school_id,
		}, dataType: "json",
		statusCode: {
			404: function () {
			},
			500: function () {
			},
		}
	}).done(function() {
	}).error(function() {
		alert("An error occured during the note input process.");
	}).success(function(data, status) {
		if (data['status'] == 'ok') {
			$("div#note").each(function() {
				if ($("#saveNote").closest('tr').prev('tr').find('span#courseId').text() == 
					$(this).closest('tr').find('span#courseId').text()){
					updateNotePlaceholder(this);
				}
			});
			$("#noteRow").remove();
		} else {
			alert(data['status']);
		}
	});
	noteTakingInProgress = false;
}

function updateNotePlaceholder(noteRow)
{
	$.ajax({
		url: "/tusk/schedule/clinical/admin/ajax/note/addedit",
		data: {
			user_id: user_id,
			school_id: school_id,
			course_id: $(noteRow).closest('tr').find('span#courseId').text(),
		}, dataType: "json",
		statusCode: {
			404: function () {
			},
			500: function () {
			},
		}
	}).done(function() {
	}).error(function() {
		alert("An error occured during the note placeholder update process.");
	}).success(function(data, status) {
		var notePlaceholder = $.parseHTML($.trim(data['placeholder']));
		$("a#placeholder", $(noteRow)).html(notePlaceholder);
	});
}

function cancelNote(current)
{
	$(current).closest('tr').prev('tr').find('div#note').show();
	$(current).closest('tr').prev('tr').find("td:nth-child(8)").css( "background-color", currentNoteColumnBackgroundColor);
	$(current).closest('tr').prev('tr').find("td:nth-child(8)").css( "border", "none");
	$("#noteRow").remove();
	noteTakingInProgress = false;
}

function constructDropdowns()
{
	$.ajax({
		url: "/tusk/schedule/clinical/admin/ajax/dropdown",
		data: {
			school_id: school_id,
			row_index: currentRowIndex,
			temp_teaching_site: $('span#alreadyEnrolledNumber0').closest('tr').find('div#teachingSite').find('select.view').val(),
			requested_course_id: $('span#alreadyEnrolledNumber0').closest('tr').find('div#course').find('select.view').val(),
			temp_time_period: $('span#alreadyEnrolledNumber0').closest('tr').find('div#timePeriod').find('select.view').val(),
		}, dataType: "json",
		statusCode: {
			404: function () {
			},
			500: function () {
			},
		}
	}).done(function() {
	}).error(function() {
		alert("An error occured during the dropdown construction process.");
	}).success(function(data, status) {
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#teachingSite').empty();
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#teachingSite').append(data['teachingsite']);
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#timePeriod').empty();
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#timePeriod').append(data['timeperiod']);
	});
}

$(document).ready(function() {
	var modificationInProgress = false;
	var currentBackgroundColor;
	$('div#timePeriod, div#teachingSite').change(function() {
		if ($(this).closest('tr').find('div#timePeriod').find('select.view').val() < 0 || 
			$(this).closest('tr').find('div#teachingSite').find('select.view').val() < 0 ||
			$(this).closest('tr').find('div#course').find('select.view').val() < 0) {
			$(this).closest('tr').find('span#alreadyEnrolled').hide();
			return;
		} else {
			$(this).closest('tr').find('span#alreadyEnrolled').show();
			$.ajax({
				url: "/tusk/schedule/clinical/admin/ajax/enrollmentcheck",
				data: {
					temp_time_period: $(this).closest('tr').find('div#timePeriod').find('select.view').val(),
					temp_teaching_site: $(this).closest('tr').find('div#teachingSite').find('select.view').val(),
					school_id: school_id,
					course_id: addRequested ? $(this).closest('tr').find('div#course').find('select.view').val() : $(this).closest('tr').find('span#courseId').text(),
				}, dataType: "json",
					statusCode: {
						404: function () {
							alert('Page not found');
						},
						500: function () {
							alert('Internal server error');
						},
					}
			}).done(function() {
			}).error(function() {
					alert("An error occured during the deletion process");
			}).success(function(data, status){
				if (data['number_of_enrolled'] != -1) {
					$('span#alreadyEnrolledNumber' + currentRowIndex).text(data['number_of_enrolled']);
				}
				else {
					alert('The number of students for the current time period and teaching site selection couldn\'t be fetched');
				}
			});
		}
		return;
	});

	$("a#placeholder").click(function() {
		if (noteTakingInProgress) {	
			alert(noteSavingWarning);
			return;
		}
		$(this).closest('tr').find('div#note').hide();
		noteTakingInProgress = true;
		var noteRow = document.createElement('tr');
		var note = document.createElement('textarea');
		var noteColumn = document.createElement('td');
		var buttons = document.createElement('span');
		var saveNoteButton = document.createElement('a');
		var cancelNoteButton = document.createElement('a');
		var littleSpacing = document.createElement('span');
		var noteContent = '';
		var breakElement = document.createElement('br');
		var noteColumnContent = document.createElement('div');

		$.ajax({
			url: "/tusk/schedule/clinical/admin/ajax/note/content",
			cache: false,
			data: {
				user_id: user_id,
				school_id: school_id,
				course_id: $(this).closest('tr').find('span#courseId').text(),
			}, dataType: "json",
			statusCode: {
				404: function () {
				},
				500: function () {
				},
			}
		}).done(function() {
		}).error(function() {
			alert("An error occured during the note retrieval process.");
		}).success(function(data, status) {
			if (data.status == 'ok') 
				note.innerHTML = data['content'];
		});
		noteColumnContent.setAttribute("id", "noteColumnContent");
		buttons.setAttribute("id", "saveCancelNote");
		buttons.setAttribute("style", "cursor: pointer;");
		saveNoteButton.setAttribute("id", "saveNote");
		saveNoteButton.setAttribute("onclick", "saveNote(this)");
		saveNoteButton.setAttribute("class", "navsm");
		saveNoteButton.innerHTML = "Save";
		cancelNoteButton.setAttribute("id", "cancelNote");
		cancelNoteButton.setAttribute("onclick", "cancelNote(this)");
		cancelNoteButton.setAttribute("class", "navsm");
		cancelNoteButton.innerHTML = "Cancel";
		littleSpacing.setAttribute("id", "littlespacing");
		littleSpacing.innerHTML = " | ";

		note.setAttribute("id", "note");
		note.setAttribute("rows", 10);
		note.setAttribute("cols", 30);
		noteColumn.setAttribute("colspan", 1);

		for (var i = 0; i < 7; i++) {
			var td = document.createElement('td');
			noteRow.appendChild(td);
		}

		buttons.appendChild(saveNoteButton);
		buttons.appendChild(littleSpacing);
		buttons.appendChild(cancelNoteButton);
		noteColumnContent.appendChild(buttons);
		noteColumnContent.appendChild(note);
		noteColumn.appendChild(noteColumnContent);
		noteRow.appendChild(noteColumn);
		noteRow.setAttribute("class", $(this).closest('tr').attr("class"));
		noteRow.setAttribute("id", "noteRow");
		$(this).closest('tr').after(noteRow);
		// $("#noteRow").closest('tr').css( "background-color", "rgba(189, 178, 202, 0.44)" );
		var abovePosition = $("#noteRow").closest('tr').prev('tr').find("td:nth-child(8)").position();
		var belowPosition = $("#noteRow").closest('tr').find("td:nth-child(8)").position();
		noteColumnContent.style.marginTop = "-" + (belowPosition.top - abovePosition.top - 7) + "pt";
		currentNoteColumnBackgroundColor = $("#noteRow").closest('tr').prev('tr').find("td:nth-child(8)").css("background-color");
		$("#noteRow").closest('tr').prev('tr').find("td:nth-child(8)").css( "background-color", "rgba(189, 178, 202, 0.44)" );
		$("#noteRow").closest('tr').prev('tr').find("td:nth-child(8)").css({"border-top-color": "rgba(189, 178, 202, 0.44)", 
             "border-left-color": "rgba(189, 178, 202, 0.44)",
             "border-right-color": "rgba(189, 178, 202, 0.44)",
             "border-top-weight":"3px", 
             "border-right-weight":"3px",
             "border-left-weight":"3px",
             "border-top-style":"solid",
             "border-right-style":"solid",
             "border-left-style":"solid"
         });
		$("#noteRow").closest('tr').find("td:nth-child(8)").css( "background-color", "rgba(189, 178, 202, 0.44)" );
		$("#noteRow").closest('tr').find("td:nth-child(8)").css({"border-bottom-color": "rgba(189, 178, 202, 0.44)", 
             "border-left-color": "rgba(189, 178, 202, 0.44)",
             "border-right-color": "rgba(189, 178, 202, 0.44)",
             "border-bottom-weight":"3px", 
             "border-right-weight":"3px",
             "border-left-weight":"3px",
             "border-bottom-style":"solid",
             "border-right-style":"solid",
             "border-left-style":"solid"
         });
	});

	$("td #modify").click(function() {
		if (modificationInProgress)
		{	
			alert('Please finish your current modifications.');
			return;
		}
		$(this).closest('tr').find('div#teachingSite').find('select.view').trigger('change');
		modificationInProgress = true;
		if ($(this).closest('tr').find('div#timePeriod').is(":visible"))
		{
			$(this).closest('tr').find('div#teachingSite').hide();
			$(this).closest('tr').find('div#timePeriod').hide();
			$(this).closest('tr').find('a#save').hide();
			$(this).closest('tr').find('a#cancel').hide();
			$(this).closest('tr').find('a#delete').hide();
		}
		else
		{
			currentTimePeriod = $(this).closest('tr').find('span#currentTimePeriodId').text();
			currentTeachingSite = $.trim($(this).closest('tr').find('span#currentTeachingSiteId').text()) == '' ? 0 : $(this).closest('tr').find('span#currentTeachingSiteId').text();
			$(this).closest('tr').find('div#timePeriod').show();
			$(this).closest('tr').find('div#teachingSite').show();
			$(this).closest('tr').find('div#course').show();
			$(this).closest('tr').find('a#save').show();
			$(this).closest('tr').find('a#cancel').show();
			$(this).closest('tr').find('a#delete').show();
			$(this).closest('tr').find('span.littlespacing').show();
			$(this).closest('tr').find('div#modify').hide();
			$(this).closest('tr').find('span#currentTimePeriod').hide();
			$(this).closest('tr').find('span#currentTeachingSite').hide();
			currentBackgroundColor = $(this).closest('tr').css("background-color");
			$(this).closest('tr').css( "background-color", "rgba(250, 181, 139, 0.39)" );
		}
		return;
	});

	$("a#delete").click(function() {
		if (noteTakingInProgress)
		{	
			alert(noteSavingWarning);
			return;
		}
		var deleteValidate = confirm("Are you sure you want to remove the student from the rotation?");
		if (deleteValidate == true) {
			$.ajax({
				url: "/tusk/schedule/clinical/admin/ajax/modification",
				data: {
					user_id: user_id,
					course_id: $(this).closest('tr').find('span#courseId').text(),
					current_time_period: currentTimePeriod,
					current_teaching_site: currentTeachingSite,
					school_id: school_id,
					delete_requested: 1
				}, dataType: "json",
					statusCode: {
						404: function () {
							alert('Page not found');
						},
						500: function () {
							alert('Internal server error');
						},
					}
			}).done(function() {
			}).error(function() {
				alert("An error occured during the deletion process");
			}).success(function(data, status){
				if (data['applied'] != 'ok') {
					alert('Student wasn\'t removed from the requested rotation: ' + data['applied'] + '.');
				}
				else {
					alert('Student was removed from the requested rotation.');
					location.reload();
				}
			});
			return;
		} else {
			return;
		}
	});

	$("a#save").click(function() {
		if (noteTakingInProgress)
		{	
			alert(noteSavingWarning);
			return;
		}
		//store the value and wait for the Ajax request result status
		var tempTimePeriod = $(this).closest('tr').find('div#timePeriod').find('select.view').val(); 
		var tempTeachingSite = $(this).closest('tr').find('div#teachingSite').find('select.view').val(); 

		var errorMessage = 'Please make a selection in the following drop down list(s): \n';
		var showErrorMessage = 0;
		if (addRequested && $(this).closest('tr').find('div#course').find('select.view').val() < 0)
		{
			errorMessage += '\nCourse';
			showErrorMessage = 1;
		} 
		if (tempTimePeriod < 0) {
			errorMessage += '\nTime Period';
			showErrorMessage = 1;
		} 
		if (tempTeachingSite < 0)
		{
			errorMessage += '\nTeaching Site';
			showErrorMessage = 1;
		} 

		if (showErrorMessage)
		{	
			showErrorMessage = 0;
			alert(errorMessage);
		} else {
			$.ajax({
				url: "/tusk/schedule/clinical/admin/ajax/modification",
				data: {
					user_id: user_id,
					course_id: addRequested ? $(this).closest('tr').find('div#course').find('select.view').val() : $(this).closest('tr').find('span#courseId').text(),
					current_time_period: currentTimePeriod,
					current_teaching_site: currentTeachingSite,
					requested_time_period: tempTimePeriod,
					requested_teaching_site: tempTeachingSite,
					school_id: school_id,
					add_requested: addRequested ? 1 : 0,
				},
				dataType: "json",
				statusCode: {
					404: function () {
						alert('Page not found');
					},
					500: function () {
						alert('Internal server error');
					},
				}
			}).done(function() {
			}).error(function() {
				alert("An error occured during the modification process.");
			}).success(function(data, status){
				if (data['applied'] != 'ok') {
					alert(addRequested ? 'There was a problem adding the rotation to the student\'s schedule: ' + data['applied']: 'There was a problem saving the selected time period and teaching site: ' + data['applied']);
				}
				else {
					currentTimePeriod = tempTimePeriod;
					currentTeachingSite = tempTeachingSite;
					alert(addRequested ? 'The rotation was added to the student\'s schedule.' : 'The time period and teaching site change took place.');
					location.reload();
				}
			});
		}
		return;
	});
	$("a#cancel").click(function() {
		modificationInProgress = false;
		$(this).closest('tr').find('div#timePeriod').find('select.view').val($.trim(currentTimePeriod));
		$(this).closest('tr').find('div#teachingSite').find('select.view').val($.trim(currentTeachingSite));
		$(this).closest('tr').find('div#teachingSite').hide();
		$(this).closest('tr').find('div#timePeriod').hide();
		$(this).closest('tr').find('div#course').hide();
		$(this).closest('tr').find('a#save').hide();
		$(this).closest('tr').find('a#cancel').hide();
		$(this).closest('tr').find('a#delete').hide();
		$(this).closest('tr').find('span#alreadyEnrolled').hide();
		$(this).closest('tr').find('span.littlespacing').hide();
		$(this).closest('tr').find('div#modify').show();
		$(this).closest('tr').find('span#currentTimePeriod').show();
		$(this).closest('tr').find('span#currentTeachingSite').show();
		$(this).closest('tr').css( "background-color", currentBackgroundColor);
		$('span#alreadyEnrolledNumber0').closest('table').hide();
		addRequested = false;
	});
	$('div.gCMSButtonRow').find('a').click(function() {
		if (modificationInProgress)
		{	
			alert('Please finish your current modifications.');
			return;
		}
		modificationInProgress = true;
		addRequested = true;
		$('span#alreadyEnrolledNumber0').closest('table').show(); //Index zero refers to the addition row
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#course').find('select.view').val(-1); 
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#timePeriod').find('select.view').val(-1); 
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#teachingSite').find('select.view').val(-1);
		currentBackgroundColor = $(this).closest('tr').css("background-color");
		$('span#alreadyEnrolledNumber0').closest('tr').css( "background-color", "rgba(250, 181, 139, 0.39)" );
		$('span#alreadyEnrolledNumber0').closest('table').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#teachingSite').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#timePeriod').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('div#course').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('span.littlespacing').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('a#save').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('a#cancel').show();
	});
});