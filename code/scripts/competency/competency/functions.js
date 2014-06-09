// Copyright 2013 Tufts University 
//
// Licensed under the Educational Community License, Version 1.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//
// http://www.opensource.org/licenses/ecl1.php 
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and 
// limitations under the License.


var competencyRoot = "/tusk/competency/competency/";

if ($("#link_competency_popup").length){
	$("#link_competency_popup").draggable();
	$("#link_competency_popup").resizable({
		stop: function(event, ui) {
			$(this).css("width", '');
		}
	});
}

var currentTitle;
var currentIndex;


//competency linking global variables
to_delete_array = [];
to_add_array = [];
to_update_array = [];
to_update_array_remove =[];

//competency checklist global variables
selected_competency_id = 0;
selected_competency_obj = [];

//Competency linking display functions

function linkSchoolNational (link, params) {
	var postURL = params.postTo.split('/');
	var school = postURL[postURL.length - 1];
	var liArray = link.parentNode.parentNode.parentNode.getElementsByTagName('LI');
	var liNode = link.parentNode.parentNode.parentNode.parentNode.parentNode;
	var currentTitle = liArray[1].innerHTML;
	$("#link-dialog-wrapper").css("visibility", "visible"); 
	$("#link-dialog").data("currentTitle", currentTitle);
 	currentCompLabel(currentTitle);
	$("#link-dialog").data("currentIndex", liNode.id);
	competencyId1 = liNode.id.split('_')[0];
	$("#link-dialog").load(competencyRoot + "admin/link/school/" + school, {competency_id: competencyId1, root_id: 0, link_type: 'national'}, initLinkDialog());
	$("#link-dialog-wrapper").dialog({dialogClass: 'competency_link_dialog', position: {my: "center", at: "top" }, width: 850, height: 600, minHeight: 450});
}

function linkCourseSchool (link, params) {
	var postURL = params.postTo.split('/');
	var school = postURL[postURL.length - 2];
	var course = postURL[postURL.length - 1];
	var liArray = link.parentNode.parentNode.parentNode.getElementsByTagName('LI');
	var liNode = link.parentNode.parentNode.parentNode.parentNode.parentNode;
	var currentTitle = liArray[1].innerHTML;
	$("#link-dialog-wrapper").css("visibility", "visible"); 
	$("#link-dialog").data("currentTitle", currentTitle);
 	currentCompLabel(currentTitle);
	$("#link-dialog").data("currentIndex", liNode.id);
	competencyId1 = liNode.id.split('_')[0];
	$("#link-dialog").load(competencyRoot + "admin/link/school/" + school + '/' + course, {competency_id: competencyId1, root_id: 0, link_type: 'school'}, initLinkDialog());
	$("#link-dialog-wrapper").dialog({dialogClass: 'competency_link_dialog', position: {my: "center", at: "top"}, width: 850, height: 600, minHeight: 450});
}

function linkContentToCourse (currentTitle, currentIndex) {
	var postTo = window.location.pathname;
	var postURL = params.postTo.split('/');
	var school = postURL[postURL.length - 3];
	var course_id = postURL[postURL.length - 2];
	$("#objective_type").html("Content");
	$('#link-dialog').html(" \
		<div id='loading_competencies'> \
			<div id='loading_competencies_text'> \
				Loading Competencies \
			</div> \
			<img src='/graphics/competency_loading.gif'> \
		</div> \
	");
	currentCompLabel(currentTitle);
	$("#link-dialog-wrapper").css("visibility", "visible");
	$("#link-dialog").data("currentTitle", currentTitle);
	$("#link-dialog").data("currentIndex", currentIndex);
	$("#link-dialog").load(competencyRoot + "admin/link/school/" + school, {competency_id: currentIndex, root_id: 0, link_type: 'class_meet', course_id: course_id}, initLinkDialog());
	$("#link-dialog-wrapper").dialog({dialogClass: 'competency_link_dialog', position: {my: "center", at: "top"}, width: 850, height: 600, minHeight: 450});
}

