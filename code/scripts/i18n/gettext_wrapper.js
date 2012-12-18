/* 
 * A thin wrapper around gettext.js to export short names for i18n functions.
 * These include all the normal gettext functions, as well as combinations of them,
 * and for each of these a version which supports variable interpolation.
 * Emulates the Locale::TextDomain API for consistency between our JS 
 * and Mason i18n functions.
 *
 * gettext.js doesn't handle contexts, and we will only be using one domain
 * in our application, so those options haven't been exposed here.
 */


//Include main gettext lib, so the caller doesn't have to include it explicitly.

/* Try and extract the 'domain' and 'lang' from parameters in the 'gettext' link we 
 * use for the .po href.
 * The domain/lang are set by I18N.pm using $ENV{'TUSK_LANGUAGE'} and $ENV{'TUSK_DOMAIN'}
*/

/* Here we use an anon function at startup to strip script query arguments from calling 
 * element.
 * It depends on script=id='i18n-gettext-js' being set.
 * It should parse and put into the params hash any number of arguments but currently
 * only 'domain' is used by gettext.
*/
var params = { "domain" : "tusk", "lang" : "C" };
(function(){
    	var scripts = document.getElementsByTagName("script");
	// Could use scripts[scripts.length - 1] here but breaks on async I used the 'id' attr instead
	for (var i=0; i<scripts.length; i++) {
		// script id supported http://www.w3schools.com/tags/ref_standardattributes.asp
		if (scripts[i].id == 'i18n-gettext-js') {
			// tokenize 'src' tag like script.js?foo=bar&bar=foo
			var tokens = scripts[i].src.split("?").pop().split("&");
			for(var j=0; j<tokens.length; j++) {
        			var pairs = tokens[j].split("=");
        			params[pairs[0]] = pairs[1];
			}
			
		}
	}	
	
}());

var gt = new Gettext(params);

/* Vanilla gettext */
function _ (msgid) {
	return gt.gettext(msgid);
}
function _x (msgid, subs) {
	return gt.gettext(msgid, subs);
}

/* Context */
function _p (ctxt, msgid) {
	return gt.pgettext(ctxt, msgid);
} 
function _px (ctxt, msgid, subs) {
	return gt.pgettext(ctxt, msgid, subs);
} 

/* Plurals */
function _n (singl, plural, num) {
	return gt.ngettext(singl, plural, num);
}
function _nx (singl, plural, num, subs) {
	return gt.ngettext(singl, plural, num, subs);
}

/* Combinations of the above */
function _np (msgctxt, msgid, msgid_plural, n) {
	return gt.npgettext(msgctxt, msgid, msgid_plural, n);
}
function _npx (msgctxt, msgid, msgid_plural, n, sub_tokens) {
	return gt.npgettext(msgctxt, msgid, msgid_plural, n, sub_tokens);
}
