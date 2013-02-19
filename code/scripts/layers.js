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


/*
For the action structure, "per_row" is a reserve word indicating that the actions for 
each row could be different and are not uniform.  If the action is per row there is an
item called action_array which has the same format as the action structure.
*/

var layers = new Array();
var openCKEditor = new Object();

function layer(structure, layer){
	this.structure = structure;
	this.layer = layer;
	this.header = header(structure);
	this.showrows = showrows;
	this.showlayer = showlayer;
	this.adddata = adddata;
	this.actionstring = actionstring;
	this.getIndexByPK = getIndexByPK;
	this.setfield = layersetfield;
	this.ckefields = new Array();
	this.generateCKECode = generateCKECode;
}

function save(){
	var string;
	var data = this.structure['data'];
	var fields = this.structure['fields'];

	for (var i=0; i<fields.length; i++){
		if (string){
			string += '\t';
		}
		string += data[fields[i]];
	}
}

function generateCKECode() {
	for (var i = 0; i < this.ckefields.length; i++) {
		if (document.getElementById(this.ckefields[i])) {
			// cleanly destroy instance if it already exists
			if (CKEDITOR.instances[this.ckefields[i]]) {
				CKEDITOR.instances[this.ckefields[i]].destroy(true);
			}
			createCKEinstance(this.ckefields[i]);
		}
	}
}

function createCKEinstance(ckefield_id) {
	// create instance
	var instance = CKEDITOR.replace(ckefield_id, {
		toolbar : 'TUSK_min', 
		toolbarStartupExpanded : false,
		toolbarCanCollapse : false,
		removePlugins : 'elementspath',
		resize_enabled : false,
		readOnly : true 
	});
	instance.on('contentDom', function(e) {
		this.document.on('click', function(event) {
			// set up variables for lightbox switch
			var link = "#" + e.editor.container.$.id;
			var editor_id = e.editor.container.$.id.substring(4);
			openCKEditor.id = editor_id;
			var edwidth = $(window).width() - 300;
			var edheight = $(window).height() - 250;

			// get readable name of field and add to the header of the lightboxed edit window
			var match = /(\w*)__(.+)__(\w*)__(.+)/.exec(editor_id);
			if (match) {
				$('#crSelItmHdr').html("Modify HTML field: " + " " + match[3].replace(/[_-]/, " ") + ", row " + (parseInt(match[4]) + 1));
			}
			
			// get id of CKEDITOR instance that triggered click event
			// and recreate it within the div to be lightboxed, saving the former parent
			openCKEditor.parent = $("#" + editor_id).parent();
			openCKEditor.width = openCKEditor.parent.width();
			openCKEditor.height = openCKEditor.parent.height();
			CKEDITOR.instances[editor_id].destroy(true);			
			$("#" + editor_id).appendTo("#largeditor .inner");					
			var instance = CKEDITOR.replace(editor_id, {
				toolbar : 'TUSK', 
				toolbarStartupExpanded : true,
				toolbarCanCollapse : true,
				removePlugins : 'elementspath',
				extraPlugins : "tuskcontent", 
				resize_enabled : true,
				readOnly : false,
				height : edheight - 200,
				width : edwidth - 10
			});
			// add lightbox animation
			$('div#largeditor').css({
				display: 'block',
				width: openCKEditor.width,
				height: openCKEditor.height,
				top: openCKEditor.parent.position().top,
				left: openCKEditor.parent.position().left
			});
			// add dragability
			$('div#largeditor').draggable({handle: 'h4#crSelItmHdr'}); 

			$('div#largeditor').animate({
				height: edheight,
				width: edwidth,
				top: (($(window).height() - edheight) / 2) + $(window).scrollTop(),
				left: (($(window).width() - edwidth) / 2) + $(window).scrollLeft()
			}, 500, function() {
				instance.focus();
			});
		
			$('div#crCurtain').css({
				display: 'block',
				position: 'fixed',
				'z-index':15,
				opacity: 0.5
			});			
		});
	});
	return instance;
}

