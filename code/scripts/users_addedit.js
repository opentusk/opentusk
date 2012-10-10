
	function check_degree(degree)
	{
		if (degree.options[degree.selectedIndex].value == 'Other'){
			document.getElementById('degree_text').style.display = 'inline';
		}else{
			document.getElementById('degree_text').style.display = 'none';
		}
	}
