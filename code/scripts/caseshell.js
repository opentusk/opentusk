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


function phase_edit(layer,id){
	var pk ;
	if (layer == 'phasesdiv'){
		pk = layers[layer].structure.data[id].phase_id;
		case_id = layers[layer].structure.data[id].case_id;
		context_path = layers[layer].structure.context_path;
		if(pk != null && pk != ''){
			window.location = "/case/author/phaseaddedit/"+context_path+"/"+case_id+"/"+pk;
		}  else {
			var type_id = layers[layer].structure.data[id].phase_type_id;
			window.location = "/case/author/phaseaddedit/"+context_path+"/"+case_id+"?phase_type="+type_id;
		}
	}
}

function case_edit(layer,id){
        var pk ;
        if (layer == 'casediv'){
                pk = layers[layer].structure.data[id].case_header_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/case/author/caseaddedit/"+context_path+"/"+pk;
                } else {
			alert("No pk for that case :"+pk);
		}
        } else {
		alert("function called with improper div : "+layer);
	}
}

function case_remove(layer,id){
        var pk ;
        if (layer == 'casediv'){
                pk = layers[layer].structure.data[id].case_header_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/case/author/casedelete/"+context_path+"/"+pk;
                }  
        }
}

function case_report(layer,id){
        var pk ;
        if (layer == 'casediv'){
                pk = layers[layer].structure.data[id].case_header_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/case/author/caseresults/"+context_path+"/"+pk;
                }
        }
}


function question_edit(layer,id){
        var pk ;
        if (layer == 'questiondiv'){
                pk = layers[layer].structure.data[id].question_id;
                phase_id = layers[layer].structure.data[id].phase_id;
		type_path = layers[layer].structure.context_path;
		open_quiz_window(type_path, phase_id, pk);
        }
}

function diagnosis_method_select(dropdown_id,tr_name){
        var method_selected = toggle_diagnosis_select(dropdown_id,tr_name)
	return;
}

function toggle_diagnosis_select(dropdown_id,tr_name){
	// returns the label of the selected method
        var dropdown = document.getElementById(dropdown_id);
        if (dropdown == null){
                alert("invalid id sent to toggle_diagnosis_select");
                return;
        }
	if (dropdown.options[dropdown.options.selectedIndex].value == ""){
		return; 
	}
	
	var display_flag;
	for (var i=0; i < dropdown.options.length; i++){
		if (dropdown.options[i].value == dropdown.value){
			display_flag = 1;
		}else{
			display_flag = 0;
		}
		display_row(dropdown.options[i].value, display_flag);
	}
	return;
}

function change_method(dropdown_id,tr_name){
	toggle_diagnosis_select(dropdown_id,tr_name)
}


function phase_select(case_id,path_context){
	var dropdown = document.forms['phaseshow'].phase_type;
	var phaseSelected = dropdown.options[dropdown.options.selectedIndex].value
	if (phaseSelected != null){
		window.location = "/case/author/phaseaddedit/"+path_context+"/"+case_id+"?phase_type="+phaseSelected;
	}
}

function open_quiz_window(type_path, phase_id, question_id){
	var dropdown = document.getElementById('question_type');
	var params = "width=1200,height=620,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes"
	if (dropdown){
		var dropdownValue = dropdown.options[dropdown.options.selectedIndex].value;
		if (question_id == null){
			window.open("/case/author/questionaddedit/" + type_path + "/" + phase_id + "?type=" + dropdownValue,"_blank",params);
		} else {
			window.open("/case/author/questionaddedit/" + type_path + "/" + phase_id + "/" + question_id,"_blank",params);
		}
	}

}

function can_add_question_type(){
	var dropdown = document.getElementById('question_type');

	var dd_val = dropdown.options[dropdown.options.selectedIndex].value;
	if (dd_val.match(/fillin|essay/i)) {
		alert(_('Sorry, you cannot add questions of type "Fill In," "Multiple Fill In," or "Essay" to a quiz that has a rule requiring a minumum score.'));
		return false;
	}
	else {
		return true;
	}
}

