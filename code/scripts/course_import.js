function toggleAuthors(toggle_box){
	var boxes = document.confirm_authors.approved_authors;

	// boxes will be a NodeList unless there is only one input box with name 'approved_authors'
	// in that case, make boxes an array with one member so that loop below works
	if(!boxes.length){
		boxes = [boxes];
	}	

	for(var i=0; i < boxes.length; i++){
		boxes[i].checked = toggle_box.checked;
	}
}

function validateImportForm(form){
	var fn = form.zip_file.value;
	
	if(fn){
		return true;
	}
	else {
		alert('Please supply a valid filename.');
		form.zip_file.focus();
		return false;
	}
}