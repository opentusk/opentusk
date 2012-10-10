function val_date_form(){
	var f = document.mplogform;

	if(isValidDate(f.showdate_month.value, f.showdate_day.value, f.showdate_year.value)){
		return true;
	}

	alert('Please enter a valid date.');
	return false;
}