function open_quiz_window_check(type_path, phase_id){
	if (can_add_question_type()) {
		open_quiz_window(type_path, phase_id);
	}
}

function populate_answers_check(formname){
	if (can_add_question_type()) {
		populate_answers(formname);
	}
	else {
		var dropdown = document.getElementById('question_type');
		dropdown.options.selectedIndex = 0;
		populate_answers(formname);
	}
}

function toggle_panel(rowid){
	var elem = document.getElementById(rowid+'-link');
	if (elem == null){
		alert('element not found for toggle_panel');
		return;
	}
	var expand_occurred = toggle_row(rowid);
	if (expand_occurred){
		elem.innerHTML = _('Minimize Panel');
	} else {
		elem.innerHTML = _('Expand Panel');
	}
}

function sim_check(checkid){
	var inputElem = document.getElementById(checkid);
	if (inputElem == null){
		alert('input '+checkid+' not found in sim_check');
		return;
	}
	var imgElem = document.getElementById(checkid+'-img');
	if (imgElem == null){
		alert('image '+checkid+'-img not found in sim_check');
		return;
	}
	if (inputElem.value == 'checked'){
		inputElem.value = '';
		imgElem.src = '/graphics/case/checkbox_empty.gif';
	} else {
		inputElem.value = 'checked';
		imgElem.src = '/graphics/case/checkbox_checked.gif';
	}
} 

function sim_radio(radioid,radioNum){
        var inputElem = document.getElementById(radioid+'-'+radioNum);
        if (inputElem == null){
                alert('input '+radioid+'-'+radioNum+' not found in sim_radio');
                return;
        }
        var imgElem = document.getElementById(radioid+'-img-'+radioNum);
        if (imgElem == null){
                alert('image '+radioid+'-img-'+radioNum+' not found in sim_radio');
                return;
        }
	//alert("checking box "+radioid+'-img-'+radioNum + " : image was "+imgElem.src);
	inputElem.value = 'checked';
	imgElem.src = '/graphics/case/checkbox_checked.gif';
	var more_radio = 1;
	var radioCount = 0;
	while (more_radio){
		radioCount++;
		if (radioCount == radioNum){
			//alert("skipping number "+radioCount);
			continue;
		}
		inputElem = document.getElementById(radioid+'-'+radioCount);
		if (inputElem == null){
			more_radio = 0;
			//alert('did not find '+radioid+'-'+radioCount);
			continue;
		}
		//alert('FOUND '+radioid+'-'+radioCount);
		imgElem = document.getElementById(radioid+'-img-'+radioCount);
		if (imgElem == null){
			alert('image '+radioid+'-img-'+radioCount+' not found in sim_radio : mismatched img and input');
			return;
		}
		inputElem.value = null;
		imgElem.src = '/graphics/case/checkbox_empty.gif';
	}

}

function show_print_version(case_id,case_report_id){
	var params = "width=680,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	window.open('/case/printview/' + case_id + '/' + case_report_id + '?preview=1','print_view'+case_report_id,params);
}


function open_content_window(case_id, content_id){
	var params = "width=580,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	window.open('/case/showcontent/'+ case_id + '/' + content_id, 'content'+content_id,params);
}

function preview_content(layer_id, data_index){
	var content_id = layers[layer_id]['structure']['data'][data_index]['content_id'];
	var params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	window.open('/view/content/' + content_id, 'content' + content_id, params);
}

function modify_content(layer_id, data_index){
	var content_id = layers[layer_id]['structure']['data'][data_index]['content_id'];
	var params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	window.open('/management/content/addedit/content/?page=edit&content_id=' + content_id, 'mod_content' + content_id, params);
}

function open_upload_content_window(url, layer, page){
	var params = "width=900,height=600,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	page = (page)? page : '';
	window.open('/case/author/uploadcontent/'+ url + '/' + layer + '?page=' + page, 'uploadcontent', params);
}

function open_feedback_window(type_path, case_id){
	var params = "width=580,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
	window.open('/case/sendfeedback/' + type_path + '/' + case_id, 'feedback' + case_id, params);
}


