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


function toggleAuthors(toggle_box){
	var boxes = document.confirm_authors.approved_authors;

	// boxes will be a NodeList unless there is only one input box with name 'approved_authors'
	// in that case, make boxes an array with one member so that loop below works
	if(!boxes.length){
		boxes = [boxes];
	}	

	for(var i=0; i < boxes.length; i++){
		boxes[i].checked = toggle_box.checked;
	}
}

function validateImportForm(form){
	var fn = form.zip_file.value;
	
	if(fn){
		return true;
	}
	else {
		alert(_('Please supply a valid filename.'));
		form.zip_file.focus();
		return false;
	}
}
