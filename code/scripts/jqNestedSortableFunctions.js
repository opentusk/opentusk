// Copyright 2012 Tufts University 
//
// Licensed under the Educational Community License, Version 1.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//
// http://www.opensource.org/licenses/ecl1.php 
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and 
// limitations under the License.


function filter (this_dd,prefix) {
	if (this_dd.value == "None" ) {
		prefix_els = document.getElementsByClassName(prefix);
		for (i=0; i< prefix_els.length; i++) {
			prefix_els[i].style.display='';
		}
		sort_els = document.getElementsByClassName("hand");
		for (i=0; i< sort_els.length; i++) {
			sort_els[i].style.display='block';
		}
	} else {
		prefix_els = document.getElementsByClassName(prefix);
		for (i=0; i< prefix_els.length; i++) {
			prefix_els[i].style.display='none';
			var splt = prefix_els[i].className.split(" ");
			var tmp = this_dd.value.replace(/ /g, "_");
			tmp = tmp.replace(/'/g,"");
			for(j=0; j< splt.length; j++) {
				if (tmp == splt[j] ) {
					prefix_els[i].style.display='';
				}
			}
		
		}
		
		sort_els = document.getElementsByClassName("hand");
		for (i=0; i< sort_els.length; i++) {
			sort_els[i].style.display='none';
		}
	} // end if/else
}

function resizeColumns( params ) {
	var totalWidth = ($('#'+params.wrapper).width()-28) - params.allocated_width;
	var tempWidth  = totalWidth - params.maxDepth*params.indent;
	var columns    = params.columns.length;
	var perCol     = Math.floor( tempWidth/(columns-params.sized_columns) );

	var colTypes = ['head','col'];
	for (var idx = 0; idx < colTypes.length; idx++) {
		var classname = colTypes[idx];

		$('li[class*=' + classname + '0]').each( function() {
			var thisDepth = 0;
			// Need to get the OL that we're in, which is four levels back:  <ol><li><div><ul><li>...
			var depthCheck = this.parentNode.parentNode.parentNode.parentNode;

			while ( depthCheck.tagName == 'OL' ) {
				// From that, we're going to continually check grandparents to see how deeply we're nested:  <ol><li><ol>...
				depthCheck = depthCheck.parentNode.parentNode;
				thisDepth++; 
			}
			var width = params.columns[0].width;
			if ( width == 0 )            { width = perCol; }

			if ( classname == 'head' )   { width += 20; }
			else if ( params.sort == 0 ) { width += 17; }

			width += (params.maxDepth-(thisDepth-1))*params.indent;

			$(this).css( 'width', width + 'px' ).css( 'text-align', params.columns[0].align );
		});

		for (var i = 1; i < columns; i++) {
			var width = params.columns[i].width || perCol;
			if ( classname == 'head' ) { $('li[class*=head' + i + ']').css( 'width', width + 'px' ).css( 'text-align', params.columns[i].head_align ); }
			else                       { $('li[class*=col'  + i + ']').css( 'width', width + 'px' ).css( 'text-align', params.columns[i].align ); }
		}
	}
}

function fixList ( list, extra ) {
	for( var idx = 0; idx < list.length; idx++ ) {
		list[idx].id = list[idx].id + extra;
	}
}

function getPositionInList( liNode ) {
	var counter = 0;
	var prev = liNode.previousSibling;
	while( prev != undefined ) {
		if ( prev.tagName == 'LI' ) counter++;
		prev = prev.previousSibling;
	}

	return counter;
}

// Note that onStop occurs AFTER onChange, so since we want to know what row was dropped, we need
// to let it cascade, storing the serialized data in the onChange and then doing the actual AJAX
// call in onStop IF something actually changed.
function initTable( params ) {
	var originalPos    = null;
	var originalParent = null;
	var changed        = false;

	$('#'+params.listId).NestedSortableDestroy();

	if ( params.sort == 0 ) {
		$("li.hand").removeClass("hand");
	}

	$('#'+params.listId).NestedSortable(
		{
			accept: 'sort-row',
			nestingPxSpace: params.indent,
			noNestingClass: params.noNesting,
			opacity: .8,
			helperclass: 'helper',
			onChange: function(serialized) { changed = true; },
			onStop: function() {
				if ( changed ) {
					var newPos    = getPositionInList(this);
					var newParent = this.parentNode.parentNode;
					var myRealId  = this.id.replace( /_[\d]+/, '' );
					var postData  = new Object;

					postData['arrName']        = params.listId;
					postData['droppedRow']     = this.id;
					postData['originalParent'] = originalParent.id;
					postData['newParent']      = this.parentNode.parentNode.id;
					postData['sorting']        = 1;
					postData['originalPos']    = originalPos;
					postData['newPos']         = newPos;
					postData['lineage']        = '/';
					postData['curDepth']       = 0;
					var depthCheck = newParent;
					var lineage = new Array();
					while(depthCheck.tagName == 'LI') {
						var tmpId = depthCheck.id.replace( /_[\d]*/, '' );
						lineage.push( tmpId );
						postData['curDepth']++;
						depthCheck = depthCheck.parentNode.parentNode;
					}
					if ( lineage.length > 0 ) {
						postData['lineage'] += lineage.reverse().join( "/" ) + "/";
					}

					$.post(params.postTo, postData, function(data){
						error = data['error'];

						if ( error ) {
							// TODO:  Error handling
						} else {
							var newParentId      = postData['newParent'].replace( /_[\d]*/, '' );
							var originalParentId = postData['originalParent'].replace( /_[\d]*/, '' );

							if ( postData['newParent'] == postData['originalParent'] ) {
								if ( postData['newParent'] != params.wrapper ) { 
									var counter = new Date().getTime();
									$('li[id^=' + newParentId + '_]').each( function() {
										if ( this != newParent ) {
											this.innerHTML = newParent.innerHTML;
											fixList( this.getElementsByTagName('OL')[0].getElementsByTagName('LI'), counter );
											counter++;
										}
									} );
								}
							} else {
								if ( postData['originalParent'] != params.wrapper ) { 
									$('li[id^=' + myRealId + '_]').each( function() {
										var myParentId = this.parentNode.parentNode.id.replace( /_[\d]+/, '' );
										if ( myParentId == originalParentId ) {
											$(this).remove();
										}
									} );
								}

								if ( postData['newParent'] != params.wrapper ) { 
									var counter = new Date().getTime();
									$('li[id^=' + newParentId + '_]').each( function() {
										if ( this != newParent ) {
											this.innerHTML = newParent.innerHTML;
											fixList( this.getElementsByTagName('OL')[0].getElementsByTagName('LI'), counter );
											counter++;
										}
									} );
								}
							}

							if ( params.numbered ) updateNumbering();

							initTable( params );
						}
					}, "json");
				}
			},
			onStart: function() { originalParent = this.parentNode.parentNode; originalPos = getPositionInList(this); },
			autoScroll: true,
			handle: '.hand'
		}
	);
	$("div.striping").removeClass("even").removeClass("odd");
	if ( params.sort != 0 ) {
		$("div.striping").mouseout( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.inactiveDragImage;
			}
		} ).mouseover( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.dragImage;
			}
		} );
	} else {
		$('#'+params.listId).NestedSortableDestroy();
	}
	
	if ( params.striping ) {
		$("div.striping:even").addClass("even");
		$("div.striping:odd").addClass("odd");
	} else {
		$("div.striping").addClass("even");
	}

	resizeColumns( params );
}

