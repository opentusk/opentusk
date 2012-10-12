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


var xRequest = null;
var tableBody;

function requestCourseUsers(course,url,school) {
	xRequest = initXMLHTTPRequest();
	if (xRequest) {
		var params = 'course_id=' + course.value + '&school=' + school;
		xRequest.open("POST", url, true);
		xRequest.onreadystatechange = showCourseUsers;
		xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xRequest.send(params);
	}
}


function showCourseUsers() {
	if (xRequest.readyState == 4) {
		var response = xRequest.responseXML;

	    	if (!response) {
		        if(xRequest.status && (xRequest.status == 200)) {
				alert(_('Please select a course.'));
			}
		} else {
			var courseUsers = response.getElementsByTagName('courseUsers');
		        var users = courseUsers[0].getElementsByTagName('user');

			tableBody = document.getElementById('usersTable').getElementsByTagName("tbody").item(0);
			removeAllRows();	

			if (users.length == 0) {
				printNoResults();	
			} else {
				printUsers(users);
			}
		}
	} 
}


function selectUnselectAll() {
	var checkboxes = document.getElementsByName('course_user');
	var checkall = document.getElementById('checkall');

	var i = 0;
	for (i = 0; i < checkboxes.length; i++) {
		if (checkboxes[i].type == 'checkbox' && checkboxes[i].name != 'checkall') {
			checkboxes[i].checked = checkall.checked;
		}
	}

}


function printSelectAll() {
	var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.colspan = 3;
	var checkbox = document.createElement('INPUT');
	checkbox.type = 'checkbox';
	checkbox.name = 'checkall';
	checkbox.id = 'checkall';

	if (checkbox.addEventListener) {
		  checkbox.addEventListener('click', selectUnselectAll, false);
	} else if (checkbox.attachEvent) {
		checkbox.attachEvent('onclick', selectUnselectAll);
	} else {
		checkbox.onclick = selectUnselectAll;
	}

	var textnode = document.createTextNode(' select/unselect all');
	col.appendChild(checkbox);
	col.appendChild(textnode);
	row.appendChild(col);
	tableBody.appendChild(row);
}


function printNoResults() {
	var row = document.createElement("TR");
	var col = document.createElement("TD");
	var textnode = document.createTextNode('No faculty/staff for selected course.');
	col.appendChild(textnode);
	row.appendChild(col);
	tableBody.appendChild(row);
	document.getElementById('course_users_instruction').style.display = 'none';
}


function printUsers(users) {
	if (users.length > 3) {
		printSelectAll();
	}

	for (var i = 0; i < users.length; i = i+3) { 
		var row = document.createElement("TR");
		for (var j = i; j < i+3 && j < users.length; j++) {
			var col = document.createElement("TD");
			col.id = 'item_' + i;
			var checkbox = createCheckbox(users[j].getAttribute('id'));
			var textnode = document.createTextNode(' ' + users[j].getAttribute('name'));
			col.appendChild(checkbox);
			col.appendChild(textnode);
			row.appendChild(col);
		}
		tableBody.appendChild(row);
	}

	document.getElementById('course_users_row').style.display = 'inline';
}


function createCheckbox(userId) {
	var checkbox = document.createElement('INPUT');
	checkbox.type = 'checkbox';
	checkbox.name = 'course_user';
	checkbox.id = 'course_user';
	checkbox.defaultChecked = false;
	checkbox.value = userId;
	return checkbox;
}


function removeAllRows() {
	var node = tableBody;
	if (node && node.hasChildNodes && node.removeChild) {
		while (node.hasChildNodes()) {
			node.removeChild(node.firstChild);
		}
	}
}
