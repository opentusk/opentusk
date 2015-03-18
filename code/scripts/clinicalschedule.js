function academicYearChange(academic_year) {
	alert(academic_year);
}

$(document).ready(function() {
	$("#current_academic_year").change(function () {
		alert("here");
		var year = this.value;
		alert(year);
	});
});