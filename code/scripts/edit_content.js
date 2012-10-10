/* toolkit of js functions to extend the functionality of /management/content/addedit pages in tusk */

function checkFileType(fileName, acceptableTypes) {
	if(acceptableTypes && acceptableTypes != 'any') {
		var fileExtension = fileName.replace(/.*\./, '\.');
		var theAcceptableTypes = acceptableTypes.split(' ');
		for(var index=0; index<theAcceptableTypes.length; index++) {
			if(fileExtension == theAcceptableTypes[index]) {
				return true;
			}
		}
		var message = 'This file must have an extension ';
		if(theAcceptableTypes.length == 1) {
			message+= 'of '+ acceptableTypes;
		} else {
			message+= 'of one of the following: '+ acceptableTypes;
		}
		alert(message);
		return false;
	}
	return true;
}

var formAction = 'submit';

function contentSetSubmit(buttonValue, newLocation, newAction) {
	formAction = newAction;
	if($('#content')) {
		$('#content').attr("action",newLocation);
	} else {
		alert('Could not find the content form');
		return;
	}
	selectPath(buttonValue);
}


var mcuTimeout;
var checkMCUUrl;
var mcuID;
var controllMCUUrl;
var completedUpload = false;
var hitError = false;

function multiUploadError(errorText) {
	document.getElementById('errorstatus').innerHTML = '<font style="color:red; font-weight:bold;">'+ errorText +'</font><a href="javascript:closeGrayOut();">Close</a>';
	clearTimeout(mcuTimeout);
	hitError = true;
}

function checkMCU(url) {
	if(!hitError) {
		document.getElementById('errorstatus').innerHTML = '<table border="0" width="100%"><tr><td align="right" valign="top">Checking request:</td><td><img src="/icons/waiting_bar.gif" alt="loading"></td></tr></table>';
	}
	$.ajax({ url: checkMCUUrl, cache: false, success: function(xml){
			var error = $(xml).find('error').text();
			if(error && error != '') { multiUploadError(error); }
			else {
				if(!hitError) {
					document.getElementById('errorstatus').innerHTML = '';
				}
			}
			document.getElementById('uploadstatus').innerHTML = $(xml).find('upload').text();
			document.getElementById('unzipstatus').innerHTML = $(xml).find('unzip').text();
			document.getElementById('previewstatus').innerHTML = $(xml).find('preview').text();
			var completed = $(xml).find('completed').text();
			if(completed == 'true') {
				/* We got a completed statement so we need to redirect the user to multiedit and pass in our multicontent id */
				completedUpload = true;
				clearTimeout(mcuTimeout);
				var editURL = document.location.pathname;
				editURL = editURL.replace(/addedit/, 'multiedit');
				editURL +='?multiContentId='+ mcuID;
				document.location.replace(editURL);
			}
		}, error: function() {
			clearTimeout(mcuTimeout);
			if(!completedUpload) {
				document.getElementById('multistatus').innerHTML = 'An error occurred when checking the status of your request';
			}
		}
	});
}


function startMCUUnzip() {
	$.ajax({ url: controllMCUUrl+'&contentAction=unzip', cache: false, success: function(xml){
			alert('Do we need to check return of kicking off the unzip? Im thinking not since the status will hit it');
		}, error: function() {
			clearTimeout(mcuTimeout);
			document.getElementById('multistatus').innerHTML = 'An error occurred when requesting the unzip of the compressed file';
		}
	});
}


function closeGrayOut() {
	if(  document.getElementById('multistatus').style.display == 'block'  ) {
		document.getElementById('multistatus').style.display='none';
		document.getElementById('grayOutDiv').style.display = 'none';
	}
}

function changeGrayOut() {
	if(  document.getElementById('multistatus').style.display == 'block'  ) {
		scroll(0,0);
		$('#grayOutDiv').css({
			"display": "block",
			opacity: 0.7,
			"width":$(document).width(),
			"height":$(document).height()
		});
	}
}