function linkObjectiveToCourse (link, params) {
	var postURL = params.postTo.split('/');
	var school = postURL[postURL.length - 3];
	var course_id = postURL[postURL.length - 2];
	var liArray = link.parentNode.parentNode.parentNode.getElementsByTagName('LI');	
	var liNode = link.parentNode.parentNode.parentNode.parentNode;
	if (!liNode.id) {
		liNode = link.parentNode.parentNode.parentNode.parentNode.parentNode;
	}	
	var currentTitle = liArray[1].innerHTML;
	$('#link-dialog').html(" \
		<div id='loading_competencies'> \
			<div id='loading_competencies_text'> \
				Loading Competencies \
			</div> \
			<img src='/graphics/competency_loading.gif'> \
		</div> \
	");
	$("#objective_type").html("Schedule");
	currentCompLabel(currentTitle);
	var currentIndex = liNode.id;
	competencyId1 = liNode.id.split('_')[0];
	$("#link-dialog-wrapper").css("visibility", "visible"); 
	$("#link-dialog").data("currentTitle", currentTitle);
	$("#link-dialog").data("currentIndex", currentIndex);
	$("#link-dialog").load(competencyRoot + "admin/link/school/" + school, {competency_id: competencyId1, root_id: 0, link_type: 'class_meet', course_id: course_id}, initLinkDialog());
	$("#link-dialog-wrapper").dialog({dialogClass: 'competency_link_dialog', position: {my: "center", at: "top"}, width: 850, height: 600, minHeight: 450});
}

function initLinkDialog() {
	currentTitle = $("#link-dialog").data("currentTitle");
	currentIndex = $("#link-dialog").data("currentIndex");
	currentIndex = currentIndex.toString();	
	competencyId1 = currentIndex.split('_')[0];
}

function closeLinkWindow() {
	$('#link-dialog').empty();
	$('.competency_link_table').empty();
	$('#link-dialog').html(" \
		<div id='loading_competencies'> \
			<div id='loading_competencies_text'> \
				Loading Competencies \
			</div> \
			<img src='/graphics/competency_loading.gif'> \
		</div> \
	");
	$('#link-dialog-wrapper').dialog('close');
}

function appendNewLinkedCompetencies (competency_id, type) {
	var currentURL = window.location.pathname;
	if (currentURL.indexOf("content") >= 0 || currentURL.indexOf("schedule") >= 0) {
		//for linking competency_types without supporting information
		col = 'col1';		
	} else if (currentURL.indexOf("school") >= 1 ) {
		//for linking school competencies
		col = 'col3';
	} else {
		//for linking competency types with supporting information
		col = 'col2';
	}
	$.each(to_update_array, function(index, value) {
		var competency_desc = value.replace(/&nbsp;/g, '');	
		$('#competency_container').find('li[id^='+ competency_id + '] .'+ col).find('.competency_popup_container a').first().append("<i>New " + (index+1) + ": </i>" + competency_desc.substring(0,50) +  "<br>");
		$('#competency_container').find('li[id^=' + competency_id + '] .' + col).find('.competency_popup_content').first().append("<b><i>New " + (index+1) + ": </i></b>" + competency_desc + "<br>");	
	});
	$.each(to_update_array_remove, function(index, value) {
		var competency_desc = value.replace(/&nbsp;/g, '');	
		var to_delete = $('#competency_container').find('li[id^='+ competency_id + '] .' + col).find('.competency_popup_container a').first();
		comp_match_pattern = new RegExp(value.replace(/&nbsp;/g, '').substring(0,50), 'g');
		var temp_html = to_delete.html();
		temp_html = temp_html.replace(comp_match_pattern, "<i>deleted</i>");
		to_delete.html(temp_html);
		to_delete = $('#competency_container').find('li[id^='+ competency_id + '] .' + col).find('.competency_popup_content').first();
		comp_match_pattern = new RegExp(value.replace(/&nbsp;/g, ''), 'g');
		temp_html = to_delete.html();
		temp_html = temp_html.replace(comp_match_pattern, "<i>deleted</i>");
		to_delete.html(temp_html);
	});
}

function currentCompLabel (current_competency) {
	$("#currentComp").html(current_competency);
	$("#link_competency_title").show();
}



//Link Competencies Page table functions

