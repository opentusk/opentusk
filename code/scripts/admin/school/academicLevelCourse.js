jQuery(document).ready(function($){
	$(".acad_level_dropdown").hide();
	var academic_levels = $(document).find(".current_academic_level");
	var academic_levels_array;
	$(academic_levels).each( function(index, level){
		academic_levels_array = $(level).html().toString().split(',');
		$(academic_levels_array).each( function( i, academic_level) {
			$(level).parent().find(".acad_level_dropdown").find('option').filter(function() {
				return ($(this).text() == academic_level);
			}).prop('selected', true);
		});
	});
});

function showAcadLevels (this_button) {
	$(this_button).hide();
	var current_academic_level = $(this_button).parent().children(".current_academic_level");
	$(current_academic_level).hide();	
	$(this_button).parent().parent().find(".ui-dropdownchecklist-text").trigger("click");	
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
				school = course_link.attr('href').split('/')[4];
			
				to_update_academic_levels = to_update_array.join(",");
				
				$.ajax({
					type: "POST",
					url: "/tusk/admin/school/academiclevel/update",
					data: {
						academic_level_id: to_update_academic_levels, 
						school : school,
						course_id: course_id
					}
				}).done(function() {					
				});

				$(current_academic_level).show();
				$(this_button).parent().find(".acad_level_dropdown").dropdownchecklist("destroy");
				$(this_button).show();
			}
	});

	setTimeout(function() {
			$(this_button).parent().find("#ddcl-acad_level_dropdown").find(".ui-dropdownchecklist-text").first().trigger("click");		
	}, 50);
}

