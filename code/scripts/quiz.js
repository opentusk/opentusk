function question_remove (layer,id){
        var pk ;
        if (layer == 'questionsdiv'){
                pk = layers[layer].structure.data[id].question_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/quiz/author/questiondelete/" + context_path + "/"+pk;
                } 
        }

}

function case_question_remove (layer,id){
        var pk ;
        if (layer == 'questionsdiv'){
                pk = layers[layer].structure.data[id].question_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/case/author/questiondelete/" + context_path + "/"+pk;
                } 
        }

}
function question_edit (layer,id){
        var pk ;
        if (layer == 'questionsdiv'){
                pk = layers[layer].structure.data[id].question_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/quiz/author/questionaddedit/" + context_path + "/"+pk;
                }  
        }

}

function case_question_edit (layer,id){
        var pk ;
        if (layer == 'questionsdiv'){
                pk = layers[layer].structure.data[id].question_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/case/author/questionaddedit/" + context_path + "/"+pk;
                }  
        }

}

function answer_remove (layer,id){
        var pk ;
        if (layer == 'answersdiv'){
                pk = layers[layer].structure.data[id].answer_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/quiz/author/answerdelete/" + context_path + "/" + pk;
                } 
        }

}

function answer_edit (layer,id){
        var pk ;
        if (layer == 'answersdiv'){
                pk = layers[layer].structure.data[id].answer_id;
		context_path = layers[layer].structure.context_path;
                if(pk != null){
                        window.location = "/quiz/author/answeraddedit/" + context_path + "/" + pk;
                }  
        }

}


function quiz_submit(form){
	var errmsg = new Array;
	var due_date;
	var available_date;
	var check_date_range = 1;

	if (!form.title.value){
		errmsg.push("Please enter a quiz title.");
	}

	if (form.available_date.value){
		available_date = make_date_object(form.available_date.value);
		if (available_date == 'Invalid Date'){
			errmsg.push("Please use the format YYYY-MM-DD HH:MM for the available date.");
			check_date_range = 0;
		}
	}

	if (form.due_date.value){
		due_date = make_date_object(form.due_date.value);
		if (due_date == 'Invalid Date'){
			errmsg.push("Please use the format YYYY-MM-DD HH:MM for due date.");
			check_date_range = 0;
		}
	}

	if (check_date_range && form.due_date.value && form.available_date.value){
		if (due_date < available_date){
			errmsg.push("Please make sure the due date is after the available date.");
		}
	}

	if (errmsg.length){
		alert(errmsg.join("\n"));
		return false;
	}else{
		return true;
	}
}

function question_submit_core(form, return_flag){
	var errmsg = new Array;
	var questionType;

	if (form.question_type && form.question_type.type == 'select-one'){
		if (!form.question_type.options[form.question_type.selectedIndex].value){
			errmsg.push("Please select a question type.");
		} else {
			questionType = form.question_type.options[form.question_type.selectedIndex].value;
		}
	} else {
		questionType = form.question_type.value;
	}

	if (!form.body && !form.body.value){
		errmsg.push("Please enter a question body.");
	}

	var loop_flag = false;
	var correct_flag = false;

	if (questionType != 'FillIn' && questionType != 'MultipleFillIn'){
		for(i=0; i<form.elements.length; i++){
			if (form.elements[i].name.match('__correct__') && form.elements[i].type != 'hidden'){
				loop_flag = true;
				var name = form.elements[i].name;
				var answer = name.replace('__correct__', '__answer__');
				if (form.elements[i].selectedIndex == 1 && form.elements[answer].value != ''){
					correct_flag = true;
					break;
				}
			}
		}
	}

	if (correct_flag == false && loop_flag == true){
		errmsg.push("Please select a correct answer.");
	}

	if (return_flag){
		return errmsg;
	}else{
		if (errmsg.length){
			alert(errmsg.join("\n"));
			return false;
		}else{
			return true;
		}
	}
}

