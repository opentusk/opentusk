// gmail attachment files clone by Gavin Lynch
//number of forms currently in < span id="content" > tree
var form_count = 0;

//add file attachment form and associated elements
function addFile() {
	//create new < img > element
	var new_img = document.createElement('img');
	//give element an id
	new_img.setAttribute('id', 'child_attachment_img_' + form_count);
	//set image source
	new_img.setAttribute('src','');
	//set image alternative text
	new_img.setAttribute('alt',' ');
	//set image stylings
	new_img.setAttribute('style', 'float: left;');
	//append newly created element to < span id="content" > tree
//	document.getElementById('content').appendChild(new_img);

	//create new < input > element
	var new_attachment = document.createElement('input');
	//give element an id
	new_attachment.setAttribute('id', 'child_attachment_' + form_count);
	//set element type
	new_attachment.setAttribute('type', 'file');
	new_attachment.setAttribute('name', 'files');
	//set element size
	new_attachment.setAttribute('size', '40');
	//append newly created element to < span id="content" > tree
	document.getElementById('content').appendChild(new_attachment);

	//create new < span > element
	var new_text = document.createElement('span');
	//give element an id
	new_text.setAttribute('id','child_attachment_text_' + form_count);

	//set element HTML to produce 'remove' text link 
	new_text.innerHTML = '&nbsp; <span style="color:#0000FF;cursor:pointer;text-decoration:underline;font-size:75%;" onclick="remove(' + form_count + ');">remove</span> <br/>';

	//append newly created element to < span id="content" > tree
	document.getElementById('content').appendChild(new_text);

	//increase the form count
	form_count++;

	//if an attachment has been added, change text to "Attach another file"
	document.getElementById('more').innerHTML = 'Upload another file';
 } 

//remove file attachment form and associated elements
function remove(remove_form_num) {
	//decrease the form count
	form_count--;

	//remove < input > element attachment
	document.getElementById('content').removeChild(document.getElementById('child_attachment_' + remove_form_num));
	//remove < span > element text
	document.getElementById('content').removeChild(document.getElementById('child_attachment_text_' + remove_form_num));
	//remove < img > element image
	document.getElementById('content').removeChild(document.getElementById('child_attachment_img_' + remove_form_num));

	//if all forms are removed, change text back to "Attach a file"
	if (form_count == 0)
	{
     	  	document.getElementById('more').innerHTML = 'Upload a file';
	}
}
