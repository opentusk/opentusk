$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		url = window.location.href;
		url += "?year=" + year;
		window.location.href = url;
		location.reload();
	});
});