function showHideDiv(name) {
	var mydiv = document.getElementById(name);
	mydiv.style.display = (mydiv.style.display == 'none') ? 'block' : 'none';
	//mydiv.style.visibility = (mydiv.style.visibility == 'hidden') ? 'visible' : 'hidden';
}

function reload_scale(scale_id){
	var new_location = location.href;
	var re = new RegExp('\\?.*');
	new_location = new_location.replace(re, '');
	var get_string = '';
	if (scale_id){
		get_string = '?scale_id=' + scale_id;
	}
   
	window.location = new_location + get_string;
}

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

var ajaxRequest;

function requestScale(scaleID) {

  var url = "/tusk/ajax/getGradeScale/"+scaleID;

  if (window.XMLHttpRequest) {
      ajaxRequest = new XMLHttpRequest();
      nodeTextType = 'textContent';
  } else if (window.ActiveXObject) {
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      nodeTextType = 'text';
  } else {
	var location = document.URL;

	alert('You are being transfered because your browser does not support AJAX.');
	document.location = location;
  }

  ajaxRequest.open("GET", url, true);
  // the following trickery is interesting
  ajaxRequest.onreadystatechange = function() { if(ajaxRequest.readyState ==4) { showScale(scaleID) } };;	
  ajaxRequest.send(null);

}

function showScale(scaleID) {

  var id;  var title; var url;

  if(!ajaxRequest) {return;}
  if(ajaxRequest.readyState == 4) {
//	alert(ajaxRequest.responseText);
    var response = ajaxRequest.responseText;
    if(!response) {
	
      if(ajaxRequest.status && (ajaxRequest.status == 200)) {
			alert('Unable to get the Scale!');
		}
    }
    else {

	 document.getElementById("td_"+scaleID).innerHTML = response;

    } //else (response exists)

  } // if readystate == 4

}