function performSubmitAction(theForm) {
	updateRTEs();
	if(!checkform(theForm)) {return false;}
	if(formAction == 'submit') {
		return true;
	} else if(formAction == 'multi') {
		document.getElementById('multistatus').style.display='block';
		document.getElementById('grayOutDiv').style.display = 'block';
		document.getElementById('errorstatus').innerHTML = '';
		changeGrayOut();
		$(window).resize(changeGrayOut);

		url = document.forms['content'].getAttribute('action');

		// Make the ajax call to get the multi content upload ID 
		document.getElementById('uploadstatus').innerHTML = 'Initiating Request';
		$.ajax({ url: url+'?contentAction=init', async: false, success: function(xml){
				mcuID=$(xml).find('mcuid').text();
				document.getElementById('uploadstatus').innerHTML	= 'Preparing to upload';
				var error=$(xml).find('error').text();
				if(error) {
					multiUploadError(error);
					return false;
				}
			}
		});

		if(!mcuID || !mcuID.match(/^\d+$/)) {
			multiUploadError('An invalid multi content upload was returned <!-- '+ mcuID +'!-->');
			return false;
		}
		document.forms['content']['multiContentId'].value = mcuID;
		document.forms['content']['contentAction'].value = 'upload';


		// Kick off the ajax to check the pages
		controllMCUUrl = url + '?multiContentId='+ mcuID;
		checkMCUUrl = controllMCUUrl + '&contentAction=check';
		mcuTimeout = setInterval('checkMCU()', 2000);
		
		// Submit the iframe to the upload page (this will kick you over to the unzip, generate pages)
		document.forms['content'].target='MCIF';
		document.forms['content']['contentAction'].value = 'upload';
		document.forms['content']['multiContentId'].value = mcuID;
		document.forms['content'].action=url
		return true;
	}
	return false;
}


function confirm_departure(dest){
	if (confirm("Previewing content means you will save any edits you might have made to this page. Are you sure you want to proceed?")) {
		if(document.forms['content'].onsubmit()){
			var form = document.getElementById('content');

			var input = document.createElement('input');
			input.setAttribute('type', 'hidden');
			input.setAttribute('name', 'redirect_after_post');
			input.setAttribute('value', dest);	
	
			form.appendChild(input);

			document.forms['content'].submit();
		}
	}
}


function selectPath(path){
	var uploadInfo = document.getElementById('uploadInfo');
 	var multiUploadInfo = document.getElementById('multiUploadInfo');

	if(path == 'create_blank_doc'){
		uploadInfo.className = 'gDisplayNone';
		multiUploadInfo.className = 'gDisplayNone';
	}
	else if(path == 'upload_file' || path == 'min_style'){
		multiUploadInfo.className = 'gDisplayNone';
		uploadInfo.className = 'gDisplayTable';
	}
	else if(path == 'upload_zip_file'){
		uploadInfo.className = 'gDisplayNone';
		multiUploadInfo.className = 'gDisplayTable';
	}
}


function confirmDimension(elt){
	var other_id;
	if(elt.id.indexOf("width") != -1) {
		other_id=elt.id.replace("width", "height");
	} else if(elt.id.indexOf("height") != -1) {
		other_id=elt.id.replace("height", "width");
	} else {
		alert('confirmDimension was not given a height or width');
		return;
	}
	var other_elt = document.getElementById(other_id);

	var err_str = '';
	var to_be = ' is ';
	if(elt.value > 800){
		err_str += ' value for ' + elt.id;
	}
	if(other_elt.value > 800){
		if(elt.value > 800){
			err_str += ' and the';
			to_be = ' are ';
		}
		err_str += ' value for ' + other_elt.id;
	}

	if(err_str){
		err_str = 'The' + err_str + to_be;
		err_str += "greater than 800px.\n\n";
		err_str += "TUSK recommends values no greater than 800 pixels in order to ensure the optimal display on the user's browser.";
		alert(err_str);
	}	
}

function changeRow(rowID, color) {
	for(var index=0; index<7; index++) {
		if(document.getElementById(rowID+'_'+ index)) {
			document.getElementById(rowID+'_'+ index).style.backgroundColor = color;
		}
	}
	if(document.getElementById(rowID+'_additionalID')) {document.getElementById(rowID+'_additionalID').style.backgroundColor = color;}
}


