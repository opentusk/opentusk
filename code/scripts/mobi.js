function isValidDate(m, d, y){

	m--;

	var months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	if(y>999 && y<10000){
		if(isLeapYear(y)){
			months[1] = 29;
		}
		if(m>=0 && m<12){
			if(d>0 && d<=months[m]){
				return true;
			}
		}
	}
	return false;
}

function isLeapYear(year){
	if(year%4 == 0){ // could be leap year
		if(year%100 || (year%100 == 0 && year%400 == 0)){
			return true;
		}
	}
	return false;
}

function submit_with_action ( newaction )
{
	document.forms[0].action = newaction;
	document.forms[0].submit();
	return false;
}
