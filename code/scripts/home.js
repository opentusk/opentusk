$(document).ready(function(){
	// attach behavior to nav "more" links
	$('ul img.more').click(changeNavSate);
	$('.notifications .close').click(closeNotifications);
	$('nav.tabs li a').click(changeTabState);
	$('nav.toptabs li a').click(changeTabState);
	$('.personal .tab input[type=button]').click(managePersonalLinks);
	makeLinksDropDown();
});

var $dialog;

function changeNavSate() {
	var item = $(this).parent('li');
	$(item).toggleClass('open');
	$(item).toggleClass('closed');
}

// hide school announcements currently being displayed and save preference to database
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

// change class of clicked on tab to current and make previous tab not current anymore
function changeTabState() {
	var tab = $($(this).attr('href'));
	tab.addClass('current');
	tab.siblings().removeClass('current');
	var item = $(this).parent('li');
	item.addClass('current');
	item.siblings().removeClass('current');
	return false;
}

// show dialog box for managing personal links
function managePersonalLinks() {
	if (!$dialog) {
		$dialog = $('<div></div>')
			.html('<form onsubmit="return savePersonalLinks()"><h2>Add New Link</h2><p><label>Label</label><input type="text" id="newlabel" /><span class="spacer">&nbsp;</span><label>URL</label><input type="text" id="newurl" /><span class="spacer">&nbsp;</span><input type="button" value="add" onclick="addPersonalLink()" /></p><hr /><h2>Modify Existing Links</h2><div id="personalLinks">' + displayPersonalLinks() + '</div><p class="buttons"><input type="submit" value="save"></p></form>')
			.dialog({
				autoOpen: false,
				title: 'Manage your personal links',
				modal: true,
				width: '50%'
			});
		}
	$dialog.dialog('open');
	// prevent the default action (following a link)
	return false;
}

// loop through links JSON array and output HTML table of links
// will re-set order to continuous increments starting with 1 in case there are gaps
function displayPersonalLinks() {
	var html = "<table>\n<thead>\n<tr>\n<th>Order</th><th>Label</th><th>URL</th>\n</tr>\n</thead>\n<tbody>";
		
	var orders = jQuery.map(links, function(n, i){
      return (n.sort_order);
    });

	$.each(links, function(index, row) { 
		if (row.label != '' && row.url != '') {
			html += "<tr>\n<td><select class='sort_order' name='sort_order_";
			html += row.id;
			html += "'>\n";
			var counter = 1;
			$.each(orders, function(num, thisvalue) {
				html += "<option";
				if (row.sort_order == thisvalue) {
					html += " selected='selected'>";
				}
				else {
					html += ">";
				}
				html += counter;
				html += "</option>\n";
			});
			html += "</select></td>\n<td><input type='text' class='label' name='label_";
			html += row.id;
			html += "' value='";
			html += row.label;
			html += "' /></td>\n<td><input type='text' class='url' name='url_";
			html += row.id;
			html += "' value='";
			html += row.url;
			html += "' /></td>\n</tr>";
		}
	});
	html += "</tbody></table>";
	return html;
}

// add new element to JSON array of links from form fields and re-display table
function addPersonalLink() {
	updateLinksArray();
	if ($("#newlabel").val() && $("#newurl").val()) {
		var newItem = new Object();
		newItem.id = '';
		newItem.sort_order = links.length + 1;
		newItem.label = $("#newlabel").val();
		newItem.url =  $("#newurl").val();
		links.push(newItem);
		$("#newlabel").val('');
		$("#newurl").val('');
		$("#personalLinks").html(displayPersonalLinks());
	}
	else {
		alert('Please fill out both the label and URL fields to add a new link.');
	}
}

// submit links via AJAX and regenerate drop down of links
function savePersonalLinks() {
	updateLinksArray();
	var ajax = new initXMLHTTPRequest();
	if (ajax) {
		ajax.open("POST", '/tusk/ajax/savePersonalLinks', true);
		ajax.onreadystatechange = resetAllLinkData;
		ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		ajax.send("data=" + encodeURIComponent(JSON.stringify(links)));
		$($dialog).dialog( "close" );
	}
	else {
		alert('There was an error saving the link data.');
	}
	return false;
}

function resetAllLinkData() {
	if (this.readyState == this.DONE && this.responseText) {
		var tmpArray = eval(this.responseText);
		links.length = 0;
		$(tmpArray).each(function() {
			links.push(JSON.parse(this));
		});
		makeLinksDropDown();
		$("#personalLinks").html(displayPersonalLinks());
	}
}

// update JSON array of links from input fields, ordered by sort_order field
function updateLinksArray() {
	links.length = 0;
	$(".label").each(function() {
		var matches = $(this).attr("name").match(/label_(.*)/);
		var id = matches[1];
		var newItem = new Object();
		newItem.id = id;
		newItem.sort_order = $(this).parent('td').siblings().children(".sort_order").val();
		newItem.label = $(this).val();
		newItem.url =  $(this).parent('td').siblings().children(".url").val();
		links.push(newItem);
	});
	links.sort(function(a,b){return a.sort_order - b.sort_order});
}

function makeLinksDropDown() {
	var options = "<option value=''>My links...</option>";
	$.each(links, function(index, hash) {
		if (hash.label != '' && hash.url != '') {
			options += '<option value="';
			options += hash.url
			options += '">';
			options += hash.label;
			options += "</option>\n";
		}
	});
	$("select.linklist").html(options);
}
