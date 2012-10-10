// Copyright 2012 Tufts University 
//
// Licensed under the Educational Community License, Version 1.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//
// http://www.opensource.org/licenses/ecl1.php 
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and 
// limitations under the License.


var xRequest = null;
var loadingContent = 0;
var tableBody = null;
var loadingImage = new Image();
loadingImage.src = "/graphics/pleasewait.gif";

function showLoading() {
  loadingContent = 1;
  document.body.style.cursor='wait';
  tableBody = document.getElementById('theTable').getElementsByTagName("tbody").item(0);;
  var loadingImageDiv = document.getElementById('loadingDiv');
  if(loadingImageDiv) {
    if(!document.body.scrollTop) {document.body.scrollTop = 0;}
    if(!document.body.scrollLeft) {document.body.scrollLeft = 0;}

    var windowWidth;
    if(window.innerWidth)              {windowWidth = window.innerWidth;}
    else if(document.body.offsetWidth) {windowWidth = document.body.offsetWidth;}
    else                               {windowWidth = 0;}

    var windowHeight;
    if(window.innerHeight)              {windowHeight = window.innerHeight;}
    else if(document.body.offsetHeight) {windowHeight = document.body.offsetHeight;}
    else                                {windowHeight = 0;}

    loadingImageDiv.style.top = ((windowHeight/2)-50+document.body.scrollTop) + "px";
    loadingImageDiv.style.left = ((windowWidth/2)-100+document.body.scrollLeft) + "px";

    loadingImageDiv.style.display='';
    document.getElementById('theLoadingImage').src = loadingImage.src;
  }
}


function hideLoading() {
	var loadingImageDiv = document.getElementById('loadingDiv');
	if (loadingImageDiv) {
		loadingImageDiv.style.display='none';
		document.body.style.cursor='';
	}
	loadingContent = 0;
}


