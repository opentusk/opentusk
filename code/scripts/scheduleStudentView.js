$( document ).ready(function() {
	$("td #modify").click( function() {
   		$(this).closest('tr').after('<tr><td colspan="4">inserted data</td></tr>');
   		return false;
	});
});