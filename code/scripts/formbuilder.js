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
	if (form.field_type_id.value && form.field_type_id.value == '#'){
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
		document.getElementById(id + '_selected').value = 1;
	}else{
		document.getElementById(id).className = 'unselected';
		document.getElementById(id + '_selected').value = 0;
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

function check_required_fields(form, required_array){

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

	for (var i=0; i < required_array.length; i++){
		var obj = document.getElementById(required_array[i]['id']);
		if (obj.nodeName == 'SELECT') {
			if (obj.selectedIndex == 0){
				alert('Please enter a value for ' + required_array[i]['message']);
				document.getElementById(required_array[i]['id']).focus();
				return false;
			}
		} else if (obj.nodeName == 'INPUT') {
			var checklist = document.getElementById(required_array[i]['id']);
			if (checklist && checklist.value > 0) {
				alert('Please complete the checklist for ' + required_array[i]['message']);
				return false;
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


