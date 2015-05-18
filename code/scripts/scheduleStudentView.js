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
			context: document.body,
			}).done(function() {
		  		alert( "done" );
		});
   		return;
	});
});