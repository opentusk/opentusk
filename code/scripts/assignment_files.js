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


var form_count = 1;
var uploaded_group_ids = new Array();
var uploaded_form_count = 0;
var max_form_count = form_count;

function disableGroup() {
	if (groupsWithContent.length > 0) {
		alert(_("There are assignment files assigned to student groups. Please delete assignment files prior to resetting this flag."));
		document.addeditassignment.group_flag[0].checked = true;
		return;
	}

	if (document.addeditassignment.group_file_flag[0].checked == true) {
		if (confirm(_("Do you want to set group assignment file to 'No'?  This will reset the 'Each Group has its own uploaded files flag' to 'No' as well."))) {
			document.getElementById('group_list').style.display = "none";
			document.addeditassignment.group_file_flag[1].checked = true;
			removeGroup();
		} else {
			document.addeditassignment.group_flag[0].checked = true;
		}
	} else {
		document.getElementById('group_list').style.display = "none";
		var groups = document.addeditassignment.group_id_list;
		if (groups instanceof HTMLInputElement) {
			groups.checked = false;
		} else {
			for (var i = 0; i < groups.length; i++) {
				if (groups[i].checked == true) {
					groups[i].checked = false;
				}
			}
		}
	}
}


function verifyGroup() {
	if (hasGroups) {
		document.getElementById('group_list').style.display = "inline";
		return true;
	} else {
		alert(_("There are no groups associated with this course. Please create groups.\n\nNote that you might need to refresh this page if you have just created groups."));
		document.addeditassignment.group_flag[1].checked = true;
		return false;
	}
}


function isAssignmentGroupSelected() {

	var groups = document.addeditassignment.group_id_list;
	if (groups) {
		if (groups instanceof HTMLInputElement) {
			if (groups.checked) {
				return true;
			}
		} else {
			for (var i = 0; i < groups.length; i++) {
				if (groups[i].checked) {
					return true;
				}
			}
		}
	}
	return false;
}


function assignGroup() {
	if (document.addeditassignment.group_flag[0].checked == true) {
		if (isAssignmentGroupSelected()) {
			for (var i = 0; i < max_form_count; i++) {
				var nodeToReplace = document.getElementById('content');
				var currentChild = document.getElementById('sub_group_' + i);
				if (currentChild) {
					var newSelect = addGroupList(i);
					nodeToReplace.replaceChild(newSelect,currentChild);
				}
			}

			if (alreadyUploadedFormCount > 0) {
				alert(_("Please save changes first. Then, you will be able to select group for each assignment files that you have already uploaded.\n"));
			}

		} else {
			alert(_("Please select appropriate assignment groups from the list.\n"));
			document.addeditassignment.group_file_flag[1].checked = true;
		}
	} else {
		alert(_("Please select 'Yes' to group assignment, then select appropriate assignment groups from the list.\n"));
		document.addeditassignment.group_file_flag[1].checked = true;
	}

}


function removeGroup() {

	if (groupsWithContent.length > 0) {
		alert(_("Please delete all the uploaded files prior to changing this flag"));
		document.addeditassignment.group_file_flag[0].checked = true;
		return;
	}

	for (var i = 0; i < max_form_count; i++) {
		if (document.getElementById('sub_group_' + i)) {
			document.getElementById('sub_group_' + i).style.display = "none";
		} 

	}
}


function showUploadedGroup(count, currentUserGroupId, assignmentContentId) {
	uploaded_group_ids[uploaded_form_count] = [currentUserGroupId,assignmentContentId];
	uploaded_form_count++;

	var nodeToReplace = document.getElementById('uploadedcontent');
	var currentChild = document.getElementById('uploaded_sub_group_' + count);
	var newSelect = addGroupList(count, 1, currentUserGroupId, assignmentContentId);
	nodeToReplace.replaceChild(newSelect,currentChild);
}


function updateGroup(isLinkedToContent,index) {
	if (document.addeditassignment.group_flag[0].checked == true) {

		if (isLinkedToContent) {
			var label;
			var groups = document.addeditassignment.group_id_list;

			if (groups instanceof HTMLInputElement) {
				label = groups.getAttribute("label");
			} else{
				label = groups[index].getAttribute("label");
			}

			alert("Please delete the content assigned to '" + label + "', or reassign a new group to content prior to removing this group.");

			if (groups instanceof HTMLInputElement) {
				groups.checked = true;
			} else {
				groups[index].checked = true;
			}
		}

		if (document.addeditassignment.group_file_flag[0].checked == true) {
			for (var i = 0; i < max_form_count; i++) {
				var nodeToReplace = document.getElementById('content');
				var currentChild = document.getElementById('sub_group_' + i);
				if (currentChild) {
					var newSelect = addGroupList(i);
					nodeToReplace.replaceChild(newSelect,currentChild);
				}
			}
		}

		for (var i = 0; i < uploaded_form_count; i++) {
			var nodeToReplace = document.getElementById('uploadedcontent');
			var currentChild = document.getElementById('uploaded_sub_group_' + i);
			var newSelect = addGroupList(i,1,uploaded_group_ids[i][0],uploaded_group_ids[i][1]);
			nodeToReplace.replaceChild(newSelect,currentChild);
		}

	}
}


