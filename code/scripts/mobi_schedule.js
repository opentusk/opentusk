function val_date_form(){
	var f = document.date_form;

	if(isValidDate(f.month.value, f.day.value, f.year.value)){
		return true;
	}

	alert('Please enter date in valid format.');
	return false;
}
