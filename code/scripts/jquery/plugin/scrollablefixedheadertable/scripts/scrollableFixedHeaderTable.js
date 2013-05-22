// Author: Jerome Clyde C. Bulanadi
//
// change by rebecca: replaced references to jQuery.browser with navigator object
// to work with 1.9+ versions of jQuery

jQuery.fn.scrollableFixedHeaderTable = scrollableFixedHeaderTable;

sfht = {};
function scrollableFixedHeaderTable(widthpx, heightpx, showSelect, cookie, headerRowSize) {
	/* table initialization */
	if (!jQuery(this).hasClass('scrollableFixedHeaderTable'))
		return;
	var $this = jQuery(this);
	/* fix width for tables witout width attribute */
	$this.attr('width', $this.width());

	$this.wrap('<div style="text-align: left"></div>');
	$this.parent().before('<div class="noDivBounds"><div class="sfhtColumnSelectButton_unPressed" title="Select Columns"></div><div class="sfhtColumnSelect"></div></div>');

 	headerRowSize = headerRowSize ? headerRowSize - 1: 0;
	headerRowSize = Math.floor(headerRowSize < 0 ? 0 : isNaN(headerRowSize) ? 0 : headerRowSize);

	var $parentDiv = $this.parent();
	var $fixedHeaderHtml = sfht.cloneHeader($parentDiv, headerRowSize);
	var $srcTableHtml = $parentDiv.html();

	$this.before('<table cellspacing="0" cellpadding="0" class="sfhtTable"><tr><td><div class="sfhtHeader"></div></td></tr><tr><td><div class="sfhtData"></div></td></tr></table>');
	$parentDiv.find('div:nth(0)').html($fixedHeaderHtml);
	$parentDiv.find('div:nth(1)').html($srcTableHtml);

	var headerId = $this.attr('id') + '_header';
	var $sfhtHeader = $parentDiv.find('.sfhtHeader');
	var $sfhtTable = $sfhtHeader.find('table').attr('id', headerId);

	$this.remove();

	var $sfhtData = $parentDiv.find('.sfhtData');
	$sfhtData.height(heightpx).width(widthpx);
	var $mainTable = $sfhtData.find('table');
	var mainTableId = $mainTable.attr('id');
	
	/* synchronized scrolling */
	$sfhtData.scroll(function() {
		$sfhtHeader.scrollLeft(jQuery(this).scrollLeft());
	});
	
	/* adjustments */
	sfht.adjustTables($sfhtTable, $mainTable, headerRowSize);
	sfht.adjustHeader($sfhtHeader, $sfhtData, $mainTable, headerRowSize);

	if (!showSelect) {
		$parentDiv.prev().remove();
		return;
	}
	
	/* column select check boxes */
	$parentDiv.prev().find('div:nth(0)').attr('id', mainTableId + '_columnSelectButton');
	$parentDiv.prev().find('div:nth(1)').attr('id', mainTableId + '_columnSelect');
	
	
	sfht.loadColumnSelect(jQuery(sfht.getColumnSelect(mainTableId)), $sfhtHeader, mainTableId, $sfhtData, $mainTable, cookie);
	
	var $columnSelect = sfht.getColumnSelect(mainTableId);
	var $columnSelectButton = sfht.getSelectButton(mainTableId);
	
	$columnSelectButton.toggle(function() {
		$columnSelect.show(250);
		$columnSelectButton.attr('class','sfhtColumnSelectButton_Pressed');
		}, function() {
			$columnSelect.hide(250);
			$columnSelectButton.attr('class','sfhtColumnSelectButton_unPressed');
	});	
	
	$columnSelect.hide();
	
	/* cookie */
	if (cookie == null || cookie == '') {
		return;
	}
	var cSize = $sfhtHeader.find('td, th').length;
	if (cSize == 0) {
		return;
	}
	
	var storedCookie = jQuery.cookie(cookie);
	if (storedCookie) {
		// synch the size
		storedCookie = storedCookie.substring(0, cSize);
		for (var index = 0; index < cSize; index++) {
			var indexState = parseInt(storedCookie.charAt(index));
			if (indexState != 1) {
				sfht.hideColumn(mainTableId, index);
				$columnSelect.find('input:nth(' + index + ')').removeAttr('checked');
			}
		}
	} else { // make new cookie
		var initState = sfht.fillState(cSize);
		jQuery.cookie(cookie, initState);
	}
}

