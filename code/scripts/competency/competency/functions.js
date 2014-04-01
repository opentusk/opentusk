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

function buildCompetencyChecklistTree( school_id, course_id, input_type, children, display_type ){
	if( display_type == "inline" ){
		$( "#checklist-dialog" ).load( competencyRoot + "tmpl/display/school/Medical" , {school_id: school_id, course: course_id, input_type: input_type, children: children });
	} else if( display_type == "dialog" ){
		$( "#checklist-dialog" ).css({
			'background' : 'white',
			'border' : '1px solid'
		});
		$( "#checklist-dialog" ).load( competencyRoot + "tmpl/display/school/Medical" , {school_id: school_id, course: course_id, input_type: input_type, children: children }).dialog( { dialogClass: 'checklist_dialog_class', title: ' ' });

		$( "#checklist-dialog" ).css({
			"width": 600,
			"min-height": 200,
			"padding" : 20
		 });
	} else{
		$( "#checklist-dialog" ).html( "Error: Unrecognized display type for checklist window." );
	}
}

function radioOnClick() {
	selected_competency_id = $( 'input[name=competency_checklist]:checked' ).val() ;
	alert( selected_competency_id );	
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
