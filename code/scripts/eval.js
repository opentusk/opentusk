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


function eval_select_all(value){
	var form = document.forms.question_list;
	if (form == null){
		return ;
	}
	var elems = form.elements;
	for (i =0; i <elems.length; i++){
		if ((elems[i].type == "checkbox") &&
			((elems[i].name == "edit_q") 
			|| (elems[i].name == "duplicate_q"))){
			elems[i].checked = value;
		}
	}
}

// NOTE:  This is /code/htdocs/eval_question.html, NOT /code/embperl/eval_question.html
function doHelpWindow() {
    window.open('/eval_question.html', 'evalQuickRefWin',
        'width=600,height=400,directories=no,status=no,toolbar=no,resizable=yes,scrollbars=yes');
}

function doQuickRefWindow(url) {
    window.open('/protected/eval/administrator/ref_sheet/'+url,
        'evalQuickRefWin',
        'width=600,height=400,directories=no,status=no,toolbar=no,resizable=yes,scrollbars=yes');
}

// TODO: This sort of browser fiddling would be better done with jQuery
function satisfy(qid, type) {
  var imgname="flag_"+qid;
  var fieldname = "eval_q_"+qid;
  if (document.images) {
    var image = document.images[imgname];
    if (image == null) return;
    var element = document.forms['eval_form'].elements[fieldname];
    if (type == 'select') {
      if (element.options[element.selectedIndex].value.length == 0) {
        image.src = "/icons/reddot.gif";
      } else {
	requiredSatisfied(qid);
        image.src = "/icons/transdot.gif";
      }
    }
    else if (type == 'text') {
      if (element.value.length == 0) {
        image.src = "/icons/reddot.gif";
      } else {
	requiredSatisfied(qid);
        image.src = "/icons/transdot.gif";
      } 
    }
    else if ('value' in element) {
      // check if element's value is non-empty
      if (element.value.length == 0) {
        image.src = "/icons/reddot.gif";
      }
      else {
        requiredSatisfied(qid);
        image.src = "/icons/transdot.gif";
      }
    }
    else {
      // It's probably OK, and we can just mark it as such
      requiredSatisfied(qid);
      image.src = "/icons/transdot.gif";
    }
  }
  return true;
}

function checkLoadPassword() {
  var element = document.forms['load_form'].elements['load_password'];
  if (element.value.length == 0) {
    alert(_('Please enter your password before selecting "Load".'));
    return false;
  }
  return true;
}


function lengthCheck(qid,type,length){
  var fieldname = "eval_q_"+qid;
  var element = document.forms['eval_form'].elements[fieldname];
  if (element.value.length >= length) {
	element.value = element.value.substring(0,length );
	alert(_("Your answer must be less than ")+length+_(" characters."));
	return false ;
  } 
  return true;
}

function requiredSatisfied(qid){
	for (var i = 0; i < requiredObject.length; i++){
		if (requiredObject[i].id == qid){
			requiredObject[i].satisfied = 1;
			return;
		}
	}
}

function markRequired(qid){
	requiredObject.push({id:qid, required:1,satisfied:0 });
}


function open_eval_edit_window(school,eval_id){
 	var params = "width=700,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes";
 	window.open('/protected/eval/administrator/eval_edit/' + school + '/' + eval_id, "_blank", params);
}

function open_delete_window(school,eval_id){

	if (confirm("Do you want to delete eval_id " + eval_id + "?")) {
		var params = "width=580,height=470,directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=no";
		window.open('/tusk/eval/administrator/delete/' + school + '/' + eval_id, "_blank", params);
	} 
}

