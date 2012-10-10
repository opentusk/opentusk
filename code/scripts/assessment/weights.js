$(function() {
	sumup();
	$('input.weight').bind('keyup', function() {
		sumup();
	});
});

function sumup() {
	var my_total_weight = $('input.weight').sumValues();
	$('#totalweighttext').html(my_total_weight);
	$('#total_weight').val(my_total_weight);
	if (my_total_weight == 100) {
		$('.error').hide();
	} else {
		$('.error').show();	
	}
}


$.fn.sumValues = function() {
 	var sum = 0; 
	this.each(function() {
		var val = ($(this).is(':input')) ? $(this).val() : $(this).text();
		sum += parseFloat( ('0' + val).replace(/[^0-9-\.]/g, ''), 10 );
	});
	return sum;
}




