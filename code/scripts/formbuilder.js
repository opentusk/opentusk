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


function formedit_submit(form){
	if (!form.form_name.value){
		alert("Please enter a form name.");
		return false;
	}

	return true;
}

function fieldaddedit_submit(form){
	if (!form.field_name.value){
		alert("Please enter a field name.");
		return false;
	}

	// good values are id#label
	if (form.field_type_id && form.field_type_id.value == '#'){
		alert("Please select a field type.");
		return false;
	}

	return true;
}


function attributeedit_submit(form){
	if (!form.attribute_name.value){
		alert("Please enter an attribute name.");
		return false;
	}

	return true;
}

function field_modify(layer, index, field){
	func_redirect(layer, index, field, 'field');
}

function dynamic_field_modify(layer, index, field){
	func_redirect(layer, index, field, 'fielddynamic');
}

function field_delete(layer, index, field){
	func_redirect(layer, index, field, 'fielddelete');
}

function dynamic_field_delete(layer, index, field){
	func_redirect(layer, index, field, 'fielddynamicdelete');
}

function attribute_modify(layer, index, field){
	data = layers[layer].structure['data'];
	id = data[index]['attribute_id'];
	name = data[index]['name'];

	if (id == 0){
		alert('Please save field before editting a new attribute.');
	}else if(!name){
		alert('Please give an attribute name before trying to create attribute items.');
	}else{
		func_redirect(layer, index, field, 'attribute');
	}
}

function change_display(element){

	selected_value = element.options[element.selectedIndex].value;

	show_flag = 0;
	if (selected_value == '#') {
		display_row('fillin_size_tr', 0);
	} else if (selected_value.substring(selected_value.indexOf('#')+1) == 'FillIn'){
		display_row('fillin_size_tr', 1);
	} else if (selected_value.substring(selected_value.indexOf('#')+1) == 'Essay'){
		display_row('fillin_size_tr', 0);
	} else if (selected_value.substring(selected_value.indexOf('#')+1) == 'Heading'){
		display_row('fillin_size_tr', 0);
	} else if (selected_value.substring(selected_value.indexOf('#')+1) == 'DynamicList'){
		display_row('fillin_size_tr', 0);
		show_flag = 1;
	} else {
		show_flag = 1;
		display_row('fillin_size_tr', 0);
	}

	elements = ['item_sort_tr','item_sort','items_tr','default_report_tr', 'default_report'];

	for (i = 0; i < elements.length; i++) {
		display_row(elements[i], show_flag);
	}

	if (selected_value.substring(selected_value.indexOf('#')+1) != 'MultiSelectWithAttributes') {
		display_row('attributes_tr', 0);
	} else {
		display_row('attributes_tr', 1);
	}


	if (selected_value.substring(selected_value.indexOf('#')+1) == 'SingleSelect' || selected_value.substring(selected_value.indexOf('#')+1) == 'SingleSelectWithSubFields') {
		display_row('selection_options_tr', 1);
	} else {
		display_row('selection_options_tr', 0);
	}


	if (selected_value.substring(selected_value.indexOf('#')+1) == 'SingleSelectWithSubFields' || selected_value.substring(selected_value.indexOf('#')+1) == 'ScalingWithSubFields') {
		display_row('subfield_tr', 1);
	} else {
		display_row('subfield_tr', 0);
	}


	if (selected_value.substring(selected_value.indexOf('#')+1) == 'Scaling' || selected_value.substring(selected_value.indexOf('#')+1) == 'ScalingWithSubFields') {
		display_row('rubric_tr', 1);
		display_row('header_rubric_tr', 1);
	} else {
		display_row('rubric_tr', 0);
		display_row('header_rubric_tr', 0);
	}

}


var form_counter = [];

function add(div){
   	if (!form_counter[div]){
		form_counter[div] = 0;
   	}

   	form_counter[div]++;

	var newFields = document.getElementById(div).cloneNode(true);

   	newFields.style.display = 'block';
   	newFields.id = '';

   	var newField = newFields.childNodes;

	for (var i=0; i<newField.length; i++){

		var theName = newField[i].id
		if (theName == "dont_copy") {
		     newFields.removeChild(newField[i]);
		     continue;
		}

		if (theName){
			newField[i].id = theName + form_counter[div];
		}


		if (newField[i].type == 'text'){
			newField[i].value = '';
		}
	}

	var maindiv = document.getElementById(div);
	maindiv.parentNode.insertBefore(newFields, null);
	textbox_display(newField[1]);

	return false;
}

