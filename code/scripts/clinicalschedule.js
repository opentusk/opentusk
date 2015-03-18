$(document).ready(function() {
	$("#current_academic_year").change(function () {
		var year = this.value;
		var url = window.location.href;
		url += "?year=";
		url += this.value;
		alert(this.value);
		alert(url);
		window.location.href = url;
	});
});