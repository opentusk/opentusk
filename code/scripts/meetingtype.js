// 'mt' in fx() name below stands for "meeting type" and is included
// to avoid name collisions.
function mtValidateForm(form) {
	if (isBlank(form.label)) {
		alert('Please provide a value for "Label"');
		return false;
	}
	else {
		return true;
	}
}