	function checkbox_action( checkbox_name ) {
		var temp  = checkbox_name.split( "all_" );
		var regex = new RegExp( temp[1] + "$" );

	    for (i=0; i < document.studentcourse.elements.length; i++) 
		{
			if ( document.studentcourse.elements[i].name.search( regex ) != -1 ) { 
				if ( document.studentcourse.elements[i].name != checkbox_name ) {
					document.studentcourse.elements[i].checked = document.getElementById( checkbox_name ).checked;
				}
			} 
		}
	}