function closeCKEbox() {
	CKEDITOR.instances[openCKEditor.id].destroy(true);

	$("#largeditor .inner #" + openCKEditor.id).appendTo(openCKEditor.parent);					
	$('div#largeditor').animate({
		top: openCKEditor.parent.position().top,
		left: openCKEditor.parent.position().left,
		opacity: 'hide',
		width: openCKEditor.width,
		height: openCKEditor.height
	}, 500, function() { 
		$('div#crCurtain').css('display', 'none');
	});
	createCKEinstance(openCKEditor.id).focus();
	openCKEditor.id = null;
	openCKEditor.parent = null;
	openCKEditor.height = null;
	openCKEditor.width = null;
}

function saveCKEbox() {
	CKEDITOR.instances[openCKEditor.id].updateElement();
	updateCKfield(CKEDITOR.instances[openCKEditor.id]);
	closeCKEbox();
}

function updateCKfield (instance) {
	// layer__id__fieldname__row
	var fieldAttrs = instance.name.split("__");
	setfield(fieldAttrs[0], fieldAttrs[3], fieldAttrs[2], instance.getData(), "this.form." + fieldAttrs[0] + "__" + fieldAttrs[1] + "__elementchanged__" + fieldAttrs[3]);
}


function showlayer(){
	var string;
	var hasdata="";
	var height = "";
	var overflow = "";

	if (this.structure['data'].length > 0){
		if (this.structure['data'].length > this.structure['scrollrows']){
			height = 30 * (this.structure['scrollrows']) + 30;
			overflow = "auto";
		}
		hasdata = 1;
		string = '<table id="' + this.structure['table_id'] + '" width="100%" cellspacing="0" class="tusk">';
		string += this.showrows();
		string += '</table>';
	}else{
		if (this.layer && this.structure['name']){
			string = '<br><span class="navsm"><i>';
			if (this.structure['empty_message']){
				string += this.structure['empty_message'];
			}else{
				string = 'No ' + this.structure['name'] + ' ' + _("associated") + '.';
			}
			string += '</i></span><br>';
		}else{
			string = "";
		}
	}
	if (this.structure['validate']['usage'] == 'Yes'){
		document.forms[this.structure['validate']['form']].elements[this.structure['validate']['element']].value = hasdata;
	}
	display(this.layer, string, height, overflow);
	
	// if there are dynamically-created CKEDITOR fields, do cleanup and generation of CKEDITOR code
	if (this.ckefields.length > 0) {
		this.generateCKECode();
		cleanUpCKEInstances(this.layer);
	}
	else if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
		cleanUpCKEInstances(this.layer);
	}
}

function display(layer, string, height, overflow){
	if (document.layers) {
		document.layers[layer].document.open();
       		document.layers[layer].document.writeln(string)
       		document.layers[layer].document.close();
		if (height){
	       		document.layers[layer].style.height = height;
       			document.layers[layer].style.overflow = overflow;
		}
	} else if (document.all){
		document.all[layer].innerHTML = string;
		if (height){
			document.all[layer].style.height = height;
			document.all[layer].style.overflow = overflow;
		}
	} else {
	       	document.getElementById(layer).innerHTML = string;
	       	if (height){
			document.getElementById(layer).style.height = height;
			document.getElementById(layer).style.overflow = overflow;
		}
	}
}


