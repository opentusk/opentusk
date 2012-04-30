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



function check_userid(){
	var user_fld = document.getElementById('userid'); 
	var err_elt = document.getElementById('errmsg');
	var err_flag = false;

	if(!user_fld.value){
		err_elt.innerHTML = 'Please enter a value for UserID';
		err_flag = true;
	}
	if(user_fld.value.indexOf("\/") > 0){
		err_elt.innerHTML = 'UserID cannot contain a forward slash "/"';
		err_flag = true;
	}
	if(err_flag){
		show(err_elt);
		user_fld.focus();
		return false;
	}
}