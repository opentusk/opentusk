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


// pass it a content id, and launch a window with preview of said content
function previewContent(id){
	var params = 'directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=850,height=600';	
	window.open('/view/content/' + id, 'preview_window', params);
}

// called on_submit of export_form.
// if approveExport() has been called and successfully executed, then 
// the hidden input 'approved' will be set to 1.
// otherwise, we need to see if there is any foreign content included
// in export. if not, go ahead and submit form. if there is f.c.,
// we retrieve all f.c. and call buildForConForm() and avoid submitting 
// form. 
function checkForeignContent(export_form){
	var approved = document.getElementById('approved').value;
	if(approved == 1){
		return true;
	}
	else{
		var fc_arr = [];

		var inputs = document.export_course.getElementsByTagName('input');
		for(var i = 0; i < inputs.length; i++) {
			if(inputs[i].type == 'checkbox' && inputs[i].checked){
				var my_class = inputs[i].className;
				if (my_class.match(/foreign/)){
					fc_arr.push(inputs[i].id);
				}
			}
		}
		if(fc_arr.length > 100){
			buildForConForm(export_form);
			return false;
		}
		else if(fc_arr.length > 0){
			buildForConForm(export_form, fc_arr);
			return false;
		}
		else{
			return true;
		}
	}
}

function tooMuchForCon(){
	var html_str = '<p style="border:2px orange solid; font-size:12px; margin:0 0 10px 0; padding:10px;">' + _('Your course has more that 100 pieces of foreign content. To export the course (including all content that is considered foreign) click the "Approve for Export" button below. Otherwise, cancel the export and please review the course and make sure that the course and content authorship is attributed correctly.') + '<br/>' + _('Thank you.') + '</p>';

	return html_str;
}

function buildForConList(fc_arr){
	var html_str = '<p style="border:2px orange solid; font-size:12px; margin:0 0 10px 0; padding:10px;">' + _('You have attempted to export the following "foreign content". For copyright protection, we ask that you please specifically approve this content for export by checking the box next to its title.') + ' <br/>' + _('Thank you!') + '</p>';

	html_str += '<div style="border:2px solid #999;">';
	html_str += '<div class="hdrRow clearfix"><input type="checkbox" onclick="toggleForCon(this);" /><h2>' + _('Content Title') + '</h2><h2 class="rightHdr">Action</h2></div>\n';
	html_str += genListHTML(fc_arr);
	html_str += '</div>\n';

	return html_str;
}

// builds the form 'foreignContentForm'. this form contains unique instances
// of all content that was requested for export, but is foreign (this means
// that the author of the content was not a director, instructor, author,
// lecturer, or instructor in course). i say 'unique instances' b/c a piece of
// content could occur in multiple places in a course, and we don't ask the 
// user to approve all occurrences for export, but just the content itself.
// the code will then crawl the export list and exclude all instances of that
// content if it is appropriate for it to do so.
function buildForConForm(export_form, fc_arr){
	var html_str;
	html_str  = '<form name="foreignContentForm" id="foreignContentForm">\n';
	html_str += '<div id="forConHdr" class="clearfix"><h3>' + _('Foreign Content Selection') + '</h3><a href="#" onclick="cancelExport(); return false;">Cancel [X]</a></div>\n';
	html_str += '<div id="foreignContentContainer">\n';
	html_str += '<div id="foreignContentList">\n';

	if(fc_arr){
		html_str += buildForConList(fc_arr);
	}
	else{
		html_str += tooMuchForCon();
	}

	html_str += '<input class="formbutton submitBtn" type="button" value="' + _('Cancel Export') + '" onclick="cancelExport()"/>'
	html_str += '<input class="formbutton submitBtn" type="button" value="' + _('Approve for Export')+'" onclick="approveExport(\'' + export_form.name + '\', \'foreignContentForm\')"/><br/>';
	html_str += '</div>\n';
	html_str += '</div>\n';
	html_str += '</form>\n';

	var div = document.getElementById('confirmForCon');
	div.innerHTML += html_str;

	var xy_array = getPageXY();
	div.style.height = xy_array[1] + 'px';
	div.style.width = xy_array[0] + 'px';

	var form = document.getElementById('foreignContentForm');
	form.style.top = getTopOfScreen() + 20 + 'px';

	div.style.display = 'block';

}

// generates the <ul> that contains all of the foreign content for 
// foreignContentForm
function genListHTML(arr){
	var str = '<ul class="contentList clearfix">';
	var seen = new Object();

	for(var i=0; i < arr.length; i++){
		var id;
		if(arr[i].match('-')){
			var id = arr[i].substring(arr[i].lastIndexOf('-') + 1);
		}
		else{
			id = arr[i];
		}
		if(!seen[id]){
			seen[id] = true;
			str += makeContentLnk(arr[i], id);
		}	
	}
	str += '</ul>\n';
	return str;
}

// called by genListHTML(). this generates the actual <li> element for each piece 
// of foreign content in form 'foreignContentForm'.
// NB that a slide, for instance, could be present in multiple collections in a
// course. we don't ask the user to approve each of these occurrences as valid
// foreign content should the content indeed by foreign. instead, we just say, 
// "this content occurred at least once in the list of content you want to 
// export, and it is foreign, do you want to approve it for export in all
// occurrences?" 
// Note on params: qualified_id is the id of the content in the 'export_form' form.
// we pass that param in order to retrieve the title of this content. The
// content_id is the id of the for. cont. and will be used to scan the 'export_form'
// for all occurences of the content and exclude them should the content NOT 
// be approved for export (this magic takes place in 'approveExport()'). 
function makeContentLnk(qualified_id, content_id){
	var parent = document.getElementById(qualified_id).parentNode;
	var title = parent.getElementsByTagName('span')[0];

	var str = '<li class="category_item excluded"><input type="checkbox" name="confirm_fc" id="confirm_' + content_id + '" value="1" onclick="includeContent(this)"/><span class="' + title.className + '">' + title.innerHTML + '</span><a class="previewLnk navsm" href="#toggle_cat" onclick="previewContent(' + content_id + ')">preview</a>';

	return str;
}

