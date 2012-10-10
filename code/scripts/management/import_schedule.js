$(function() {
	useDateRangeChange();	
	$('#date_range_display').click(useDateRangeChange);
});


function useDateRangeChange() {
	if ($('#date_range_display').attr('checked') == false) {
		$('#start_date_tr').hide();
		$('#end_date_tr').hide();
	} 
	else {
		$('#start_date_tr').show();
		$('#end_date_tr').show();
	}
}