function textbox_display(self){
    var textbox = document.getElementById('text_' + self.id);
    selected_value = self.options[self.selectedIndex].value;

    if (selected_value.substring(selected_value.indexOf('#')+1) == 1){
         textbox.style.display = 'inline';
    }else{
		if (textbox) {
	    	textbox.style.display = 'none';
			textbox.value = '';
		}
    }
   	if (selected_value == '-1#0'){
		alert('You have selected a subheader, please instead select an item.');
		self.selectedIndex = 0;
		self.focus();
   }
}

function change_style(id, count){

	if (document.getElementById(id).className == "unselected"){
		document.getElementById(id).className = 'selected';
		document.getElementById('multiwithattr_' + id + '_selected').value = 1;
	}else{
		document.getElementById(id).className = 'unselected';
		document.getElementById('multiwithattr_' + id + '_selected').value = 0;
	}
	for (i=1; i<=count; i++){
		state = toggle_row(id + '_select_' + i);
	}
	if (document.getElementById(id + '_user_defined')){
		state = toggle_row(id + '_user_defined');
	}
}

function change_focus(id){
	var user_defined = document.getElementById(id + '_user_defined');
	if (user_defined && user_defined.style.display != "none"){
		user_defined.focus();
	}
}

function show_trs(field_count, element, label, base_element){
	if (element.value == "Show " + label){
		element.value = "Hide " + label;
	}else{
		element.value = "Show " + label;
	}
	
	for (var i = 1; i <= field_count; i++){
		toggle_row(base_element + i + '_tr');
	}
}

function report_submit(form){
	if (form.fields.selectedIndex == -1){
		alert('Please select at least one Report Field.');
		return false;
	}
	return true;
}

function check_required_fields(form, required_array) {
    // TODO: Also implement server-side logic to verify.

    if (form.encounter_date) {
        if (!isValidDate(form.encounter_date)) {
            return false;
        }
    }

    if (window.checkNotRequired == 1) {
        return true;
    }


    if (document.getElementById("check_required").value == 0) {
        return true;
    }

    if (window.checkTimePeriod && form.time_period_id.value == 0) {
        alert('Please select a site and time period');
        return false;
    }

    for (var i=0; i < required_array.length; i++) {
        var obj_id = required_array[i]['id'];
        var msg = required_array[i]['message'];
        var obj = document.getElementById(obj_id);

        if (obj && obj.nodeName == 'SELECT') {
            if (obj.multiple) {
                if (obj.selectedIndex == -1) {
                    alert('Please select an option for ' + msg);
                    obj.focus();
                    return false;
                }
            }
            else {
                if (obj.selectedIndex == 0) {
                    alert('Please select an option for ' + msg);
                    obj.focus();
                    return false;
                }
            }
        }
        else if (obj_id.match(/^checklist_/)) {
            if (obj && obj.value > 0) {
                alert('Please complete the checklist for ' + msg);
                return false;
            }
        }
        else if (obj_id.match(/^text_id_/)) {
            // I don't understand the logic here. TODO: Examine "single
            // select allow multiple" formbuilder element.
            var textboxes = document.getElementsByName(obj_id);
            for (var j = 0; j < textboxes.length; j++) {
                var text_str = textboxes[j].value;
                if (textboxes[j].style.display == 'inline'
                    && text_str.match(/^\s*$/)) {
                    alert('Please complete the text description for ' + msg);
                    return false;
                }
                else if (textboxes[j].style.display == 'none') {
                    // Added to handle "single select allow multiple"
                    var item_id = obj_id.substr(8);
                    var table_obj = document.getElementById('f' + item_id);
                    var select_obj = document.getElementById('id_' + item_id);
                    if ((! table_obj) && (select_obj.selectedIndex == 0)) {
                        alert ('Please select an option for ' + msg);
                        return false
                    }
                }
            }
        }
        else if (obj_id.match(/^id_/)) {
            if (obj.nodeName.toLowerCase() == 'textarea'
                || (obj.nodeName.toLowerCase() == 'input'
                    && obj.type.toLowerCase() == 'text')) {
                if (obj.value.length == 0) {
                    alert ('Please complete the text description for ' + msg);
                    return false;
                }
            }
        }
        else if (obj_id.match(/^multiwithattr_/)) {
            var items = getElementsByClassName(obj_id);
            var field_id = obj_id.split('_')[1];
            var attribute_count = document.getElementById(
                'attributes_' + field_id).value;
            var errmsg = 'Please complete the required information for ' +
                'your selection(s) in the ' + msg + ' section.';
            for (var j = 0; j < items.length; j++) {
                if (items[j].value == 1) {
                    var field_item = items[j].name.split('_');
                    for (var p = 1; p <= attribute_count; p++) {
                        var attrs = getElementsByClassName('attribute-item_' +
                                                           field_item[1] +
                                                           '_' +
                                                           field_item[2] +
                                                           '_select_' +
                                                           p);
                        if (attrs && attrs.length > 0) {
                            if (attrs[0].nodeName == 'SELECT'
                                && attrs.length == 1) {
                                if (attrs[0].selectedIndex == 0) {
                                    alert(errmsg);
                                    return false;
                                }
                            } else {  // if not dropdown then it must be radio!
                                var checked = 0;
                                for (var k = 0; k < attrs.length; k++) {
                                    if (attrs[k].checked == true) {
                                        checked = 1; break;
                                    }
                                }
                                if (checked == 0) {
                                    alert(errmsg);
                                    return false;
                                }
                            }
                        }
                    }
                }

            }
        }
    }

    if (window.confirmMessage) {
        return confirm("Are you sure you want to submit this form?");
    }
    return true;
}

