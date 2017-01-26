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

// check if this browser is IE 10 or earlier
var is_ie = new Function("/*@cc_on return true @*/")();

// check if this browser supports DHTML
var DHTML = document.getElementById;

function checkform(aform) {
	for (var i = 0; i < aform.length; i++) {
		element = aform.elements[i];
		id = element.id;
		if (id) {
			split = id.indexOf('__');
			name = id.substring(0, split);
			if (!name) {
				continue;
			}
			attrib = id.substring(split + 2, id.length);
			// ff had no problem accessing chars in the attrib string (below) through array notation,
			// but ie6 needed to split() the array with empty string in order to create an
			// array with each char from the orig string being represented as an elt in the array
			attrib = attrib.split("");
			if (attrib[0] == 'y') {
				if (element.value == "") {
					name = name.replace('_', ' ');
					alert('Please fill in a value for ' + name);
					document.getElementById(id).focus();
					return false;
				}
			}
			if (attrib[1] == 'y') {
				var reg = /^\s*\d\d\d\d\-\d?\d\-\d?\d\s*$/;
				var results = reg.exec(element.value);
				if (results == null || element.value == "0000-00-00") {
					name = name.replace('_', ' ');
					alert('Please fill in a value for ' + name + ' in the format YYYY-MM-DD');
					document.getElementById(id).focus();
					return false;
				}
			}
		}
	}
	return true;
}

function MM_openBrWindow(theURL, winName, features) { //v2.0
	window.open(theURL, winName, features);
}

function closeIt() {
	close();
}

function openHelp(link) {
	var param = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	var win_name = 'quickhelp';
	help_window = window.open(link, win_name, param);
	if (!help_window.opener) help_window.opener = self;
}

function openJustContent(content_id, win_name, params) {
	if (!win_name) win_name = 'just_content';
	if (!params) params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	content_window = window.open('/view/justcontent/content/' + content_id, win_name, params);
	if (!content_window.opener) help_window.opener = self;
}


function show_props(obj, obj_name) {
	var result = ""
	for (var i in obj)
		result += obj_name + "." + i + " = " + obj[i] + "<br>\n"
	return result
}

function go_back(url) {
	window.location = url;
}


function open_window(url, param) {
	chooser_window = window.open(url, "opensaysme", param);
	if (!chooser_window.opener) chooser_window.opener = self;
}

function check_dropdowns(this_dropdown, that_dropdown) {
	if (this_dropdown.selectedIndex > 0) {
		that_dropdown.disabled = true;
		that_dropdown.style.color = '#E7EFF7';
	} else {
		that_dropdown.disabled = false;
		that_dropdown.style.color = '#000000';
	}
}

function toggle_boxes(element, form, boxname) {
	boxes = form.elements[boxname];
	for (var index = 0; index < boxes.length; index++) {
		boxes[index].checked = element.checked;
	}
}

function getObj(name) {
	if (document.getElementById) {
		this.obj = document.getElementById(name);
		if (this.obj != null) {
			this.style = document.getElementById(name).style;
		}
	}
	else if (document.all) {
		this.obj = document.all[name];
		this.style = document.all[name].style;
	}
	else if (document.layers) {
		this.obj = document.layers[name];
		this.style = document.layers[name];
	}
}

function isValidTUSKBrowser() {
	var errordiv = document.getElementById('errordiv');
	if (!errordiv) {
		alert("errordiv not found.");
	} else if (is_ie || !document.addEventListener) {
		errordiv.innerHTML += '<p class="errTxt">You are using an outdated browser which will not display TUSK properly.</p>';
	}
}

function togglelayerbutton(button, layername, title) {
	var layer;
	if (document.layers) {
		layer = document.layers[layername];
	} else if (document.all) {
		layer = document.all[layername];
	} else {
		layer = document.getElementById(layername);
	}

	var extra;
	if (title) {
		extra = " " + title;
	}

	if (button.value == 'Hide' + extra) {
		layer.style.display = 'none';
		button.value = 'Show' + extra;
	} else {
		layer.style.display = 'block';
		button.value = 'Hide' + extra;
	}
}


function togglelayer(layername, checked) {
	var layer;
	if (document.layers) {
		layer = document.layers[layername];
	} else if (document.all) {
		layer = document.all[layername];
	} else {
		layer = document.getElementById(layername);
	}

	if (checked) {
		layer.style.visibility = "hidden";
	} else {
		layer.style.visibility = "visible";
	}
}

