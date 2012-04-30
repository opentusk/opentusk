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


//Draging JavaScript functions
//This script has 3 functions: startDrag, stopDrag, scroller

var dragging = false;
var startX, startY;
var tableX, tableY;
var dragCookiesLater = new Date();
dragCookiesLater.setTime(dragCookiesLater.getTime() + 1000*60*60*24*365*4);

var dragArray = new Array();
var currentlyDraggingID;

function registerDragItem(itemID, topOrBottom, leftOrRight, afterDrag)
{
  dragArray[itemID] = new Array(topOrBottom, leftOrRight, itemID, afterDrag);
  document.getElementById(itemID+'Handle').onmousedown=startDrag;
  document.getElementById(itemID+'Handle').onmouseup=stopDrag;
}

function mouseMove(anEvent)
{
  var evt;
  if(anEvent) {evt=anEvent;} else {evt=window.event;}
  if(dragging)
  {
    if(dragArray[currentlyDraggingID][0] == 'top')
    {
      var newLocation = tableY - (startY - evt.clientY);
      var yScroll = getScrollXY()[1];
      var topOfDocument = 0 + yScroll;
      if(newLocation < topOfDocument) {newLocation = topOfDocument;}

      var itemHeight = 250;
      if(document.getElementById(currentlyDraggingID).offsetHeight)
        {itemHeight = document.getElementById(currentlyDraggingID).offsetHeight;}
      else if(document.getElementById(currentlyDraggingID).style.pixelHeight)
        {itemHeight = document.getElementById(currentlyDraggingID).style.pixelHeight;}
      var windowHeight;
      if(window.innerHeight){
		windowHeight = window.innerHeight;
      }
      else if(typeof document.documentElement != 'undefined'
           && typeof document.documentElement.clientWidth != 'undefined'
           && document.documentElement.clientWidth != 0){ 
		windowHeight = document.documentElement.clientHeight;
      }
      // The +20 is for scroll bars (just in case).
      if(  windowHeight && ((newLocation + itemHeight + 20) > (windowHeight + yScroll))  ){
		newLocation = (windowHeight + yScroll) - itemHeight - 20;
      }
        document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][0]] = newLocation + 'px';
    }
    else
      {document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][0]] = (tableY + (startY - evt.clientY)) + 'px' ;}

    if(dragArray[currentlyDraggingID][1] == 'left')
    {
      var newLocation = tableX - (startX - evt.clientX);
      var xScroll = getScrollXY()[0];
      var leftOfDocument = 0 + xScroll;
      if(newLocation < leftOfDocument) {newLocation = leftOfDocument;}

      var itemWidth = 250;
      if(document.getElementById(currentlyDraggingID).offsetWidth)
        {itemWidth = document.getElementById(currentlyDraggingID).offsetWidth;}
      else if(document.getElementById(currentlyDraggingID).style.pixelWidth)
        {itemWidth = document.getElementById(currentlyDraggingID).style.pixelWidth;}
      var windowWidth;
      if(window.innerWidth)              {windowWidth = window.innerWidth;}
      else if(document.body.offsetWidth) {windowWidth = document.body.offsetWidth;}
      if(  windowWidth && ((newLocation + itemWidth + 20) > (windowWidth + xScroll))  )
        {newLocation = (windowWidth + xScroll) - itemWidth - 20;}

        document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][1]] = newLocation + 'px';
    }
    else
      {document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][1]] = (tableX + (startX - evt.clientX)) + 'px';}

    return false;
  }
}

document.onmousemove=mouseMove;
//ar reportedAJavaScriptDragError = false;
//self.onerror=if(!reportedAJavaScriptDragError) {alert('A javaScript error has occurred'); reportedAJavaScriptDragError=true;} return true;

//function startDrag(itemToDrag, anEvent)
function startDrag(anEvent)
{
  var evt;
  if(anEvent) {evt = anEvent;} else {evt = window.event;}
  if(evt) {
    for(var index in dragArray) {
      var theElement = document.getElementById(''+dragArray[index][2]+'Body');
      if(theElement) {theElement.style.display = 'none';}
    }
    dragging = true;
    currentlyDraggingID = this.id.replace(/Handle$/, '');
    startX = evt.clientX;
    startY = evt.clientY;
    tableX = parseInt(document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][1]]+0);
    tableY = parseInt(document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][0]]+0);
    return false;
  } else {alert('Your browser is not compatable with this function!');}
}

function stopDrag()
{
  if(dragging == true)
  {
    dragging = false;

	var xyScroll = getScrollXY();

    var cookieValue = parseInt(document.getElementById(currentlyDraggingID).style[dragArray[currentlyDraggingID][0]]) - xyScroll[1];

    for(var index in dragArray) {
      var theElement = document.getElementById(''+dragArray[index][2]+'Body');
      if(theElement) {theElement.style.display = '';}
    }
    if(dragArray[currentlyDraggingID][3]) {eval(dragArray[currentlyDraggingID][3]);}
  }
}

var lastHorziontalScrool = 0;
var lastVerticalScroll = 0;
function scrollDragables()
{
  for(var index in dragArray)
  {
    var theElement = document.getElementById(''+dragArray[index][2]);
	var xyScroll = getScrollXY();

    //Y Scroll
    theElement.style[dragArray[index][0]] = (parseInt(theElement.style[dragArray[index][0]]) + (xyScroll[1]-lastVerticalScroll)) + 'px';

    //X Scroll
    theElement.style[dragArray[index][1]] = (parseInt(theElement.style[dragArray[index][1]]) + (xyScroll[0]-lastHorziontalScrool)) + 'px';
  }
  lastVerticalScroll = xyScroll[1];
  lastHorziontalScrool = xyScroll[0];
}

window.onscroll = scrollDragables;
window.onmouseup = stopDrag;
window.onclick = stopDrag;