function quiz_preview(layer){
	if(layer == 'questiondiv'){
		if(layers[layer].structure.data.length > 0){
			pk = layers[layer].structure.data[0].quiz_id;
			context_path = layers[layer].structure.context_path;
			if(pk != null && pk != ''){
				var params = "width=580,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
				window.open("/quiz/author/quizpreview/"+context_path+"/"+pk,'quiz_preview',params);
			}
		}
		else {
			alert('No quiz items to preview.');
		}
	}
}

function exam_modify(layer, index, field){
	func_redirect(layer, index, field, 'examaddedit');
}

function exam_delete(layer, index, field){
	func_redirect(layer, index, field, 'examdelete');
}

function exam_add(url){
	save_and_continue('batteryaddedit', url);
}

function subtest_modify(layer, index, field){
	func_redirect(layer, index, field, 'subtestedit');
}

// essentially form validation used by examaddedit when adding new test
// make sure user selects radio declaring whether test has subtests or not
function confirm_has_sub(){
	if(document.examaddedit.has_sub){
		for(var i = 0; i < document.examaddedit.has_sub.length; i++) {
			if(document.examaddedit.has_sub[i].checked) {
				return true;
			}
		}

		//failed
		alert(_('Please select whether this test will have sub-tests or not.'));
		return false;
	}
}


// form validation used by caseaddedit 
// make sure user specifies a value for title field
function validate_case_form(form_obj){
	if(isBlank(form_obj.title)) {
		//failed
		alert(_('Please specify a Case Title.'));
		form_obj.title.className += ' focusField';	
		form_obj.title.focus();	
		return false;
	}
	return true;
}


// used by examaddedit
// make sure user selects valid patient type from drop down when assigning
// new patient type to test. then, remove patient from drop down.
function add_patient_type(dropdown, layer, newdata, checkflag, checkfield){
	if(dropdown.selectedIndex != 0){	
		addnewdata(layer, newdata, checkflag, checkfield);
		dropdown.options[dropdown.selectedIndex] = null;
		dropdown.selectedIndex = 0;
	}
}


// used by /case/administrator/assigntests
// function is called by onclick of an input element.
// will cascade de(activating) of input up or down as needed.
// if category is activated, all tests and subtests contained within it
// will be activated. subtest input boxes are hidden from display, but still
// need to be activated.
// function is a bit overkill, but that is because initially subtests were 
// going to have visible and would need to cascade clicks as well. am keeping
// that functionality in in case it is desired later
function cascade_checks(node) {

	var checked_status = node.checked;

	if(checked_status && node.id){
		var parent_txt = node.id;
		var parentNodes = new Array();

		parentNodes = parent_txt.split("-");
		// first, we de(activate) the checkboxes for clicked test and its
		// parent cat (or just for clicked cat)
		for (var i=0;i<parentNodes.length - 1;i++){
			document.patient_tests[parentNodes[i]].checked = checked_status;
		}
	}

	// then, get <li> object that contains clicked box, and by extension
	// all 'children' boxes
	var nodename = node.value + '_node';
	var activeNode = document.getElementById(nodename);

	// get all checkboxes within beneath parent
	var inputs = activeNode.getElementsByTagName('input');

	// cascade the click
	for (var i=0; i<inputs.length;i++){
		inputs[i].checked = checked_status;
	}
}

// used by /case/administrator/assigntests
// takes in 'category', and will toggle visibility of tests/subtests beneath
// it by manipulating css classes of the <ul>'s that contain tests.
function hide_show_tests(link, category){
	var node = document.getElementById(category);

	var tests = node.getElementsByTagName('ul');
	for (var i=0; i<tests.length; i++){
		tests[i].className = (tests[i].className == 'test_list_show')?
						'test_list_hide' : 'test_list_show' ;
	}
	link.innerHTML = (link.innerHTML == '[ - ]')? '[+]' : '[ - ]';

}

