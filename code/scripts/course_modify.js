function addToLayer(){
	if (!(document.forms.course.code.value)){
		alert('Please enter a course code.');
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