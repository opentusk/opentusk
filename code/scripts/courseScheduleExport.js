function exportCourseSchedule
{
	$.ajax({
		url: "/tusk/schedule/clinical/admin/ajax/export",
		data: {

		}, dataType: "json"
	}).error(function(){
		alert("An error occured during the rotation schedule export process");
	});
}

$(document).ready(function() {
	
});