/* check a given element in the form if it contains a numeric ID without leading zeroes */
function isValidIdWithoutLeadingZeroes(elem) {

	var str = elem.value;
	var re = /^[1-9]\d*$/;
	str = str.toString();
	if (!str.match(re)) {
		alert("Enter a valid numeric ID with no leading zeroes.");
		return false;
	}
	return true;
}


function reload_entry_form(entry_id, array_index){
	var new_location = location.href;
	var re = new RegExp('\\?.*');
	new_location = new_location.replace(re, '');
	var get_string = '';
	if (entry_id){
		get_string = '?entry_id=' + entry_id;
	}
    if (array_index){
		get_string += '&index=' + array_index;
	}

	window.location = new_location + get_string;
}


function checkUncheckAll(theElement) {
	var theForm = theElement.form;
	var i = 0;
	for (i = 0; i < theForm.length; i++) {
		if (theForm[i].type == 'checkbox' && theForm[i].name != 'checkall') {
			theForm[i].checked = theElement.checked;
		}
	}
}

/* in case of many checkbox fields in the form, so the caller should pass the checkall */
function checkUncheckAllMulti(checkboxes,checkall) {
	if (checkall.checked == true) {
		for (var i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = true;
		}
	} else if (checkall.checked == false) {
		for (var i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = false;
		}
	}
}

function checkUncheckAllUpdate(checkboxes,checkall) {
	if (checkall.checked == true) {
		for (var i = 0; i < checkboxes.length; i++) {
			if (checkboxes[i].checked == false) {
				checkall.checked = false;
				break;
			}
		}
	} else if (checkall.checked == false) {
		for (var i = 0; i < checkboxes.length; i++) {
			if (checkboxes[i].checked == false) {
				return;
			}				
		}
		checkall.checked = true;
	}
}

function validateCheckbox(theElement) {
	var i = 0;
	for (i = 0; i < theElement.length; i++) {
		if (theElement[i].checked == true) {
			return true;
		}
	}	
	alert("Please select at least one checkbox.\n");
	return false;
}

function showHideRows(button) {
	for (var i = 0; i < should_see_rows; i++) {
		var currRow = document.getElementById('notRequired' + i);
		currRow.style.display = (currRow.style.display == "none") ? '' : 'none';
	}

	if (button.value == 'Show All') {
		button.value = 'Show only \'Should See\'';
	} else {
		button.value = 'Show All';
	}
}