function verifyDates(available_date, due_date) {
	var errmsg = new Array;
	var check_date_range = 1;
	var available_date_object;
	var due_date_object;

	if (available_date.value){
		available_date_object = make_date_no_time_object(available_date.value);
		if (available_date_object == 'Invalid Date') {
			errmsg.push(_("Please use the format YYYY-MM-DD for the available date."));
			check_date_range = 0;
		}
	} else {
		errmsg.push(_("Please enter the available date (YYYY-MM-DD)."));
	}

	if (due_date.value){
		due_date_object = make_date_no_time_object(due_date.value);
		if (due_date_object == 'Invalid Date'){
			errmsg.push(_("Please use the format YYYY-MM-DD for due date."));
			check_date_range = 0;
		}
	} else {
		errmsg.push(_("Please enter the due date (YYYY-MM-DD)."));
	}


	if (check_date_range && due_date.value && available_date.value){
		if (due_date_object < available_date_object){
			errmsg.push(_("Please make sure the due date is after the available date."));
		}
	}

	return errmsg;
}


function isCourseUserSelected(theElement) {
	if (!theElement) {
		return false;
	}

	var i = 0;
	for (i = 0; i < theElement.length; i++) {
		if (theElement[i].checked == true) {
			return true;
		}
	}

	if (theElement.checked == true) {
		return true;
	}
	
	return false;
}


function verifyCreateEvalsByUser() {
	var errmsg = new Array;

	var dates_errmsg = verifyDates(document.bulkevalsbyuser.available_date, document.bulkevalsbyuser.due_date);

	if (dates_errmsg) {
		errmsg = dates_errmsg;
	}

	if (!document.bulkevalsbyuser.template_eval_id.value) {
		errmsg.push(_('Please enter a Template Eval ID.'));
	}

	if (!document.bulkevalsbyuser.title.value) {
		errmsg.push(_('Please enter a title.'));
	}

	if (!document.bulkevalsbyuser.time_period_id.value) {
		errmsg.push(_('Please select a time period.'));
	}

	if (!document.bulkevalsbyuser.course_id.value) {
		errmsg.push(_('Please select a course.'));
	}

	if (!isCourseUserSelected(document.bulkevalsbyuser.course_user)) {
		errmsg.push(_('Please select at least one faculty/staff.'));
	}

	if (errmsg.length){
		alert(errmsg.join("\n"));
		return false;
	} 

	if (confirm(_('Do you want to create evaluations?'))) {
		return true;
	} else {
		return false;
	}
}



function verify_create_bulk_evals_submit() {

	var errmsg = new Array;

	var dates_errmsg = verifyDates(document.createbulkevals.available_date, document.createbulkevals.due_date);

	if (dates_errmsg) {
		errmsg = dates_errmsg;
	}

	if (!document.createbulkevals.time_period_id.value) {
		errmsg.push(_('Please select a time period.'));
	}

	if (errmsg.length){
		alert(errmsg.join("\n"));
		return false;
	} 

	if (confirm(_('Do you want to create evaluations for selected time period?'))) {
		return true;
	} else {
		return false;
	}
}


function verifyForward(destination, eval_id) {
	var dest = destination.value;
	if (dest) {
		var del = /delete/;
		var result = dest.match(del);

		if (result == null) {
			if (destination.selectedIndex > 0) {
				location.href = dest;
			}
		} else {
			if (confirm(_('Do you want to delete eval id ') + eval_id + ' ?')) {
				location.href = dest;
			} 
		} 
	} 

	destination.selectedIndex = 0;
}


function verifyOtherEvalTools() {
	var destination = document.other_eval_tools.url;
	if (!destination.value) {
		alert(_('Please select an evaluation tool.'));
		return false;
	} else {
		return true;
	}
	destination.selectedIndex = 0;
}


function forwardOtherEvalTools() {
	var destination = document.other_eval_tools.url;
	if (destination.selectedIndex > 0) {
		location.href = destination.value;
	}
	destination.selectedIndex = 0;
}



function verifyShowEvalsByTimePeriod() {
	var time_period = document.show_evals_by_time_period.time_period_id;
	if (!time_period.value) {
		alert(_('Please select a time period.'));
		return false;
	} 
	return true;
}


function verifyShowEvalsByCourse() {
	var course = document.show_evals_by_course.course_id;
	if (!course.value) {
		alert(_('Please select a course.'));
		return false;
	} 
	return true;
}
