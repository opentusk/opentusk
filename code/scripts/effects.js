var changingItems = new Array();
// this array keeps track of all the things that it is changing.
// changingItems[index].object - object being changed
// changingItems[index].property - object being changed
// changingItems[index].colors - the colors to change the item to
// changingItems[index].interval - the interval to change the item on
// changingItems[index].timeout - current timeout pointer
// changingItems[index].index - the current index of the colors array



function changeColor(startColor, endColor, numberOfSeconds, itemToFade, itemProperty) {
  var tempArray = new Array;
  tempArray['object'] = itemToFade;
  tempArray['colors'] = new Array();
  tempArray['property'] = itemProperty;

  //Take a color and a second color and determines the number of steps between them.
  var startRed = parseInt(startColor.substr(0,2), 16);
  var startGreen = parseInt(startColor.substr(2,2), 16);
  var startBlue = parseInt(startColor.substr(4,2), 16);
  
  var endRed = parseInt(endColor.substr(0,2), 16);
  var endGreen = parseInt(endColor.substr(2,2), 16);
  var endBlue = parseInt(endColor.substr(4,2), 16);

  var greatestDiff = 0;
  if(Math.abs(endRed-startRed) > greatestDiff) {greatestDiff = Math.abs(endRed-startRed);}
  if(Math.abs(endGreen-startGreen) > greatestDiff) {greatestDiff = Math.abs(endGreen-startGreen);}
  if(Math.abs(endBlue-startBlue) > greatestDiff) {greatestDiff = Math.abs(endBlue-startBlue);}

  for(var index=0; index<=greatestDiff; index++) {
    var localRed, localGreen, localBlue;
    if(startRed > endRed) {
      if((startRed-index) >= endRed) {localRed = startRed-index;} else {localRed = endRed;}
    } else {
      if((startRed+index) <= endRed) {localRed = startRed+index;} else {localRed = endRed;}
    }

    if(startGreen > endGreen) {
      if((startGreen-index) >= endGreen) {localGreen = startGreen-index;} else {localGreen = endGreen;}
    } else {
      if((startGreen+index) <= endGreen) {localGreen = startGreen+index;} else {localGreen = endGreen;}
    }

    if(startBlue > endBlue) {
      if((startBlue-index) >= endBlue) {localBlue = startBlue-index;} else {localBlue = endBlue;}
    } else {
      if((startBlue+index) <= endBlue) {localBlue = startBlue+index;} else {localBlue = endBlue;}
    }


    tempArray['colors'].push(localRed+', '+localGreen+', '+localBlue);
  }


  tempArray['interval'] = (numberOfSeconds/greatestDiff) * 1000;
  tempArray['index'] = 0;

  changingItems.push(tempArray);
  var myChangingItemsIndex = changingItems.length-1;
  changePropertyColor(myChangingItemsIndex);
  return(myChangingItemsIndex);
}

function changePropertyColor(indexOfMasterArray) {
  if(changingItems[indexOfMasterArray] && changingItems[indexOfMasterArray].object && changingItems[indexOfMasterArray].colors[ changingItems[indexOfMasterArray].index ]) {
    changingItems[indexOfMasterArray].object.style[''+changingItems[indexOfMasterArray].property] = 'rgb('+changingItems[indexOfMasterArray].colors[ changingItems[indexOfMasterArray].index ]+')';
    changingItems[indexOfMasterArray].index++;
    changingItems[indexOfMasterArray].timeout = setTimeout("changePropertyColor("+indexOfMasterArray+");", changingItems[indexOfMasterArray].interval);
  } else {
    deleteArrayElement(indexOfMasterArray);
  }
}


function cancelChangeColor(indexOfMasterArray) {
  clearTimeout(changingItems[indexOfMasterArray].timeout);
  deleteArrayElement(indexOfMasterArray);
}


function deleteArrayElement(indexOfMasterArray) {
  delete changingItems[indexOfMasterArray].property;
  for(var index=0; index<changingItems[indexOfMasterArray].colors.length; index++) {delete changingItems[indexOfMasterArray].colors[index];}
  delete changingItems[indexOfMasterArray].colors;
  delete changingItems[indexOfMasterArray].interval;
  delete changingItems[indexOfMasterArray].timeout;
  delete changingItems[indexOfMasterArray].index;
}



