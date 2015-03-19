$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		var url = window.location.href;
	
		jQuery('<form>', {
			'action' : url,
			'target' : '_top'
		}).append(jQuery('<input>', {
			'name': 'academic_year',
			'value' : year,
			'type' : 'hidden'
		})).appendTo('body')
		.submit();
	});
});