//$( function() { imagePreview(); });
//
//this.imagePreview = function() {
//	xOffset = 18; // 10;
//	yOffset = 10; // 30;
//
//	$("img.imgPreview").hover(
//		function(e){
//			this.t = this.title;
//			this.title = "";
//			var c = (this.t != "") ? "<br/>" + this.t : "";
//			$("body").append("<p id='imgPreview'><img src='"+ this.src +"' alt='Image preview' width='100px' height='100px' />"+ c +"</p>");
//			$("#imgPreview")
//			.css("top",(e.pageY - xOffset) + "px")
//			.css("left",(e.pageX + yOffset) + "px")
//			.fadeIn("fast");
//		},
//
//		function(){
//			this.title = this.t;
//			$("#imgPreview").remove();
//		}
//	);
//
//	$("a.imgPreview").mousemove(function(e){
//		$("#imgPreview")
//		.css("top",(e.pageY - xOffset) + "px")
//		.css("left",(e.pageX + yOffset) + "px");
//	});
//};


var idsToImport;
var currentImportIndex;
var saveReturnStatus;
var userScrolled = false;
var saveErrors = 0;

function runImportContent() {
	// Check to make sure that everything has a title.
	var errors = '';

	var errorColor = 'yellow';
	if(document.content.parentFolderTitle.value == '') {
		errors += 'Please fill in a value for parent folder name.\n';
		document.content.parentFolderTitle.style.backgroundColor = errorColor;
	} else {
		document.content.parentFolderTitle.style.backgroundColor = '';
	}

        for(var contentID in contentImports) { // This comes from multiEdit page
                //Perform one last check in case the browser created the objects but is not keeping track of them
                var object = 'contentInfo_'+ contentID +'_dne';
                // Note that if the checkbox is checked that means don't import so we need !checked
                if(!document.content[object] || !document.content[object].checked) {
			if(document.content['contentInfo_'+ contentID +'_title'].value == '') {
				errors += 'Please fill in a value for title on content number '+ contentID +'\n';
				document.content['contentInfo_'+ contentID +'_title'].style.backgroundColor = errorColor;
			} else {
				document.content['contentInfo_'+ contentID +'_title'].style.backgroundColor = '';
			}
		} else {
			document.content['contentInfo_'+ contentID +'_title'].style.backgroundColor = '';
		}
        }

	if(errors != '') {
		alert(errors);
		return;
	}
	if(navigator.userAgent.toLowerCase().indexOf('msie 6') != -1) {
		var msg = 'Warning: We have detected that you are using an older browser (Internet Explorer 6).\n\n';
		    msg+= 'Multi-Content upload should work but the progress may not work quite right and you may see some graphic quirks.';
		    msg+= ' Please be patient while we import your content.\n\n';
		    msg+= 'We recommend upgrading or using a different browser if possible (e.g. Firefox).';
		alert(msg);
	}
	try {importContent();}
	catch(e) {
		alert("We're sorry, a javascript error has occrred, please contact support");
		return false;
	}
}


// This function will setup the page to start the import and query for the content numbers to import
function importContent() {
	idsToImport = new Array();
	// contentImports comes from the multiEditPage
	for(var contentID in contentImports) {
		//Perform one last check in case the browser created the objects but is not keeping track of them
		var object = 'contentInfo_'+ contentID +'_dne';
		// Note that if the checkbox is checked that means don't import so we need !checked
		if(!document.content[object] || !document.content[object].checked) {idsToImport.push(contentID);}
	}
	document.getElementById('totalNumber').innerHTML = idsToImport.length;

	document.getElementById('multistatus').style.display='block';
	document.getElementById('grayOutDiv').style.display = 'block';
	document.getElementById('errorstatus').innerHTML = '';
	changeGrayOut();
	$(window).resize(changeGrayOut);

	currentImportIndex = 0;
	saveErrors = 0;
	saveReturnStatus = '';
	userScrolled = false;
	saveNextContent();
}

