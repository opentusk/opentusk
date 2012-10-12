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


var minusImage = new Image();
minusImage.src = "/graphics/icons/ico-folder-openminus.gif";
var plusImage = new Image();
plusImage.src = "/graphics/icons/ico-folder-plus.gif";
var loadingImage = new Image();
loadingImage.src = "/graphics/Loading.gif";

var viewingShortNotes = 1;
var ajaxRequest;
var loadedContentIDs = new Array();
var openContentIDs = new Array();
var currentIndentLength;
var appendTo;
var theNotes = new Array();
var notesCounter = 0;
var loadingContent = 0;
var idToUseForContent;
var needToCheckForRefresh = 0;
var tableObject     = null;
var tablebodyObject = null;
var head_row;

function clearLoadedContentIDs() {
	tableObject     = null;
	tablebodyObject = null;
	loadedContentIDs = new Array();
	needToCheckForRefresh = 1;
}

function refreshFilteredContentIDs() {
	var indent;
	needToCheckForRefresh = 0;

	var rows = tablebodyObject.getElementsByTagName("tr");

	for ( var i = 0; i < rows.length; i++ ) {
		var my_td = rows[i].getElementsByTagName("td")[0];
    	var index = (my_td) ? my_td.title.search(/Expand/) : -1;
    	if (index != -1) {
			var splitResults = rows[i].getElementsByTagName("td")[0].id.split("_");

			var folderIcon = document.getElementById('icon'+splitResults[1]);
			if ( folderIcon.src.match(/plus/) && openContentIDs[splitResults[1]] ) {
				var spacer = document.getElementById("spacer_"+splitResults[1]);
				if (spacer) { 
					indent = spacer.width/20;
				} else {
					indent = 0;
				}
				needToCheckForRefresh = 1;
				displayContent( indent, splitResults[1] );
				i = rows.length;
			}
		}
	}
}

function showLoading() {
  loadingContent = 1;
  document.body.style.cursor='wait';
  var loadingImageDiv = document.getElementById('loadingDiv');
  if(loadingImageDiv) {
    loadingImageDiv.style.visibility='visible';
  }
}

function displayContentNotes(theElement) {
  var tempText = '';
  for(var index=0; index<theNotes.length; index++) {
    if(document.getElementById(index+'NotesSpan')) {
      tempText = document.getElementById(index+'NotesSpan').innerHTML;
      document.getElementById(index+'NotesSpan').innerHTML = theNotes[index];
      theNotes[index] = tempText;
    }
  }
  if(theElement) {
    if(theElement.innerHTML.search('Full') == -1) {
      theElement.innerHTML = theElement.innerHTML.replace(/Short/, 'Full');
      theElement.title = theElement.title.replace(/short/, 'full');
    } else {
      theElement.innerHTML = theElement.innerHTML.replace(/Full/, 'Short');
      theElement.title = theElement.title.replace(/full/, 'short');
    }
  }
  if(viewingShortNotes) {viewingShortNotes=0;} else {viewingShortNotes=1;}
}

function hideLoading() {
  var loadingImageDiv = document.getElementById('loadingDiv');
  if(loadingImageDiv) {
    loadingImageDiv.style.visibility='hidden';
  }
  loadingContent = 0;
  document.body.style.cursor='default';
}

var nodeTextType = '';

