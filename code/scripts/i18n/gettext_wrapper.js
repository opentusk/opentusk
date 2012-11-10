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

var params = { "domain" : "tusk" };

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