function addGroupList(count, uploadedFlag, groupId, assignmentContentId) {
	var idString = (uploadedFlag) ? 'uploaded_sub_group_' : 'sub_group_';
	var nameString = (uploadedFlag) ? 'uploaded_group_id' : 'group_id';
	var newSelect = document.createElement('select');
	newSelect.setAttribute('id', idString + count);
	newSelect.setAttribute('name', nameString);

	addOption(newSelect, (assignmentContentId) ? assignmentContentId + '_' + 0 : 0, 'select group');

	var groups = document.addeditassignment.group_id_list;
	if (groups instanceof HTMLInputElement) {
		if (groups.checked) {
			var selectFlag = (groupId == groups.value) ? 1 : 0;
			var val = (assignmentContentId) ? assignmentContentId + '_' + groups.value : groups.value;
			addOption(newSelect, val, groups.getAttribute("label"), selectFlag);
		}

	} else {

		for (var i = 0; i < groups.length; i++) {
			if (groups[i].checked) {
				var selectFlag = (groupId == groups[i].value) ? 1 : 0;
				var val = (assignmentContentId) ? assignmentContentId + '_' + groups[i].value : groups[i].value;
				addOption(newSelect, val, groups[i].getAttribute("label"), selectFlag);
			}
		}
	}
	return newSelect;
}


function addOption(sel, val, txt, selectFlag) {
	var o = document.createElement("option");
	var t = document.createTextNode(txt);
	o.setAttribute('value', val);
	if (selectFlag) {
		o.setAttribute('selected', true);
	}
	o.appendChild(t);
	sel.appendChild(o);
}


//add file attachment form and associated elements
function addFile() {

	var nodeToAdd = document.getElementById('content');
	var new_attachment = document.createElement('input');
	new_attachment.setAttribute('id', 'child_attachment_' + form_count);
	new_attachment.setAttribute('type', 'file');
	new_attachment.setAttribute('name', 'files');
	new_attachment.setAttribute('size', '40');

	nodeToAdd.appendChild(new_attachment);

	var newSelect = addGroupList(form_count);
	nodeToAdd.appendChild(newSelect);

	if (document.addeditassignment.group_file_flag[1].checked == true) {
		document.getElementById('sub_group_' + form_count).style.display = "none";		
	}

	var new_text = document.createElement('span');
	new_text.setAttribute('id','child_attachment_text_' + form_count);
	new_text.innerHTML = '&nbsp; <span style="color:#0000FF;cursor:pointer;text-decoration:underline;font-size:75%;" onclick="remove(' + form_count + ');">' + _("remove") + '</span><br/>';
	nodeToAdd.appendChild(new_text);

	//increase the form count
	form_count++;
	max_form_count = form_count;

	//if an attachment has been added, change text to "Attach another file"
	document.getElementById('more').innerHTML = _('Upload another file');
 } 


//remove file attachment form and associated elements
function remove(remove_form_num) {

/*
	if (remove_form_num != form_count-1) {
		alert("Please remove in descending order");
		return;
	}
*/
	form_count--; 	//decrease the form count

	document.getElementById('content').removeChild(document.getElementById('child_attachment_' + remove_form_num));

//	if (document.addeditassignment.group_flag[0].checked == true) {	
//	if (document.getElementById('sub_group_' + remove_form_num)) {
		document.getElementById('content').removeChild(document.getElementById('sub_group_' + remove_form_num));
//	}

	document.getElementById('content').removeChild(document.getElementById('child_attachment_text_' + remove_form_num));

	//if all forms are removed, change text back to "Attach a file"
	if (form_count == 0) {
     	  	document.getElementById('more').innerHTML = _('Upload a file');
	}
}


function checkUncheckAll(checkboxes,checkall) {
	
	if (checkall.checked == true) {
		for (var i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = true;
		}
	} else {
		if (groupsWithContent.length > 0) {
			alert(_("Please delete uploaded assignment files prior to deselecting these groups."));
			checkall.checked = true;
		} else {
			if (document.addeditassignment.group_file_flag[1].checked == true) {
				for (var i = 0; i < checkboxes.length; i++) {
					checkboxes[i].checked = false;

				}
			} else {
				alert(_("Please reset 'Each group has its own uploaded files' to 'no' prior to deselecting all the groups."));
				checkall.checked = true;
			}

		}
	}
}



