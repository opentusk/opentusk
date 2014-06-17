function detectIE() {
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");

        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)){      
            alert("Our competency modules currently do not support the Internet Explorer web browsers. We recommend using either Google Chrome or Mozilla Firefox browsers while we work on making our modules IE-Compatible. We apologise for any inconvenience caused by this.");
	} else {
            return false;
	}
}