function updatetime(form, label) {
	var string;
	if (form.elements['timebox-checkbox-' + label]) {
		if (form.elements['timebox-checkbox-' + label].checked) {
			form.elements[label].value = "00:00:00";
			return;
		}
	}

	form.elements[label].value = form.elements['hours-' + label].options[form.elements['hours-' + label].selectedIndex].value
	form.elements[label].value += ":" + form.elements['minutes-' + label].options[form.elements['minutes-' + label].selectedIndex].value
	if (form.elements['seconds-' + label]) {
		form.elements[label].value += ":" + form.elements['seconds-' + label].options[form.elements['seconds-' + label].selectedIndex].value
	} else {
		form.elements[label].value += ":00";
	}

}

function make_date_object(date_string) {
	var date_array = date_string.split(/[- :]/);
	// Date constructor needs month val from 0-11. cast string to integer and subtract 1
	var month = (parseInt(date_array[1], 10)) - 1;
	return new Date(date_array[0], month, date_array[2], date_array[3], date_array[4]);
}

function make_date_no_time_object(date_string) {
	var date_array = date_string.split(/[- ]/);
	return new Date(date_array[0], date_array[1], date_array[2]);
}

function isValidDate(date) {
	var date_str = date.value;
	date_str = date_str.replace(/^\s+|\s+$/g, "");
	var date_array = date_str.split(/[- :]/);
	var dt;
	if (!date_str.match(/^\d{4}-\d{2}-\d{2}(?:\s\d{2}:\d{2}(?::\d{2})?)?$/)) {
		return false;
	}

	if (date_array.length == 3) {
		dt = new Date(date_array[0], date_array[1] - 1, date_array[2]);
		if (dt.getDate() != date_array[2]) {
			return false;
		} else if (dt.getMonth() + 1 != date_array[1]) {
			return false;
		} else if (dt.getFullYear() != date_array[0]) {
			return false;
		}
	} else if (date_array.length == 5) {
		dt = new Date(date_array[0], date_array[1] - 1, date_array[2], date_array[3], date_array[4]);
		if (dt.getMinutes() != date_array[4]) {
			return false;
		} else if (dt.getHours() != date_array[3]) {
			return false;
		} else if (dt.getDate() != date_array[2]) {
			return false;
		} else if (dt.getMonth() + 1 != date_array[1]) {
			return false;
		} else if (dt.getFullYear() != date_array[0]) {
			return false;
		}
	} else if (date_array.length == 6) {
		dt = new Date(date_array[0], date_array[1] - 1, date_array[2], date_array[3], date_array[4], date_array[5]);
		if (dt.getSeconds() != date_array[5]) {
			return false;
		} else if (dt.getMinutes() != date_array[4]) {
			return false;
		} else if (dt.getHours() != date_array[3]) {
			return false;
		} else if (dt.getDate() != date_array[2]) {
			return false;
		} else if (dt.getMonth() + 1 != date_array[1]) {
			return false;
		} else if (dt.getFullYear() != date_array[0]) {
			return false;
		}
	} else {
		return false;
	}

	return (true);
}

function isValidDateOrEmpty(date) {
	return (date.value.match(/^\s*$/) || isValidDate(date));
}

function forward(destination) {
	// do nothing if there is no url provided
	var word = /\w+/;
	var dest = destination.value;
	var result = dest.match(word);
	destination.selectedIndex = 0;
	if (result == null) {
		return false;
	}
	window.location.href = dest;
}

function fowardToNew(destination) {
	// do nothing if there is no url provided
	var word = /\w+/;
	var dest = destination.value;
	var result = dest.match(word);
	destination.selectedIndex = 0;
	if (result == null) {
		return false;
	}
	window.open(dest);
}

// used by admin left nav to hide show sub navigation for different elements (case, competencies)
function show_subnav(id, sub_link) {
	document.getElementById(id).className = 'showNav';
	document.getElementById(sub_link).innerHTML = '-';
}

function hide_subnav(id, sub_link) {
	document.getElementById(id).className = 'hideNav';
	document.getElementById(sub_link).innerHTML = '+';
}

function toggle_subnav(id, sub_link) {
	var status = document.getElementById(id).className;
	(status == 'showNav') ? hide_subnav(id, sub_link) : show_subnav(id, sub_link);
}

function getScrollXY() {
	var scrOfX = 0, scrOfY = 0;
	if (window.pageYOffset) {
		scrOfY = window.pageYOffset;
		scrOfX = window.pageXOffset;
	} 
	return [scrOfX, scrOfY];
}

// quirksmode.org supplied the following functions. thanks!

// return the x,y coordinates of an element on the page.
function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft, curtop];
}

