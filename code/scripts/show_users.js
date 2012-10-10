
function changeSearch(isAdvanced) {
		if(isAdvanced) {
			document.getElementById('regularForm').style.display = 'none';
			document.getElementById('advancedForm').style.display = '';
		} else {
			document.getElementById('advancedForm').style.display = 'none';
			document.getElementById('regularForm').style.display = '';
		}
	}
