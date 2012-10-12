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



function toggle_visibility(id) {

	var e = document.getElementById(id);


	if(e.style.visibility == "visible"){
		e.style.visibility = "hidden";
	}
	else {
		e.style.visibility = "visible";
	}
}


function toggle_visibility_multiple(id){

    var idlength = id.length;

	var elems = document.getElementsByTagName('tr'); 
	for (var i=0;i<elems.length;i++) {
        var elemsub = elems[i].id.substring(0,idlength); 
		if ( elemsub == id ) {

			if (elems[i].style.display == 'none' ) { // you probably don't want to hide *all* elements
				elems[i].style.display='';
			}
			else {
				elems[i].style.display='none';
			}

		}
	}	

}

function toggle_display(id) {

	var e = document.getElementById(id);
	if( e != null && e.style.display == 'none')
		e.style.display = 'block';
	else
		e.style.display = 'none';
}


function toggle_button(id) {

var e = document.getElementById(id);
 
if (e.value.indexOf(_("Show")) >= 0 ) {
	e.value= e.value.replace(_("Show"),_("Hide"));

} else {
	e.value= e.value.replace(_("Hide"),_("Show"));
}

}

function toggle_img(i){

	var fldr = document.getElementById("fldr_"+i);

	if ( (fldr.src).match("minus") ) {
		fldr.src = "/icons/ico-folder-plus.gif";  

	}
	else  {
		fldr.src = "/icons/ico-folder-openminus.gif";

	}

}


function submitform(itemID,isDeck)
{
 
	var sure= confirm(_("Are you sure you wish to delete?"));
	if ( sure == true) {

 		if ( isDeck  == 1) {
 			document.fcardform.deleteDeck.value=itemID;
 		}
 		else {
 			document.fcardform.deleteContent.value=itemID;
 		}

 		document.fcardform.submit();

	}
}

function submitformpc(itemID,cntntID){


	var sure= confirm(_("Are you sure you wish to delete?"));
	if ( sure == true) {

 		if ( cntntID > 0) {
			document.pcform.deleteContent.value=itemID+"/"+cntntID;
 			
 		}
 		else {
			document.pcform.deleteFolder.value=itemID;
 			//document.pcform.deleteContent.value=itemID;
 		}

 		document.pcform.submit();

	}


}


function swapOverlay(imgID)
{
	
	var main_img = document.getElementById(imgID);
  
	if ( main_img.src.match(/overlay/) ) {
		var source=main_img.src.replace(/\/overlay/, "");
	}
    else
	{
		var source = main_img.src.replace(/medium/, "overlay/medium" );
		source=source.replace(/\/large/, "/overlay/large" );
		source=source.replace(/xlarge/, "overlay/xlarge" );
		source=source.replace(/orig/, "overlay/orig" );		
	}
	
	main_img.src = source;
}


function submitnewfolder(formName)
{
	var frm = document.getElementById(formName);
	frm.newfldr.value=1;
	frm.submit();
}

function submitrename(formName,id)
{
	var frm = document.getElementById(formName);
	frm.rnm.value=id;
	frm.submit();
}

function submitnote(formName,id)
{
	var frm = document.getElementById(formName);
	frm.addnote.value=id;
	frm.submit();
}

function showOrHideHelp() {

       if(document.getElementById('showHideDiv').innerHTML == _('Show')) {
         document.getElementById('showHideDiv').innerHTML = _('Hide');
         document.getElementById('helpDiv').style.display = '';
       } else {
         document.getElementById('showHideDiv').innerHTML = _('Show');
         document.getElementById('helpDiv').style.display = 'none';
       }
}

var ajaxRequest;

function requestContent(personalContentID) {

  var url = "/tusk/ajax/getFlashCardDeck/"+personalContentID;

  if (window.XMLHttpRequest) {
      ajaxRequest = new XMLHttpRequest();
      nodeTextType = 'textContent';
  } else if (window.ActiveXObject) {
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      nodeTextType = 'text';
  } else {
	var location = document.URL;

	alert(_('You are being transfered because your browser does not support AJAX.'));
	document.location = location;
  }

  ajaxRequest.open("GET", url, true);
  // the following trickery is interesting
  ajaxRequest.onreadystatechange = function() { if(ajaxRequest.readyState ==4) { showContent(personalContentID) } };;	
  ajaxRequest.send(null);

}

function showContent(contentID) {

  var id;  var title; var url;

  if(!ajaxRequest) {return;}
  if(ajaxRequest.readyState == 4) {
//	alert(ajaxRequest.responseText);
    var response = ajaxRequest.responseText;
    if(!response) {
	
      if(ajaxRequest.status && (ajaxRequest.status == 200)) {
			alert(_('I was unable to get the Deck!'));
		}
    }
    else {

	 document.getElementById("td_"+contentID).innerHTML = response;

    } //else (response exists)

  } // if readystate == 4

}


function submitContent(mycontent,myfolder,url,savediv) {
//this is currently used by flashcards and personalcontent in the toolkit	

  			 if (window.XMLHttpRequest) {
      			ajaxRequest = new XMLHttpRequest();
      			nodeTextType = 'textContent';
  			} else if (window.ActiveXObject) {
      			ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      			nodeTextType = 'text';
  			} else {
				var location = document.URL;

				alert(_('You are being transfered because your browser does not support AJAX.'));
				document.location = location;
  			}

  		ajaxRequest.open("GET", url, true);
		ajaxRequest.onreadystatechange = function() { 
		if(ajaxRequest.readyState ==4) { 
			document.getElementById(savediv).style.display="block";
			setTimeout('document.getElementById("'+savediv+'").style.display="none"', 3000);
		}
	
		};;	
  		ajaxRequest.send(null);	
}