function initXMLHTTPRequest() {

	var xReq = null;
	if (window.XMLHttpRequest) {
		xReq = new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		try {
		      	xReq = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (err) {
		      	xReq = new ActiveXObject("Microsoft.XMLHTTP");			
		}
	}

	return xReq;
}


function requestEvalSearch(url,params) {

	showLoading();
	xRequest = initXMLHTTPRequest();
	if (xRequest) {
		xRequest.open("POST", url, true);
		xRequest.onreadystatechange = showEvalResults;
		xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xRequest.send(params);
	}
}


function showEvalResults() {

	if (xRequest.readyState == 4) {
		var response = xRequest.responseXML;

	    	if (!response) {
			hideLoading();
		        if(xRequest.status && (xRequest.status == 200)) {
				alert('Sorry. We cannot get results for this search!');
				history.back();
			}
		} else {

			var evalResults = response.getElementsByTagName('evalResults');
			var school = evalResults[0].getAttribute('school');
			var evals = evalResults[0].getElementsByTagName('eval');
			var mergedEvals = evalResults[0].getElementsByTagName('mergedEval');

			if (evals.length == 0 && mergedEvals.length == 0) {
				printNoResults();	
			} else {
				printEvalResults(evals,mergedEvals,school);
			}
			hideLoading();
		}
	} 
}


function printEvalResults (evals,mergedEvals,school) {	

	if (evals.length) {
		headerRow('Single Eval Results');
	}

	for (var i = 0; i < evals.length; i++) { 
		var evalId = evals[i].getAttribute('id');
		var evalIdUrl = "<a href=\"#\" onClick=\"newEvalPage('/hsdb45/eval/report/" + school + "/" + evalId + "')\">" + evalId + "</a>";

		createRow('Eval Title:', evals[i].getElementsByTagName('title')[0].firstChild.nodeValue + ' &nbsp;<span class="smallfont">(#' + evalIdUrl + ')</span>');
		var course = evals[i].getElementsByTagName('course')[0].firstChild;
		var course_id = (course.parentNode.getAttribute('id').length > 0) ? ' &nbsp;<span class="smallfont">(#' + course.parentNode.getAttribute('id') +  ')</span>' : '';
		createRow('Course:', course.nodeValue + course_id);
		createRow('Time Period:', evals[i].getElementsByTagName('timePeriod')[0].firstChild.nodeValue);

		printQuestions(evals[i]);

		spacingRow();
	}

	if (mergedEvals.length) {
		headerRow('Merged Eval Results');
	}

	for (var i = 0; i < mergedEvals.length; i++) { 
		var mergedEvalId = mergedEvals[i].getAttribute('id');
		var mergedEvalIdUrl = "<a href=\"#\" onClick=\"newEvalPage('/eval/merged_report/" + school + "/" + mergedEvalId + "')\">" + mergedEvalId + "</a>";
		var primaryEvalIdUrl = "<a href=\"#\" onClick=\"newEvalPage('/hsdb45/eval/report/" + school + "/" + mergedEvals[i].getElementsByTagName('primaryEval')[0].getAttribute('id') + "')\">" + mergedEvals[i].getElementsByTagName('primaryEval')[0].getAttribute('id') + "</a>";

		createRow('Merged Eval Title:', mergedEvals[i].getElementsByTagName('title')[0].firstChild.nodeValue + ' &nbsp;<span class="smallfont">(#' + mergedEvalIdUrl + ')</span>');
		createRow('Primary Eval:', mergedEvals[i].getElementsByTagName('primaryEval')[0].firstChild.nodeValue + ' &nbsp;<span class="smallfont">(#' + primaryEvalIdUrl + ')</span>');
		var secondaryRows = "<p class='xsm'>";
		var secondaryTags = mergedEvals[i].getElementsByTagName('secondaryEvals')[0].getElementsByTagName('secondaryEval');
		var idlink = "";
		for (var j = 0; j < secondaryTags.length; j++) {
			idlink = " (#<a href=\"#\" onClick=\"newEvalPage('/hsdb45/eval/report/" + school + "/" + secondaryTags[j].getAttribute('id') + "')\">" + secondaryTags[j].getAttribute('id') + "</a>)";
			secondaryRows += secondaryTags[j].firstChild.nodeValue;
			secondaryRows += idlink;
			secondaryRows += "<br />";
		}
		createRow('Secondary Evals:', secondaryRows + '</p>');
		printQuestions(mergedEvals[i]);
		spacingRow();
	}
}


function printQuestions (evalTag) {
	var questions = evalTag.getElementsByTagName('question');
	for (var i = 0; i < questions.length; i++) {
		var questionId = questions[i].getAttribute('id');
		createRow('Question &nbsp;<span class="smallfont">(#' + questionId  + ')</span>:', questions[i].getElementsByTagName('questionText')[0].firstChild.nodeValue);

		var responses = questions[i].getElementsByTagName('response');
		createRow('Responses:', responses[0].firstChild.nodeValue);
	}
}

function spacingRow () {
	var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.innerHTML = '&nbsp;';
	row.appendChild(col);
	row.appendChild(col);
	tableBody.appendChild(row);
}

function headerRow (text) {
	var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.innerHTML = '<h3>' + text + '</h3>';
	row.appendChild(col);
	row.appendChild(col);
	tableBody.appendChild(row);
}

function createRow (title,text,num) {
	var row = document.createElement("TR");
	row.appendChild(createColumn(title,1));
	row.appendChild(createColumn(text,0));
	row.id = 'export' + num;
	tableBody.appendChild(row);
}

function createColumn (text,label){
	var col = document.createElement("TD");
	if (label) col.className = 'labelgray';
	col.innerHTML = text;
	return col;
}


function printNoResults() {
	var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.innerHTML = '<div class="sm">There are no matched results.</div>';
	row.appendChild(col);
	tableBody.appendChild(row);
}


function showHide(switchContent) {
	var currContent = document.getElementById('switchContent');
	currContent.style.display = (currContent.style.display == "none") ? 'inline' : 'none';
		
}

var exportForm = document.createElement('form');

function exportContent(searchString,school) {

	var url = '/eval/administrator/search/export';

	exportForm.action = url;
	exportForm.method = 'POST';

	addElement2Form('newBody', getMainContent());
	addElement2Form('search_string', searchString);
	addElement2Form('school', school);

	exportForm.style.display = 'none';
	document.body.appendChild(exportForm);
	exportForm.submit();
}


function addElement2Form(iname,ivalue) {
	var input = document.createElement('input');
	input.name = iname;
	input.value = ivalue;
	exportForm.appendChild(input);
}


function getMainContent() {
	var docTable = document.getElementById('theTable');
	return '<table>' + docTable.innerHTML + '</table>';
}


function newEvalPage(url) {
	params = "directories=no,menubar=yes,toolbar=no,scrollbars=yes,location=no,resizable=yes";
	window.open(url,'_blank',params);
}


function isBlank(str) {
	for (var i = 0; i < str.length; i++) {
		var c = str.charAt(i);
		if ((c != ' ') && (c != '\n') && (c != '')) {
			return false;
		}
	}
	return true;
}


function setIncludeChecks(checkboxObj) {
//	include
//		- merged
//		- single
//		- outsidetime
//		- onlysingle
	var name = checkboxObj.value;
	var form = checkboxObj.form;
	switch (name) {
		case "merged":
			if (checkboxObj.checked) {
				form.outsidetime.disabled = false;
				document.getElementById('outsidetimelabel').className = "";
			}
			else {
				form.outsidetime.disabled = true;
				form.outsidetime.checked = false;
				document.getElementById('outsidetimelabel').className = "disabled";
			}
			break;
		case "single":
			if (checkboxObj.checked) {
				form.onlysingle.disabled = false;
				document.getElementById('onlysinglelabel').className = "";
			}
			else {
				form.onlysingle.disabled = true;
				form.onlysingle.checked = false;
				document.getElementById('onlysinglelabel').className = "disabled";
			}
			break;
		case "onlysingle":
			if (checkboxObj.checked) {
			}
			break;
	}
}


function verify(form) {
	var search = form.search_string;
	if (isBlank(search.value)) {
		alert("Name/Keyword field is required!\n");
		return false;
	}
	// check to make date information has been entered
	if (isBlank(form.start_time_period_id.value) && isBlank(form.end_time_period_id.value) && isBlank(form.start_available_date.value) && isBlank(form.end_available_date.value) && isBlank(form.start_due_date.value) && isBlank(form.end_due_date.value)) {
		alert("Time period or available/due date fields are required!\n");
		return false;
	}
	// if one time period has been entered, make sure other time period id field has been filled out, too
	else if ((isBlank(form.start_time_period_id.value) && !isBlank(form.end_time_period_id.value)) || (!isBlank(form.start_time_period_id.value) && isBlank(form.end_time_period_id.value))) {
		alert("To narrow down the results by time period, please select both a beginning time period and an ending time period!\n");
		return false;
	}
	// if one available date has been entered, make sure other available date field has been filled out, too
	else if ((isBlank(form.start_available_date.value) && !isBlank(form.end_available_date.value)) || (!isBlank(form.start_available_date.value) && isBlank(form.end_available_date.value))) {
		alert("To narrow down the results by available date, please select both a beginning available date and an ending available date!\n");
		return false;
	}
	// if one due date has been entered, make sure other due date field has been filled out, too
	else if ((isBlank(form.start_due_date.value) && !isBlank(form.end_due_date.value)) || (!isBlank(form.start_due_date.value) && isBlank(form.end_due_date.value))) {
		alert("To narrow down the results by due date, please select both a beginning due date and an ending due date!\n");
		return false;
	}
	// make sure either "merged evals" or "single evals" is checked
	else if (!form.include[0].checked && !form.include[1].checked) {
		alert("At least one type of evaluation (merged or single) must be included!\n");
		return false;
	}

	return true;
}
