function detectIE(msg, msg11) {
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");

        if (msie > 0) {
		if (typeof msg === "undefined"){
	            alert("The page you are currently trying to access does not fully support the Internet Explorer web browser. We recommend using either Google Chrome or Mozilla Firefox browsers while we work on making our modules IE-Compatible. We apologise for any inconvenience caused by this.");
		} else {
		    alert(msg);
	    	}	
	} else if ( !!navigator.userAgent.match(/Trident.*rv\:11\./)) {      
	    	if (typeof msg11 === "undefined" && typeof msg === "undefined") {
	            alert("The page you are currently trying to access does not fully support the Internet Explorer web browser. We recommend using either Google Chrome or Mozilla Firefox browsers while we work on making our modules IE-Compatible. We apologise for any inconvenience caused by this.");
	    	} else {
			if (typeof msg11 === "undefined" ){
				alert(msg);
			} else {
				alert(msg11);
			}
	    	}
	} else {
		return false;
	}
}