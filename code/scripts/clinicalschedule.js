$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		window.location.href = window.location.href + "?year=" + year;
		location.reload();
	});
});