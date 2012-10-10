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



