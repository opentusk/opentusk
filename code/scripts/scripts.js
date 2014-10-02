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


<!--
// Ultimate client-side JavaScript client sniff. Version 3.03
// (C) Netscape Communications 1999-2001.  Permission granted to reuse and distribute.
// Revised 17 May 99 to add is_nav5up and is_ie5up (see below).
// Revised 20 Dec 00 to add is_gecko and change is_nav5up to is_nav6up
//                      also added support for IE5.5 Opera4&5 HotJava3 AOLTV
// Revised 22 Feb 01 to correct Javascript Detection for IE 5.x, Opera 4, 
//                      correct Opera 5 detection
//                      add support for winME and win2k
//                      synch with browser-type-oo.js
// Revised 26 Mar 01 to correct Opera detection
// Revised 02 Oct 01 to add IE6 detection

// Everything you always wanted to know about your JavaScript client
// but were afraid to ask. Creates "is_" variables indicating:
// (1) browser vendor:
//     is_nav, is_ie, is_opera, is_hotjava, is_webtv, is_TVNavigator, is_AOLTV
// (2) browser version number:
//     is_major (integer indicating major version number: 2, 3, 4 ...)
//     is_minor (float   indicating full  version number: 2.02, 3.01, 4.04 ...)
// (3) browser vendor AND major version number
//     is_nav2, is_nav3, is_nav4, is_nav4up, is_nav6, is_nav6up, is_gecko, is_ie3,
//     is_ie4, is_ie4up, is_ie5, is_ie5up, is_ie5_5, is_ie5_5up, is_ie6, is_ie6up, is_hotjava3, is_hotjava3up,
//     is_opera2, is_opera3, is_opera4, is_opera5, is_opera5up
// (4) JavaScript version number:
//     is_js (float indicating full JavaScript version number: 1, 1.1, 1.2 ...)
// (5) OS platform and version:
//     is_win, is_win16, is_win32, is_win31, is_win95, is_winnt, is_win98, is_winme, is_win2k
//     is_os2
//     is_mac, is_mac68k, is_macppc
//     is_unix
//     is_sun, is_sun4, is_sun5, is_suni86
//     is_irix, is_irix5, is_irix6
//     is_hpux, is_hpux9, is_hpux10
//     is_aix, is_aix1, is_aix2, is_aix3, is_aix4
//     is_linux, is_sco, is_unixware, is_mpras, is_reliant
//     is_dec, is_sinix, is_freebsd, is_bsd
//     is_vms
//
// See http://www.it97.de/JavaScript/JS_tutorial/bstat/navobj.html and
// http://www.it97.de/JavaScript/JS_tutorial/bstat/Browseraol.html
// for detailed lists of userAgent strings.
//
// Note: you don't want your Nav4 or IE4 code to "turn off" or
// stop working when new versions of browsers are released, so
// in conditional code forks, use is_ie5up ("IE 5.0 or greater") 
// is_opera5up ("Opera 5.0 or greater") instead of is_ie5 or is_opera5
// to check version in code which you want to work on future
// versions.

    // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();
    // *** BROWSER VERSION ***
    // Note: On IE5, these return 4, so use is_ie5up to detect IE5.
    var is_major = parseInt(navigator.appVersion);
    var is_minor = parseFloat(navigator.appVersion);
    // Note: Opera and WebTV spoof Navigator.  We do strict client detection.
    // If you want to allow spoofing, take out the tests for opera and webtv.
    var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1));
    var is_nav2 = (is_nav && (is_major == 2));
    var is_nav3 = (is_nav && (is_major == 3));
    var is_nav4 = (is_nav && (is_major == 4));
    var is_nav4up = (is_nav && (is_major >= 4));
    var is_navonly      = (is_nav && ((agt.indexOf(";nav") != -1) ||
                          (agt.indexOf("; nav") != -1)) );
    var is_nav6 = (is_nav && (is_major == 5));
    var is_nav6up = (is_nav && (is_major >= 5));
    var is_gecko = (agt.indexOf('gecko') != -1);

    var is_ie     = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
    var is_ie3    = (is_ie && (is_major < 4));
    var is_ie4    = (is_ie && (is_major == 4) && (agt.indexOf("msie 4")!=-1) );
    var is_ie4up  = (is_ie && (is_major >= 4));
    var is_ie5    = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.0")!=-1) );
    var is_ie5_5  = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.5") !=-1));
    var is_ie5up  = (is_ie && !is_ie3 && !is_ie4);
    var is_ie5_5up =(is_ie && !is_ie3 && !is_ie4 && !is_ie5);
    var is_ie6    = (is_ie && (is_major == 4) && (agt.indexOf("msie 6.")!=-1) );
    var is_ie6up  = (is_ie && !is_ie3 && !is_ie4 && !is_ie5 && !is_ie5_5);
    // KNOWN BUG: On AOL4, returns false if IE3 is embedded browser
    // or if this is the first browser window opened.  Thus the
    // variables is_aol, is_aol3, and is_aol4 aren't 100% reliable.
    var is_aol   = (agt.indexOf("aol") != -1);
    var is_aol3  = (is_aol && is_ie3);
    var is_aol4  = (is_aol && is_ie4);
    var is_aol5  = (agt.indexOf("aol 5") != -1);
    var is_aol6  = (agt.indexOf("aol 6") != -1);
    var is_opera = (agt.indexOf("opera") != -1);
    var is_opera2 = (agt.indexOf("opera 2") != -1 || agt.indexOf("opera/2") != -1);
    var is_opera3 = (agt.indexOf("opera 3") != -1 || agt.indexOf("opera/3") != -1);
    var is_opera4 = (agt.indexOf("opera 4") != -1 || agt.indexOf("opera/4") != -1);
    var is_opera5 = (agt.indexOf("opera 5") != -1 || agt.indexOf("opera/5") != -1);
    var is_opera5up = (is_opera && !is_opera2 && !is_opera3 && !is_opera4);
    var is_webtv = (agt.indexOf("webtv") != -1); 

    var is_TVNavigator = ((agt.indexOf("navio") != -1) || (agt.indexOf("navio_aoltv") != -1)); 
    var is_AOLTV = is_TVNavigator;
    var is_hotjava = (agt.indexOf("hotjava") != -1);
    var is_hotjava3 = (is_hotjava && (is_major == 3));
    var is_hotjava3up = (is_hotjava && (is_major >= 3));
    // *** JAVASCRIPT VERSION CHECK ***
    var is_js;
    if (is_nav2 || is_ie3) is_js = 1.0;
    else if (is_nav3) is_js = 1.1;
    else if (is_opera5up) is_js = 1.3;
    else if (is_opera) is_js = 1.1;
    else if ((is_nav4 && (is_minor <= 4.05)) || is_ie4) is_js = 1.2;
    else if ((is_nav4 && (is_minor > 4.05)) || is_ie5) is_js = 1.3;
    else if (is_hotjava3up) is_js = 1.4;
    else if (is_nav6 || is_gecko) is_js = 1.5;
    // NOTE: In the future, update this code when newer versions of JS
    // are released. For now, we try to provide some upward compatibility
    // so that future versions of Nav and IE will show they are at
    // *least* JS 1.x capable. Always check for JS version compatibility
    // with > or >=.
    else if (is_nav6up) is_js = 1.5;
    // NOTE: ie5up on mac is 1.4
    else if (is_ie5up) is_js = 1.3

    // HACK: no idea for other browsers; always check for JS version with > or >=
    else is_js = 0.0;
    // *** PLATFORM ***
    var is_win   = ( (agt.indexOf("win")!=-1) || (agt.indexOf("16bit")!=-1) );
    // NOTE: On Opera 3.0, the userAgent string includes "Windows 95/NT4" on all
    //        Win32, so you can't distinguish between Win95 and WinNT.
    var is_win95 = ((agt.indexOf("win95")!=-1) || (agt.indexOf("windows 95")!=-1));
    // is this a 16 bit compiled version?
    var is_win16 = ((agt.indexOf("win16")!=-1) || 
               (agt.indexOf("16bit")!=-1) || (agt.indexOf("windows 3.1")!=-1) || 
               (agt.indexOf("windows 16-bit")!=-1) );  

    var is_win31 = ((agt.indexOf("windows 3.1")!=-1) || (agt.indexOf("win16")!=-1) ||
                    (agt.indexOf("windows 16-bit")!=-1));
    var is_winme = ((agt.indexOf("win 9x 4.90")!=-1));
    var is_win2k = ((agt.indexOf("windows nt 5.0")!=-1));
    // NOTE: Reliable detection of Win98 may not be possible. It appears that:
    //       - On Nav 4.x and before you'll get plain "Windows" in userAgent.
    //       - On Mercury client, the 32-bit version will return "Win98", but
    //         the 16-bit version running on Win98 will still return "Win95".
    var is_win98 = ((agt.indexOf("win98")!=-1) || (agt.indexOf("windows 98")!=-1));
    var is_winnt = ((agt.indexOf("winnt")!=-1) || (agt.indexOf("windows nt")!=-1));
    var is_win32 = (is_win95 || is_winnt || is_win98 || 
                    ((is_major >= 4) && (navigator.platform == "Win32")) ||
                    (agt.indexOf("win32")!=-1) || (agt.indexOf("32bit")!=-1));
    var is_os2   = ((agt.indexOf("os/2")!=-1) || 
                    (navigator.appVersion.indexOf("OS/2")!=-1) ||   
                    (agt.indexOf("ibm-webexplorer")!=-1));
    var is_mac    = (agt.indexOf("mac")!=-1);
    // hack ie5 js version for mac
    if (is_mac && is_ie5up) is_js = 1.4;
    var is_mac68k = (is_mac && ((agt.indexOf("68k")!=-1) || 
                               (agt.indexOf("68000")!=-1)));
    var is_macppc = (is_mac && ((agt.indexOf("ppc")!=-1) || 
                                (agt.indexOf("powerpc")!=-1)));
    var is_sun   = (agt.indexOf("sunos")!=-1);
    var is_sun4  = (agt.indexOf("sunos 4")!=-1);
    var is_sun5  = (agt.indexOf("sunos 5")!=-1);
    var is_suni86= (is_sun && (agt.indexOf("i86")!=-1));
    var is_irix  = (agt.indexOf("irix") !=-1);    // SGI
    var is_irix5 = (agt.indexOf("irix 5") !=-1);
    var is_irix6 = ((agt.indexOf("irix 6") !=-1) || (agt.indexOf("irix6") !=-1));
    var is_hpux  = (agt.indexOf("hp-ux")!=-1);
    var is_hpux9 = (is_hpux && (agt.indexOf("09.")!=-1));
    var is_hpux10= (is_hpux && (agt.indexOf("10.")!=-1));
    var is_aix   = (agt.indexOf("aix") !=-1);      // IBM
    var is_aix1  = (agt.indexOf("aix 1") !=-1);    
    var is_aix2  = (agt.indexOf("aix 2") !=-1);    
    var is_aix3  = (agt.indexOf("aix 3") !=-1);    
    var is_aix4  = (agt.indexOf("aix 4") !=-1);    
    var is_linux = (agt.indexOf("inux")!=-1);
    var is_sco   = (agt.indexOf("sco")!=-1) || (agt.indexOf("unix_sv")!=-1);
    var is_unixware = (agt.indexOf("unix_system_v")!=-1); 
    var is_mpras    = (agt.indexOf("ncr")!=-1); 
    var is_reliant  = (agt.indexOf("reliantunix")!=-1);
    var is_dec   = ((agt.indexOf("dec")!=-1) || (agt.indexOf("osf1")!=-1) || 
           (agt.indexOf("dec_alpha")!=-1) || (agt.indexOf("alphaserver")!=-1) || 
           (agt.indexOf("ultrix")!=-1) || (agt.indexOf("alphastation")!=-1)); 
    var is_sinix = (agt.indexOf("sinix")!=-1);
    var is_freebsd = (agt.indexOf("freebsd")!=-1);
    var is_bsd = (agt.indexOf("bsd")!=-1);
    var is_unix  = ((agt.indexOf("x11")!=-1) || is_sun || is_irix || is_hpux || 
                 is_sco ||is_unixware || is_mpras || is_reliant || 
                 is_dec || is_sinix || is_aix || is_linux || is_bsd || is_freebsd);
    var is_vms   = ((agt.indexOf("vax")!=-1) || (agt.indexOf("openvms")!=-1));
