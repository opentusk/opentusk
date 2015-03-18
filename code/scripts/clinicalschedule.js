$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		alert(window.location.href);
		window.location.href = window.location.href + "?year=" + year;
		alert(window.location.href);
		location.reload();
	});
});