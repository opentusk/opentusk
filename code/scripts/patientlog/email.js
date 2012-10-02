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


var missingEmails = 0;

$(function() {

	$("#tpid").change(displayEmailRecipients);

	$('#emailsubmit').click(sendEmail);

	$('#alladdrs').live("click", function() {
		$("input[name='to_addr']").attr('checked', $("#alladdrs").is(':checked'));   
	}); 
});

function displayEmailRecipients() {
	$("div#ok-container").hide("slow");

   	$.ajax({
		type		: 'POST',
		url			: '/patientlog/author/emailgetrecipients/' + $("input[name='type_path']").val(),
		dataType	: 'json',
		data		: $(this).serialize(),
        success		: function(data) {
			var directors = data.directors || [];
			var siteDirectors = data.sitedirectors || [];
			if (directors.length == 0 && siteDirectors.length == 0) {
				$('#recipients').html('<em>No associated email recipients</em>');							
			} else {
				var items = '';
				
				if (directors.length) {
					items += '<li><span class="med"> &nbsp;Directors</span> <span class="xsm">(' + directors.length + ')</span></li>';
					items = getItems(directors, items);
				}

				if (siteDirectors.length) {
					items += '<li><span class="med"> &nbsp;Site Directors</span> <span class="xsm">(' + siteDirectors.length + ')</span></li>';
					items = getItems(siteDirectors, items);
				}

				var sitesWithNoDirector = '';
				if (data.siteswithnodirector && data.siteswithnodirector.length) {
					sitesWithNoDirector += '<br/><div class="sm errTxt"> Site(s) with no assigned Site Director. Please update on faculty page.</div>';
					var cnt = 1;
					$.each(data.siteswithnodirector, function(i) {
						sitesWithNoDirector	+= '<div class="xsm errTxt"> &nbsp;' + cnt++ + '. ' + data.siteswithnodirector[i] + '</div>';
					});
				}

				var pretext = '';
				if (directors.length + siteDirectors.length > 1) {
					pretext += '<div><input type="checkbox" id="alladdrs" /> Select/Deselect all</div>';
				}

				if (missingEmails > 0) {
					pretext += '<div class="errTxt">Missing email address(es). Please update on user page.</div>';
					missingEmails = 0;
				}

				$('#recipients').html(pretext + '<ul class="scrollChecklist">' + items + '</ul>' + sitesWithNoDirector);
			}
		},
		error		: function(xhr, ajaxOptions, thrownError) {
           	alert('Error: ' + thrownError);
       	}    
	});
}


function getItems(data, items) {
	$.each(data, function(i) {
	    items += '<li><input type="checkbox" name="to_addr" value="' + data[i].email + '__' + data[i].isSiteDirector + '__' + data[i].siteId + '" ';
		items += (data[i].email) ? '' : 'DISABLED';
		items += ' /> <span class="sm">' + unescape(data[i].name) + '</span> &nbsp;&nbsp;';
		if (data[i].isSiteDirector) {
			items +=  '<span class="xsm">' + data[i].siteName + '</span>';
		}
		if (!data[i].email) {
			items += ' <span class="xsm errTxt errmsg" style="padding-left:20px"> <em>Missing Email Address</em></span>';
			missingEmails++;
		}
		items += "</li>\n";
	});

	return items;
}


function isAtLeastOneRecipient() {
	var selected = 0;
	$("input[name='to_addr']").each(function() {
		if ($(this).is(':checked')) {
			selected = 1;
			return false;
		}
	});

	return selected;
}

function sendEmail() {
	if (!$("input[name='to_addr']").length) {
		alert("There is no recipient to send email");
		return false;
	}

	if (!isAtLeastOneRecipient()) {
		alert("Please select at least one email recipient");
		return false;
	}

	if (confirm("Are you sure you want to send email(s)?") == false) {
		return false;
	}

   	$("div#ok-container").text("Sending Email(s) ...");
	$("div#ok-container").show("slow");
	$("#emailform").hide("slow");

    $.ajax({
		type		: 'POST',
		url			: '/patientlog/author/emailsend/' + $("input[name='type_path']").val(),
		dataType	: 'json',
		data		: $('#emailplogs').serialize(),
        success		: function(response) {
		   	$("div#ok-container").text(response.msg);
			$("#emailform").show("slow");
		},
		error		: function(xhr, ajaxOptions, thrownError) {
		   	$("div#ok-container").text('There is an error sending email(s)');
			$("#emailform").show("slow");
        }    
    });
	return false;
}