/* check to see if this browser supports DHTML */
var DHTML = (document.getElementById || document.all || document.layers);
function checkform(aform){
	for ( var i=0;i<aform.length;i++ )
    	{
		element = aform.elements[i];
		id = element.id;
		if (id){
			split = id.indexOf('__');
			name = id.substring(0, split);
			if (!name){
				continue;
			}
			attrib = id.substring(split + 2, id.length);
			// ff had no problem accessing chars in the attrib string (below) through array notation, 
			// but ie6 needed to split() the array with empty string in order to create an 
			// array with each char from the orig string being represented as an elt in the array 
			attrib = attrib.split("");
			if (attrib[0] == 'y'){
				if (element.value == ""){
					name = name.replace('_', ' ');
					alert('Please fill in a value for ' + name);
					document.getElementById(id).focus();
					return false;
				}
			}
			if (attrib[1] == 'y'){
				var reg = /^\s*\d\d\d\d\-\d?\d\-\d?\d\s*$/;
				var results = reg.exec(element.value);
				if (results == null || element.value == "0000-00-00"){
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

function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}

function closeIt() {
  close();
}

function openHelp (link) {
	var param = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	var win_name = 'quickhelp';
	help_window = window.open(link, win_name, param);
	if (!help_window.opener) help_window.opener = self;
}

function openJustContent(content_id, win_name, params){
	if(!win_name) win_name = 'just_content';
	if(!params) params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	content_window = window.open('/view/justcontent/content/' + content_id, win_name, params);
	if (!content_window.opener) help_window.opener = self;
}


function show_props(obj, obj_name) {
   var result = ""
   for (var i in obj)
      result += obj_name + "." + i + " = " + obj[i] + "<br>\n"
   return result
}

function go_back(url){
        window.location = url;
}


function open_window(url, param){
        	chooser_window = window.open(url, "opensaysme", param);
	        if (!chooser_window.opener) chooser_window.opener = self;
	}

function check_dropdowns(this_dropdown, that_dropdown){
	if (this_dropdown.selectedIndex > 0 ){
		that_dropdown.disabled = true;
		that_dropdown.style.color='#E7EFF7';
	}else{
		that_dropdown.disabled = false;
		that_dropdown.style.color='#000000';
	}
}

function toggle_boxes(element, form, boxname){
	boxes = form.elements[boxname];
	for (var index=0; index<boxes.length; index++){
		boxes[index].checked = element.checked;
	}
}

function getObj(name)
{
  if (document.getElementById)
  {
  	this.obj = document.getElementById(name);
	if (this.obj != null){
		this.style = document.getElementById(name).style;
	} 
  }
  else if (document.all)
  {
	this.obj = document.all[name];
	this.style = document.all[name].style;
  }
  else if (document.layers)
  {
   	this.obj = document.layers[name];
   	this.style = document.layers[name];
  }
}

function isValidTUSKBrowser(){
	
	var errordiv = document.getElementById('errordiv');
	if (errordiv.innerHTML == null){
		errordiv.innerHTML = null;
		alert("errordiv not found.");
		return;
	}
	var browser_error = 0;
	if ((is_mac) && (is_ie)){
		browser_error = 1; 	
	}
	if ((!is_ie6up) && (!is_nav6up)){
		browser_error = 1;
	}
	if(browser_error){
		errordiv.innerHTML += ' You need to use a supported browser. ' + 
			'<br>See <a href="/hsdb45/course/HSDB/1185">Help</a> for more information.';
	}
		
}

function togglelayerbutton(button, layername, title){
	var layer;
	if (document.layers) {
		layer = document.layers[layername];
	} else if (document.all) {
		layer = document.all[layername];
	}else{
		layer = document.getElementById(layername);
	}
	
	var extra;
	if (title){
		extra = " " + title;
	}

	if (button.value == 'Hide' + extra){
		layer.style.display = 'none';
		button.value = 'Show' + extra;
	}else{
		layer.style.display = 'block';
		button.value = 'Hide' + extra;
	}
}


function togglelayer(layername, checked){
	var layer;
	if (document.layers) {
		layer = document.layers[layername];
	} else if (document.all) {
		layer = document.all[layername];
	}else{
		layer = document.getElementById(layername);
	}
	
	if (checked){
		layer.style.visibility = "hidden";
	}else{
		layer.style.visibility = "visible";
	}
}

function updatetime(form, label){
	var string;
	if (form.elements['timebox-checkbox-' + label]){
		if (form.elements['timebox-checkbox-' + label].checked){
			form.elements[label].value = "00:00:00";
			return;
		}
	}

	form.elements[label].value = form.elements['hours-' + label].options[form.elements['hours-' + label].selectedIndex].value
	form.elements[label].value += ":" + form.elements['minutes-' + label].options[form.elements['minutes-' + label].selectedIndex].value
	if (form.elements['seconds-' + label]){
		form.elements[label].value += ":" + form.elements['seconds-' + label].options[form.elements['seconds-' + label].selectedIndex].value
	}else{
		form.elements[label].value += ":00";
	}

}

function make_date_object(date_string){
	var date_array = date_string.split(/[- :]/);
	// Date constructor needs month val from 0-11. cast string to integer and subtract 1
	var month = (parseInt(date_array[1], 10)) - 1;
	return new Date(date_array[0], month, date_array[2], date_array[3], date_array[4]);
}

function make_date_no_time_object(date_string){
	var date_array = date_string.split(/[- ]/);
	return new Date(date_array[0], date_array[1], date_array[2]);
}

function isValidDate(date) {
	var date_str   = date.value;
	date_str = date_str.replace(/^\s+|\s+$/g,"");
	var date_array = date_str.split(/[- :]/);
	var dt;
	if ( !date_str.match(/^\d{4}-\d{2}-\d{2}(?:\s\d{2}:\d{2}(?::\d{2})?)?$/) ) {
		return false;
	}

	if ( date_array.length == 3 ) {
		dt = new Date(date_array[0], date_array[1]-1, date_array[2]);
		if (dt.getDate() != date_array[2]){
			return false;
		} else if (dt.getMonth()+1 != date_array[1]){
			return false;
		} else if(dt.getFullYear() != date_array[0]){
			return false;
		}
	} else if ( date_array.length == 5 ) {
		dt = new Date(date_array[0], date_array[1]-1, date_array[2], date_array[3], date_array[4]);
		if ( dt.getMinutes() != date_array[4] ) {
			return false;
		} else if ( dt.getHours() != date_array[3] ) {
			return false;
		} else if (dt.getDate() != date_array[2]){
			return false;
		} else if (dt.getMonth()+1 != date_array[1]){
			return false;
		} else if(dt.getFullYear() != date_array[0]){
			return false;
		}
	} else if ( date_array.length == 6 ) {
		dt = new Date(date_array[0], date_array[1]-1, date_array[2], date_array[3], date_array[4], date_array[5]);
		if ( dt.getSeconds() != date_array[5] ) {
			return false;
		} else if ( dt.getMinutes() != date_array[4] ) {
			return false;
		} else if ( dt.getHours() != date_array[3] ) {
			return false;
		} else if (dt.getDate() != date_array[2]){
			return false;
		} else if (dt.getMonth()+1 != date_array[1]){
			return false;
		} else if(dt.getFullYear() != date_array[0]){
			return false;
		}
	} else {
		return false;
	}

    return(true);
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
function show_subnav(id, sub_link){
	document.getElementById(id).className = 'showNav';
	document.getElementById(sub_link).innerHTML = '-';
}
function hide_subnav(id, sub_link){
	document.getElementById(id).className = 'hideNav';
	document.getElementById(sub_link).innerHTML = '+';
}
function toggle_subnav(id, sub_link){
	var status = document.getElementById(id).className;
	(status == 'showNav')? hide_subnav(id, sub_link) : show_subnav(id, sub_link);
}


//http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
function getScrollXY(){
	var scrOfX = 0, scrOfY = 0;
	if( typeof( window.pageYOffset ) == 'number' ) {
		//Netscape compliant
		scrOfY = window.pageYOffset;
		scrOfX = window.pageXOffset;
	} 
	else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
		//DOM compliant
		scrOfY = document.body.scrollTop;
		scrOfX = document.body.scrollLeft;
	} 
	else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
		//IE6 standards compliant mode
		scrOfY = document.documentElement.scrollTop;
		scrOfX = document.documentElement.scrollLeft;
	}
	return [ scrOfX, scrOfY ];
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
	return [curleft,curtop];
}

// given an event, find the element that initiated it
// that is, if anchor clicked on, return the anchor element
function getElt(e){
	var targ;
	if(e.target){ 
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
function addEvent( obj, type, fn )
{
	if (obj.addEventListener)
		obj.addEventListener( type, fn, false );
	else if (obj.attachEvent)
	{
		obj["e"+type+fn] = fn;
		obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
		obj.attachEvent( "on"+type, obj[type+fn] );
	}
}
// /end quirksmode functions


//simple form field validation. make sure there is a non-space character in field
function isBlank(field){
	if(field.value && /\S+/.test(field.value)) {
		return false;
	}
	return true;
}

//complex form field validation. checks radio buttons and selects; returns true if blank
function multipleIsBlank(field){
	var value = multipleValue(field);
	if (value && /\S+/.test(value)) {
		return false;
	}
	else {
		return true;
	}
}

//complex form field validation. checks radio buttons and selects; returns value if there is one
function multipleValue(field){
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
	}
	else {
		return false;
	}
}

// basic moving effects function-set. if we want to do some more complex stuff, we should probably invest some time in examining yahoo's yui or the script.aculo.us libs.
function fxLock(ele){
	if(!ele.lock || ele.lock == false){
		ele.lock = true;
		return false;
	}
	else {
		return true;
	}
}

function widthfx(from, to, ele, options){
	if(!fxLock(ele)){
		var increment = (typeof(options) == 'object' && options.increment)? options.increment : 5;
		var duration =  (typeof(options) == 'object' && options.duration)? options.duration : 15;
		if (from > to) increment -= (2 * increment);
	
		movefx('width', from, to, ele, increment, duration);
	}
}

function heightfx(from, to, ele, options){
	if(!fxLock(ele)){
		var increment = (typeof(options) == 'object' && options.increment)? options.increment : 10;
		var duration =  (typeof(options) == 'object' && options.duration)? options.duration : 15;
		if (from > to) increment -= (2 * increment);
		movefx('height', from, to, ele, increment, duration);
	}
}

function movefx(effect, from, to, ele, increment, duration){

		if(from == to) {
			ele.lock = false;
			return;
		} else if(Math.abs((to - from)) <= Math.abs(increment)){
			from = to;
		} else {
			from += increment;
		}

		ele.style[effect] = (from + 'px');
		setTimeout(function(){movefx(effect, from, to, ele, increment, duration)}, duration);			
	
}
// end effects

function email_user(user_id, context_path){
	var pop_url = '/management/mail/emailuser/' + context_path + '?recipient=' + user_id;
	var params = "directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=" + 650 + ",height=" + 450;
	var win = window.open(pop_url, 'email_' + user_id, params);
}

function toggle_div(id){
	var new_display = 'none';
	if (document.getElementById(id).style.display == 'none'){
		new_display = 'block';
	}

	document.getElementById(id).style.display = new_display;
}


/*
fx for form on /management/course/modify/ and /management/course/info/
*/
function adjustXtraFields(selection, integrated){

	var selectionTxt = selection[selection.selectedIndex].text;
	if(!selectionTxt || selectionTxt.match(/group|thesis committee/i)){
		document.getElementById('caeXtraFields').className = 'hideAll';		
	}
	else {
		document.getElementById('caeXtraFields').className = 'showAll';
	}

	if ( integrated ) {
	    if (!selectionTxt.match(/integrated course/i)){
			document.getElementById('caeSubcourses').className = 'hideAll';
		}
		else {
			document.getElementById('caeSubcourses').className = 'showAll';
		}
	}
}

// get http request
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


// http://www.quirksmode.org/viewport/compatibility.html
// sec: 'scrolling offset'
function getTopOfScreen(){
	var screen_top;
	if (self.pageYOffset){ // all except Explorer
		screen_top = self.pageYOffset;
	}
	else if (document.documentElement && document.documentElement.scrollTop){
	// Explorer 6 Strict
		screen_top = document.documentElement.scrollTop;
	}
	else if (document.body){
 	// all other Explorers
		screen_top = document.body.scrollTop;
	}
	return screen_top;
}

// http://www.quirksmode.org/viewport/compatibility.html
// sec: 'Page Height'
// Further discussion on different ways to get page dimensions:
// http://www.quirksmode.org/js/doctypes.html
function getPageXY(){
	var x,y;
	var test1 = document.body.scrollHeight;
	var test2 = document.body.offsetHeight;
	var test3 = document.documentElement.scrollHeight;
	if (test1 > test2){
	// all but IE
		x = document.body.scrollWidth;
		y = document.body.scrollHeight;
	}
	else if (test3 > test2){
	// IE 6
		x = document.documentElement.scrollWidth;
		y = document.documentElement.scrollHeight;
	}
	else{
	// others
		x = document.body.offsetWidth;
		y = document.body.offsetHeight;
	}
	
	return [x, y];
}


// given a frame, will set all links to have a target of _top unless they already
// have that value set to _blank
function setTargets(frame_name){
	var doc = top[frame_name].document;
	var lnks = doc.getElementsByTagName('a');
	for(var i=0; i<lnks.length; i++){
		if(lnks[i].target != '_blank'){
			lnks[i].target = '_top';
		}
	}
}

// will set a hidden input field to transmit the desired timeperiod, while changing dropdown
// back to a neutral state; eg "please select time period"
function updateTPAndSubmit(elt){
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
function getElement(elt){
	if(elt){
		if(typeof elt == 'string'){
			elt = document.getElementById(elt);
		}
		// if we were passed a string, make sure it was a valid id that returned a DOM elt
		if(elt){
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
function hide(elt){
	elt = getElement(elt);
	if(elt){
		elt.style.visibility = 'hidden';
	}
}

/* to show a hidden element. 
   can pass in either a string id or an actual DOM element
*/
function show(elt){
	elt = getElement(elt);
	if(elt){
		elt.style.visibility = 'visible';
	}
}

// from: http://www.dustindiaz.com/getelementsbyclass/
function getElementsByClass(params){

	if (typeof(params) != 'object')
		return [];
	if (params['className'] == null)
		return [];
	var searchClass = params['className'];
	var node        = params['node'];
	var tag         = params['tag'];
	var classElements = new Array();
	if ( node == null )
		node = document;
	if ( tag == null )
		tag = '*';
	var els = node.getElementsByTagName(tag);
	var elsLen = els.length;
	var pattern = new RegExp("(^|\\s)"+searchClass+"(\\s|$)");
	for (i = 0, j = 0; i < elsLen; i++) {
		if ( pattern.test(els[i].className) ) {
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
function toggleExcess(elt){
	if(!elt.fullTxtWin){
		var new_win = document.createElement('div');
		new_win.innerHTML = elt.innerHTML;
		new_win.className = 'excessTxtWin gHidden';
		document.body.appendChild(new_win);
		elt.fullTxtWin = new_win;
	}

	if(elt.fullTxtWin.className.match(/\sgHidden/)){
		positionExcessWin(elt);
		elt.fullTxtWin.className = elt.fullTxtWin.className.replace(/\sgHidden/, '');
	}
	else {
		elt.fullTxtWin.className += ' gHidden';
	}
}

function positionExcessWin(elt){
	var txt_win = elt.fullTxtWin;
	var hgt = txt_win.offsetHeight;
	var browser_top = getScrollXY()[1];
	var yPos = findPos(elt)[1] - hgt;
	if(yPos < browser_top){
		 yPos = findPos(elt)[1] + elt.offsetHeight + 5;
	}
	txt_win.style.top = yPos + 'px';
	var width = txt_win.offsetWidth;		
	var browser_width = document.documentElement.clientWidth;
	var browser_scroll = getScrollXY()[0];
	var browser_edge = browser_scroll + browser_width
	var xPos = findPos(elt)[0];
	if((xPos + width) > browser_edge){
		xPos = browser_edge - width - 20;
		if(xPos < browser_scroll){
			xPos = findPos(elt)[0];
		}
	}
	txt_win.style.left = xPos + 'px';
}

function setupCal(elt){
	Calendar.setup({
		inputField     :    elt.id,
		ifFormat       :    "%Y-%m-%d",       // format of the input field
		showsTime      :    false,      // will display a time selector
		button         :    elt.id,
		singleClick    :    true,           // double-click mode
		align          :    "Tl",
		step           :    1          // show all years in drop-down boxes (instead of every other year as default)
	});
	elt.onclick();
}

// This function will be called by any calendar textbox to ensure proper dates
// are entered throughout the form.  If any date is invalid, the form will not
// submit.
//
// Parameters:  el       -  form element
//              no_empty -  1 indicates blank date is bad
function checkDates( el, no_empty ) {
	if ( el.form.orig_onsubmit == undefined ) {
		el.form.orig_onsubmit = null;
	}
	if ( el.form.invalid_dates == undefined ) {
		el.form.invalid_dates = new Array();
	}

	var isValid;
	if ( no_empty ) {
		isValid = isValidDate( el );
	} else {
		isValid = isValidDateOrEmpty( el );
	}
	if ( !isValid ) {
		if ( !el.form.invalid_dates[ el.id ] ) {
			el.form.invalid_dates[ el.id ] = 1;
			if ( el.form.orig_onsubmit === null ) {
				if ( el.form.onsubmit == undefined ) {
					el.form.orig_onsubmit = "";
				} else {
					el.form.orig_onsubmit = el.form.onsubmit;
				}
			}

			el.form.onsubmit = function test() { alert( 'Error:  Please make sure that all dates are valid.' ); return false; }
			el.style.backgroundColor = "#FF3333";
		}
	} else {
		if ( el.form.invalid_dates[ el.id ] ) {
			var all_ok = 1;
			el.form.invalid_dates[ el.id ] = 0;
			for (var i in el.form.invalid_dates) {
				if ( el.form.invalid_dates[i] ) { all_ok = 0; break; }
			}

			if ( all_ok && el.form.orig_onsubmit !== null ) {
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
function activateTab(active){
	var nav = active.parentNode.parentNode;
	var deactivate = getElementsByClass({node: nav, tag:'li', className:'activeTab'})[0];
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