var redirect;

// This function will save one piece of content
function saveNextContent() {
	if(currentImportIndex < idsToImport.length) {
		// Change the form to represent what content we are on
		document.getElementById('currentNumber').innerHTML = currentImportIndex+1;

		// Tell the form which content we are saving so the parent page knows (eventually we may want to specifically select what data is being sent
		document.content['saveContent'].value = idsToImport[currentImportIndex];
		document.content['ajax_save'].value = 1;

		var title = document.content['contentInfo_'+ idsToImport[currentImportIndex] +'_title'].value;
		document.getElementById('errorstatus').innerHTML = saveReturnStatus + 'Importing '+ title +'...';
		// Make ajax call to save
		$.ajax({ url: window.location.pathname, async: false, type: 'post', data: $('#content').serialize(),
			success: function(xml) {
				redirect=$(xml).find('redirect').text();
				var error=$(xml).find('messages').text();
				var success=$(xml).find('success').text();
				var parentContent=$(xml).find('parentContentID').text();
				var contentTitle = document.content['contentInfo_'+ idsToImport[currentImportIndex] +'_title'].value;
				if(parentContent) { document.content['parentContentID'].value = parentContent; }
				if(error) {
					saveReturnStatus+= 'Error importing '+ contentTitle +': '+ error +'<br>';
					saveErrors++;
				} else if(success)  {
					saveReturnStatus+= 'Successfully completed '+ contentTitle +'<br>';
				} else {
					saveReturnStatus+= 'Error importing '+ contentTitle +': Unknown error<br>';
					saveErrors++;
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				var contentTitle = document.content['contentInfo_'+ idsToImport[currentImportIndex] +'_title'].value;
				saveReturnStatus += 'Unable to make call for '+ contentTitle +': '+errorThrown +' ('+ textStatus +')<br>';
				saveErrors++;
			},
			complete: function(jqXHR, textStatus) {
				document.getElementById('errorstatus').innerHTML = saveReturnStatus;
				if(!userScrolled) { document.getElementById('errorstatus').scrollTop = document.getElementById('errorstatus').scrollHeight; }
				var width = Math.round(((currentImportIndex+1)/idsToImport.length) * 350);
				$("#percentBar").width(width);
				currentImportIndex++;
				var theTimer = setTimeout("saveNextContent()", 500);
			}
		});
	} else {
		// We have done all of the content
		// Make sure we have the latest saveReturnStatus
		document.getElementById('errorstatus').innerHTML = saveReturnStatus;
		
		if(saveErrors == idsToImport.length) {
			// If everything failed, don't proceeed, just close the import window
			var errorMessage = 'All imports failed. Please contact support.';
			document.getElementById('done_div').style.display = 'block';
			document.getElementById('done_div').innerHTML=errorMessage;
			document.getElementById('done_div').className = 'gLighterror';

			var buttonDiv = document.getElementById('continue_button');
			buttonDiv.style.display = 'block';
			buttonDiv.innerHTML = '<input type="button" name="Close" value="Close Import Screen" class="formbutton" onClick="closeGrayOut();">';
		} else {
			var saveMessage = 'Save completed';
			document.getElementById('done_div').className = 'gLightsuccess';
			if(saveErrors > 0) {
				saveMessage+= ' with errors';
				document.getElementById('done_div').className = 'gLighthint';
			}
			if(!redirect) {
				redirect = window.location.pathname;
				if(redirect.matches('\d+\/\d+')) {
					redirect.replace('management/content/multiedit/course', 'management/folders/course');
				} else {
					redirect.replace('management/content/multiedit/course', 'management/course/display');
				}
			}
			document.getElementById('savingmessages').style.display = 'none';
			document.getElementById('done_div').innerHTML= saveMessage +'.';
			document.getElementById('done_div').style.display = 'block';
			var buttonDiv = document.getElementById('continue_button');
			buttonDiv.style.display = 'block';
			buttonDiv.innerHTML = '<input type="button" name="Continue" value="Continue" class="formbutton" onClick="document.location=\''+ redirect +'\';">';
		}
	}
}