function editRow( link, params ) {
	$(link.parentNode.parentNode.getElementsByTagName('LI')[0]).removeClass("hand").css('display', 'none');
	var liArray = link.parentNode.parentNode.getElementsByTagName('LI');

	for( var idx = 1; idx < liArray.length; idx++ ) {
		var value = liArray[idx].innerHTML;
		// This next line is for IE7.  It likes to add an extra space at the end.
		value = value.replace(/^\s+$/g,"");
		var editParams = params.columns[idx-1].edit;

		switch ( editParams.type ) {
			case 'text':
				liArray[idx].innerHTML = '<input type="text" value="' + value + '" class="' + editParams.classname + '" size="' + editParams.size + '" maxlength="' + editParams.maxlength + '">';
				break;

			case 'textarea':
				liArray[idx].innerHTML = '<textarea class="' + editParams.classname + '" rows="' + editParams.rows + '" cols="' + editParams.cols + '">' + value + '</textarea>';
				break;

			case 'checkbox':
				// This guarantees that it's bookended so that, e.g., "Skill" doesn't accidentally match "Skillset"
				value = editParams.delimiter + value + editParams.delimiter;
				var newInnerHTML = '';
				for ( var i in editParams.options ) {
					var o_value = editParams.options[i].value;
					var o_label = editParams.options[i].label;
					if ( o_value !== undefined ) {
						var o_label_re = new RegExp( editParams.delimiter + o_label + editParams.delimiter );
						newInnerHTML += '<input type="checkbox" value="' + o_value + '"' + ((o_label_re.test(value)) ? ' checked' : '') + '>' + o_label + '<br />';
					}
				}
				liArray[idx].innerHTML = newInnerHTML;
				break;

			case 'action':
				liArray[idx].innerHTML = '<a onclick="saveRow( this, params );" class="navsm">Save</a>';
				break;

			default:
				alert( 'Unknown edit type!' );
				break;
		}
	}

	initTable( params );
}