function requestSubContent(indentLength, contentID, documentType, documentAbbreviation) {
  showLoading();
  currentIndentLength = indentLength;
  if(documentAbbreviation != '') {idToUseForContent = documentAbbreviation;}
  else                           {idToUseForContent = contentID;}

  var url = "/tusk/ajax/"
  if(documentType == 'course') {url+= "getCourseSubContent/";} else {url+= "getCollectionSubContent/";}
  url+= contentID;
	if ( document.getElementById("view_by") ) {
		url+= "?view_by="+document.getElementById("view_by").options[document.getElementById("view_by").selectedIndex].value;
	}

  if (window.XMLHttpRequest) {
      ajaxRequest = new XMLHttpRequest();
      nodeTextType = 'textContent';
  } else if (window.ActiveXObject) {
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      nodeTextType = 'text';
  } else {
	var location = document.URL;
	if(location.search(/\/content\//) != -1) {location = location.replace(/content/, 'contentSimple');}
	else {location = location+'?simple=1';}
	alert('You are being transfered because your browser does not support AJAX.');
	document.location = location;
  }
  if(ajaxRequest) {
	if (tableObject == null) {
		tableObject             = document.createElement("table");
		tableObject.id          = "theTable";
		tableObject.cellPadding = 3;
		tableObject.cellSpacing = 0;
		tableObject.width       = "100%";

		tablebodyObject = document.createElement("tbody");

		if ( head_row == null ) {
			 head_row = document.createElement("tr");
		
			var type_h = document.createElement("td");
  			type_h.style.borderBottom = '1px solid black';
			type_h.width = 120;
			type_h.innerHTML = '<font style="font-size:8pt;">' + _('Type') + '</font>';

			var document_h = document.createElement("td");
  			document_h.style.borderBottom = '1px solid black';
			document_h.innerHTML = '<font style="font-size:8pt;">' + _('Document') + '</font>';

			var course_h   = document.createElement("td");
  			course_h.style.borderBottom = '1px solid black';
			course_h.innerHTML = '<font style="font-size:8pt;">' + _('Course') + '</font>';

			var authors_h  = document.createElement("td");
  			authors_h.style.borderBottom = '1px solid black';
			authors_h.innerHTML = '<font style="font-size:8pt;">' + _('Authors') + '</font>';

			head_row.appendChild( type_h );
			head_row.appendChild( document_h );
			if ( document.getElementById("view_by") ) {
				head_row.appendChild( course_h );
			}
			head_row.appendChild( authors_h );
		}

		tablebodyObject.appendChild( head_row );

		tableObject.appendChild( tablebodyObject );
		document.getElementById("theTableWrapperDiv").appendChild( tableObject );
	}

    ajaxRequest.open("GET", url, true);
    ajaxRequest.onreadystatechange = showSubContent;
    ajaxRequest.send(null);
  }
}


function showSubContent() {
  var id; var image; var author; var fullNote; var shortNote; var title; var url;
  var abstract;
		
  if(!ajaxRequest) {return;}
  if(ajaxRequest.readyState == 4) {
    var response = ajaxRequest.responseXML;
    if(!response) {
      hideLoading();
      if(ajaxRequest.status && (ajaxRequest.status == 200)) {alert(_('I was unable to get the subcontent of this item!'));}
    }
    else {
      var subContents = response.getElementsByTagName('subContent');
      for(var index=0; index<subContents.length; index++) {
        var id = 'Error';
        var image = 'Error';
        var author = 'Error';
        var fullNote = 'Error';
        var shortNote = 'Error';
        var title = 'Error';
        var url = 'Error';
		var course = 'Error';
		var courseid = '0';
        for(var index2=0; index2<subContents[index].childNodes.length; index2++) {
          var node = subContents[index].childNodes[index2];
          var nodeValue = '';
          if(node[nodeTextType]) {nodeValue = node[nodeTextType];}
          else if(node.firstChild && node.firstChild.nodeValue) {nodeValue = node.firstChild.nodeValue;}

          if(node.nodeName == 'id')             {id = nodeValue;}
          else if(node.nodeName == 'image')     {image = nodeValue;}
          //This is a safari hack.
          else if(node.nodeName == 'img')       {image = nodeValue;}
          else if(node.nodeName == 'author')    {author = nodeValue;}
          else if(node.nodeName == 'fullNote')  {fullNote = nodeValue;}
          else if(node.nodeName == 'shortNote') {shortNote = nodeValue;}
          else if(node.nodeName == 'title')     {title = nodeValue;}
          else if(node.nodeName == 'url')       {url = nodeValue;}
          else if(node.nodeName == 'abstract')  {abstract = nodeValue;}
          else if(node.nodeName == 'course')    {course = nodeValue;}
          else if(node.nodeName == 'courseid')    {courseid = nodeValue;}
        }

		if ( course == '' && document.getElementById("view_by") != null) course = document.getElementById("view_by").options[document.getElementById("view_by").selectedIndex].text;

        var tempRow = document.createElement("TR")
        tempRow.onmouseover = new Function ("this.style.backgroundColor='lightgrey';");
        tempRow.onmouseout  = new Function ("this.style.backgroundColor='';");
        tempRow.style.cursor = 'pointer';
	tempRow.id = idToUseForContent+'-'+index;

        tempRow.appendChild(createCell(id, image, url, 'image'));
        //Build the title with the note below it.
        var titleToDisplay = '<a href="'+url+'"><font class="bold_emphasis_font">'+title+'</font></a>';
        if(shortNote) {
          titleToDisplay += '<br><span style="font-size:8pt;" id="'+notesCounter+'NotesSpan">';
          if(viewingShortNotes) {titleToDisplay += shortNote; theNotes[notesCounter] = fullNote;}
          else                  {titleToDisplay += fullNote; theNotes[notesCounter] = shortNote;}
          notesCounter++;
          titleToDisplay +='</span>';
        }

	if (abstract) {
		titleToDisplay += "<br/><br/><input type=\"button\" class=\"formbutton\" value=\"View Abstract\" onclick=\"showHideAbstract(this," + index + ");\"/>\n<br/><div id=\"abstract_" + index + "\" style=\"display:none;\" class=\"sm\">" + abstract + "</div>";
	        tempRow.appendChild(createCell(id, titleToDisplay, url, 'abstract'));
	} else {
	        tempRow.appendChild(createCell(id, titleToDisplay, url, ''));
	}
	abstract = null; // need to clean off the old one

		if ( course != 'Error' ) {
			tempRow.appendChild(createCell(id, course, url, 'course'));
		}

        tempRow.appendChild(createCell(id, author, url, 'author'));

        //Add the new row to the table
        if (currentIndentLength == 0) {
		tablebodyObject.appendChild(tempRow);
	} else {
		tablebodyObject.insertBefore(tempRow, appendTo);
	}
      }

      loadedContentIDs[idToUseForContent] = 1;
      openContentIDs[idToUseForContent] = 1;
      hideLoading();
    }

	if ( needToCheckForRefresh ) {
		refreshFilteredContentIDs();
	}
  }
}

function createCell(id, passedInnerHTML, url, cellType) {
  var theInnerHTML = passedInnerHTML;
  var tempCell = document.createElement("TD");
  if(theInnerHTML.search(/[A-Za-z0-9]/) == -1) {theInnerHTML = '&nbsp;'}
  tempCell.style.borderBottom = '1px solid lightgrey';
  tempCell.style.verticalAlign = 'middle';
  var openContentFunction = new Function ("showLoading(); window.location='"+url+"';");
  //In image cell can either open the content or expand a folder. All other cells open the content.
  if(cellType == 'image') {
    theInnerHTML = '<img src="/graphics/spacer.gif" id="spacer_'+idToUseForContent+'/'+id+'" height="1" width="'+ 20*currentIndentLength +'">'+theInnerHTML;

    if(theInnerHTML.search(/folder/) != -1) {
      tempCell.onclick = new Function ("displayContent("+currentIndentLength+", '"+idToUseForContent+"/"+id+"');");
      tempCell.title = _('Expand content');
      theInnerHTML = theInnerHTML.replace('="icon'+id, '="icon'+idToUseForContent+'/'+id);
      tempCell.id = 'folder_'+idToUseForContent+"/"+id;
    } else {
      tempCell.onclick = openContentFunction;
      tempCell.title = _('Open this content');
    }
  } else if (cellType == 'abstract') {
	// don't want default opencontent so do nothing here
  } else {
    tempCell.onclick = openContentFunction;
  }

  if(cellType == 'author') {
    tempCell.innerHTML = '<font style="font-size:8pt;">' + theInnerHTML + '</font>';
  } else {
    tempCell.innerHTML = theInnerHTML;
  }
  return tempCell;
}

function displayFolderContents(rowID) {
  var index = 0;
  openContentIDs[rowID] = 1;
  while(document.getElementById(rowID+'-'+index)) {
    document.getElementById(rowID+'-'+index).style.display = '';
    //If the row icon has a minus in it then display those things too.
    var imagesInRow = document.getElementById(rowID+'-'+index).getElementsByTagName('img');
    for(var index2=0; index2<imagesInRow.length; index2++) {
      if(imagesInRow[index2].id && (imagesInRow[index2].src.search(/minus/) != -1)) {
        displayFolderContents(imagesInRow[index2].id.replace('icon', ''));
      }
    }
    index++;
  }
}

function displayContent(currentIndent, contentIDToRequest) {
  var folderIcon = document.getElementById('icon'+contentIDToRequest);
  var displayType = '';
  if(folderIcon.src.match(/minus/)) {
    displayType = 'none';
    folderIcon.src = plusImage.src;
    folderIcon.title = _("Expand Content");
  } else {
    folderIcon.src = minusImage.src;
    folderIcon.title = _("Collapse Content");
  }

  if(loadedContentIDs[contentIDToRequest] == 1) {
    if(displayType == 'none') {
      var tableRows = tablebodyObject.getElementsByTagName('TR');
      var idRegExp = new RegExp(contentIDToRequest+'['+'-\/]');
      for(var index=0; index<tableRows.length; index++) {
        if(tableRows[index].id.search(idRegExp) == 0) {
          tableRows[index].style.display = displayType;
        }
      }
      openContentIDs[contentIDToRequest] = 0;
    } else {displayFolderContents(contentIDToRequest);}
  } else {
  //Take the icon image, then get the cell its in, then get the row the cell is in, then get the next node.
    appendTo = folderIcon.parentNode.parentNode.nextSibling;
    requestSubContent((currentIndent+1), contentIDToRequest, idToUseForContent, '');
  }
}


function showHideAbstract(button, aid){
	if (button.value == 'View Abstract') {
		document.getElementById('abstract_' + aid).style.display = 'inline';
		document.getElementById('abstract_' + aid).value = 1;
		button.value = 'Hide Abstract';
	} else {
		document.getElementById('abstract_' + aid).style.display = 'none';
		document.getElementById('abstract_' + aid).value = 0;
		button.value = 'View Abstract';
	}
}