function linkedCellOnClick (linked_cell) {
	var $current_id = linked_cell.id.split('_')[1];
	var $parent_id = $(linked_cell).attr('data-parent');
	var $not_linked_parent_id = "#NLS_cat_" + $parent_id;
	var $not_linked_id = "#NLS_" + $current_id;
	var $description = $(linked_cell).html();
	$($not_linked_parent_id).parent().after("<tr><td class=\"not_linked_cell\" id=\"LS" + $not_linked_id + "\" onclick=\"notLinkedCellOnClick(this);\" data-parent=\""+ $parent_id + "\">" + $description + "</td></tr>");
	$(linked_cell).parent().remove();
	to_delete_array.push($current_id);
	to_update_array_remove.push($description);
	if ($.inArray($current_id, to_add_array) > -1) {
		to_add_array.splice($.inArray($current_id, to_add_array), 1);
		to_update_array.splice($.inArray($description, to_update_array), 1);
	}
}

function notLinkedCellOnClick (not_linked_cell) {
	var $current_id = not_linked_cell.id.split('_')[1];
	var $parent_id = $(not_linked_cell).attr('data-parent');
	var $linked_parent_id = "#LS_cat_" + $parent_id;
	var $linked_id = "#LS_" + $current_id;
	var $description = $(not_linked_cell).html();
	$($linked_parent_id).parent().after("<tr><td class=\"linked_cell\" id=\"LS" + $linked_id + "\" onclick=\"linkedCellOnClick(this);\" data-parent=\""+ $parent_id + "\">" + $description + "</td></tr>");
	$(not_linked_cell).parent().remove();
	to_add_array.push($current_id);
	to_update_array.push($description);
	if ($.inArray($current_id, to_delete_array) > -1) {
		to_delete_array.splice($.inArray( $current_id, to_delete_array), 1);
	}
}

//Function to go through competency linking window tables and create new competency links or 
//delete existing competency links as necessary. 

function updateCompetencies() {
	var competencyId2;
	var total_relations = to_add_array.length + to_delete_array.length;
	//add first
	jQuery.each(to_add_array, function(i, val) {
		competencyId2 = val;
		$.ajax({
			type: "POST",
			url: "/tusk/competency/competency/tmpl/relation/save",
			data: {id1: competencyId1, id2: competencyId2}
		}).done(function() {
		  });
	});
	//now delete
	jQuery.each(to_delete_array, function(i, val) {
		competencyId2 = val;
		$.ajax({
			type: "POST",
			url: "/tusk/competency/competency/tmpl/relation/delete",
			data: { id1: competencyId1, id2: competencyId2}
		}).done(function() {
		  });
	});

	if (total_relations == 0) {
		$("#save_notifications").html('No changes.');
	} else if (total_relations == 1) {
		$("#save_notifications").html(total_relations + ' change updated successfully.');
	}
	else {
		$("#save_notifications").html(total_relations + ' changes updated successfully.');
	}
	appendNewLinkedCompetencies(competencyId1);
	total_relations = 0;
	to_add_array = [];
	to_delete_array = [];
	to_update_array = [];
	to_update_array_remove = [];
}

//End Link Competencies Page table functions

//Functions related to competency checklist division/popup

function buildCompetencyList (dialog_name, school_name, course_id) {	
/*Uses the "<competencyRoot>/tmpl/static_display" page and given parameters to build a list tree of competencies and displays it in the given division.*/
	$("#" + dialog_name).load(competencyRoot + "tmpl/static_display/course/" + school_name + "/" + course_id, {school_name: school_name, course: course_id});
}

