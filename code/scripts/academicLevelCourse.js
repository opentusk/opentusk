jQuery(document).ready(function($){
	$(".acad_level_dropdown").hide();
	//$(".acad_level_dropdown").dropdownchecklist();	
});

function showAcadLevels (this_button) {
	$(this_button).hide();
	$(this_button).parent().find(".acad_level_dropdown").dropdownchecklist({
			firstItemChecksAll : true,
			explicitClose: 'Save',
			onComplete: function(selector) {
				for (i=0; i < selector.options.length; i++){
					if (selector.options[i].selected){
						console.log(selector.options[i].value);
					}
				}
			}
	});
	$(this_button).parent().find(".ui-dropdownchecklist").trigger("click");
}