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

$( function(){
	$('#competency_search_string').bind("click", function(){
		alert("link-dialog");
	});
});

var currentTitle;
var currentIndex;
var competencyRoot = "/tusk/competency/competency/";

//competency linking global arrays
selected_competency_id = 0;
selected_competency_obj = [];


function closeLinkWindow() {
	$( '#link-dialog' ).empty();
	$( '.competency_link_table' ).empty();
	$( '#link-dialog-wrapper' ).dialog( 'close' );
}

var selComp = {};


function viewCategory( current ){
	$( "#list_competencies" ).html( current.id );
}

function resetDropDown( dropDown ){
	dropDown.selectedIndex = 0;
}

function currentCompLabel( current_competency ){
	$( "#currentComp" ).html( current_competency );
	$( "#link_competency_title" ).show();
}

//Functions related to competency checklist division/popup

function buildCompetencyChecklistTree( dialog_name, school_name, course_id, selected_competency_id, input_type, children, display_type, extend_function ){

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

	if( display_type == "inline" ){
		$( "#" + dialog_name ).load( competencyRoot + "tmpl/display/course/" + school_name + "/" + course_id, {school_name: school_name, course: course_id, selected_competency_id: selected_competency_id, input_type: input_type, children: children, extend_function: extend_function, display_type: display_type });
	} else if( display_type == "dialog" ){
		$( "#" + dialog_name).css({
			'background' : 'white',
			'border' : '1px solid'
		});
		$( "#" + dialog_name ).load( competencyRoot + "tmpl/display/school/" + school_name + "/" + course_id, {school_name: school_name, course: course_id, selected_competency_id: selected_competency_id, input_type: input_type, children: children, extend_function: extend_function, display_type: display_type }).dialog( { dialogClass: 'checklist_dialog_class', title: ' ' });
		$( "#" + dialog_name ).css({
			"width": 600,
			"min-height": 200,
			"padding" : 20
		 });
	} else{
		$( "#" + dialog_name ).html( "Error: Unrecognized display type for checklist window." );
	}
}

function radioOnClick( extendFunction ) {

	selected_competency_id = $('input[name=competency_checklist]:checked').val() ;

	var current_children = [];

	$.each( $("#Child_of_"+selected_competency_id).find(".description"), function() {
		current_children.push( $(this).html() );
	});


	selected_competency_obj = {
		"id" : selected_competency_id,
		"description" :  $('input[name=competency_checklist]:checked').parent().find(".description").html(),
		"category" : $('input[name=competency_checklist]:checked').parent().parent().prev().find(".description").html(),
		"skills" : current_children
	};

	console.log(selected_competency_obj);

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

}

//End functions related to competency checklist division/popup


$(document).ready( function() {
	$( '.competency_popup_container' ).click( function() {
		$( this ).children( '.competency_popup_content' ).css({
			"position": "fixed",
			"left": 35 + "%",
			"top": 50 + "%"
		}).show();
	});
	$( '.linked_competency_close_button' ).click( function() {
		$( this ).parent().hide( 50 );
	});
});

