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


/* 
the first time we mouse over an announcement, make a full text window for display.
the elt passed in is the link that was moused over to show the fullTextWin
*/
function makeFullTextWin(elt){
	var new_win = document.createElement('div');

	// the elt (link) has a classname that uniquely identifies the link.
	// take that name, give it to the new_win so that we can easily identify
	// window/link pairs so that we can treat the link/window as one entity
	// for mouseover/off considerations. that is, when user moves mouse from window
	// to link, do not consider that a mouseoff but a continued mouseover
	new_win.className = 'fullTxtWin ' + elt.className;
	new_win.regex = elt.regex = new RegExp(elt.className);

	new_win.onmouseout = function(event) { mouseoffFullText(event) };

	positionWin(elt, new_win);

	// each announcement is in a two member ul
	// the first member is the abbreviated announcement.
	// the second is the full text, get that one.
	var parentUL = elt.parentNode.parentNode
	var sibling = parentUL.getElementsByTagName('li')[1];
	var txt = sibling.innerHTML;

	new_win.innerHTML  = '<div class="fullTxt">' + txt + '</div>';
	return new_win;
}

// make window appear 100px to the right of the upper left corner of the link
function positionWin(elt, new_win){
	var xy = findPos(elt);
	var x = xy[0] + 100;
	var y = xy[1];
	new_win.style.top = (y) + 'px'; 
	new_win.style.left = (x) + 'px';
}


function showFullText(e){
	if(!e) e = window.event;
	var elt = getElt(e);

	if(!elt.currently_over){
		elt.currently_over = true;
		if(!elt.fullTxtWin){
			var ft_win = makeFullTextWin(elt);

			ft_win.lnk = elt;
			elt.fullTxtWin = ft_win;

			document.body.appendChild(ft_win);
		}
		elt.fullTxtWin.style.display = 'block';
	}
}


function hideFullText(full_text_win){
	var anchor = full_text_win.lnk;

	anchor.currently_over = false;
	full_text_win.style.display = 'none';
}


function clickFullText(e){
	if(!e) e = window.event;
	var elt = getElt(e);

	// bubble up from the "close" link to find the fullTextWindow.
	// we will know when we have reached it because of the class on the dom element
	while(!elt.className.match(/winPartner/)){
		elt = elt.parentNode;
	}

	hideFullText(elt);

}

function mouseoffFullText(e){
	if(!e) e = window.event;
	var elt = getElt(e);

	var to_elt = e.relatedTarget || e.toElement;

	// do not consider a mouseoff from link to the fulltextwin or vice-versa a mouseoff
	// both elt's will have a class of winPartner_[integer]

	// a little complex b/c if the fulltxtwin contained a span elt, mousing over that
	// span will constitute a mouseoff the fulltxtwin.
	// so, when we generate a mouseoff event, we want to bubble-up from the moused over
	// elt until we either reach the fulltextwin (with class matching winPartner) or
	// a parent element that has a class (say the body element).
	// this will make sure that we didn't mouseoff the fulltxtwin by mousing over an
	// elt contained within the fulltxtwin.
	while(!to_elt.className.match(/winPartner/)){
		if(typeof to_elt.parentNode.className != 'undefined'){
			to_elt = to_elt.parentNode;
		}
		else {
			break;
		}
	}

	// we are either mousing off the link in the left nav, the fullTextwin, or
	// some elt contained within the fulltxtwin. for reason explained immediately 
	// above, if we are in the last case, bubble up until we are the fulltxtwin, itself.
	while(!elt.className.match(/winPartner/)){
		elt = elt.parentNode;
	}

	// if we moused off the fulltxtwin for the announcement link or vice versa,
	// do not consider that a mouseoff
	if(to_elt.className.match(elt.regex)){
		return;
	}

	var full_text_win = (elt.fullTxtWin)? elt.fullTxtWin : elt;

	hideFullText(full_text_win);
}



function toggleHdr(caller, uid, section){
	// anchor is in h3 (first parentNode), which is in a div (second parentNode)
	// get that div
	var parent = caller.parentNode.parentNode;

	var elt = getElementsByClass({className: 'toggled', tag: 'div', node: parent})[0];

	var action;
	if(elt.className.match(/\sgDisplayNone/)){
		elt.className = elt.className.replace(/\sgDisplayNone/, '');
		caller.innerHTML = '[-]';
		action = 'include';
	}
	else{
		elt.className += ' gDisplayNone';
		caller.innerHTML = '[+]';
		action = 'exclude';
	}
	exclude(action, uid, section);
}

// make ajax call to mason page that will ex/include this section
// for display to user
function exclude(action, uid, section){
	xRequest = initXMLHTTPRequest();
	if (xRequest) {
		var params = 'action=' + action + '&uid=' + uid + '&section=' + section;
		xRequest.open("POST", '/tusk/ajax/home_section_exclusion', true);
		xRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xRequest.send(params);
	}
}


// if user clicks on a parent sublink label, toggle the display of the 
// sublinks.
function toggleSublinkDisplay(elt){

	var nested_uls = getElementsByClass({ node: elt.parentNode, className: 'nestedList', tag: 'ul'}); 

	if (elt.className == 'closed') {
		elt.innerHTML = elt.innerHTML.replace(/\[\+\]/, '[-]');
		if (nested_uls[0]) {
			nested_uls[0].className = nested_uls[0].className.replace(/\s?gDisplayNone\s?/, '');
		}
	}
	else {
		elt.innerHTML = elt.innerHTML.replace(/\[-\]/, '[+]');
		if (nested_uls[0]) {
			nested_uls[0].className = nested_uls[0].className += ' gDisplayNone';
		}
	}

	elt.className = (elt.className == 'closed')? 'open' : 'closed';

}