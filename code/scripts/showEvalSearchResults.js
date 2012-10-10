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
//		document.write(params);
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
			createSearchForm(evalResults[0].getElementsByTagName('searchForm')[0].firstChild.nodeValue);
			var school = evalResults[0].getAttribute('school');
		        var evals = evalResults[0].getElementsByTagName('eval');

			if (evals.length == 0) {
				printNoResults();	
			} else {
				printEvalResults(evals,school);
			}
			hideLoading();
		}
	} 
}


function printEvalResults (evals,school) {	

	for (var i = 0; i < evals.length; i++) { 
		var evalId = evals[i].getAttribute('id');
		var evalIdUrl = "<a href=\"#\" onClick=\"newEvalPage('/hsdb45/eval/report/" + school + "/" + evalId + "')\">" + evalId + "</a>";

		createRow('Eval Title:', evals[i].getElementsByTagName('title')[0].firstChild.nodeValue + ' &nbsp;<span class="smallfont">(#' + evalIdUrl + ')</span>');
		var course = evals[i].getElementsByTagName('course')[0].firstChild;
		var course_id = (course.parentNode.getAttribute('id').length > 0) ? ' &nbsp;<span class="smallfont">(#' + course.parentNode.getAttribute('id') +  ')</span>' : '';
		createRow('Course:', course.nodeValue + course_id);
		createRow('Time Period:', evals[i].getElementsByTagName('timePeriod')[0].firstChild.nodeValue);
		var questions = evals[i].getElementsByTagName('question');
		for (var j = 0; j < questions.length; j++) {
			var questionId = questions[j].getAttribute('id');
			createRow('Question &nbsp;<span class="smallfont">(#' + questionId  + ')</span>:', questions[j].getElementsByTagName('questionText')[0].firstChild.nodeValue);

			var responses = questions[j].getElementsByTagName('response');
			createRow('Responses:', responses[0].firstChild.nodeValue);
		}
		spacingRow();
	}
}


function createSearchForm (text) {
        var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.colSpan = 2;
	col.innerHTML = text;
	row.appendChild(col);
	tableBody.appendChild(row);

}

function spacingRow () {
        var row = document.createElement("TR");
	var col = document.createElement("TD");
	col.innerHTML = '&nbsp;';
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
	var searchForm = document.getElementById('searchForm');	
	searchForm.style.display = "none";
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

function isValidDate(input) {
	var dateFormat = /(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])/
	var result = input.match(dateFormat);
	return (result == null) ? false : true;
}

function verify(form) {
	var search = form.search_string;
	if (isBlank(search.value)) {
		alert("Name/Keyword field is required!\n");
		return false;
	}
	var toDate = form.to_date;
	var fromDate = form.from_date;
	if ((!isValidDate(toDate.value)) || (!isValidDate(fromDate.value))) {
		alert("Either date format or date is invalid!\n Please make sure you have entered valid dates in yyyy-mm-dd format.\n");
		return false;
	}

	return true;
}