function addNewRow( link, params ) {
	var parentId = 0;
	if ( link != 'top' && link != 'bottom' ) {
		parentId = link.parentNode.parentNode.parentNode.parentNode.id;
	}
	var time = new Date().getTime();
	var rowText  = '<li class="clr sort-row" id="new_child_of_' + parentId + '_' + time + '"><div class="clearfix striping"><ul class="row-list"><li style="display:none">&nbsp;</li>';
	for (var i = 0; i < params.columns.length; i++) {
		rowText += '<li class="col' + i + '">';
		if ( i == params.columns.length-1 ) rowText += '<a id="new_' + time + '"></a>';  // We need this link so that editRow knows what to grab.
		rowText += '</li>';
	}
	rowText     += '</ul></div></li>';

	if ( link == 'top' ) {
		$('#'+params.listId).prepend( rowText );
		$('#empty_message').remove();
	} else if ( link == 'bottom' ) {
		$('#'+params.listId).append( rowText );
		$('#empty_message').remove();
	} else {
		// If we have a link, then the containing div is three levels up:  <div><ul><li><a>...
		var containingDiv = link.parentNode.parentNode.parentNode;
		var thisDepth = 0;

		// From that div, we're going to continually check grandparents to see how deeply we're nested:  <ol><li><ol>...
		var depthCheck = containingDiv.parentNode.parentNode;
		while ( depthCheck.tagName == 'OL' ) {
			depthCheck = depthCheck.parentNode.parentNode;
			thisDepth++;
		}

		var existingList = containingDiv.parentNode.getElementsByTagName('OL')[0];
		if ( existingList == undefined || $(existingList).length == 0 ) {
			thisDepth++;
			if (thisDepth > params.maxDepth) { params.maxDepth = thisDepth; }
			$(containingDiv).after('<ol class="page-list">' + rowText + '</ol>'); 
		} else {
			$(existingList).append( rowText );
		}
	}

	editRow( document.getElementById('new_' + time), params );
}

function updateNumbering() {
	var row_num = 0;
	$("li.col0").each( function() {
		this.innerHTML = ++row_num;
	} );
}

