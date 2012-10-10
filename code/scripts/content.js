/* toolkit of js functions to extend the functionality of content pages in tusk */

var images = new Array();

function showimage(content_id, align, size, count){
	if (align == null || align == ''){
		align="center";	
	}
	if (size == null || size == ''){
		size="medium";	
	}

	document.writeln('<p align="' + align +'"><font color="#ffffff"><img src="/' + size + '/' + content_id + '" id="' + content_id + '-' + count + '" border="0"></font></p>');
}

function showimageoverlay(content_id, align, size){
	if (align == null || align == ''){
		align="center";	
	}
	if (size == null || size == ''){
		size="medium";	
	}

	if (!images[content_id]){
		images[content_id] = new Image();
		images[content_id].src = '/overlay/' + size + '/' + content_id;
		images[content_id].orig = '/' + size + '/' + content_id;
		images[content_id].count = 1; /* need to do this in case image appears more then once on the page */
	}else{
		images[content_id].count++;
	}
	showimage(content_id, align, size, images[content_id].count);
	document.writeln('<p align="' + align + '"><input type="button" class="formbutton" value="Overlay" name="TUSKREPLACE" onclick="overlay('+content_id+','+images[content_id].count+',\'' + size +'\')">');
}

function overlay(content_id, count, size){
	var id = content_id + '-' + count;
	if (document.getElementById(id).src.match(/overlay/)){
		document.getElementById(id).src = images[content_id].orig;
	}else{
		document.getElementById(id).src = images[content_id].src;
	}
}

/* next two fx's are for the image zoomer. this is not the image zoomer in the floating
   nav menu, but the image zoomer that appears directly above the image in places such as 
   the case tool.
*/
function toggleImgCntrl(ele){
	var imgControl = ele.imgCntrl;

	if(!imgControl){
		imgControl = getElementsByClass({className:'imgCntrl', tag:'div', 'node':ele.parentNode})[0];
		ele.imgCntrl = imgControl;
	}

	var fxWidth = 130;
	
	if(imgControl.offsetWidth < fxWidth){
		widthfx(0, fxWidth, imgControl);
	}
	else {
		widthfx(imgControl.offsetWidth, 0, imgControl);
	}
}

function swapImg(size, lnk){
	// get all of the individual zoom buttons
	var links = getElementsByClass({className:'zoomBtn', tag:'img', 'node':lnk.parentNode});

	//the following zoom_input code is used in /flashcard/editcard and viewcard in order to
	//allow the zoom level to persist through a deck
	var zoom_input = document.getElementById("zoom_level");
	if (zoom_input) {	
		zoom_input.value=size;
	}

	if(!lnk.image){
		var main_img = getElementsByClass({className:'mainImg', tag:'img', 'node':lnk.parentNode.parentNode.parentNode})[0];

		// for each zoom button, add a property that is a reference to the main img
		// that this zoom button should affect. 
		for(var j=0; j<links.length; j++){
			links[j].image = main_img;
		}

	}

	var img = lnk.image;

	for(var j=0; j<links.length; j++){
		if(links[j] == lnk){
			links[j].style.backgroundColor = '#d3d3d3';
		} else {
			links[j].style.backgroundColor = '#ffffff';
		}
	}

	var source = img.src.replace(/(.*)\/\D+\/(\d+)$/m, "$1/" + size + "/$2");
	img.src = source;	

// we are changing the src of the image, the images have various sizes, we need
// to make sure that we remove the height and width attributes, accordingly
	if(img.height){
		img.removeAttribute('height');
	}
	if(img.width){
		img.removeAttribute('width');
	}
}