// called upon submission of foreignContentForm, which is, itself, 
// manufactured by js fx 'buildForConForm()'. approveExport() 
// determines which foreign content is approved to be included in 
// export. it then goes to 'export_form' to appropriately exclude
// any foreign content that was not approved.
function approveExport(export_form_id, forCon_form_id){
	var fc_inputs = document.getElementById(forCon_form_id).getElementsByTagName('input');

	var regex_arr = new Array();
	for(var j=0; j<fc_inputs.length; j++) {
		if(fc_inputs[j].name == 'confirm_fc' && fc_inputs[j].checked == false){
			var id = fc_inputs[j].id.replace(/confirm_/, '');
			var regex = new RegExp(id);
			regex_arr.push(regex);
		}
	}

	var export_form = document.getElementById(export_form_id);
	var inputs = export_form.getElementsByTagName('input');

	for(var i=0; i<inputs.length; i++){
		if(inputs[i].type == 'checkbox' && inputs[i].checked == true){
			for(var j=0; j<regex_arr.length; j++) {
				if(inputs[i].name.match(regex_arr[j])){
					inputs[i].checked = false;
					break;
				}
			}
		}
	}

	var approved = document.getElementById('approved');
	approved.value = 1;
	
	if(export_form.onsubmit()){
		export_form.submit();
	}
}

// fx() that is available to content that is either a collection or 
// multi-document. by calling this you will either show or reveal
// all subcontent
function hideShowSubContent(lnk){
	lnk.className = (lnk.className == 'collectionLnkClosed')? 'collectionLnkOpened' : 'collectionLnkClosed';
	var parent = lnk.parentNode;
	var subContent = parent.getElementsByTagName('ul')[0];

	// make sure collection is not empty
	if(subContent){		
		subContent.className = (subContent.className == 'displayedSubContent')? 'hiddenSubContent' : 'displayedSubContent';
	}
}

// if content contained in a collection or multidocument is toggled
// for inclusion make sure that the parent directories (recursively)
// are also included.
function toggleParents(names){
	if(names.indexOf('-') != -1){
		var parentID = names.substring(0, names.lastIndexOf('-'));
		if(parentID){
			var parent = document.getElementById(parentID);
			if(parent){
				parent = parent.parentNode;
			}
			else{
				return;
			}
	
			exclusionToggle(parent, 'include', true);
			
			toggleParents(parentID);
		}
	}
}

// following 3 fx()'s take care of excluding and including content
// for export. recursion is taken care of in exclusionToggle().
// that is, if a parent directory is included, make sure that all
// sub content is also included. similarly, if a piece of subcontent 
// is included, make sure that its parents are also included.
function excludeContent(c_box){
	var parent = c_box.parentNode;
	exclusionToggle(parent, 'exclude');
}

function includeContent(c_box){
	var parent = c_box.parentNode;
	exclusionToggle(parent, 'include');
}

function exclusionToggle(parent, action, recursive){
	var liClass  = (action == 'exclude')? 'excluded' : 'included';
	var regEx    = (action == 'exclude')? new RegExp(/included/) : new RegExp(/excluded/);
	var inputVal = (action == 'exclude')?  false     : true;

	if(parent.className != 'hdrRow'){
		if(parent.className.match(regEx)){
			parent.className = parent.className.replace(regEx, liClass);
		}
	}

	var input = parent.getElementsByTagName('input')[0];
	input.checked = inputVal;

	input.onclick = (action == 'exclude')? function(){includeContent(this)} : function(){excludeContent(this)};

	if(!recursive){
		var subContent = parent.getElementsByTagName('li');
		for(var i=0; i<subContent.length; i++){
			exclusionToggle(subContent[i], action, true);
		}
	}

	if(!recursive && action == 'include') { toggleParents(input.name); };
}

function checkDates(form){
	if(form.start_date.value && form.end_date.value){
		// cursory check of format
		if(!form.start_date.value.match(/\d\d\d\d-\d\d-\d\d/)){
			alert(_('Sorry, start date does not appear to be of the format: "YYYY-MM-DD"'));
			form.start_date.focus();
			return false;
		}
		if(!form.end_date.value.match(/\d\d\d\d-\d\d-\d\d/)){
			alert(_('Sorry, end date does not appear to be of the format: "YYYY-MM-DD"'));
			form.end_date.focus();
			return false;
		}
	}
}

// appropriately toggle all the checkboxes in the form based upon
// 'checked' status of master check box
function toggleForCon(toggle_box){
	var my_form = toggle_box.form;
	var fc_inputs = my_form.getElementsByTagName('input');

	for(var j=0; j<fc_inputs.length; j++) {
		if(fc_inputs[j].name == 'confirm_fc'){
			fc_inputs[j].onclick = (toggle_box.checked)? function(){includeContent(this)} : function(){excludeContent(this)};
			fc_inputs[j].checked = toggle_box.checked;
			fc_inputs[j].onclick();
		}
	}
}

// fx takes the div that contains the foreign content form and 
// makes it invisible
function cancelExport(){
	var elt = document.getElementById('confirmForCon');
	elt.style.display = 'none';	
	elt.innerHTML = '';
}