function question_submit_all(form){
	var errmsg = question_submit_core(form, 1);

	if (form.question_type.value != 'Section'){
		if (!form.points.value){
			errmsg.push("Please enter question points.");
		}else if (form.points.value <= 0){
			errmsg.push("Please enter a positive question points.");
		}else if (parseFloat(form.points.value) != form.points.value){
			errmsg.push("Please only use numeric chars for points.");
		}
	}

	if (errmsg.length){
		alert(errmsg.join("\n"));
		return false;
	}else{	
		return true;
	}
}

function check_quiz(clickButton) {
	var forgotmessage = '';
	var counter = 0;
	var radio = Array;
	var form = document.takequiz;

	clickSubmit();

	if (clickButton == 'Continue' || clickButton == 'Done?') {
		return 1;
	}

	for (var i = 0; i < form.elements.length; i++){
		if (parseInt(form.elements[i].name) > 0){
			if (form.elements[i].type == "radio"){
				if (!radio[form.elements[i].name]){
					radio[form.elements[i].name] = form.elements[i].checked;
				}
			} else if ((form.elements[i].type == "textarea" || form.elements[i].type == "text") && form.elements[i].value == ""){
				counter++;
			}
		}
	}

	for (var element in radio){
		if (!radio[element]){
			counter++;
		}
	}

	if (counter){
		var s = "s";
		if (counter == 1){
			s = "";
		}
		forgotmessage = "You have left " + counter + " question" + s + " unanswered.\n";
	}

	if (clickButton == 'Next Page') {
		if (forgotmessage) {
			alert(forgotmessage);
		}
	} else {
		return confirm(forgotmessage + 'Are you sure you want to submit?');
	}
}


function toggle_clock(button){
	if (button.value == 'Show Clock'){
		document.getElementById('timer').style.display = 'inline';
		document.getElementById('show_clock').value = 1;
		button.value = 'Hide Clock';
	} else {
		document.getElementById('timer').style.display = 'none';
		document.getElementById('show_clock').value = 0;
		button.value = 'Show Clock';
	}
}


function verifyQuestionsCopy() {
	var at_least_one = 0;
	var quiz_ids = document.questionscopy.source_quiz_id;
	for (var i = 0; i < quiz_ids.length; i++) {
		if (quiz_ids[i].checked) {
			at_least_one = 1;
		}
	}

	var quiz_id_list = document.questionscopy.source_quiz_id_list;
	if (quiz_id_list.value) {
		var list = /^[\d,]+$/;
		var val = quiz_id_list.value;
		var result = val.match(list);

		if (result == null) {
			alert('Incorrect quiz id list format.\nOnly digits and commas, not space.');
			return false;
		} else {
			at_least_one = 1;
		}
	}

	if (at_least_one) {
		return true;
	} else {
		alert('Please select/enter a quiz you like to copy from.');
		return false;
	}
}


function verifySelectedQuestionsCopy() {

	var question_ids = document.questionselectedcopy.question_id;
	for (var i = 0; i < question_ids.length; i++) {
		if (question_ids[i].checked) {
			return true;
		}
	}

	alert('Please select at least a question.');
	return false;
}


function showHide(switchContent) {
	var currContent = document.getElementById('switchContent');
	currContent.style.display = (currContent.style.display == "none") ? 'inline' : 'none';
		
}


function validateNumber(score) {
	var num = /^[0-9\.]+$/;
	var val = score.value;
	var result = val.match(num);

	if (result == null) {
		alert('Only numbers are allowed in score column. You entered ' + val);
	}
}

function updateGradedPoints(index) {
	document.quizresponses.response_id[index].checked = true;
}


function updateDeleteCheckbox() {

	var keys = document.questionsdelete.question_keys;

	for (var i = 0; i < keys.length; i++) {
		var ids = keys[i].value.split('_');
	}
}

function showHideQuestions(button,quizId){
	if (button.value == 'Show Questions'){
		document.getElementById(quizId).style.display = 'inline';
		document.getElementById(quizId).value = 1;
		button.value = 'Hide Questions';
	} else {
		document.getElementById(quizId).style.display = 'none';
		document.getElementById(quizId).value = 0;
		button.value = 'Show Questions';
	}
}


