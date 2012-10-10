function validate_sl_addedit(){
	if(isBlank(document.forms.addedit.label)){
		alert('Please provide a value for "label".');
		document.forms.addedit.label.focus();
		return false;
	}
	return true;
}