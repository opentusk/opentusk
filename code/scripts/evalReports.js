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


window.onerror=function(msg, url, linenumber){
        document.getElementById('evalArea').innerHTML = '<font color="red">'+_('Eval load failed due to script error.')+'</font><br><b>'+msg+'</b><br>At line '+linenumber+' of '+url;
}

var elements = new Array();
var urls = new Array();
var ajaxRequest;
var processingElement;
var timerTimeout;
var time = 0;
var queueLength = 0;
var graphs = new Array();
var text_graphs = new Array();
var siteAbbreviation = '';
var merged = 0;
var pathInfo = '';

// Queue up all of the graphs into arrays
function queueEvalGraphsToLoad() {
	if(!window.XMLHttpRequest && !window.ActiveXObject) {alert(i_('Your browser does not support ajax, unable to load graphs.')); return;}
	document.getElementById('graphicsLoadMessage').style.display = '';
	if(document.getElementById('evalArea')) {
		try {
			document.getElementById('evalArea').style.backgroundColor = "lightgray";
		} catch (e) {}
	}
	spans = document.getElementsByTagName('span');
	for(var index=0; index<spans.length; index++) {
		if(spans[index].id.match("eval_question_")) {
			var questionID = spans[index].id.replace("eval_question_", "");
			var url="/tusk/ajax/evalGraph/"+ pathInfo +"/"+ questionID +"?merged="+ merged +"&random="+ new Date().getTime();
			spans[index].innerHTML = '<font color="green">'+_('Queued for Load')+'</font>';
			elements.push(spans[index]);
			urls.push(url);
		}
	}
	queueLength = urls.length;
	processQueue();
}

var queueCounter = 1;
var nodeTextType = '';
function processQueue() {
	var url = urls.shift();
	processingElement = elements.shift();
	document.getElementById('queueMessage').innerHTML= _("Loading Eval Graph ")+ queueCounter++ +" of "+ queueLength;
	//processingElement will always be set since its global
	if(!url) {
		document.getElementById('graphLink').style.display = '';
		document.getElementById('graphicsLoadMessage').innerHTML=_("Completed");
		document.getElementById('graphicsLoadMessage').style.display='none';
		document.getElementById('evalArea').style.backgroundColor = '';
		return;
	}
	if (window.XMLHttpRequest) {
		ajaxRequest = new XMLHttpRequest();
		nodeTextType = 'textContent';
	} else if (window.ActiveXObject) {
		ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
		nodeTextType = 'text';
	}

	if(ajaxRequest) {
		ajaxRequest.open("GET", url, true);
		ajaxRequest.onreadystatechange = doGraphLoad;
		ajaxRequest.send(null);
	} else {
		processingElement.innerHTML = '<font color="red">'+_("Error requesting graph.")+'</font>';
		processQueue();
	}
}


function GraphObject(parentDiv) {
	var self=this;
	this.displayParent = parentDiv;
	this.graphNode = document.createElement("div");
	this.textGraphNode = document.createElement("div");

	this.displayGraph = function() {
		self.displayParent.removeChild(self.displayParent.lastChild);
		self.displayParent.appendChild(self.graphNode);
	}

	this.displayTextGraph = function() {
		self.displayParent.removeChild(self.displayParent.lastChild);
		self.displayParent.appendChild(self.textGraphNode);
	}

	this.setGraph = function(nodeValue)	{  self.graphNode.innerHTML = nodeValue  }
	this.setTextGraph = function(nodeValue)	{  self.textGraphNode.innerHTML = nodeValue  }
}

function doGraphLoad() {
	if(processingElement) {
		processingElement.innerHTML = "<font color=\"#CC6600\">"+_("Returning Image")+"</font>";
		if(ajaxRequest && ajaxRequest.readyState == 4) {
			if(ajaxRequest.status && (ajaxRequest.status == 200)) {
				if(ajaxRequest.responseText.search("Unknown User") == -1 && ajaxRequest.responseText.search("Login") == -1) {
					//Split out the graph and the text of the response (also check for error)
					var graphNode = ajaxRequest.responseXML.getElementsByTagName('graph')[0];
					var aGraph = new GraphObject(processingElement);
					for(var index=0; index<graphNode.childNodes.length; index++) {
						var xmlNode = graphNode.childNodes[index];
						var nodeValue = '';
						if(xmlNode[nodeTextType]) {nodeValue = xmlNode[nodeTextType];}
						else if(xmlNode.firstChild && xmlNode.firstChild.nodeValue) {nodeValue = xmlNode.firstChild.nodeValue;}
						else {nodeValue = _('Unable to decypher graph XML');}

						var skipNode = false;
						if(xmlNode.nodeName == 'visual') {
							aGraph.setGraph(nodeValue);
						} else if(xmlNode.nodeName == 'textual') {
							aGraph.setTextGraph(nodeValue);
						} else {
							skipNode = true;
						}
					}
					graphs.push(aGraph);
					aGraph.displayGraph();
					processQueue();
				} else {
					processingElement.innerHTML = '<font color="red">'+_('Your session timed out.')+'</font>';
					processQueue();
				}
			} else if(ajaxRequest.status && (ajaxRequest.status == 403)) {
				processingElement.innerHTML = '<font color="red">'+_('Your session timed out.')+'</font>';
				processQueue();
			} else if(ajaxRequest.status && (ajaxRequest.status == 500)) {
				processingElement.innerHTML = '<font color="red">'+_('Error loading graph.')+'</font>';
				processQueue();
			} else {
				processingElement.innerHTML = '<font color="red">'+_('Graph load canceled.')+'</font>';
				processQueue();
			}
		}
	} else {
		alert(_('Error: mislocated current processing element'));
	}
}

