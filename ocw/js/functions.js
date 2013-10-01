var survWin = null;

function popSurvey(checkshow) 
	{

	if (checkshow && getCookie('show_survey')){
		return;
	}
	
	setCookie('show_survey', 1, 0, '/');

	var url = "https://tuftsir.qualtrics.com/SE/?SID=SV_3KQVMDw6xICNpVa";

	// check if window already exists

	if (!survWin || survWin.closed) 
		{
		// store new window object in global variable
			survWin = window.open(url,'survey','width=735,height=400,toolbar=no,location=yes,directories=yes,status=yes,menubar=yes,scrollbars=yes,resizable=yes')
		} 
	else 
		{
		// window already exists, so bring it forward
		survWin.focus()
		}
	}

/**
 * Sets a Cookie with the given name and value.
 *
 * name       Name of the cookie
 * value      Value of the cookie
 * [expires]  Expiration date of the cookie (default: end of current session)
 * [path]     Path where the cookie is valid (default: path of calling document)
 * [domain]   Domain where the cookie is valid
 *              (default: domain of calling document)
 * [secure]   Boolean value indicating if the cookie transmission requires a
 *              secure transmission
 */

function setCookie(name, value, expires, path, domain, secure)
{
    document.cookie= name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires.toGMTString() : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

/**
 * Gets the value of the specified cookie.
 *
 * name  Name of the desired cookie.
 *
 * Returns a string containing value of specified cookie,
 *   or null if cookie does not exist.
 */
function getCookie(name)
{
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1)
    {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    }
    else
    {
        begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1)
    {
        end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
}

