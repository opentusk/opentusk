$(document).ready(function() {

	$("td #modify").click(function() {
		if ($(this).closest('tr').find('div#timePeriod').is(":visible"))
		{
			$(this).closest('tr').find('div#timePeriod').hide();
			$(this).closest('tr').find('div#save').hide();
		}
		else
		{
   			$(this).closest('tr').find('div#timePeriod').show();
   			$(this).closest('tr').find('div#save').show();
   		}
   		return;
	});

	$("div#save").click(function() {
		$.ajax({
			url: "/tusk/schedule/clinical/admin/ajax/modification",
			data: {
				user_id: user_id,
				course_name: $(this).closest('tr').find('select.view').val()
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
		  	alert( "done" );
		}).error(function() {
			alert("an error occured during the modification process");
		}).success(function(data, status){
			if (data['can_enroll'] == 'false')
			{
				alert('Enough students are already enrolled.');
			}
			console.log("data also should be: ", data['can_enroll']);
		});
   		return;
	});

});