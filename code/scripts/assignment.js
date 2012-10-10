function verifyAuthorAddedit(form) {

	var errmsg = new Array();
	var available_date;
	var due_date;

	if (!form.title.value) {
		errmsg.push('Please enter an assignment title.');
	}


	if (form.available_date.value) {
		available_date = make_date_object(form.available_date.value);
		if (available_date == 'Invalid Date'){
			errmsg.push("Please use the format YYYY-MM-DD HH:MM for the available date.");
		}
	}

	if (form.due_date.value) {
		due_date = make_date_object(form.due_date.value);
		if (due_date == 'Invalid Date'){
			errmsg.push("Please use the format YYYY-MM-DD HH:MM for due date.");
		}
	}

	if (available_date > due_date) {
		errmsg.push("Please make sure that the due date is after the available date.");
	} 

	if (form.group_flag[0].checked) {
		if (!isCheckedAtLeastOne(form.group_id_list)) {
			errmsg.push("Please select at least one assignment group.\n");
		}
	}

	if (errmsg.length) {
		alert(errmsg.join("\n"));
		return false;
	}

	if (confirmDelete(document.addeditassignment.del_content_id)) {
		return true;
	} else {
		return false;
	}

	return true;
}

function isCheckedAtLeastOne(groups) {
	if (groups instanceof HTMLInputElement) {
		if (groups.checked == true) {
			return true;
		}
	} else {
		for (var i = 0; i < groups.length; i++) {
			if (groups[i].checked == true) {
				return true;
			}
		}
	}
	return false;
}

function verifyGradeUpdate(form) {
	var grade = form.grade;
	if (!isblank(grade)) {
		alert("Grade is required. " + grade.value);
		return false;
	}
	return true;
}


function verifyStudentSubmit() {
	var del = document.completeassignment.del_content_id;
	if (del) {
		if (del instanceof NodeList) {
			for (var i = 0; i < del.length; i++) {
				if (del[i].checked) {
					alert('You cannot delete files and submit assignment at the same time');
					return false;
				}
			}
		} else {
			if (del && del.checked) {
				alert('You cannot delete files and submit assignment at the same time');
				return false;
			}
		}
	}


	if (confirm("Do you want to submit your assignment?")) {
		return true;
	} else {
		return false;
	}
}

function verifyStudentSave() {

	if (confirmDelete(document.completeassignment.del_content_id)) {	
		return true;
	} else {
		return false;
	}
}


function confirmDelete(del) {

	if (del instanceof NodeList) {
		for (var i = 0; i < del.length; i++) {
			if (del[i].checked) {
				return (confirm("Do you want to delete your assignment file(s)?")) ? true : false;
			}
		}
	} else {
		if (del && del.checked) {
			return (confirm("Do you want to delete your assignment file(s)?")) ? true : false;
		}
	}

	return true;
}


function showHide(switchContent) {
	var currContent = document.getElementById(switchContent);
	currContent.style.display = (currContent.style.display == "none") ? 'inline' : 'none';
}

function showHideSubmission(button,submitId){
	if (button.value == 'Show') {
		document.getElementById(submitId).style.display = 'inline';
		document.getElementById(submitId).value = 1;
		button.value = 'Hide';
	} else {
		document.getElementById(submitId).style.display = 'none';
		document.getElementById(submitId).value = 0;
		button.value = 'Show';
	}
}

function addNote(button, note_area, save_note_button) {
	if (button.value == 'Add Note') {
		document.getElementById(note_area).style.display = 'inline';
		document.getElementById(save_note_button).style.display = 'inline';
		button.value = 'Discard';
	} else {
		document.getElementById(note_area).style.display = 'none';
		document.getElementById(save_note_button).style.display = 'none';
		button.value = 'Add Note';
	}
}
