function changeSearch(isAdvanced) {
		if(isAdvanced) {
			document.getElementById('regularForm').style.display = 'none';
			document.getElementById('advancedForm').style.display = '';
		} else {
			document.getElementById('advancedForm').style.display = 'none';
			document.getElementById('regularForm').style.display = '';
		}
}
		
function do_keyword(){
	document.forms.search.make_keyword.value = 1;
	document.forms.search.submit();
}

function definition(layer, index){
	if (layers[layer].structure.data[index]['definition']){
		var RExp = /<% $umlsNewlineEscape %>/g;
		var defn = layers[layer].structure.data[index]['definition'].replace(RExp,"\n");
		alert(defn);
	}else{
		alert("No definition.");
	}
}

function validateSearch(formObj) {
	if (formObj.content_id != null && formObj.content_id.value != "") {
		if (isNaN(parseInt(formObj.content_id.value))) {
			alert ('You must enter a numeric value for the content id.');
			return false;
		}
	}
	return true;
}