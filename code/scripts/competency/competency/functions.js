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