sfht.loadColumnSelect = function ($container, $sfhtHeader, mainTableId, $sfhtData, $mainTable, cookie) {
	var myInnerHtml = "<ul>";
	$sfhtHeader.find('td, th').each(function(index) {
		myInnerHtml += '<li><input type="checkbox" class="columnCheck" checked="checked">' + jQuery(this).text() + '</input></li>';
	});
	myInnerHtml += '</ul>';
	$container.html(myInnerHtml);
	$container.find('.columnCheck').each(function(index) {
		var $this = jQuery(this);
		$this.click(function() {
			var checked = $this.attr('checked');
			if (!checked) {
				sfht.hideColumn(mainTableId, index);
				if (cookie != null && cookie != '') {
					var cookieStr = jQuery.cookie(cookie);
					cookieStr = replaceOneChar(cookieStr, '0', index + 1);
					jQuery.cookie(cookie, cookieStr);
				} 
			} else {
				sfht.showColumn(mainTableId, index);
				if (cookie != null && cookie != '') {
					var cookieStr = jQuery.cookie(cookie);
					cookieStr = replaceOneChar(cookieStr, '1', index + 1);
					jQuery.cookie(cookie, cookieStr);
				} 
			}
			sfht.adjustHeader($sfhtHeader, $sfhtData, $mainTable);
		});
	});
}

sfht.hideColumn = function(id, index) {
	var $mainTable = jQuery('table[id=' + id + "]");
	var $headerTable = sfht.getFixedHeader(id);
	$mainTable.find('tr').each(function() {
		//jQuery(this).find('td:nth(' + index + ')').hide();
		jQuery(jQuery(this).find('td,th')[index]).hide();
	});
	$headerTable.find('tr').each(function() {
		//jQuery(this).find('td:nth(' + index + ')').hide();
		jQuery(jQuery(this).find('td,th')[index]).hide();
	});
	var jqKey = sfht.getSfhtVar(id);
	var lastWidth = sfht[jqKey]['lastWidth'];
	var indexWidth = sfht[jqKey]['tdWidths'][index];
	lastWidth -= indexWidth;
	sfht[jqKey]['lastWidth'] = lastWidth;
	$mainTable.width(lastWidth);
	$headerTable.width(lastWidth);
}

sfht.showColumn = function (id, index) {
	var $mainTable = jQuery('table[id=' + id + "]");
	var $headerTable = sfht.getFixedHeader(id);
	$mainTable.find('tr').each(function() {
		//jQuery(this).find('td:nth(' + index + ')').show();
		jQuery(jQuery(this).find('td,th')[index]).show();
	});
	$headerTable.find('tr').each(function() {
		//jQuery(this).find('td:nth(' + index + ')').show();
		jQuery(jQuery(this).find('td,th')[index]).show();
	});
	var jqKey = sfht.getSfhtVar(id);
	var lastWidth = sfht[jqKey]['lastWidth'];
	var indexWidth = sfht[jqKey]['tdWidths'][index];
	lastWidth += indexWidth;
	sfht[jqKey]['lastWidth'] = lastWidth;
	$mainTable.width(lastWidth);
	$headerTable.width(lastWidth);
}

sfht.adjustHeader = function($sfhtHeader, $sfhtData, $mainTable) {
	var containerWidth = $sfhtData.width();
	var containerInnerWidth = $sfhtData.innerWidth();
	var scrollBarSize = containerWidth - containerInnerWidth;
	var dataTableWidth = $mainTable.width();

	if (!(navigator.userAgent.match(/mozilla/) || navigator.userAgent.match(/msie/) || navigator.userAgent.match(/opera/))) {
		containerInnerWidth = dataTableWidth >= containerWidth ? containerWidth - 17 : containerWidth;
	}

	if (dataTableWidth >= containerInnerWidth) {
		$sfhtHeader.width(containerInnerWidth);
	} else {
		$sfhtHeader.width(dataTableWidth);
	}
}


sfht.adjustTables = function($sfhtTable, $mainTable, headerRowSize) {
	var tdWidthArr = new Array();
	var adjTableWidth = 0;

	var totalWidth = 0;
	var idAdjWidth = sfht.getSfhtVar($mainTable.attr('id'));

	//var id = '#' + $mainTable.attr('id'); // IE compatibility
	var id = $mainTable.attr('id');
	//var queryStr = id + ' tr:nth(0) td';
	var idPrefix = 'table[id=' + id + '] tr:lt(' + (headerRowSize + 1) + ')';
	jQuery(idPrefix).find('td, th').each(function(index) {
		var $this = jQuery(this);
		var actualWidth = parseInt($this.width());
		var attrWidth = parseInt($this.attr('width'));
		var plusWidth = attrWidth > actualWidth ? attrWidth : actualWidth;
		totalWidth += plusWidth;
		tdWidthArr[index] = plusWidth;
		$this.width(plusWidth);
		$sfhtTable.find('td:nth(' + index + '), th:nth(' + index + ')').width(plusWidth);
	});
	
	adjTableWidth = totalWidth;
	// $sfhtTable.width(totalWidth);
	// $mainTable.width(totalWidth);
	
	/* Register this variable to sfht globals */
	sfht[idAdjWidth] = {'lastWidth': adjTableWidth, 'tdWidths': tdWidthArr};
}

sfht.getSfhtVar = function(id) {
	return id + 'Widths';
}

