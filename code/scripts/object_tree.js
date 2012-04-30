// Copyright 2012 Tufts University 
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


var open_html = "<img src=\"/graphics/down_triangle.gif\" border=\"0\">";
var open_html_string = "down_triangle";
var close_html = "<img src=\"/graphics/right_triangle.gif\"border=\"0\">";
var close_html_string = "right_triangle";

function toggle_branch(id){
	var branchLink = document.getElementById(id+"_link");
	var do_close = 1 ;
	if (branch_open(id)){
		do_close = 1;
	} else {
		do_close = 0;
	}
		
	var at_end = false;
	var count = 0;
	var row_element;
	if (do_close) {
		// if doing close, close all the children
		//alert("COLLAPSING branch " + id);
		collapse_branch(id);
	}  else {
		while (!at_end){
			row_element = document.getElementById(id+"_"+count);
			if (row_element == null){
				// alert(" called with "+id+" Not found "+ id+"_"+count);
				at_end = true;
				continue;
			}
			//alert("toggle row " + id+"_"+count);
			toggle_row(id+"_"+count);
			count++;
		}
	}
	toggle_branch_link(id);

}

function branch_displayed(id){
	var elem = document.getElementById(id);
	if (elem != null && elem.style.display != "none"){
		return 1;
	}
	return 0;
}
function branch_open(id){
	var branchLink = has_children(id);
	if (branchLink){
		if (branchLink.innerHTML.match(open_html_string)){
			return 1;	
		}
	} else {
		return branch_displayed(id);
	}
	return 0;
}

function has_children(id){
	// returns the branch link for a row
	// this indicates whether there are children for the row or not
	var branchLink = document.getElementById(id+"_link");
	if (branchLink != null){
		return branchLink;
	} else {
		return 0;
	}
}
function toggle_branch_link(id){
	var branch_link = has_children(id);
        if (branch_link){
                if (branch_open(id)){
                        branch_link.innerHTML = close_html;
                } else {
                        branch_link.innerHTML = open_html;
                }
        }
}

function collapse_branch(id){
	// this closes all of the children for a given branch
	// it leaves branch id passed alone
	var at_end = false; 
	var next_id;
	var branchLink;
	var count = 0;
	//alert ("collapse called with "+id);
        while (!at_end){
		next_id = id+"_"+count;
                row_element = document.getElementById(next_id);
                if (row_element == null){
                        at_end = true;
                        continue;
		}
		if (branch_open(id) && has_children(id)){
			collapse_branch(next_id);
		} else {
			branchLink = has_children(id);
			//alert("not collapsing "+next_id+" because id has_children"+ branchLink +
			//	" and branch_open "+branch_open(id));
			//alert("branch link html "+branchLink.innerHTML);
		}		 
		if (branch_displayed(next_id)){
			//alert("collapse is CLOSING this "+next_id);
			toggle_row(next_id);
			if(branch_open(next_id)){
				toggle_branch_link(next_id);
			}
		}
		count++;
	}
}

function tree_select_all(formname,checkedValue){
	var the_form = document.getElementById(formname);
	if (the_form == null){
		alert("form not found.");
		return;
	} 	
	if (checkedValue == null){
		checkedValue = true;
	}
	the_elements = the_form.elements;
	for (var i = 0; i < the_form.elements.length; i++){
		elem = the_form.elements[i];
		if (elem.type == "checkbox"){
			elem.checked = checkedValue;
		}
	}
}

function tree_clear_all(formname){
	tree_select_all(formname,false);
}

function tree_toggle_branch(element){
	var checkedValue = element.checked;
	var the_form = element.form;

	var the_elements = the_form.elements;
	for (var i = 0; i < the_form.elements.length; i++){
		var elem = the_form.elements[i];
		if (elem.type == "checkbox"){
			if (elem.id.match("-" + element.name + "-")){
				elem.checked = checkedValue;
			}
		}
	}

	if (checkedValue){
		// strip out "parent-" and the ending "-"
		var parsed_string = element.id.substring(7, element.id.length-1);
		var parents = parsed_string.split('-');
		for (i=0; i < parents.length; i++){
			if (parents[i]){		
				the_form.elements[parents[i]].checked = checkedValue;
			}
		}
	}
}