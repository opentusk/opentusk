/*	wrapper function for the scrollableFixedHeaderTable plugin created by rebecca

		adjustedwidth	maximum available width for the table in the given page
		adjustedwidth	maximum available height for the table in the given page
		headerRowSize	number of static header rows (0 to disable)
		numCols			number of static left columns (0 to disable)

*/
jQuery.fn.scrollableTable=scrollableTable;

function scrollableTable(adjustedwidth, adjustedheight, headerRowSize, numCols) {
	var tablewidth = 0;
	var tableheight = 0;
	var addW = 0;
	var addH = 0;
	
	// get size of scrollbars for the current browser
	var width = Math.abs($.scrollbarWidth());

	// if table width is greater than available width, tablewidth variable is set to available width
	// and the size of the scrollbar that will be added to the height stored in addH
	if ($(this).width() > adjustedwidth) { 
		tablewidth = adjustedwidth; 
		addH = width;
	}
	// otherwise just use the table's actual width and zero out the addH variable
	else {
		tablewidth = $(this).width();
		addH = 0;
	}

	// if table height is greater than available height, tableheight variable is set to available height
	// and the size of the scrollbar that will be added to the width is stored in addW
	if ($(this).height() > adjustedheight) {
		tableheight = adjustedheight;
		addW = width;
	}
	// otherwise just use the table's actual height and zero out the addW variable
	else {
		tableheight = $(this).height();
		addW = 0;
	}
	
	// pass the adjusted dimensions to the scrollableFixedHeaderTable function
	$(this).scrollableFixedHeaderTable(tablewidth + addW, tableheight + addH, null, null, headerRowSize);

	// set up fixed column(s)
	if (numCols > 0) {
		colIds = freezeFirstColumnSorter($(this).attr('id'), numCols - 1);
	}
}