// given an event, find the element that initiated it
// that is, if anchor clicked on, return the anchor element
function getElt(e) {
	var targ;
	if (e.target) {
		targ = e.target;
	}
	else if (e.srcElement) {
		targ = e.srcElement;
	}
	if (targ.nodeType == 3) // defeat Safari bug
		targ = targ.parentNode;
	return targ;
}

// add an event listener to a DOM element
function addEvent(obj, type, fn) {
	if (obj.addEventListener)
		obj.addEventListener(type, fn, false);
	else if (obj.attachEvent) {
		obj["e" + type + fn] = fn;
		obj[type + fn] = function() { obj["e" + type + fn](window.event); }
		obj.attachEvent("on" + type, obj[type + fn]);
	}
}
// /end quirksmode functions


//simple form field validation. make sure there is a non-space character in field
function isBlank(field) {
	if (field.value && /\S+/.test(field.value)) {
		return false;
	}
	return true;
}

//complex form field validation. checks radio buttons and selects; returns true if blank
function multipleIsBlank(field) {
	var value = multipleValue(field);
	if (value && /\S+/.test(value)) {
		return false;
	}
	else {
		return true;
	}
}

//complex form field validation. checks radio buttons and selects; returns value if there is one
function multipleValue(field) {
	var values = new Array();

	// single checkbox
	if (field.type != null && field.type.toString().indexOf('checkbox') > -1) {
		if (field.checked) {
			values.push(field.value);
		}
	}
	// select with array of options
	else if (field.toString().indexOf('Select') > -1) {
		for (var i = 0; i < field.options.length; i++) {
			if (field.options[i].selected) {
				values.push(field.options[i].value);
			}
		}
	}
	// set of radio buttons or checkboxes
	else if (field.length) {
		for (var i = 0; i < field.length; i++) {
			if (field[i].checked) {
				values.push(field[i].value);
			}
		}
	}

	if (values.length) {
		return values;
	} else {
		return false;
	}
}

// basic moving effects function-set. if we want to do some more complex stuff, we should probably invest some time in examining yahoo's yui or the script.aculo.us libs.
function fxLock(ele) {
	if (!ele.lock || ele.lock == false) {
		ele.lock = true;
		return false;
	} else {
		return true;
	}
}

function widthfx(from, to, ele, options) {
	if (!fxLock(ele)) {
		var increment = (typeof (options) == 'object' && options.increment) ? options.increment : 5;
		var duration = (typeof (options) == 'object' && options.duration) ? options.duration : 15;
		if (from > to) increment -= (2 * increment);

		movefx('width', from, to, ele, increment, duration);
	}
}

function heightfx(from, to, ele, options) {
	if (!fxLock(ele)) {
		var increment = (typeof (options) == 'object' && options.increment) ? options.increment : 10;
		var duration = (typeof (options) == 'object' && options.duration) ? options.duration : 15;
		if (from > to) increment -= (2 * increment);
		movefx('height', from, to, ele, increment, duration);
	}
}

function movefx(effect, from, to, ele, increment, duration) {

	if (from == to) {
		ele.lock = false;
		return;
	} else if (Math.abs((to - from)) <= Math.abs(increment)) {
		from = to;
	} else {
		from += increment;
	}

	ele.style[effect] = (from + 'px');
	setTimeout(function() { movefx(effect, from, to, ele, increment, duration) }, duration);

}
// end effects

function email_user(user_id, context_path) {
	var pop_url = '/management/mail/emailuser/' + context_path + '?recipient=' + user_id;
	var params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	var win = window.open(pop_url, 'email_' + user_id, params);
}

function toggle_div(id) {
	var new_display = 'none';
	if (document.getElementById(id).style.display == 'none') {
		new_display = 'block';
	}

	document.getElementById(id).style.display = new_display;
}

/*
fx for form on /management/course/modify/ and /management/course/info/
*/
function adjustXtraFields(selection, integrated) {
	var selectionTxt = selection[selection.selectedIndex].text;
	if (!selectionTxt || selectionTxt.match(/group|thesis committee/i)) {
		document.getElementById('caeXtraFields').className = 'hideAll';
	}
	else {
		document.getElementById('caeXtraFields').className = 'showAll';
	}

	if (integrated) {
		if (!selectionTxt.match(/integrated course/i)) {
			document.getElementById('caeSubcourses').className = 'hideAll';
		}
		else {
			document.getElementById('caeSubcourses').className = 'showAll';
		}
	}
}

// get HTTP request
function initXMLHTTPRequest() {
	if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	}
}


function getTopOfScreen() {
	if (self.pageYOffset) {
		return self.pageYOffset;
	}
}

