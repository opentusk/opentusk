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


window.onerror = function(msg, url, linenumber) {
	document.getElementById('evalArea').innerHTML = '<font color="red">' + _('Eval load failed due to script error.') + '</font><br><b>' + msg + '</b><br>At line ' + linenumber + ' of ' + url;
}

var elements = new Array();
var urls = new Array();
var ajaxRequest;
var processingElement;
var timerRunning = 1;
var timerTimeout;
var time = Date.now();
var queueLength = 0;
var graphs = new Array();
var text_graphs = new Array();
var siteAbbreviation = '';
var merged = 0;
var pathInfo = '';
var full = 0;

// Queue up all of the graphs into arrays
function queueEvalGraphsToLoad() {
	if (!window.XMLHttpRequest) {
		alert(i_('Your browser does not support ajax, unable to load graphs.'));
		return;
	}
	document.getElementById('graphicsLoadMessage').style.display = '';
	if (document.getElementById('evalArea')) {
		document.getElementById('evalArea').style.backgroundColor = "lightgray";
	}
	spans = document.getElementsByTagName('span');
	for (var index = 0; index < spans.length; index++) {
		if (spans[index].id.match("eval_question_")) {
			var questionID = spans[index].id.replace("eval_question_", "");
			var url = "/tusk/ajax/evalGraph/" + pathInfo + "/" + questionID + "?merged=" + merged + "&random=" + Date.now();
			spans[index].innerHTML = '<font color="green">' + _('Queued for Load') + '</font>';
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
	document.getElementById('queueMessage').innerHTML = _("Loading Eval Graph ") + queueCounter++ + " of " + queueLength;
	//processingElement will always be set since its global
	if (!url) {
		document.getElementById('graphLink').style.display = '';
		document.getElementById('graphicsLoadMessage').innerHTML = _("Completed");
		document.getElementById('graphicsLoadMessage').style.display = 'none';
		document.getElementById('evalArea').style.backgroundColor = '';
		return;
	}
	if (window.XMLHttpRequest) {
		ajaxRequest = new XMLHttpRequest();
		nodeTextType = 'textContent';
	}

	if (ajaxRequest) {
		ajaxRequest.open("GET", url, true);
		ajaxRequest.onreadystatechange = doGraphLoad;
		ajaxRequest.send(null);
	} else {
		processingElement.innerHTML = '<font color="red">' + _("Error requesting graph.") + '</font>';
		processQueue();
	}
}

function GraphObject(parentDiv) {
	var self = this;
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

	this.setGraph = function(nodeValue) {
		self.graphNode.innerHTML = nodeValue;
	}

	this.setTextGraph = function(nodeValue) {
		self.textGraphNode.innerHTML = nodeValue;
	}
}

function doGraphLoad() {
	if (processingElement) {
		processingElement.innerHTML = '<font color="#CC6600">' + _("Returning Image") + "</font>";
		if (ajaxRequest && ajaxRequest.readyState == 4) {
			if (ajaxRequest.status && (ajaxRequest.status == 200)) {
				if (ajaxRequest.responseText.search("Unknown User") == -1 && ajaxRequest.responseText.search("Login") == -1) {
					// Split out the graph and the text of the response (also check for error)
					var graphNode = ajaxRequest.responseXML.getElementsByTagName('graph')[0];
					var aGraph = new GraphObject(processingElement);
					for (var index = 0; index < graphNode.childNodes.length; index++) {
						var xmlNode = graphNode.childNodes[index];
						var nodeValue = '';
						if (xmlNode[nodeTextType]) {
							nodeValue = xmlNode[nodeTextType];
						} else if (xmlNode.firstChild && xmlNode.firstChild.nodeValue) {
							nodeValue = xmlNode.firstChild.nodeValue;
						} else {
							nodeValue = _('Unable to decypher graph XML');
						}

						var skipNode = false;
						if (xmlNode.nodeName == 'visual') {
							aGraph.setGraph(nodeValue);
						} else if (xmlNode.nodeName == 'textual') {
							aGraph.setTextGraph(nodeValue);
						} else {
							skipNode = true;
						}
					}
					graphs.push(aGraph);
					aGraph.displayGraph();
					processQueue();
				} else {
					processingElement.innerHTML = '<font color="red">' + _('Your session timed out.') + '</font>';
					processQueue();
				}
			} else if (ajaxRequest.status && (ajaxRequest.status == 403)) {
				processingElement.innerHTML = '<font color="red">' + _('Your session timed out.') + '</font>';
				processQueue();
			} else if (ajaxRequest.status && (ajaxRequest.status == 500)) {
				processingElement.innerHTML = '<font color="red">' + _('Error loading graph.') + '</font>';
				processQueue();
			} else {
				processingElement.innerHTML = '<font color="red">' + _('Graph load canceled.') + '</font>';
				processQueue();
			}
		}
	} else {
		alert(_('Error: mislocated current processing element'));
	}
}

function tickTimer() {
	document.getElementById('timer').innerHTML = Math.round((Date.now() - time) / 1000);
	if (timerRunning) {
		timerTimeout = setTimeout(tickTimer, 1000);
	} else {
		document.getElementById('waitMessage').innerHTML = 'waited';
	}
}

function loadEval(url, siteAbbr, path, doMerged, doFull) {
	siteAbbreviation = siteAbbr;
	pathInfo = path;
	merged = doMerged;
	full = doFull;

	if (!is_ie) {
		timerTimeout = setTimeout(tickTimer, 1000);
		try {
			if (window.XMLHttpRequest) {
				ajaxRequest = new XMLHttpRequest();
			}
			if (ajaxRequest) {
				ajaxRequest.open("GET", url, true);
				ajaxRequest.onreadystatechange = doEvalLoad;
				ajaxRequest.send(null);
			} else {
				processingElement.innerHTML = '<font color="red">' + _('Error requesting eval.') + '</font>';
			}
		} catch (error) {
			alert(_('Error in eval ajax request') + ':\n' + error.description);
		}
	}
}

function doEvalLoad() {
	try {
		if (document.getElementById('evalArea')) {
			document.getElementById('evalArea').innerHTML = '<br><br><center><font color="#CC6600">' + _('Loading Eval') + '</font><br><img src="/graphics/icons/waiting_bar.gif"></center>';
			if (ajaxRequest && ajaxRequest.readyState == 4) {
				timerRunning = 0;
				if (ajaxRequest.status && (ajaxRequest.status == 200)) {
					document.getElementById('evalArea').innerHTML = ajaxRequest.responseText;
					if (full) {
						queueEvalGraphsToLoad();
					} else {
						drawGraphs();
					}
				} else if (ajaxRequest.status && (ajaxRequest.status == 500)) {
					processingElement.innerHTML = '<font color="red">' + _('Error loading eval.') + '</font>';
				} else if (ajaxRequest.status && (ajaxRequest.status == 302)) {
					processingElement.innerHTML = '<font color="red">' + _('Got a redirect.') + '</font>';
				} else {
					document.getElementById('evalArea').innerHTML = '<br><br><center><font color="red">' + _('Error loading eval.') + '</font><center>';
				}
			}
		} else {
			alert(_('Error: mislocated eval element'));
		}
	} catch (error) {
		timerRunning = 0;
		if (document.getElementById('graphicsLoadMessage')) {
			document.getElementById('graphicsLoadMessage').style.display = 'none';
		}
		if (document.getElementById('evalArea')) {
			document.getElementById('evalArea').innerHTML = '<center><font color="red">' + _('Sorry, an error has occurred while requesting this eval. Please contact here for support:') + siteAbbreviation + '<font></center>';
			if (error.description) {
				document.getElementById('evalArea').innerHTML += '<br><center>Error was: ' + error.description + '</center>';
			}
			if (ajaxRequest && ajaxRequest.status) {
				document.getElementById('evalArea').innerHTML += '<br><center>' + _('Ajax Return Code:') + ajaxRequest.status + '</center>';
			}
		} else {
			alert(_('There was an error processing eval ajax request. Please contact here for support: ') + siteAbbreviation);
		}
	}
}

function showHideGraphs() {
	var linkText;
	var showGraph = true;
	if (document.getElementById('graphLink').innerHTML.indexOf('Hide') != -1) {
		showGraph = false;
		linkText = "Show";
	} else {
		linkText = "Hide";
	}
	linkText += " " + _("Graphs");

	if (document.getElementById('graphLink')) {
		document.getElementById('graphLink').innerHTML = linkText;
	}
	for (var index = 0; index < graphs.length; index++) {
		if (showGraph) {
			graphs[index].displayGraph();
		} else {
			graphs[index].displayTextGraph();
		}
	}
}

function drawGraphs() {
	var size = { width: 360, height: 120 };
	var margin = { top: 20, right: 20, bottom: 40, left: 40 };
	var width = size.width - margin.left - margin.right;
	var height = size.height - margin.top - margin.bottom;
	var x = d3.scale.ordinal().rangeRoundBands([0, width], 0.6);
	var y = d3.scale.linear().range([height, 0]);
	var xAxis = d3.svg.axis().scale(x).orient("bottom");
	var yAxis = d3.svg.axis().scale(y).orient("left").ticks(4).tickFormat(d3.format("d"));

	d3.selectAll("div.graph").each(function() {
		var graph = d3.select(this);
		var json = JSON.parse(graph.select("script").html());
		var data = json.data;
		var type = json.type;
		var mean = json.mean;
		var low_text = json.low_text;
		var high_text = json.high_text;

		x.domain(data.map(function(d) {
			return d.bin;
		}));

		y.domain([0, d3.max(data, function(d) {
			return d.count;
		})]);

		var svg = graph.append("svg")
			.attr("width", size.width)
			.attr("height", size.height)
			.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

		svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.call(xAxis);

		svg.append("g")
			.attr("class", "y axis")
			.call(yAxis);

		svg.append("text")
			.attr("transform", "rotate(-90)")
			.attr("y", -margin.left)
			.attr("x", -height / 2)
			.attr("dy", "1em")
			.style("text-anchor", "middle")
			.text("Frequency");

		if (mean) {
			var xNum = d3.scale.linear()
				.range([x(data[0].bin) + x.rangeBand() / 2, x(data[data.length - 1].bin) + x.rangeBand() / 2])
				.domain([data[0].bin, data[data.length - 1].bin]);

			svg.append("text")
				.attr("x", xNum(mean))
				.attr("y", height + 12)
				.style("text-anchor", "middle")
				.style("font-size", "18px")
				.text("\u25B2");

			if (type == "PlusMinusRating") {
				svg.append("line")
					.attr("x1", width / 2)
					.attr("y1", height + 36)
					.attr("x2", xNum(mean))
					.attr("y2", height + 36)
					.attr("stroke-width", 8)
					.attr("stroke", (xNum(mean) > width / 2) ? "green" : "red");

				svg.append("line")
					.attr("x1", xNum(mean))
					.attr("y1", height)
					.attr("x2", xNum(mean))
					.attr("y2", height + 40)
					.attr("stroke-width", 2)
					.attr("stroke", "black");
			}
		}

		if (low_text) svg.append("text")
			.attr("class", "x axis")
			.attr("x", 0)
			.attr("y", height + 28)
			.style("text-anchor", "start")
			.text(low_text);

		if (high_text) svg.append("text")
			.attr("class", "x axis")
			.attr("x", width)
			.attr("y", height + 28)
			.style("text-anchor", "end")
			.text(high_text);

		var bar = svg.selectAll(".bar")
			.data(data)
			.enter();

		bar.append("rect")
			.attr("class", "bar")
			.attr("x", function(d) {
				return x(d.bin);
			})
			.attr("y", function(d) {
				return y(d.count);
			})
			.attr("width", x.rangeBand())
			.attr("height", function(d) {
				return height - y(d.count);
			});

		bar.append("text")
			.attr("x", function(d) {
				return x(d.bin);
			})
			.attr("y", function(d) {
				return y(d.count);
			})
			.attr("dx", x.rangeBand() / 2)
			.attr("dy", -4)
			.attr("text-anchor", "middle")
			.text(function(d) {
				return (d.count) ? d.count : "";
			});

	});
}

function printReport() {
	drawGraphs();
	setTimeout(window.print, 1000);
}