function saveRow( link, params ) {
	$(link.parentNode.parentNode.getElementsByTagName('LI')[0]).addClass("hand").css('display', 'block');
	var liArray = link.parentNode.parentNode.getElementsByTagName('LI');
	var liNode = link.parentNode.parentNode.parentNode.parentNode;
	var postData = new Object();

	postData['id'] = liNode.id;
	var nextSibling = liNode.nextSibling;
	while ( nextSibling && nextSibling.tagName != 'LI' ) {
		nextSibling = nextSibling.nextSibling;
	}
	if ( nextSibling ) postData['position'] = 'first';
	else postData['position'] = 'last';

	postData['lineage'] = '/';
	postData['curDepth'] = 0;
	var depthCheck = liNode.parentNode.parentNode;
	var lineage = new Array();
	while(depthCheck.tagName == 'LI') {
		var tmpId = depthCheck.id.replace( /_[\d]*/, '' );
		lineage.push( tmpId );
		postData['curDepth']++;
		depthCheck = depthCheck.parentNode.parentNode;
	}
	if ( lineage.length > 0 ) {
		postData['lineage'] += lineage.reverse().join( "/" ) + "/";
	}

	for( var idx = 1; idx < liArray.length; idx++ ) {
		var value;
		var display;
		var editParams = params.columns[idx-1].edit;
		var postThis = true;
		var isArray  = false;

		switch ( editParams.type ) {
			case 'text':
				value   = liArray[idx].getElementsByTagName('input')[0].value;
				display = value;
				break;

			case 'textarea':
				value = liArray[idx].getElementsByTagName('textarea')[0].value;
				display = value;
				break;

			case 'checkbox':
				var checkboxes = liArray[idx].getElementsByTagName('input');
				var typesArray = [];
				value = [];
				for (var i in checkboxes) {
					if ( checkboxes[i].checked ) { 
						typesArray.push(editParams.options[i].label); 
						value.push(editParams.options[i].value); 
					}
				}
				display = typesArray.join(editParams.delimiter);
				isArray = true;
				break;

			case 'action':
				if ( params.actionDropdown ) {
					display = '<form method="post"><select onChange="forward(this);" class="navsm"><option value="" class="navsm"> -- select -- </option>' + editParams.options.join( '' ) + '</select></form>';
				} else {
					display = editParams.options.join( ' | ' );
				}
				postThis = false;
				break;

			default:
				alert( 'Unknown edit type!' );
				break;
		}

		liArray[idx].innerHTML = display;
		if ( postThis ) {
			if ( isArray ) { postData['col' + (idx-1) + '[]'] = value; }
			else           { postData['col' + (idx-1)] = value; }
		}
	}

	var newId;
	var error;
	$.post(params.postTo, postData, function(data){
		error = data['error'];	
		newId = data['id'];

		if ( error ) {
			// TODO:  Error handling
		} else {
			liNode.id = newId;
			var compId = newId.replace( /_[\d]*/, '' );

			$('li[id^=' + compId + '_]').each( function() {
				var newLiArray = this.getElementsByTagName('DIV')[0].getElementsByTagName('UL')[0].getElementsByTagName('LI');
				for( var idx = 0; idx < liArray.length; idx++ ) {
					newLiArray[idx].innerHTML = liArray[idx].innerHTML;
				}
			} );

			if ( data['parent'] ) {
				var time = new Date().getTime();
				var counter = 0;

				var rowText   = '<li class="clr sort-row" id="' + compId + '_' + time + '_';
				var rowText2  = '"><div class="clearfix striping"><ul class="row-list"><li class="hand">&nbsp;</li>';
				for (var i = 0; i < params.columns.length; i++) {
					rowText2 += '<li class="col' + i + '">' + liArray[i+1].innerHTML + '</li>';
				}
				rowText2     += '</ul></div></li>';

				var currentList = document.getElementById( newId ).parentNode;

				$('li[id^=' + data['parent'] + '_]').each( function() {
					var thisDepth = 0;

					// From that div, we're going to continually check grandparents to see how deeply we're nested:  <ol><li><ol>...
					var depthCheck = this.parentNode;
					while ( depthCheck.tagName == 'OL' ) {
						depthCheck = depthCheck.parentNode.parentNode;
						thisDepth++;
					}

					var existingList = this.getElementsByTagName('OL')[0];
					if ( existingList != currentList ) {
						if ( $(existingList).length == 0 ) {
							var containingDiv = this.getElementsByTagName('DIV')[0];
							thisDepth++;
							if (thisDepth > params.maxDepth) { params.maxDepth = thisDepth; }
							$(containingDiv).after('<ol class="page-list">' + rowText + counter++ + rowText2 + '</ol>'); 
						} else {
							$(existingList).append( rowText + counter++ + rowText2 );
						}
					}
				} );
			}
		}

		initTable( params );
	}, "json");
}

