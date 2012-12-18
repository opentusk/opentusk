$(document).ready(function(){
	// attach behavior to nav "more" links
	$('ul img.more').click(changeNavSate);
	$('.notifications .close').click(closeNotifications);
	$('nav.tabs li a').click(changeTabState);
	$('nav.toptabs li a').click(changeTabState);
	$('.personal .tab input[type=button]').click(addPersonalLink);
});

function changeNavSate() {
	var item = $(this).parent('li');
	$(item).toggleClass('open');
	$(item).toggleClass('closed');
}

function closeNotifications() {
	$('.notifications').hide();
	$('#gContent').removeClass('withnote');

	// AJAX call to hide user's current announcements
	var url = '/tusk/ajax/hideCurrentAnnouncements';
	var xRequest = new initXMLHTTPRequest();
	if (xRequest) {
		xRequest.open("POST", url, true);
		xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xRequest.send();
	}

}

function changeTabState() {
	var tab = $($(this).attr('href'));
	tab.addClass('current');
	tab.siblings().removeClass('current');
	var item = $(this).parent('li');
	item.addClass('current');
	item.siblings().removeClass('current');
	return false;
}

function addPersonalLink() {
	var $dialog = $('<div></div>')
		.html('<form><p><label>URL </label><input type="text"></p><p>&nbsp;</p><p><label>link text </label><input type="text"></p><p>&nbsp;</p><p><input type="submit" value="save"></p></form>')
		.dialog({
			autoOpen: false,
			title: 'Add a personal link',
			modal: true
		});
	$dialog.dialog('open');
	// prevent the default action, e.g., following a link
	return false;
}