sfht.getSelectButton = function(id) {
	return(jQuery('div[id=' + id + '_columnSelectButton]'));
}

sfht.getColumnSelect = function(id) {
	var selector = '';
	return(jQuery('div[id=' + id + '_columnSelect]'));
}

sfht.getFixedHeader = function(id) {
	return (jQuery('table[id=' + id + '_header]'));
}

sfht.fillState = function (i) {
	  if (i == 0) {
	    return;
	}
	state = '';
	for (var x = 0; x < i; x++) {
	    state += '1';
	}
	return state;
}

sfht.loadAttributes = function(dest, source) {
	var attributes = jQuery(source).listAttrs();
	jQuery(attributes).each(function(){
		var at = this + '';
		jQuery(dest).attr(at, jQuery(source).attr(at));
	});
}

sfht.cloneHeader = function(parentDiv, headerRowSize) {
	var rowIndex = headerRowSize;
	if (jQuery.fn.listAttrs) {
	  var $container = jQuery("<div><table><thead></thead></table></div>");
		var $clone = $container.find('table:eq(0)');
		var tableNode = jQuery(parentDiv).children().first();
		sfht.loadAttributes($clone,tableNode);
		sfht.loadAttributes($clone.children().first(),tableNode.children().first());

		var $thead = $clone.find('thead');
		for (var _i = 0; _i <= rowIndex; _i++) {
			var $rowHeaderNode = tableNode.children().first().children(':nth(' + _i + ')');
			var $cloneRow = jQuery('<tr></tr>');
			sfht.loadAttributes($cloneRow,$rowHeaderNode);
			$cloneRow.html($rowHeaderNode.html());
			$cloneRow.appendTo($thead);
		}
	  return $container.html();
	} else {
		var $cloned = jQuery(parentDiv).clone();
		$cloned.children().first().children().children('tr:gt(' + headerRowSize + ')').remove();
		return $cloned.html();
	}
}

function replaceOneChar(s,c,n){
	var re = new RegExp('^(.{'+ --n +'}).(.*)$','');
	return s.replace(re,'$1'+c+'$2');
};
    
/* dirty solution, not good for large tables:
 clone table and reduce to first columns
 TODO: copy only the columns instead of reducing the clone
 
 This returns object holding the ids of the clone table.
 colBodyId = tableId + '_column'
 colHeaderId = tableId + _columnHeader
 */
function freezeFirstColumnSorter(tableId, lastColIndex){
	if (!lastColIndex) {
		lastColIndex = 0;
	}
	
	/* object to be returned */
	var ids = {};
	ids.colBodyId = tableId + '_column';
	ids.colHeaderId = tableId + '_columnHeader';
	
	var $columnTable = $('.sfhtData #' + tableId).clone().attr('id', ids.colBodyId);
	$columnTable.removeAttr('width');
	$columnTable.children().children().each(function(){
		$(this).children(':gt(' + lastColIndex + ')').remove()
	});
	$columnTable.wrap('<div></div>');
	
	/* floating column */
	var $colDiv = $columnTable.parent();
	$colDiv.attr('class', 'freezCol');
	
	/* floating header of the floating column */
	var $columnTableHeader = $columnTable.clone();
	$columnTableHeader.children(':gt(' + 0 + ')').remove();
	$columnTableHeader.attr('id', ids.colHeaderId)
	$columnTableHeader.wrap('<div></div>');
	var $colHeaderDiv = $columnTableHeader.parent();
	$colHeaderDiv.addClass('freezColHeader');
	
	/* $().innerHeight does not seem to work so 17px which is common in a default theme
	 was subtracted to get the innerHeight */
	var scrollHeight = $('#' + tableId).parents('[class="sfhtTable"]').innerHeight() - 17;

	/* added by rebecca --
	   browser-specific code for IE7 and IE6 to correct 1px discrepancy between static column and the rest of the table */
	if (navigator.userAgent.match(/msie/) && parseInt(navigator.appVersion) < 8) {
		$colDiv.height(scrollHeight - 1);
	} else {
		$colDiv.height(scrollHeight);
	}
	
	/* ref var for floating header */
	var $sfhtHeader = $('#' + tableId).parents('[class="sfhtTable"]').find('.sfhtHeader');
	
	/* add the header of the floating column */
	$sfhtHeader.parent().append($colHeaderDiv);
		
	/* add the floating column */
	$sfhtHeader.parent().append($colDiv);

	/* reset the scrolling before synching */
	$colDiv.scrollTop(0);
	
	/* added by rebecca --
	   browser-specific code for IE7 and IE6 to correct 1px discrepancy between static column and the rest of the table */
	if (navigator.userAgent.match(/msie/) && parseInt(navigator.appVersion) < 8) {
		$colDiv.css("margin-top", "1px");
	}

	/* sync vertical scroll */
	$('#' + tableId).parent().scroll(function(){
		$colDiv.scrollTop($(this).scrollTop());
	});

	/* return id object */
	return ids;
}
