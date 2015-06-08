var currentRowIndex = 0;

function getRowIndex(rowIndex)
{
	currentRowIndex = rowIndex;
}

$(document).ready(function() {

	var currentTimePeriod;
	var currentTeachingSite; 
	var modificationInProgress = false;

	$('div#timePeriod, div#teachingSite').change(function() {
		if ($(this).closest('tr').find('div#timePeriod').find('select.view').val() == 0 || $(this).closest('tr').find('div#teachingSite').find('select.view').val() == 0) {
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
					school_db: school_db,
					course_id: $(this).closest('tr').find('span#courseId').text()
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

	$("td #modify").click(function() {
		if (modificationInProgress)
		{	
			alert('Please either \'Cancel\' or \'Save\' current modifications.')
			return;
		}
		// $(this).closest('tr').find('div#teachingSite').find('select.view').trigger('change');
		console.log('The row number is ' + currentRowIndex);
		// $(this).closest('tr').find('div#timePeriod').trigger('change');
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
			currentTeachingSite = $(this).closest('tr').find('span#currentTeachingSiteId').text();
   			$(this).closest('tr').find('div#timePeriod').show();
   			$(this).closest('tr').find('div#teachingSite').show();
   			$(this).closest('tr').find('a#save').show();
   			$(this).closest('tr').find('a#cancel').show();
   			$(this).closest('tr').find('a#delete').show();
   			$(this).closest('tr').find('span.littlespacing').show();
   			$(this).closest('tr').find('div#modify').hide()
   		}
   		return;
	});

	$("a#delete").click(function() {
		$.ajax({
		url: "/tusk/schedule/clinical/admin/ajax/modification",
		data: {
			user_id: user_id,
			course_id: $(this).closest('tr').find('span#courseId').text(),
			current_time_period: currentTimePeriod,
			current_teaching_site: currentTeachingSite,
			school_id: school_id,
			school_db: school_db,
			delete_requested: 'yes'
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
			if (data['applied'] == 'true') {
				alert('Student was removed from the requested rotation.');
				location.reload();
			}
			else {
				alert('Student wasn\'t removed from the requested rotation.');
			}
		});
		return;
	});

	$("a#save").click(function() {
		//store the value and wait for the Ajax request result status
		var tempTimePeriod = $(this).closest('tr').find('div#timePeriod').find('select.view').val(); 
		var tempTeachingSite = $(this).closest('tr').find('div#teachingSite').find('select.view').val(); 
		if (tempTeachingSite == 0 || tempTimePeriod == 0)
		{
			alert('Please make a selection from the drop down list(s) first.');
		} else {
			$.ajax({
				url: "/tusk/schedule/clinical/admin/ajax/modification",
				data: {
					user_id: user_id,
					course_id: $(this).closest('tr').find('span#courseId').text(),
					current_time_period: currentTimePeriod,
					current_teaching_site: currentTeachingSite,
					requested_time_period: tempTimePeriod,
					requested_teaching_site: tempTeachingSite,
					school_id: school_id,
					school_db: school_db
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
				alert("An error occured during the modification process");
			}).success(function(data, status){
				if (data['applied'] == 'false') {
					alert('There was a problem saving the selected time period and teaching site.');
				}
				else {
					currentTimePeriod = tempTimePeriod;
					currentTeachingSite = tempTeachingSite;
					alert('The time period and teaching site change took place.');
					location.reload();
				}
			});
		}
   		return;
	});
	$("a#cancel").click(function() {
		modificationInProgress = false;
		$(this).closest('tr').find('div#teachingSite').hide();
		$(this).closest('tr').find('div#timePeriod').hide();
		$(this).closest('tr').find('a#save').hide();
		$(this).closest('tr').find('a#cancel').hide();
		$(this).closest('tr').find('a#delete').hide();
		$(this).closest('tr').find('span#alreadyEnrolled').hide();
		$(this).closest('tr').find('span.littlespacing').hide();
		$(this).closest('tr').find('div#modify').show()
	});
});