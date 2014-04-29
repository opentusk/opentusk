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

$( "#link_competency_popup" ).draggable();
$( "#link_competency_popup" ).resizable({
	stop: function(event, ui){
		$(this).css("width", '');
	}
});

var currentTitle;
var currentIndex;
var competencyRoot = "/tusk/competency/competency/";

//competency linking global arrays
to_delete_array = [];
to_add_array = [];
selected_competency_id = 0;

// show dialog box for managing personal links
function linkSchoolNational( link, params ) {
	var postURL = params.postTo.split('/');
	var school = postURL[postURL.length-1];
	var liArray = link.parentNode.parentNode.parentNode.getElementsByTagName('LI');
	var liNode = link.parentNode.parentNode.parentNode.parentNode.parentNode;
	var currentTitle = liArray[1].innerHTML;
	$( "#link-dialog-wrapper" ).css( "visibility", "visible" ); 
	$( "#link-dialog" ).data("currentTitle", currentTitle);
	currentCompLabel( currentTitle );
	$( "#link-dialog" ).data("currentIndex", liNode.id);
	competencyId1 = liNode.id.split('_')[0];
	$( "#link-dialog" ).load( competencyRoot + "admin/link/school/" + school, {competency_id: competencyId1, root_id: 0}, initLinkDialog());
	$( "#link-dialog-wrapper" ).dialog({dialogClass: 'competency_link_dialog', position: { my: "center", at: "top" }, minWidth: 850, minHeight: 640});
}

function linkCourseSchool( currentTitle, currentIndex){
	$( "#link-dialog" ).empty();
	$( "#link-dialog-wrapper" ).css( "visibility", "visible" );
	$( "#link-dialog" ).data("currentTitle", currentTitle);
	$( "#link-dialog" ).data("currentIndex", currentIndex);
	$( "#link-dialog" ).load(competencyRoot + "admin/link/school/Medical", {competency_id: currentIndex, root_id: 0}, initLinkDialog());
	$( "#link-dialog-wrapper" ).dialog({dialogClass: 'competency_link_dialog', position: {my: "center", at: "top" }, minWidth: 850, minHeight: 640});
}

function linkClassMeetingTo ( currentCourseID, currentTitle, currentIndex){
	$( "#link-dialog" ).data("currentTitle", currentTitle);
	$( "#link-dialog" ).data("currentIndex", currentIndex);
	$( "#link-dialog" ).load( competencyRoot + "/admin/linkToCourse/school/Medical", {course_id: currentCourseID}, initLinkDialog());
	$( "#link-dialog-wrapper" ).dialog({ position: { my: "center", at: "top" }});
}

function linkContentTo ( currentCourseID, currentTitle, currentIndex){
	$( "#link-dialog" ).data("currentTitle", currentTitle);
	$( "#link-dialog" ).data("currentIndex", currentIndex);
	$( "#link-dialog" ).load( competencyRoot + "/admin/linkToCourse/school/Medical", {course_id: currentCourseID}, initLinkDialog());
	$( "#link-dialog-wrapper" ).dialog({ position: { my: "center", at: "top" }});
}

function initLinkDialog(){
	currentTitle = $( "#link-dialog" ).data( "currentTitle" );
	currentIndex = $( "#link-dialog" ).data( "currentIndex" );
	competencyId1 = currentIndex.split('_')[0];
}

function viewNational() {
	if ($("#list_competencies" ).css( "display" ) == "none"){
		$( "#list_competencies" ).show();
	} else {
		$( "#list_competencies" ).css("display", "none");
	}
}


function closeLinkWindow() {
	$( '#link-dialog' ).empty();
	$( '.competency_link_table' ).empty();
	$( '#link-dialog-wrapper' ).dialog( 'close' );
}

var selComp = {};

function selectedCompetenciesCourse() {
	selComp = $("#list_course input:checkbox:checked").map(function(){
		var thisComp = {};
		thisComp.id = this.id;
		thisComp.value = $(this).attr('value');
		return thisComp;
	}).get();
	var competencyId2;
	jQuery.each( selComp, function(i, val) {
		competencyId2 = selComp[i].id;
		$.ajax({
			type: "POST",
			url: "/tusk/competency/competency/tmpl/saveLink",
			data: { id1: competencyId1, id2: competencyId2}
		}).done(function(){
			$( "#save_notifications" ).html(selComp.length + ' competency Relationships Saved Successfully');
		  });
	});
}

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

//Link Competencies Page table functions

function linkedCellOnClick( linked_cell ){
	var $current_id = linked_cell.id.split('_')[1];
	var $parent_id = $( linked_cell ).attr( 'data-parent' );
	var $not_linked_parent_id = "#NLS_cat_" + $parent_id;
	var $not_linked_id = "#NLS_" + $current_id;
	var $description = $( linked_cell ).html();
	$( $not_linked_parent_id ).parent().after( "<tr><td class=\"not_linked_cell\" id=\"LS" + $not_linked_id + "\" onclick=\"notLinkedCellOnClick( this );\" data-parent=\""+ $parent_id + "\">" + $description + "</td></tr>");
	$ ( linked_cell ).parent().remove();
	to_delete_array.push( $current_id );
	if ($.inArray( $current_id, to_add_array) > -1){
		to_add_array.splice( $.inArray( $current_id, to_add_array), 1);
	}
}

function notLinkedCellOnClick( not_linked_cell ){
	var $current_id = not_linked_cell.id.split('_')[1];
	var $parent_id = $( not_linked_cell ).attr( 'data-parent' );
	var $linked_parent_id = "#LS_cat_" + $parent_id;
	var $linked_id = "#LS_" + $current_id;
	var $description = $( not_linked_cell ).html();
	$( $linked_parent_id ).parent().after( "<tr><td class=\"linked_cell\" id=\"LS" + $linked_id + "\" onclick=\"linkedCellOnClick( this );\" data-parent=\""+ $parent_id + "\">" + $description + "</td></tr>");
	$( not_linked_cell ).parent().remove();
	to_add_array.push( $current_id );
	if ($.inArray( $current_id, to_delete_array) > -1){
		to_delete_array.splice( $.inArray( $current_id, to_delete_array), 1);
	}
}

//Function to go through competency linking window tables and create new competency links or 
//delete existing competency links as necessary. 

function updateCompetencies(){
	var competencyId2;
	var total_relations = to_add_array.length + to_delete_array.length;
	//add first
	jQuery.each( to_add_array, function(i, val) {
		competencyId2 = val;
		$.ajax({
			type: "POST",
			url: "/tusk/competency/competency/tmpl/relation/save",
			data: { id1: competencyId1, id2: competencyId2}
		}).done(function(){
			$( "#save_notifications" ).html(total_relations + ' Relationships updated  Successfully');
		  });
	});
	//now delete
	jQuery.each( to_delete_array, function(i, val) {
		competencyId2 = val;
		$.ajax({
			type: "POST",
			url: "/tusk/competency/competency/tmpl/relation/delete",
			data: { id1: competencyId1, id2: competencyId2}
		}).done(function(){
			$( "#save_notifications" ).html(total_relations + ' Relationships updated Successfully');
		  });
	});

}

//End Link Competencies Page table functions

//Competency Checklist Functions

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


$(document).ready( function() {
	$( '.competency_popup_content' ).draggable();
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
