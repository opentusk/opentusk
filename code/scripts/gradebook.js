function event_submit(form){
	if (!form.event_name.value){
		alert("Please enter a grade event name.");
		return false;
	}
	return true;
}

function categorySubmit(form) {
	var selectlist = document.getElementsByTagName('select');
	for (var i = 0; i < selectlist.length; i++) {
		if (selectlist[i].id == 'layerselect') {
			for (var j = 0; j < selectlist[i].options.length; j++) {
				if (selectlist[i].options[j].selected == true && selectlist[i].options[j].value == '-1') {
					alert("Please select a code");
					return false;
				}
			}
		}
	}
	return true;
}

function showHideMultiSite(element) {
	var multisite = document.getElementById('multi_site_tr');
	multisite.style.display = (element.selectedIndex == 0) ? '' : 'none';
}


function updateGradeStatus(elem_name) {
	var elem = document.createElement('input');
	elem.setAttribute("type", "hidden");
	elem.setAttribute("name", elem_name);
	elem.setAttribute("value", 1);
	document.forms['gradeaddeeditbystudent'].appendChild(elem);
}


function changeFailedGrade(elem_value) {
	var elem = document.createElement('input');
	elem.setAttribute("type", "hidden");
	elem.setAttribute("name", "failed_grade_changed");
	elem.setAttribute("value", elem_value);
	document.forms['gradefail'].appendChild(elem);
}


function updateWeights() {
	var sum = 0;
	for (var i = 0; i < itemNum; i++) {
		var elem = document.getElementById('item_' + i);
		var val = parseInt(elem.value);
		if (!isNaN(val))
		sum += val;
	}
	document.getElementById('totalWeight').value = sum;
}


function submitGradeFinal(form) {

	if (form.total_weight.value == 0) {
		alert("Please assign weight to events before calculating final grades\n");
		return false;
	}

	if (!form.event_name.value){
		alert("Please enter a grade event name.");
		return false;
	}

	return true;
}


function updateFinalGradeMetaData(elem) {
	var newelem = document.createElement('input');
	newelem.setAttribute("type", "hidden");
	newelem.setAttribute("name", elem.name + '_changed');
	newelem.setAttribute("value", 1);
	document.forms['gradefinal'].appendChild(newelem);
}