function showrows(){
	var string = this.header;
	var align;
	var data = this.structure['data'];
	var display = this.structure['display'];
	var action = this.structure['action'];
	var sort = this.structure['sort'];
	var fields = this.structure['fields'];
	var fieldRE = new RegExp('"',"g");
	var ckefields = this.ckefields = new Array();
	for (var i=0; i<data.length; i++){
		if (i % 2){
			rowclass = 'odd';
		}else{
			rowclass = 'even';
		}

		var changedname = elementname(this.layer, data[i][fields[0]], 'elementchanged', i);

		string += '<tr class="' + rowclass + '">';
		if (sort['usage'] == 'Yes'){
			string += '<td class="layers-center" width="'+ sort['length'] + '">' + makesortbox(this.layer, data[i][fields[0]], i, data.length, rowclass) + '</td>';
		}
		for (var j=0; j<display.length; j++){
			if (data[i][display[j]['field']] == undefined){
				data[i][display[j]['field']] = '';
			}
			var displayFieldValue = new String(data[i][display[j]['field']]);
			if (displayFieldValue == null){
				displayFieldValue = '';
			}
			var hiddenFieldValue = displayFieldValue.replace(fieldRE,'&quot;');

			if (display[j]['type'] == 'hidden'){
				string += '<input type="hidden" name="'+ elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" value="' + hiddenFieldValue + '">';
				continue;
			}
			if (display[j]['align']){
				align = display[j]['align'];
			}else{
				align = "center";
			}
			
			if (! display[j]['radio_options']){
				string += '<td class="layers-' + align + '"';
				if ( display[j]['length'] ) {
					string += ' style="width:' + display[j]['length'] + 'px"';
				}
				string += '>';
			}

			if (display[j]['options']){
				string += '<select id="layerselect" class="' + rowclass + '" name="' + elementname(this.layer, data[i][fields[0]],display[j]['field'], i) + '" onchange="setfield(\'' + this.layer + '\',\'' + i + '\',\'' + display[j]['field'] + '\', this.options[this.selectedIndex].value, this.form.' + changedname + ')">';
				for (var k=0; k<display[j]['options'].length; k++){
					if (!display[j]['options'][k]['value']){
						display[j]['options'][k]['value'] = display[j]['options'][k]['label'];
					}

					if (display[j]['options'][k]['value'] == displayFieldValue ){
						select = 'selected';
					}else{
						select = '';
					}
					string += '<option class="' + rowclass + '" style="' + display[j]['options'][k]['style'] + '" value="' + display[j]['options'][k]['value']  + '" ' + select + '>' + display[j]['options'][k]['label'];
				}
				string += '</select>';
			}
			else if (display[j]['radio_options']){
				for (var k=0; k < display[j]['radio_options'].length; k++){

					string += '<td class="layers-' + align + '"';
					if ( display[j]['length'] ) {
						string += ' style="width:' + display[j]['length'] + 'px"';
					}
					string += '>';
					
					string += '<input type="radio" class="' + rowclass + '" name="' + elementname(this.layer, data[i][fields[0]],display[j]['field'], i) + '" onclick="setfield(\'' + this.layer + '\',\'' + i + '\',\'' + display[j]['field'] + '\', \'' + display[j]['radio_options'][k]['value'] + '\', this.form.' + changedname + ')" value="' + display[j]['radio_options'][k]['value'] + '"';

					if (display[j]['radio_options'][k]['value'] == displayFieldValue ){
						string += ' checked';
					}

					string += '></td>';
				}
			}
			
			else{
				if ((this.editnum == i && display[j]['uneditable'] == null) || (((display[j]['type'] == 'textarea') || (display[j]['type'] == 'textbox') || (display[j]['type'] == 'checkbox')) && typeof(data[i]['isHeaderRow']) == 'undefined')){
					displayFieldValue = displayFieldValue.replace(new RegExp('&','g'), '&amp;');
					if ((display[j]['edittype'] == 'textarea') || (display[j]['type'] == 'textarea')){
						string += '<textarea class="textareawhite" id="' + elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" name="' + elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" onChange="setfield(\'' + this.layer + '\', ' + i + ', \'' + display[j]['field'] + '\', this.value, this.form.' + changedname + ')" style="width:' + display[j]['length']  + 'px;height:70px">' + displayFieldValue + '</textarea>';
						if (display[j]['htmleditor']) {
							ckefields.push(elementname(this.layer, data[i][fields[0]], display[j]['field'], i));
						}
					}else if ((display[j]['edittype'] == 'checkbox') || (display[j]['type'] == 'checkbox')){
						string += '<input type="checkbox" name="' + elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" '
						if (displayFieldValue == 1){
							string += ' CHECKED';
						}
						string += ' />';
					}else{
						displayFieldValue = displayFieldValue.replace(fieldRE, '&quot;');

						string += '<input type="text" class="textareawhite" name="' + elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" id="' + elementname(this.layer, data[i][fields[0]], display[j]['field'], i) + '" value="' + displayFieldValue + '" onChange="setfield(\'' + this.layer + '\', ' + i + ', \'' + display[j]['field'] + '\', this.value, this.form.' + changedname + ');" style="width:' + display[j]['length']  + 'px" onclick="' + display[j]['onclick'] + '">';
					}
				}else{
					if (display[j]['uneditable'] == null && typeof(data[i]['noHiddenFields']) == 'undefined'){
						string += '<input type="hidden" name="' 
						+ elementname(this.layer, data[i][fields[0]], display[j]['field'], i) 
						+ '" value="' + hiddenFieldValue + '">';
					} 
					if (display[j]['checkvaluefield']){
						string += '<input type="checkbox" ';
						if (displayFieldValue){
							string += 'onChange="this.checked = true;" checked';
						}else{
							string += 'onChange="this.checked = false;"';
						}
						string += '>';
					}else{
						string += displayFieldValue;
					}
				}
			}
			if (!data[i]['elementchanged']){
				data[i]['elementchanged'] = 0;
			}
			if(typeof(data[i]['noHiddenFields']) == 'undefined'){
				string += '<input type="hidden" name="' + changedname + '" value="' + data[i]['elementchanged'] + '"></td>';
			}
		}

		if (action.functions != "per row"){ 
			string += this.actionstring(action,i);
		} else {
			string += this.actionstring(data[i]['action_array'],i);
		}
		string +='</tr>';
	}

	return string;
}

function actionstring(action,id){
	var string = '';
	if (action['usage'] == 'Yes'){
		string += '<td class="layers-center" style="width:' + action['length'] + 'px" style="white-space: nowrap" nowrap>';
		for(var k=0; k<action['functions'].length; k++){
			if (k>0){
				string += '<span class="littlespacing">|</span>';
			}
			var link_action = action['functions'][k]['func'];
			var linkid =  link_action + '_' + id;
			string += '<a class="navsm" id="' + linkid + '" href="javascript:';
			if (action['functions'][k]['prompt'] == 'Yes'){
				var act = action['functions'][k]['label'].toLowerCase();
				var msg = _x("'Are you sure you want to {action}?'", {'action' : act });
				string += '{if (confirm(' + msg +  ')){';
			}
			string += link_action + '(\'' + this.layer + '\', ' + id;

			if (typeof(action['functions'][k]['extra_param']) != 'undefined'){
				for (i in action['functions'][k]['extra_param']){
					if(typeof(action['functions'][k]['extra_param'][i]) == "string"){
						string += ', \'' + action['functions'][k]['extra_param'][i] + '\'';
					} else {
						string += ', ' + action['functions'][k]['extra_param'][i];
					}
				}
			}

			if (this.structure.parentlayer){
				string += ', \'' + this.structure.parentlayer + '\'';
			}
			string += ', \'' + linkid + '\')';
			if (action['functions'][k]['prompt'] == 'Yes'){
				string += '}}';
			}
			string += '">' + action['functions'][k]['label'] + '</a>';
		}
		string += '</td>';
	} 
	return string;
}

function elementname(layer, id, field, index){
	return layer + '__' + id + '__' + field + '__' + index;
}

function header(structure){
	var string = '<tr class="header">';
	var align;

	if (structure['sort']['usage'] == 'Yes'){
		string += '<td class="header-center" align="center" valign="top" width="1%">' + _('Sort') + '</td>';
	}
	for (var i=0; i<structure['display'].length; i++){
		if (structure['display'][i]['type'] == 'hidden'){
			continue;
		}
		if (structure['display'][i]['headeralign']){
			align = structure['display'][i]['headeralign'];
		}else if (structure['display'][i]['align']){
			align = structure['display'][i]['align'];
		}else{
			align = 'center';
		}

		if (structure['display'][i]['radio_options']){
			for (var k=0; k < structure['display'][i]['radio_options'].length; k++){
				string += '<td class="header-' + align + '" style="width:' + structure['display'][i]['length'] + 'px">';
				string += structure['display'][i]['radio_options'][k]['label'];
				string += '</td>';
			}
		}
		else {
			string += '<td class="header-' + align + '" style="width:' + structure['display'][i]['length'] + 'px">';
			
			if (structure['display'][i]['label']){
				string += structure['display'][i]['label'];
			}else{
				string += structure['display'][i]['field'].substring(0, 1).toUpperCase() + structure['display'][i]['field'].substring( 1 );
			}
		}
		string += '</td>';
	}
	if (structure['action'] && structure['action']['length'] && structure['action']['usage'] == 'Yes'){
		string += '<td class="header-center" width="1%" nowrap>' + _('Action') + '</td>';
	}
	string += '</tr>';

	return string;
}

function makesortbox(layer, key, index, length, rowclass){
	var string = '<select class="' + rowclass + '" name="' + elementname(layer, key, 'sortorder', index) + '" onchange="swap(\'' + layer + '\', this.options[this.selectedIndex].value);">';
	for(var i=1; i<length+1; i++){
		string += '<option class="' + rowclass + '" ';
		if (i == index + 1){
			string += 'value="' + i +'" selected>';
		}else{
			string += 'value="' + index + ':' + (i-1) + '">';
		}
		string += i + '</option>';
	}
	string += '</select>';

	return string;
}

function swap(layer, string){
	if (!string) return;
	var stringsplit = string.indexOf(':');
	var index = string.substring(0, stringsplit);
	var newindex = string.substring(stringsplit + 1, string.length);

	layers[layer].editnum = -1; // stop editing if swapping

	layers[layer].structure.data.splice(newindex, 0, layers[layer].structure.data.splice(index, 1)[0]);
	for (var i =0; i < layers[layer].structure.data.length; i++){
		layers[layer].structure.data[i]['elementchanged'] = 1;
	}
	layers[layer].showlayer();
}

function layersetfield(index, field, value, formelement){
	this.structure.data[index][field] = value;
	this.structure.data[index]['elementchanged'] = 1;
	if (formelement != null){
		formelement.value = 1;
	}
}

function setfield(layer, index, field, value, formelement){
	layers[layer].setfield(index, field, value, formelement);
}

function remove(layer, index){
	layers[layer].structure.data.splice(index, 1);
	layers[layer].showlayer();
}

function removemulti(layer, index, quantity){
	layers[layer].structure.data.splice(index, quantity);
	layers[layer].showlayer();
}

function removeall(layer){
	layers[layer].structure.data = new Array(0);
	layers[layer].showlayer();
}

function moveToDrop(layer, index, dropdown_id, text, value){
	// this method can remove a row from a sort_order_box and 
	// return the element to the drop down box.
	// can be seen in action at: /case/administrator/examaddedit/
	
	var dropdown = document.getElementById(dropdown_id);
	if (dropdown){
		var data_obj = layers[layer].structure.data[index];
		dropdown.options[dropdown.length] = new Option(data_obj[text], data_obj[value], false);
		// /case/admin/examaddedit needs the test_value_id so that if the patient type 
		// gets reinserted into box, it will retain id and execute an update instead of insert
		var primary_key = layers[layer].structure.fields[0];
		dropdown.options[dropdown.length-1].id = data_obj[primary_key];

	}
	layers[layer].structure.data.splice(index, 1);
	layers[layer].showlayer();
}
// end new
function hidebutton(button){
	document.getElementById(button).style.display = "none";
	document.getElementById(button).style.visibility = "hidden";
}

function showbutton(button){
	document.getElementById(button).style.display = "block";
	document.getElementById(button).style.visibility = "visible";
}


function edit(layer, index, id){
	// user is going from edit mode
	if (layers[layer].editnum == index){
		layers[layer].editnum = -1;
	// user is going to edit mode
	}else{
		layers[layer].editnum = index;
	}

	layers[layer].showlayer();
	if (layers[layer].editnum != -1){
		display(id, "Done");
	}
}

function openwindow(layer, width, height, xtraParams){
	if (!width){
		width = 640;
	}	
	if (!height){
		height = 500
	}

	var spaceRE = new RegExp(' ',"g"); 
	var name = layers[layer].structure.name.toLowerCase().replace(spaceRE, '');
	
	var param = "directories=no,menubar=no,toolbar=yes,scrollbars=yes,resizable=yes,width=" + width + ",height=" + height;
	
	var school = '';
	var course = '';
	if(xtraParams){
		school = xtraParams['school'] || '';
		course = xtraParams['course'] || '';
	}

//	chooser_window = window.open("/management/searchpages/index.html?type=" + name + "&parentlayer=" + layer + '&school=' + school + '&course=' + course, layer, param);
    var pathStr = "/management/searchpages/" + name +"/";
//	if (school) pathStr+= school + "/";
//	if (course) pathStr+= course + "/";
    pathStr+="?parentlayer=" + layer;
	if (school) pathStr+= "&schl=" + school ;
	if (course) pathStr+= "&crs=" + course ;
    chooser_window = window.open(pathStr, layer, param);
	//chooser_window = window.open("/management/searchpages/" + name + "/" + school + "/" + course + "?parentlayer=" + layer, layer, param);
	if (!chooser_window.opener) chooser_window.opener = self;
	chooser_window.focus();
}

function adddata(indata, checkflag, checkfield){
	var newdata = {};
	for (i in indata) {
		newdata[i] = indata[i];
	}
	var data = this.structure.data;
	newdata['elementchanged'] = 1;

	if (checkflag){
		var primary_key = this.structure.fields[0];

		if (typeof(checkfield) == "undefined"){
			checkfield = primary_key;
		}

		for (i=0; i<data.length; i++){
			if (newdata[checkfield] == data[i][checkfield]){
				return this.structure.name.charAt(0).toUpperCase() + this.structure.name.substr(1, this.structure.name.length-1);
			}
		}
	}

	if (newdata[primary_key] == null){
		newdata[primary_key] = 0 ;
	}
	var flag = 0;
	if (this.structure.sortoninsert && this.structure.sortoninsert['usage'] == 'Yes'){
		for (j=0; j<data.length; j++){
			if (newdata[this.structure.sortoninsert['sorton']].toUpperCase() < data[j][this.structure.sortoninsert['sorton']].toUpperCase()){
				data.splice(j, 0, newdata);
				flag = 1;
				break;
			}
		}
		if (flag == 0){
			data.push(newdata);
		}
	}else{
		data.push(newdata);
	}
	this.showlayer();
}

function add(layer, index, parentlayer){
	var data = layers[layer].structure.data[index];

	var msg = parent.opener.layers[parentlayer].adddata(data, 1);
	if (msg){
		if (msg.charAt(msg.length-1) == 's'){
			msg = msg.substr(0, msg.length-1);
		}
		alert(msg + _(" already exists."));
	}
	remove(layer, index);
	if (layers[layer].structure.data.length > 0){
		display("count", layers[layer].structure.data.length + _(" matching entries:"	));
	}else{
		display("count", _("No matching entries"));
	}
}

function addnew(layer, newdata){
	parent.opener.layers[layers[layer].structure.parentlayer].adddata(newdata, 0);
}

function addnewdata(layer, newdata, checkflag, checkfield){
	if (typeof(checkflag) == "undefined")  {
		checkflag = 0;
	}
	layers[layer].adddata(newdata, checkflag, checkfield);
}

function getIndexByPK(pk){
        var data = this.structure.data;
	var primary_key = this.structure.fields[0];
	for (i=0; i<data.length; i++){
                        if (pk == data[i][primary_key]){
                                return i;
                        }
        }
	return;
}

function func_redirect(layer, index, field, path){
	data = layers[layer].structure['data'];

 	fields = layers[layer].structure['fields'];
 	context_path = layers[layer].structure['context_path'];
	formname = layers[layer].structure['validate']['form'];
	base_path = layers[layer].structure['base_path'];
	if (base_path){
		path = base_path + '/' + path;
	}
	next_page = path + '/' + context_path;
	id = data[index][fields[0]];
	// this function is located in element.js
	save_and_continue(formname, next_page, id);
}

function duplicate_row(layer, index, linkid){
	var data = layers[layer].structure['data'];
	var primary_key = layers[layer].structure.fields[0];
	var newitem = data[index];
	newitem[primary_key] = 0;
	data.splice(index, 0, newitem);
	layers[layer].showlayer();
}

function isEmptyObject(obj) {
	for(var prop in obj) {
		if (Object.prototype.hasOwnProperty.call(obj, prop)) {
		  return false;
		}
	}
	return true;
}

// clean up all CKE Instances within a container div
function cleanUpCKEInstances(containerDiv) {
	for (var i in CKEDITOR.instances) {
		if (CKEDITOR.instances[i].name.indexOf(containerDiv) > -1 && !document.getElementById(CKEDITOR.instances[i].name)) {
			CKEDITOR.instances[i].destroy(true);
		}
	}
}

