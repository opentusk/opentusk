var currentRowIndex = 0;
var currentTimePeriod;
var currentTeachingSite; 
var addRequested = false;
var assessmentMoveRequested = false;
var noteTakingInProgress = false;
var noteSavingWarning = 'Please finish your note modifications first.';
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

function changeDefaultText(note) {
	if (note.value === note.defaultValue) {
		note.value = '';
	}
}

function loadJS() {
	var head= document.getElementsByTagName('head')[0];
	var script= document.createElement('script');
	script.type= 'text/javascript';
	script.src= '/scripts/noteOverlay.js';
	head.appendChild(script);
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
			$("span#placeholder", $(noteRow)).html(notePlaceholder);
			loadJS();
		});
	}

	$("span#placeholder").click(function(){
		if ($(this).closest('tr').find("a#noteHistoryPlaceholder").length) {
			if (noteTakingInProgress) {	
				return;
			}
			createNotePlaceholderTrigger(this);
			$("a#cancelNoteTrigger").click(function() {
				$(this).closest('tr').find('#noteHistoryColumnContent').remove();
			});
			$(this).closest('tr').find('#noteActions').remove();
		}
	});

	$("a#createNotePlaceholder").click(function() {
		createNotePlaceholderTrigger(this);
	});

	function createNotePlaceholderTrigger(createNotePlaceholder) {
		if (noteTakingInProgress) {	
			alert(noteSavingWarning);
			return;
		}
		$(createNotePlaceholder).closest('td').css("text-align", "center");
		$(createNotePlaceholder).closest('tr').find('span#placeholder').hide();
		$(createNotePlaceholder).closest('tr').find('a#saveNoteTrigger').show();
		$(createNotePlaceholder).closest('tr').find('span.littlespacing#noteLineSeperator').show();
		$(createNotePlaceholder).closest('tr').find('a#cancelNoteTrigger').show();
		var noteBoxHolder = document.createElement('div');
		noteBoxHolder.setAttribute("id", "noteBoxHolder");
		var noteBox = document.createElement('div');
		noteBox.setAttribute("id", "noteBox");
		var note = document.createElement('textarea');
		$(noteBox).append(note);
		$(noteBoxHolder).append(noteBox);
		note.setAttribute("id", "note");
		note.setAttribute("rows", 10);
		note.setAttribute("cols", 23);
		note.defaultValue = 'Please add your note here..';
		note.setAttribute("onfocus", "changeDefaultText(this)");
		$(createNotePlaceholder).closest('tr').find("div#note").append(noteBoxHolder);
		noteTakingInProgress = true;
	}

	

	$("td #modify").click(function() {
		if (modificationInProgress)
		{	
			alert('Please finish your current modifications.');
			return;
		}
		$(this).closest('tr').find('div#assessmentTimePeriod').show();
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
			$(this).closest('tr').find('span.littlespacing#modifyLineSeperator').show();
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

	$("a#cancelNoteTrigger").click(function() {
		$(this).closest('td').css("text-align", "inherit");
		$(this).closest('tr').find('span#placeholder').show().children().show();
		$(this).closest('tr').find('textarea#note').remove();
		$(this).closest('tr').find('span.littlespacing#noteLineSeperator').hide();
		$(this).closest('tr').find('a#saveNoteTrigger').hide();
		$(this).closest('tr').find('a#cancelNoteTrigger').hide();
		noteTakingInProgress = false;
	});

	$("a#saveNoteTrigger").click(function() {
		$(this).closest('td').css("text-align", "inherit");
		$(this).closest('tr').find('span#placeholder').show();
		var currentCourseId = $(this).closest('tr').find('span#courseId').text();

		$(this).closest('tr').find("td:nth-child(8)").css( "background-color", currentNoteColumnBackgroundColor);
		$(this).closest('tr').find("td:nth-child(8)").css( "border", "none");
		$.ajax({
			url: "/tusk/schedule/clinical/admin/ajax/note/input",
			data: {
				note: ($(this).closest('tr').find('textarea#note'))[0].value,
				user_id: user_id,
				course_id: $(this).closest('tr').find('span#courseId').text(),
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
					if (currentCourseId == $(this).closest('tr').find('span#courseId').text()){
						updateNotePlaceholder(this);
					}
				});
			} else {
				alert(data['status']);
			}
		});
		$(this).closest('tr').find('textarea#note').remove();
		$(this).closest('tr').find('div#noteHistoryColumnContent').remove();
		$(this).closest('tr').find('span.littlespacing#noteLineSeperator').hide();
		$(this).closest('tr').find('a#saveNoteTrigger').hide();
		$(this).closest('tr').find('a#cancelNoteTrigger').hide();
		noteTakingInProgress = false;
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
		var assessmentMoveRequested = ($(this).closest('tr').find('input[type="checkbox"]').prop("checked") == true) 
			? 1 : 0;
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
					assessment_move_requested: assessmentMoveRequested ? 1 : 0
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
					alert(addRequested ? 'There was a problem adding the rotation to the student\'s schedule: ' + data['applied']: 
						(assessmentMoveRequested ? 'There was a problem saving the selected time period and teaching site as well as moving the assessment: ' 
							+ data['applied']
							: 'There was a problem saving the selected time period and teaching site: ' + data['applied']));
				}
				else {
					currentTimePeriod = tempTimePeriod;
					currentTeachingSite = tempTeachingSite;
					alert(addRequested ? 'The rotation was added to the student\'s schedule.' : 
						(assessmentMoveRequested ? 'The time period and teaching site change took place. The assessment was moved as well.' 
							: 'The time period and teaching site change took place.'));
					location.reload();
				}
			});
		}
		return;
	});
	$("a#cancel").click(function() {
		modificationInProgress = false;
		$(this).closest('tr').find('div#assessmentTimePeriod').hide();
		$(this).closest('tr').find('div#timePeriod').find('select.view').val($.trim(currentTimePeriod));
		$(this).closest('tr').find('div#teachingSite').find('select.view').val($.trim(currentTeachingSite));
		$(this).closest('tr').find('div#teachingSite').hide();
		$(this).closest('tr').find('div#timePeriod').hide();
		$(this).closest('tr').find('div#course').hide();
		$(this).closest('tr').find('a#save').hide();
		$(this).closest('tr').find('a#cancel').hide();
		$(this).closest('tr').find('a#delete').hide();
		$(this).closest('tr').find('span#alreadyEnrolled').hide();
		$(this).closest('tr').find('span.littlespacing#modifyLineSeperator').hide();
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
		$('span#alreadyEnrolledNumber0').closest('tr').find('span.littlespacing#modifyLineSeperator').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('a#save').show();
		$('span#alreadyEnrolledNumber0').closest('tr').find('a#cancel').show();
	});
});