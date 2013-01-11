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


function addToLayer(){
	if (!(document.forms.course.code.value)){
		alert(_('Please enter a course code.'));
		return false;
	}
	var newdata = {course_code_id:'0',code_type:'SIS',code:document.forms.course.code.value};
	layers['codesdiv'].adddata(newdata,0);
}


function hide_error(id){
	document.getElementById(id).style.visibility="hidden";
	return;
}

window.onload = function() {
	adjustXtraFields(document.getElementById('cr_type'));
};