function showTxtWin(link_ele, txt_ele_id){
	var txt_ele = document.getElementById(txt_ele_id);
	var coords = new Array();
	coords = findPos(link_ele);
	coords[1] = ((coords[1] - 200) < 10)? 10 : coords[1] - 200;
	coords[0] -= 400;
	txt_ele.style.top = coords[1] + 'px';
	txt_ele.style.left = coords[0] + 'px';
	txt_ele.className = "showTxtWin";	
}

function hideTxtWin(ele_id){
	document.getElementById(ele_id).className = "hideTxtWin";
}

// launch expertselections popup from test results page
function expert_window(case_id, phase_id, report_id){
	var params = "width=720,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";

	window.open('/case/expertselections/' + case_id + '/' + phase_id + '/' + report_id, 'expert', params);
}

// use on /case/administrator/patienttypeaddedit
function change_phase(drop_down, url){
	url += "?phase_type=" + drop_down[drop_down.selectedIndex].value;
	window.location = url;
}

// use by differential dx and dx to insure that user has either ranked
// or selected a likelihood for every element before proceeding
function is_form_complete(){
	var input_rows = getElementsByClass({className: 'reqInput', tag: 'tr'});
	var return_value = true;
	tr_loop:
	for(var i=0; i<input_rows.length; i++){
		var form_eles = new Array();
		form_eles = getElementsByClass({className: 'qqqq', node: input_rows[i]});
		for(var j=0; j<form_eles.length; j++){
			if(form_eles[j].value == 'checked' || form_eles[j].value > 0){
				continue tr_loop;
			}
		}
		return_value = false;
		alert(_("Sorry. You cannot continue to the next phase until you have selected an option for each diagnosis."));
		break;
	}
	document.forms[0].onsubmit = function(){ return return_value; };
}


function complete_phase(formname, nextpage){
	if (document.forms[formname] != null ){
		var casedone = /casedone/;
		if (nextpage.match(casedone)) {
			if (!confirm_case_completion()) {
				return;
			}
		}

		var currentElement = document.createElement("input");
		currentElement.setAttribute("type", "hidden");
		currentElement.setAttribute("name", "phase_complete");
		currentElement.setAttribute("id", "phase_complete");
		currentElement.setAttribute("value", "1");
		document.forms[formname].appendChild(currentElement);

		save_and_continue(formname, nextpage);
	}
}

function retake_quiz(formname) {
	if (document.forms[formname] != null ){
		var currentElement = document.createElement("input");
		currentElement.setAttribute("type", "hidden");
		currentElement.setAttribute("name", "retake_quiz");
		currentElement.setAttribute("id", "retake_quiz");
		currentElement.setAttribute("value", "1");
		document.forms[formname].appendChild(currentElement);

		document.forms[formname].submit();
	}
}


function confirm_case_completion() {
	return confirm(_("Are you sure you want to finish this case?")+"\n\n"+_("If you click 'OK', you will no longer be able to access information or make changes."));
}

/*
used by case/author/phaseaddedit.

this function only works with serious no-cache controls because this fx 
alters a hidden form value and then posts the form. that hidden form value
clues the page to redirect after processing the posted data. this is because
the user is hitting a special link on the page that takes the user off the 
page, so we want to post the form before linking away.

if the user browses with 'back' button to return to the form, that form 
value will still be present, and should the user use the "save" button
to post the form, will find themselves redirected (undesired).

for this reason, phaseaddedit sets meta tags, response headers, and an
iframe so that safari and ie6 will not cache on browser back button 
in http mode (all browsers seem to work fine with ONLY response headers 
in https).
*/
function editTest(myform, nextpage){
	myform.next_page.value = nextpage;
	myform.submit();
}

function pwSort(sortby, lnk) {
	lnk.className = 'activeSort';
	var sort_lnks = lnk.parentNode.getElementsByTagName('a');
	for(var i=0; i<sort_lnks.length; i++){
		if(sort_lnks[i] != lnk){
			sort_lnks[i].className = '';
		}
	}

	if (sortby == 'chrono') {
		document.getElementById('pwSortByPhase').style.display = 'none';
		document.getElementById('pwSortByChrono').style.display = 'block';
	}
	else if (sortby == 'phase') {
		document.getElementById('pwSortByChrono').style.display = 'none';
		document.getElementById('pwSortByPhase').style.display = 'block';
	}
}

