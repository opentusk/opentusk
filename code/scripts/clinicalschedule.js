$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		var url = window.location.href;
		alert(this.value);
		$.post(url, 
			{academic_year : this.value},
			reloadpage
		);
		/*
		$.ajax({
			type: "POST",
			url: url,
			data: {academic_year : this.value},
			dataType: "json",
			success: function() {
				location.reload();
			}
		});
		*/
	});
});