function showHideAllEntries(button) {
	for (var i = 1; i < entries; i++) {
		var entry = document.getElementById('entry_' + i);
		entry.style.display = (entry.style.display == "none") ? '' : 'none';
	}

	if (button.value == 'show all') {
		button.value = 'hide all';
	} else {
		button.value = 'show all';
	}
}


function showHideEntry(button, num) {
	var entry = document.getElementById('entry_' + num);
	entry.style.display = (entry.style.display == "none") ? '' : 'none';

	if (button.value == 'show') {
		button.value = 'hide';
	} else {
		button.value = 'show';
	}
}

function updateRequiredItem(item_id, field_id) {
	var item = document.getElementById('id_' + item_id);

	if (item) {
		item.style.display = 'none';
	}

	var num_items = document.getElementById('checklist_' + field_id);
	if (num_items) {
		num_items.value -= 1;
		var cl = document.getElementById('checklist_' + field_id);
	}
}


function disableForm() {
	var theform = document.myform;
	if (document.all || document.getElementById) {
		for (i = 0; i < theform.length; i++) {
			var formElement = theform.elements[i];
			if (true) {
				formElement.disabled = true;
			}
		}
	}
}

function toggle_links(id,cid,indx){
	var new_display = 'block';
    
	var el = document.getElementById("theWrapperDiv"+cid);
	var href = document.getElementById("a"+cid);

	if (el) {

		if (el.style.display == 'block'){
			new_display = 'none';
			href.innerHTML="Show Links";
		} else { href.innerHTML="Hide Links"; }
		el.style.display = new_display;
    } else {
        href.innerHTML="Hide Links";
		var cell_el = document.getElementById("td"+cid);
		cell_el.innerHTML += " <div id='theWrapperDiv"+cid+"' style='display:block'></div>";
		requestContent(cid);

	} 
}

var ajaxRequest;

function requestContent(contentID) {

  var url = "/tusk/ajax/getCollectionSubContent/"+contentID;

  if (window.XMLHttpRequest) {
      ajaxRequest = new XMLHttpRequest();
      nodeTextType = 'textContent';
  } else if (window.ActiveXObject) {
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      nodeTextType = 'text';
  } else {
	var location = document.URL;
	if(location.search(/\/content\//) != -1) {location = location.replace(/content/, 'contentSimple');}
	else {location = location+'?simple=1';}
	alert('You are being transfered because your browser does not support AJAX.');
	document.location = location;
  }

  ajaxRequest.open("GET", url, true);
  // the following trickery is interesting
  ajaxRequest.onreadystatechange = function() { if(ajaxRequest.readyState ==4) { showContent(contentID) } };;	
  ajaxRequest.send(null);

}

function showContent(contentID) {

  var id;  var title; var url;

  if(!ajaxRequest) {return;}
  if(ajaxRequest.readyState == 4) {
    var response = ajaxRequest.responseXML;
    if(!response) {
	
      if(ajaxRequest.status && (ajaxRequest.status == 200)) {
			alert('I was unable to get the subcontent of this item!');
		}
    }
    else {
      var subContents = response.getElementsByTagName('subContent');
      var myUL = document.createElement("UL");	

	  myUL.setAttribute("class","gNoTopMargin");  
	  document.getElementById("theWrapperDiv"+contentID).appendChild( myUL );

      for(var index=0; index<subContents.length; index++) {
        var id = 'Error';
        var title = 'Error';
        var url = 'Error';
	
        for(var index2=0; index2<subContents[index].childNodes.length; index2++) {
          var node = subContents[index].childNodes[index2];
          var nodeValue = '';
          if(node[nodeTextType]) {nodeValue = node[nodeTextType];}
          else if(node.firstChild && node.firstChild.nodeValue) {nodeValue = node.firstChild.nodeValue;}
          if(node.nodeName == 'id')             {id = nodeValue;}
          else if(node.nodeName == 'title')     {title = nodeValue;}
          else if(node.nodeName == 'url')       {url = nodeValue;}
    
        }

		var myLI = document.createElement("LI");
		var titleToDisplay = '<a href="'+url+'" target="_blank"><font class="">'+title+'</font></a>'; 
		myLI.innerHTML =titleToDisplay;
		myUL.appendChild(myLI);
					      
    }

    } //else (response exists)

  } // if readystate == 4

}