function getPageXY() {
	if (document.body.scrollHeight) {
		return [document.body.scrollWidth, document.body.scrollHeight];
	} else {
		return [undefined, undefined];
	}
}


// given a frame, will set all links to have a target of _top unless they already
// have that value set to _blank
function setTargets(frame_name) {
	var doc = top[frame_name].document;
	var lnks = doc.getElementsByTagName('a');
	for (var i = 0; i < lnks.length; i++) {
		if (lnks[i].target != '_blank') {
			lnks[i].target = '_top';
		}
	}
}

// will set a hidden input field to transmit the desired timeperiod, while changing dropdown
// back to a neutral state; eg "please select time period"
function updateTPAndSubmit(elt) {
	var hidInp = document.generic.timeperiod;
	hidInp.value = elt.value;
	elt.selectedIndex = 0;
	document.generic.submit();
}

/* if called, will either return the DOM element passed in
   or the DOM element referred to by string id.
   handy, because it enables a calling function to accept either a string
   or a DOM element as its own arg (this fx will ensure that it will
   perform actions on the DOM element
*/
function getElement(elt) {
	if (elt) {
		if (typeof elt == 'string') {
			elt = document.getElementById(elt);
		}
		// if we were passed a string, make sure it was a valid id that returned a DOM elt
		if (elt) {
			return elt;
		}
		else {
			return false;
		}
	}
}

/* to hide an element.
   can pass in either a string id or an actual DOM element
*/
function hide(elt) {
	elt = getElement(elt);
	if (elt) {
		elt.style.visibility = 'hidden';
	}
}

/* to show a hidden element.
   can pass in either a string id or an actual DOM element
*/
function show(elt) {
	elt = getElement(elt);
	if (elt) {
		elt.style.visibility = 'visible';
	}
}

// from: http://www.dustindiaz.com/getelementsbyclass/
function getElementsByClass(params) {

	if (typeof (params) != 'object')
		return [];
	if (params['className'] == null)
		return [];
	var searchClass = params['className'];
	var node = params['node'];
	var tag = params['tag'];
	var classElements = new Array();
	if (node == null)
		node = document;
	if (tag == null)
		tag = '*';
	var els = node.getElementsByTagName(tag);
	var elsLen = els.length;
	var pattern = new RegExp("(^|\\s)" + searchClass + "(\\s|$)");
	for (i = 0, j = 0; i < elsLen; i++) {
		if (pattern.test(els[i].className)) {
			classElements[j] = els[i];
			j++;
		}
	}
	return classElements;
}


/*
toggleExcess() and positionExcess() are used to pop up a little yellow box with additional
text. similar to the bahavior of target text on an <a>.
*/
function toggleExcess(elt) {
	if (!elt.fullTxtWin) {
		var new_win = document.createElement('div');
		new_win.innerHTML = elt.innerHTML;
		new_win.className = 'excessTxtWin gHidden';
		document.body.appendChild(new_win);
		elt.fullTxtWin = new_win;
	}

	if (elt.fullTxtWin.className.match(/\sgHidden/)) {
		positionExcessWin(elt);
		elt.fullTxtWin.className = elt.fullTxtWin.className.replace(/\sgHidden/, '');
	}
	else {
		elt.fullTxtWin.className += ' gHidden';
	}
}

function positionExcessWin(elt) {
	var txt_win = elt.fullTxtWin;
	var hgt = txt_win.offsetHeight;
	var browser_top = getScrollXY()[1];
	var yPos = findPos(elt)[1] - hgt;
	if (yPos < browser_top) {
		yPos = findPos(elt)[1] + elt.offsetHeight + 5;
	}
	txt_win.style.top = yPos + 'px';
	var width = txt_win.offsetWidth;
	var browser_width = document.documentElement.clientWidth;
	var browser_scroll = getScrollXY()[0];
	var browser_edge = browser_scroll + browser_width
	var xPos = findPos(elt)[0];
	if ((xPos + width) > browser_edge) {
		xPos = browser_edge - width - 20;
		if (xPos < browser_scroll) {
			xPos = findPos(elt)[0];
		}
	}
	txt_win.style.left = xPos + 'px';
}

function setupCal(elt) {
	Calendar.setup({
		inputField: elt.id,
		ifFormat: "%Y-%m-%d", // format of the input field
		showsTime: false, // will display a time selector
		button: elt.id,
		singleClick: true, // double-click mode
		align: "Tl",
		step: 1 // show all years in drop-down boxes (instead of every other year as default)
	});
	elt.onclick();
}

