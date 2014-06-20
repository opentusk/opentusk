jQuery(document).ready(function($){
	$(".acad_level_dropdown").hide();
	//$(".acad_level_dropdown").dropdownchecklist();	
});

function showAcadLevels (this_button) {
	$(this_button).hide();
	$(this_button).parent().find(".acad_level_dropdown").dropdownchecklist({
			firstItemChecksAll : true,
			explicitClose: 'Done'
	});
	$(this_button).parent().find(".ui-dropdownchecklist").trigger("click");
}