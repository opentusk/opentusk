$(document).ready(function(){
	$('ul img.more').click(changeState);
	$('.notifications .close').click(closeNotifications);
	$('nav.tabs li a').click(changeTabState);
	$('nav.toptabs li a').click(changeTabState);
	$('.personal .tab input[type=button]').click(managePersonalLinks);
	makeLinksDropDown();
});

var $dialog;

// toggle nested list state between open and closed
function changeState() {
	var item = $(this).parent('li');
	$(item).toggleClass('open');
	$(item).toggleClass('closed');
}

// hide school announcements currently being displayed and save preference to database
function closeNotifications() {
	$('.notifications').hide();
	$('#gContent').removeClass('withnote');
	// AJAX call to hide user's current announcements
	var url = '/user/ajax/hideCurrentAnnouncements';
	var xRequest = new initXMLHTTPRequest();
	if (xRequest) {
		xRequest.open("POST", url, true);
		xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xRequest.send();
	}
	materialsHeightAdjust();
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

/* begin Personal Links */

// show dialog box for managing personal links
function managePersonalLinks() {
	if (!$dialog) {
		$dialog = $('<div></div>')
			.html('<form onsubmit="return savePersonalLinks()"><h2>' + _("Add New Link") + '</h2><p><label>' + _("Label") + '</label><input type="text" id="newlabel" /><span class="spacer">&nbsp;</span><label>' + _("URL") + '</label><input type="text" id="newurl" /><span class="spacer">&nbsp;</span><input type="button" value="' + _("add") + '" onclick="addPersonalLink()" /></p><hr /><h2>' + _("Modify Existing Links") + '</h2><p>' + _("To delete an existing link, leave both the Label and URL fields blank.") + '</p><div id="personalLinks">' + displayPersonalLinks() + '</div><p class="buttons"><input type="submit" value="' + _("save") + '"></p></form>')
			.dialog({
				autoOpen: false,
				title: _("Manage your personal links"),
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
	var html = "<table>\n<thead>\n<tr>\n<th>" + _("Order") + "</th><th>" + _("Label") + "</th><th>" + _("URL") + "</th>\n</tr>\n</thead>\n<tbody>";
		
	var orders = jQuery.map(links, function(n, i){
      return (n.sort_order);
    });

	$.each(links, function(index, row) { 
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
			counter += 1;
		});
		html += "</select></td>\n<td><input type='text' class='js-personal-link-label' name='label_";
		html += row.id;
		html += "' value='";
		html += row.label;
		html += "' /></td>\n<td><input type='text' class='js-personal-link-url' name='url_";
		html += row.id;
		html += "' value='";
		html += row.url;
		html += "' /></td>\n</tr>";
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
		alert(_("Please fill out both the Label and URL fields to add a new link."));
	}
}

// submit links via AJAX and regenerate drop down of links
function savePersonalLinks() {
	// validate form data to make sure the necessary fields have been filled out
	var counter = 1;
	var error;
	$(".js-personal-link-label").each(function() {
		error = '';
		var thislabel = $(this).val();
		var thisurl =  $(this).parent('td').siblings().children(".js-personal-link-url").val();
		if (!(/^((https?|ftp):\/\/)?(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(thisurl))) {
			error = _('The URL in row ') + counter + _(' is not valid.\nIf you would like to delete a link, leave both the Label and URL fields blank.');
		}
		if(!(/\S+/.test(thislabel))) {
			error = _('The Label in row ') + counter + _(' is blank.\nIf you would like to delete a link, leave both the Label and URL fields blank.');
		}
		if(!(/\S+/.test(thisurl)) && !(/\S+/.test(thislabel))) {
			error = '';
		}
		if (error != '') {
			return false;
		}
		counter += 1;
	});

	if (error && error != '') {
		alert(error);
		return false;
	}

	// no error, so go ahead and send the AJAX request to save the data
	updateLinksArray();
	var ajax = new initXMLHTTPRequest();
	if (ajax) {
		ajax.open("POST", '/user/ajax/savePersonalLinks', true);
		ajax.onreadystatechange = resetAllLinkData;
		ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		ajax.send("data=" + encodeURIComponent(JSON.stringify(links)));
	}
	else {
		alert('There was an error saving the link data.');
	}
	return false;
}

// either use the JSON returned from the AJAX call to rebuild the links array, 
// dropdown and dialog fields
// or let the user know that there was a problem
function resetAllLinkData() {
	if (this.readyState == 4) {
		if (this.status == 200 && this.responseText) {
			var tmpArray = eval(this.responseText);
			links.length = 0;
			$(tmpArray).each(function() {
				links.push(JSON.parse(this));
			});
			makeLinksDropDown();
			$("#personalLinks").html(displayPersonalLinks());
			$($dialog).dialog( "close" );
		}
		else{
			alert(_("An error has occurred while attempting to save."));
			return false;
		}
	}
}

// update JSON array of links from input fields, ordered by sort_order field
function updateLinksArray() {
	links.length = 0;
	$(".js-personal-link-label").each(function() {
		var matches = $(this).attr("name").match(/label_(.*)/);
		var id = matches[1];
		var newItem = new Object();
		newItem.id = id;
		newItem.sort_order = $(this).parent('td').siblings().children(".sort_order").val();
		newItem.label = $(this).val();
		newItem.url =  $(this).parent('td').siblings().children(".js-personal-link-url").val();
		links.push(newItem);
	});
	links.sort(function(a,b){return a.sort_order - b.sort_order});
}

// use JSON links array to generate select form element of personal links
function makeLinksDropDown() {
	var options = "<option value=''>" + _("My links") + "...</option>";
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

/* end Personal Links */

function toggleMaterialLinks( material, obj ) {
	var materialLinks = document.getElementById( material );
	if ( $( '#' + material ).css( "display" ) == "inline" ) {
		$( '#' + material ).css( "display", "none" );
		$( obj ).children('img').attr( "src", "/graphics/icon-nav-closed.png" );
	} else {
		$( '#' + material ).css( "display", "inline" );
		$( obj ).children('img').attr( "src", "/graphics/icon-nav-open.png" );
		materialsHeightAdjust();
	}
}	

function materialsHeightAdjust() {	
	var paddingAdjustment = 70; //px
	var trafficLightHeight = ( $( '#gTrafficLight' ).height() ) || 0;
	if ( trafficLightHeight > 0 ) {
		paddingAdjustment = paddingAdjustment - 25;
	};
	var scrollBoxHeight = $( '#gContent' ).height() + trafficLightHeight - $( '#communicationsBox' ).height() - paddingAdjustment;
	$( '#materialsScrollContainer' ).css( "max-height", scrollBoxHeight );		
}

function toggleLinksLinks( material, obj ) {
	if ( $( '#' + material ).css( "display" ) == "none" ) {
		$( '#' + material ).css( "display", "block");
		$( obj ).children('img').attr( "src", "/graphics/icon-nav-open.png" );
	} else {
		$( '#' + material ).css( "display", "none");
		$( obj ).children('img').attr( "src", "/graphics/icon-nav-closed.png");
	}
}


	
	

