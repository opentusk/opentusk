$(function() {
	$("#domain_dropdown").val(0);
	$("#competency_dropdown").val(0);
});

function loadTopLevelCompetencies(domain) {
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxTopLevelCompetencies",
			data: {competency_id: domain.value},
						
		}).success(function(data) {
			$("#competency_dropdown").empty();
			var blankCompetency = $('<option value="">' + "-- Select a Competency --" + '</option>');
			$("#competency_dropdown").append(blankCompetency);
			data = $.parseJSON(data);
			$.each(data, function(index, competency_object) {
				var newCompetency = $('<option value="' + competency_object.competency_id + '">' + competency_object.title + '</option>');
				$("#competency_dropdown").append(newCompetency);
			});
			if ($("#competency_dropdown option").length  <= 1) {
				var newCompetency = $('<option value="" disabled>' + "(None Available for current Selection)" + '</option>');
				$("#competency_dropdown").append(newCompetency);
			}
		});
}