function tickTimer() {
	time += 1;
	document.getElementById('timer').innerHTML = time;
	timerTimeout = setTimeout(tickTimer, 1000);
}

function loadEval(url, siteAbbr, path, doMerged) {
	siteAbbreviation = siteAbbr;
	pathInfo = path;
	merged = doMerged;
	
	var isNotIE8 = true;
        try {
		if(document.documentMode == 8) {
			var message =	_('You appear to be using Internet Explorer 8 which has known issues displaying eval results.')+'<br>'+
					_('We are working to resolve these issues but until that time, please enable compatibility mode by selecting "Compatibility View" from the Tools menu.')+'<br>'+
					_('If we have detected this incorrectly or you have questions or require assistance, please use the Contact page.');
			if(document.getElementById('evalArea')) {
				document.getElementById('evalArea').innerHTML = '<center><b><font color="red">' + message + '</font></b></center>';
			} else {
				alert(message);
			}
			isNotIE8 = false;
		}
        } catch(e) {alert('caught');}

	if(isNotIE8) {
		timerTimeout = setTimeout(tickTimer, 1000);
		try {
			if (window.XMLHttpRequest)	{ajaxRequest = new XMLHttpRequest();}
			else if (window.ActiveXObject)	{ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");}
			if(ajaxRequest) {
				ajaxRequest.open("GET", url, true);
				ajaxRequest.onreadystatechange = doEvalLoad;
				ajaxRequest.send(null);
			} else {
				processingElement.innerHTML = '<font color="red">'+_('Error requesting eval.')+'</font>';
			}
		} catch(error) {
			alert(_('Error in eval ajax request')+':\n'+error.description);
		}
	}
}

function doEvalLoad() {
	try {
		if(document.getElementById('evalArea')) {
			document.getElementById('evalArea').innerHTML= "<br><br><center><font color=\"#CC6600\">"+_('Loading Eval')+"</font><br><img src=\"/graphics/icons/waiting_bar.gif\"></center>";
			if(ajaxRequest && ajaxRequest.readyState == 4) {
				if(ajaxRequest.status && (ajaxRequest.status == 200)) {
					document.getElementById('evalArea').innerHTML = ajaxRequest.responseText;
					queueEvalGraphsToLoad();
				} else if(ajaxRequest.status && (ajaxRequest.status == 500)) {
					processingElement.innerHTML = '<font color="red">'+_('Error loading eval.')+'</font>';
				} else if(ajaxRequest.status && (ajaxRequest.status == 302)) {
					processingElement.innerHTML = '<font color="red">'+_('Got a redirect.')+'</font>';
				} else {
					document.getElementById('evalArea').innerHTML = '<br><br><center><font color="red">'+_('Error loading eval.')+'</font><center>';
				}
				clearTimeout(timerTimeout);
				document.getElementById('waitMessage').innerHTML = 'waited';
			}
		} else {
			alert(_('Error: mislocated eval element'));
		}
	} catch(error) {
		if(timerTimeout) {clearTimeout(timerTimeout);}
		if(document.getElementById('waitMessage')) {document.getElementById('waitMessage').innerHTML = 'waited';}
		if(document.getElementById('graphicsLoadMessage')) {document.getElementById('graphicsLoadMessage').style.display = 'none';}
		if(document.getElementById('evalArea')) {
			document.getElementById('evalArea').innerHTML = '<center><font color="red">'+_('Im sorry, an error has occurred while requesting this eval. Please contact here for support:')+ siteAbbreviation +'<font></center>';
			if(error.description) {document.getElementById('evalArea').innerHTML += '<br><center>Error was: '+error.description+'</center>';}
			if(ajaxRequest && ajaxRequest.status) {
				document.getElementById('evalArea').innerHTML += '<br><center>' + _('Ajax Return Code:') + ajaxRequest.status + '</center>';
			}
		} else {alert(_('There was an error processing eval ajax request. Please contact here for support: ')+ siteAbbreviation);}
	}
}

function showHideGraphs() {
	var linkText;
	var showGraph = true;
	if(document.getElementById('graphLink').innerHTML.indexOf('Hide') != -1) {
		showGraph = false;
		linkText = "Show";
	} else {
		linkText = "Hide";
	}
	linkText += " "+_("Graphs");

	if(document.getElementById('graphLink')) {document.getElementById('graphLink').innerHTML = linkText;}
	for(var index=0; index<graphs.length; index++) {
		if(showGraph)	{graphs[index].displayGraph();}
		else		{graphs[index].displayTextGraph();}
	}
//		var theDivs = document.getElementsByTagName('div');
//		for(var index=0; index<theDivs.length; index++) {
//			if(theDivs[index].className == 'theGraph') {theDivs[index].style.display = visualGraphDisplay;}
//			else if(theDivs[index].className == 'theGraphText') {theDivs[index].style.display = textulGraphDisplay;}
//		}
}