function buildCompetencyChecklistTree(dialog_name, school_name, course_id, selected_competency_id, input_type, children, display_type, extend_function) {

/*
Uses the "<competencyRoot>/tmpl/display" page and given parameters to build a competency checklist tree and displays it in the given division.
The competency_id for the selected competency from the checklist is stored in the javascript variable selected_competency_id after a user clicks on "select" 
and can then be used accordingly.

	Requires:
			jQuery libraries and jQuery UI libraries.
						- "jquery/jquery.min.js"
						- "jquery/jquery-ui.min.js"
						- "jquery/jquery.ui.widget.min.js"
						- "jquery/plugin/interface/interface.js"

	Parameters:
			dialog_name = HTML 'id' for the div used to display the dialog_box. Div must be present on caller page.
			school_name = School that the course belongs to Eg. Medical, Dental, etc.
			course_id   = HSDB45 course id for the course that we want to create the checklist for.
			selected_competency_id = Competency_id for a competency that has already been selected and saved from a previous session. Pass 0 if new.
			input_type  = Determines whether the checklist items compromise of:
					"radio" = radio buttons ( able to select one )
					"checkbox" = checkboxes ( able to select multiple )
			children    = Determines whether the child competencies of the top level competencies are selectable or not:
					"on" = selectable
					"off" = not selectable
			display_type = Determines whether the checklist division is displayed as:
					"inline" = inline to other HTML elements in the page
					"dialog" = displayed as a popup dialog box
	Example Usage: 
			<div id = "test_dialog"</div>
			<input type="button" value="Display Checklist" onclick="buildCompetencyChecklistTree('test_dialog', 'Dental', 1251, 'radio', 'off', 'inline');
			(The above example has a button with value "Display Checklist" which when clicked displays a competency checklist tree for course 1251 of the Dental 
			School, consisting of radio buttons with child competencies unselectable inline on the "test_dialog" division.)
 */

	if (display_type == "inline") {
		$("#" + dialog_name).load(competencyRoot + "tmpl/display/course/" + school_name + "/" + course_id, {school_name: school_name, course: course_id, selected_competency_id: selected_competency_id, input_type: input_type, children: children, extend_function: extend_function, display_type: display_type });
	} else if(display_type == "dialog"){
		$("#" + dialog_name).css({
			'background' : 'white',
			'border' : '1px solid'
		});
		$("#" + dialog_name).load( competencyRoot + "tmpl/display/school/" + school_name + "/" + course_id, {school_name: school_name, course: course_id, selected_competency_id: selected_competency_id, input_type: input_type, children: children, extend_function: extend_function, display_type: display_type }).dialog( { dialogClass: 'checklist_dialog_class', title: ' ' });
		$("#" + dialog_name).css({
			"width": 600,
			"min-height": 200,
			"padding" : 20
		 });
	} else {
		$("#" + dialog_name).html("Error: Unrecognized display type for checklist window.");
	}
}

function radioOnClick(extendFunction) {

	selected_competency_id = $('input[name=competency_checklist]:checked').val() ;

	var current_children = [];

	$.each($("#Child_of_"+selected_competency_id).find(".description"), function() {
		current_children.push( $(this).html() );
	});


	selected_competency_obj = {
		"id" : selected_competency_id,
		"description" :  $('input[name=competency_checklist]:checked').parent().find(".description").html(),
		"category" : $('input[name=competency_checklist]:checked').parent().parent().prev().find(".description").html(),
		"skills" : current_children
	};


	$("#competency_module").text(selected_competency_obj.description);
	$("#competency_category").text(selected_competency_obj.category);

	var skills_list = '<ul class="gArrow">';
	$.each(selected_competency_obj.skills, function(index, item) {
		skills_list += '<li class="gArrow">' + item;  // + '</li>';
	});
	skills_list += '</ul>';
	$("#skills").html(skills_list);

	$('input[name=competency_id]').val(selected_competency_obj.id);
}

function extendExample() {
	alert("radioOnClick extension example: description is " + selected_competency_obj["description"]);
}

function checkboxOnClick() {
	//WIP: Similar to radioOnClick but with array of all selected ids.
}

//End functions related to competency checklist division/popup


//Functions to be run at pageload, included making divisions dragable and resizable

$(document).ready( function() {
	if ($(".competency_popup_content").length){
		$('.competency_popup_content').draggable();
	}
	$('.competency_popup_container').click( function() {
		$(this).children('.competency_popup_content').css({
			"position": "fixed",
			"left": 35 + "%",
			"top": 50 + "%"
		}).show();
	});
	$('.linked_competency_close_button').click(function() {
		$(this).parent().hide(50);
	});
	var select_buttons = $(document).find("#competency_container select");
	$(select_buttons).each(function( index, this_button) {
		resetDropDown(this_button);
	});
	
});

//End functions to be run at pageload.
