/********************************************************************************
  This file for functions that could be reused across TUSK and used with JQuery
*********************************************************************************/


/********************************************************************************
	Functions used for big data tables
	Usage: 	fnAdjustTable();
*********************************************************************************/
fnAdjustTable=function(){
	var colCount=$('#firstTr>td').length; //get total number of column
	var m=0;
	var n=0;
	var brow='mozilla';
	jQuery.each(jQuery.browser, function(i, val) {
		if (val==true) {
			brow=i.toString();
		}
	});

	$('.tableHeader').each(function(i) {
		if (m<colCount) {
			if (brow=='mozilla') {
				//for adjusting first td
				$('#firstTd').css("width",$('.tableFirstCol').innerWidth());
				//for assigning width to table Header div
				$(this).css('width',$('#table_div td:eq('+m+')').innerWidth());
			} else if (brow=='msie') {
				$('#firstTd').css("width",$('.tableFirstCol').width());
				//In IE there is difference of 2 px
				$(this).css('width',$('#table_div td:eq('+m+')').width()-2);
			} else if (brow=='safari') {
				$('#firstTd').css("width",$('.tableFirstCol').width());
				$(this).css('width',$('#table_div td:eq('+m+')').width());
			} else {
				$('#firstTd').css("width",$('.tableFirstCol').width());
				$(this).css('width',$('#table_div td:eq('+m+')').innerWidth());
			}
		}
		m++;
	});

	$('.tableFirstCol').each(function(i) {
		if (brow=='mozilla') {
			//for providing height using scrollable table column height
			$(this).css('height',$('#table_div td:eq('+colCount*n+')').outerHeight());
		} else if(brow=='msie') {
			$(this).css('height',$('#table_div td:eq('+colCount*n+')').innerHeight()-2);
		} else {
			$(this).css('height',$('#table_div td:eq('+colCount*n+')').height());
		}
	n++;
	});
}
 
//function to support scrolling of title and first column
fnScroll = function(){
  $('#divHeader').scrollLeft($('#table_div').scrollLeft());
  $('#firstcol').scrollTop($('#table_div').scrollTop());
}