// This function will be called by any calendar textbox to ensure proper dates
// are entered throughout the form.  If any date is invalid, the form will not
// submit.
//
// Parameters:  el       -  form element
//              no_empty -  1 indicates blank date is bad
function checkDates(el, no_empty) {
	if (el.form.orig_onsubmit == undefined) {
		el.form.orig_onsubmit = null;
	}
	if (el.form.invalid_dates == undefined) {
		el.form.invalid_dates = new Array();
	}

	var isValid;
	if (no_empty) {
		isValid = isValidDate(el);
	} else {
		isValid = isValidDateOrEmpty(el);
	}
	if (!isValid) {
		if (!el.form.invalid_dates[el.id]) {
			el.form.invalid_dates[el.id] = 1;
			if (el.form.orig_onsubmit === null) {
				if (el.form.onsubmit == undefined) {
					el.form.orig_onsubmit = "";
				} else {
					el.form.orig_onsubmit = el.form.onsubmit;
				}
			}

			el.form.onsubmit = function test() { alert('Error:  Please make sure that all dates are valid.'); return false; }
			el.style.backgroundColor = "#FF3333";
		}
	} else {
		if (el.form.invalid_dates[el.id]) {
			var all_ok = 1;
			el.form.invalid_dates[el.id] = 0;
			for (var i in el.form.invalid_dates) {
				if (el.form.invalid_dates[i]) { all_ok = 0; break; }
			}

			if (all_ok && el.form.orig_onsubmit !== null) {
				el.form.onsubmit = el.form.orig_onsubmit;
				el.form.orig_onsubmit = null;
			}

			el.style.backgroundColor = "white";
		}
	}
}


/* Hopefully a generic enough implementation of a tab nav that can be used
** to show/hide divs on a page.
*/
function activateTab(active) {
	var nav = active.parentNode.parentNode;
	var deactivate = getElementsByClass({ node: nav, tag: 'li', className: 'activeTab' })[0];
	deactivate.className = '';
	var deactivate_div = document.getElementById(deactivate.id + 'Area');
	deactivate_div.className = 'tabArea';
	active.parentNode.className = 'activeTab';
	var activate_div = document.getElementById(active.parentNode.id + 'Area');
	activate_div.className += ' activeArea';
}

function currentYear() {
	var now = new Date;
	document.write(now.getFullYear());
}

function toggleMaterialLinks(material, obj, event) {
	var materialLinks = document.getElementById(material);
	if ($('#' + material).css("display") == "inline") {
		$('#' + material).css("display", "none");
		$(obj).children('img').attr("src", "/graphics/icon-nav-closed.png");
	} else {
		$('#' + material).css("display", "inline");
		$(obj).children('img').attr("src", "/graphics/icon-nav-open.png");
		materialsHeightAdjust();
	}
	event.preventDefault();
}

function materialsHeightAdjust() {
	var paddingAdjustment = 70; //px
	var trafficLightHeight = ($('#gTrafficLight').height()) || 0;
	if (trafficLightHeight > 0) {
		paddingAdjustment = paddingAdjustment - 25;
	}
	var scrollBoxHeight = $('#gContent').height() + trafficLightHeight - $('#communicationsBox').height() - paddingAdjustment;
	$('#materialsScrollContainer').css("max-height", scrollBoxHeight);
}

// Add or change parameter of URL and redirect to the new URL
function setGetParameter(paramName, paramValue, clearFlag) {
	var url = (clearFlag) ? window.location.href.split('?')[0] : window.location.href;
	if (url.indexOf(paramName + '=') >= 0) {
		var prefix = url.substring(0, url.indexOf(paramName));
		var suffix = url.substring(url.indexOf(paramName));
		suffix = suffix.substring(suffix.indexOf('=') + 1);
		suffix = (suffix.indexOf('&') >= 0) ? suffix.substring(suffix.indexOf('&')) : '';
		url = prefix + paramName + '=' + paramValue + suffix;
	} else {
		if (url.indexOf('?') < 0) {
			url += '?' + paramName + '=' + paramValue;
		} else {
			url += '&' + paramName + '=' + paramValue;
		}
	}
	window.location.href = url;
}


//Toggle button functionality for Competency Checklist
function toggleSkillModules(button) {
	var button_text = $(button).html();
	if (button_text == 'Expand All') {
		$(".med").each(function() {
			if (($(this).children("img").attr("src")) == '/graphics/icon-nav-closed.png') {
				$(this).trigger("click");
			}
		});
		$(button).html('Collapse All');
	} else {
		$(".med").each(function() {
			if (($(this).children("img").attr("src")) == '/graphics/icon-nav-open.png') {
				$(this).trigger("click");
			}
		});
		$(button).html('Expand All');
	}
}