function deleteRow( link, params ) {
	if ( params.sort ) {
		$("div.striping").mouseover( function() { 
			this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = 'none';
		} ).mouseout( function() {
			this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = 'none';
		} );
		$("div.striping").each( function() { 
			$(this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0]).removeClass("hand"); 
			this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = 'none';
		} );
	}
	$('#'+params.listId).NestedSortableDestroy();

	var actionCol = params.columns.length - 1;

	var parentUl = link.parentNode.parentNode;
	$(parentUl).after( '<div id="deleteMsg" style="clear:both;"><br /><center><b>Are you sure you want to delete this row?</b><br /><a onclick="deleteRowConfirm( this, params );" class="navsm">CONFIRM</a> | <a onclick="deleteRowCancel( this, params );" class="navsm">CANCEL</a></center></div>' ); 

	var parentDiv = parentUl.parentNode;
	parentDiv.style.backgroundColor = "#FF9999";

	$("li.col"+actionCol).css( 'visibility', 'hidden' );
}

function deleteRowConfirm( link, params ) {
	var liNode = link.parentNode.parentNode.parentNode.parentNode;
	var postData = new Object();

	var actionCol = params.columns.length - 1;

	postData['delete'] = 1;
	postData['id'] = liNode.id;
	if ( liNode.parentNode.parentNode.tagName == 'LI' ) {
		postData['parentId'] = liNode.parentNode.parentNode.id;
	} else {
		postData['parentId'] = 0;
	}
	postData['position'] = getPositionInList( liNode );

	if ( params.sort ) {
		$("div.striping").each( function() {
			this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.inactiveDragImage; 
		} ).mouseout( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.inactiveDragImage; 
			}
		} ).mouseover( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.dragImage;
			}
		} );

		$("div.striping").each( function() { $(this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0]).addClass("hand"); } );
	}

	$("li.col"+actionCol).css( 'visibility', 'visible' );

	$.post(params.postTo, postData, function(data){
		var counter = new Date().getTime();
		error = data['error'];

		if ( error ) {
			var parentDiv = link.parentNode.parentNode.parentNode;
			parentDiv.style.backgroundColor = "#FFF380";

			$("#deleteMsg").html( '<br /><center><b>' + error + '</b><br /><a onclick="dismissMessage( this );" class="navsm">Dismiss Message</a></center>' ).attr( "id", "warning_" + counter );
		} else {
			// Promote all children
			$($(liNode.getElementsByTagName('OL')[0]).children( 'li.sort-row' ).get().reverse()).each( function() {
				var text = '<li class="clr sort-row" id="' + this.id + '">' + $(this).html() + '</li>';
				$(this).remove();
				$(liNode).after( text );
			} );

			// TODO:
			// 	Need to update all the other instances of this competency with the same parent.

			$(liNode).remove();
		}

		initTable( params );
	}, 'json' );
}

function deleteRowCancel( link, params ) {
	var originalDiv = link.parentNode.parentNode.parentNode;
	originalDiv.style.backgroundColor = '';

	var actionCol = params.columns.length - 1;

	if ( params.sort ) {
		$("div.striping").each( function() {
			this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.inactiveDragImage; 
		} ).mouseout( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.inactiveDragImage; 
			}
		} ).mouseover( function() { 
			if ( this.parentNode.id != 'empty_message' ) {
				this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0].style.backgroundImage = params.dragImage;
			}
		} );

		$("div.striping").each( function() { $(this.getElementsByTagName('UL')[0].getElementsByTagName('LI')[0]).addClass("hand"); } );
	}

	$("#deleteMsg").remove();

	$("li.col"+actionCol).css( 'visibility', 'visible' );

	initTable( params );
}

function dismissMessage( link ) {
	link.parentNode.parentNode.parentNode.style.backgroundColor = '';
	$(link.parentNode.parentNode).remove();
}


