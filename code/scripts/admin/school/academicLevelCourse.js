jQuery(document).ready(function($){
	$(".acad_level_dropdown").hide();
});

function showAcadLevels (this_button) {
	$(this_button).hide();
	var current_academic_level = $(this_button).parent().children(".current_academic_level");
	$(current_academic_level).hide();
	$(this_button).parent().find(".acad_level_dropdown").dropdownchecklist({
			firstItemChecksAll : true,
			width : '300px',
			explicitClose: 'Save&nbsp',
			onComplete: function(selector) {
				var option_count = 0;	
				var to_update_array = [];			
				for (i=0; i < selector.options.length; i++) {
					if (selector.options[i].selected) {
						var current_label = $(current_academic_level).html();
						if ($(current_academic_level).html().match(/Uncategorized/gi)) {
							if (selector.options[i].label != "All"){						
								$(current_academic_level).html(selector.options[i].label);
							}
						} else {
							if (option_count == 0) {								
								if (selector.options[i].label != "All") {
									$(current_academic_level).html(selector.options[i].label + " ");
								} else {
									$(current_academic_level).html("");
								}
							} else {
								if (selector.options[i].label != "All") {
									$(current_academic_level).append(", " + selector.options[i].label + " ");
								} 
							}							
						}
						option_count++;
						to_update_array.push(selector.options[i].value);
					}					
				}
				if (option_count == 0) {
					$(current_academic_level).html("Uncategorized ");
				}

				course_link = $(this_button).parent().parent().find('a').first();
				course_id = course_link.attr('href').split('/')[5];				
				
				to_update_academic_levels = to_update_array.join(",");
				
				$.ajax({
					type: "POST",
					url: "/tusk/admin/school/academiclevel/update",
					data: {academic_level_id: to_update_academic_levels, course_id: course_id}
				}).done(function() {					
				});

				$(current_academic_level).show();
				$(this_button).parent().find(".acad_level_dropdown").dropdownchecklist("destroy");
				$(this_button).show();
			}
	});
}

