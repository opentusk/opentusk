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


//Disable right mouse click Script
//By Maximus (maximus@nsimail.com) w/ mods by DynamicDrive
//For full source code, visit http://www.dynamicdrive.com
///////////////////////////////////

function clickIE4(){
	if (event.button==2) {
		alert(message);
		return false;
	}
}

function clickNS4(e) {
	if (document.layers||document.getElementById&&!document.all) {
		if (e.which==2||e.which==3) {
			alert(message);
			return false;
		}
	}
}

function disableRightClick(message) {
	if (document.layers) {
		document.captureEvents(Event.MOUSEDOWN);
		document.onmousedown=clickNS4;
	} else if (document.all&&!document.getElementById) {
		document.onmousedown=clickIE4;
	}

	document.oncontextmenu=new Function("alert(message);return false")
}



