/* toolkit of js functions to extend the functionality of /management/content/addedit pages in tusk */


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
 
	if(path == 'create_blank_doc'){
		uploadInfo.className = 'gDisplayNone';
	}
	else if(path == 'upload_file' || path == 'min_style'){
		uploadInfo.className = 'gDisplayTable';
	}
}


function confirmDimension(elt){
	var other_id = (elt.id == 'height')? 'width' : 'height';
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