// get the patient chart
function getChart(repid) {
	// cache whether we have already received chart in showChart()
	if (!window.have_chart) { 
		var xRequest = initXMLHTTPRequest();
		if (xRequest) {
			var time = new Date();    // append to url to avoid caching
			var url = '/case/getchart/' + repid + '?' + time.getTime();
			xRequest.open("GET", url, true);
			xRequest.onreadystatechange = function () { showChart(xRequest); };	
			xRequest.send(null);
		}
	}
}

function showChart(ajaxRequest){
	if(ajaxRequest.readyState == 4) {
		var response = (ajaxRequest.status == 200)? ajaxRequest.responseText : '';
		if(!response) {
			response = _('Sorry, cannot retrieve patient chart at this time.');
		}
		else {
			window.have_chart = 1;
		}
		var elt = document.getElementById('chart_panel');
		var td = elt.getElementsByTagName('td')[0];
		td.innerHTML = response;
	}
}

function getNotes(repid){
	// cache whether we have notes in showNotes()
	if (!window.have_notes) { 
		var xRequest = initXMLHTTPRequest();
		if (xRequest) {
			var time = new Date();    // append to url to avoid caching
			var url = '/case/notepad/' + repid + '?' + time.getTime();
			xRequest.open("GET", url, true);
			xRequest.onreadystatechange = function() { showNotes(xRequest) };
			xRequest.send(null);
		}
	}
}

function postNotes(repid){
	var xRequest = initXMLHTTPRequest();
	if (xRequest) {
		var notes = document.getElementById('casenotes');
		if (notes) {
			var params = 'casenotes=' + notes.value;
			var url = '/case/notepad/' + repid;
			xRequest.open("POST", url, true);
			xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			xRequest.onreadystatechange = function() { showNotes(xRequest) };	
			xRequest.send(params);
		}
	}
}

function showNotes(ajaxRequest){
	if(ajaxRequest.readyState == 4) {
		var response = (ajaxRequest.status == 200)? ajaxRequest.responseText : '';
		if(!response) {
			response = _('Sorry, cannot retrieve notes at this time.');
		}
		else {
			window.have_notes = 1;
		}
		var elt = document.getElementById('notepad_panel');
		var td = elt.getElementsByTagName('td')[0];
		td.innerHTML = response;
	}
}

/* *****
** this function duplicates most of the behavior of a fx in home.js
** if this functionality is used elsewhere, it would make sense to 
** invest the time in promoting this fx to scripts.js and making it 
** more generic.
***** */
function toggleView(caller) {
	// anchor is in h4 (first parentNode), which is in a div (second parentNode)
	// get that div
	var parent = caller.parentNode.parentNode;

	var elt = getElementsByClass({className: 'quizInfo', tag: 'div', node: parent})[0];

	var action;
	if(elt.className.match(/\sgDisplayNone/)){
		elt.className = elt.className.replace(/\sgDisplayNone/, '');
		caller.innerHTML = '[-]';
		action = 'include';
	}
	else{
		elt.className += ' gDisplayNone';
		caller.innerHTML = '[+]';
		action = 'exclude';
	}
}


function addRuleToPhase(dd, type_path, caseid){
	if (isEnabled(dd)) {
		var phaseid = (dd.options[dd.options.selectedIndex].value);
		if (phaseid) {
			window.location = '/case/author/ruleaddedit/' +type_path+ '/' +caseid+ '/' +phaseid;
		}
	}
}


// ie7 doesn't disable options, so if disabled attribute is present, prevent its selection
function isEnabled(dd) {
	var disabled = $(dd).children(':selected').attr('disabled');
	if (disabled) {
		alert(_('You have selected an invalid option. Please try again.'));
		$(dd).get(0).selectedIndex = 0;
		return 0;
	}
	return 1;
}
