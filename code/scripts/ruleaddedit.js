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


var new_rule_markup;			// store markup for additional rules
var new_rule_count = 1;			// to make ids of new rules unique
var ajax_cache = [];	// cache our ajax calls so we don't need to repeat
var retake_quiz_alerted = new Object();	// keep track of whether we have alerted user to need to set 'retake quiz'

$(document).ready(function() {
	new_rule_markup = $('div#crWrapperNewRule0').html();

	// if we only have one crRuleDef, it is our default blank one, show it.
	// if we have more than one, keep this blank rule hidden
	if ($('.crRuleDef').length == 1) {
		$('div#crWrapperNewRule0').css('display', 'block');
	}

	// make header of new operand draggable handle
	$('div#crNewOperand').draggable({handle: 'h4#crSelItmHdr'}); 
});

// if new operand is desired for a rule, show the operand 'popup' and
// block interaction with rest of page with 'curtain'
function addOperand(link) {
	$('div#crNewOperand').get(0).caller = link;

	$('div#crNewOperand').css({
		position: 'absolute',
		display: 'block',
		top: $(link).offset().top,
		left: $(link).offset().left,
		width: $(link).width(),
		height: $(link).height(),
		overflow: 'hidden',
		padding:0,
		'z-index': '20'
	});

	$('div#crNewOperand').animate({
		height: 300,
		width: 420,
		top: $(link).offset().top - 10,
		left: $(link).offset().left - 10
	}, 1000);

	$('div#crCurtain').css({
		position: 'fixed',
		display: 'block',
		'background-color': '#1f1f1f',
		'z-index':15,
		opacity: 0.5
	});
}

/* 
// if first rule (with id of 0) is not visible, make it so and return.
// otherwise, get markup for a new rule, put the appropriate index on it 
// and insert it into DOM
*/
function addRuleDef(elt) {
	if ($('div#crWrapperNewRule0').css('display').match(/none/i)) {
		$('div#crWrapperNewRule0').css('display', 'block');
		return;
	}
	var this_rule = new_rule_markup.replace(/NewRule0/g, 'NewRule' + new_rule_count++);
	$(elt).parent().before(this_rule);
}


function delrule(elt, alt_msg) {
	var warning = (alt_msg)? alt_msg : 'Are you sure you want to delete this rule?';

	if(confirm(warning)){
		$(elt).remove();
	}
}


function delElt(layer, index) {
	if (layers[layer].structure.data.length > 1) {
		remove(layer, index);  
	}
	else {
		// if there is only one element left in s.o. box, don't call remove() on it, 
		// just remove the rule from the dom. if the rule, itself, is removed, that will
		// ensure that all of its elements are removed, as well.
		var rule_id = layer.match(/^rule(.*)div$/)[1];
		var rule_elt = document.getElementById('ruleSec' + rule_id);
		var msg = 'You are attempting to delete the last element of a rule; this will effectively delete the rule. Would you like to continue?';
		delrule(rule_elt, msg);
	}
}


/* shrink new operand window into button and 'raise' the curtain blocking
   interaction with rest of page */
function closeNewOp() {
	// first, set crStep1 dropdown back to value-less, neutral selection
	// this will cascade to removing data from crStep2 and crStep3 (if applicable)
	var dd = $('select#rule_phase').get(0);
	dd.selectedIndex = 0;
	dd.onchange();

	var caller = $('div#crNewOperand').get(0).caller;

	$('div#crNewOperand').animate({
		height: ( $(caller).outerHeight() ),
		width: ( $(caller).outerWidth() ),
		top: $(caller).offset().top,
		left: $(caller).offset().left
	}, 1000, function() { 
		$(this).animate({
			opacity: 'hide'
		}, 200, function() {
			$('div#crCurtain').css('display', 'none');
			})
	});
}


function saveNewOp(){
	var caller = $('div#crNewOperand').get(0).caller;
	var parentDiv = $(caller).parents('.crRuleDef').get(0);

	var phase_id, parent_lbl, elt_id, elt_lbl, elt_type_id, relation_type_id, relation_value;
	
	phase_id = $('select#rule_phase').children(':selected').attr('value');

	if (!phase_id) {
		alert("At a minimum, you must select at least one phase for the rule.");
		return;
	}

	var parent_lbl = $('select#rule_phase').children(':selected').html();

	// this var will hold a jquery obj of 1 to n elements
	// get selected tests/treatments/quiz questions from appropriate phase/quiz
	var child_elts = $('ul.selectlist-list input[type="hidden"][value!=""]');

	if ($('select#quiz_alt').size()) {
		if ( !($('select#quiz_alt').children(':selected').attr('value')) ) {
			alert("You must select an option from 'Step 2'");
			return;
		}

		// quizzes are a child of a phase, so we partner phase and quiz ids in one 
		// id. to wit, quizzes have a value in the 'rule_phase' dropdown that is phase_id-quiz_id
		// this replace will do nothing to all other <option> values since none of them 
		// *should* match the regex.
		var quiz_id = phase_id.replace(/\d+-/,'');
		phase_id = phase_id.replace(/-\d+/,'');

		if ($('select#quiz_alt').children(':selected').attr('value') == 'completion') {
			elt_id = quiz_id;
			elt_lbl = '';
			elt_type_id = $('select#quiz_alt').children(':selected').attr('class').replace(/type_/,'');
		}
		else if ($('select#quiz_elt').size()) {
			if ( !($('select#quiz_elt').children(':selected').attr('value')) ) {
				alert("You must select at least one option from 'Step 3'");
				return;
			}
		}
		else if ($('input#min_score').length) {
			if ( !($('input#min_score').attr('value')) || $('input#min_score').attr('value').match(/\D/) ) {
				alert("You must insert a numeric value for 'Step 3'");
				return;
			}
			if ( $('input#min_score').attr('value') > 100 ) {
				alert("The minimum score must be 100 or less.");
				return;
			}
			elt_id = quiz_id;
			elt_lbl = 'Quiz Score >= ' + $('input#min_score').attr('value') + '%';
			var class_str = $('input#min_score').attr('class');
			elt_type_id = class_str.replace(/type_(\d+)_relate_\d+/,"$1");
			relation_type_id = class_str.replace(/type_\d+_relate_(\d+)/,"$1"); 
			relation_value = $('input#min_score').attr('value'); 
		}
	}

	// if we have at least one element from our drop down lists of phase elements or quiz elements...
	if (child_elts.length) {
		var id = parentDiv.id.replace(/^ruleSec/,'');
		var has_duped_data = 0;

		// add them one at a time to s.o. box.
		child_elts.each(function(){	
			elt_lbl = $(this).parent().text();
			elt_type_id = $(this).attr('class').replace(/type_/,'');

			var success = adduniquedata('rule' + id + 'div', { 
				'phase_id':         phase_id,
				'parent_label':     parent_lbl, 
				'elt_id':           this.value,
				'elt_label':        elt_lbl, 
				'elt_type_id':      elt_type_id, 
				'relation_type_id': relation_type_id, 
				'relation_value':   relation_value 
			});
			if (!success) {
				has_duped_data = 1;
			}
		});
	}
	// else, we're a score, or a phase/quiz completion rule
	else {
		var id = parentDiv.id.replace(/^ruleSec/,'');
		var has_duped_data = 0;
alert(elt_id);
		// in adduniquedata(), we want to compare following vals. due to s.o.box, existing, 
		// undefined vals from db will be '', but new ones, just created, will be undef. they will
		// not be equal. set undef values to empty string here for that comparison later.
		elt_id = elt_id || '';
		elt_type_id = elt_type_id || '';

		var success = adduniquedata('rule' + id + 'div', { 
			'phase_id':         phase_id,
			'parent_label':     parent_lbl, 
			'elt_id':           elt_id, 
			'elt_label':        elt_lbl, 
			'elt_type_id':      elt_type_id, 
			'relation_type_id': relation_type_id, 
			'relation_value':   relation_value 
		});
		if (!success) {
			has_duped_data = 1;
		}
	}

	if (has_duped_data) {
		alert('You attempted to add at least one option that was already present in your rule. Any previously selected options will not be duplicated in the rule.'); 
	}
	closeNewOp();
}


function adduniquedata(layer, newdata) {
	var curdata = layers[layer].structure.data;
	var is_duplicate = 0;

	for (i=0; i<curdata.length; i++){
		if (curdata[i].phase_id == newdata.phase_id && 
		    curdata[i].elt_type_id == newdata.elt_type_id &&
		    curdata[i].elt_id == newdata.elt_id) {
				is_duplicate = 1;
		}
	}
	if (!is_duplicate) {
		addnewdata(layer, newdata);
		return 1;
	}
	else {
		return 0;
	}
} 


function popNextStep(elt, type_path, pop_elt_id) {
	// this check makes sure that the option we selected is not disabled.
	// if it is disabled, we will alert and reset selection.
	isEnabled(elt);

	var type = $(elt).children(':selected').attr('class').replace(/_opt/,'');
	var id   = $(elt).children(':selected').attr('value');

	// quizzes are a child of a phase, so we partner phase and quiz ids in one 
	// id. to wit, quizzes have a value in the 'rule_phase' dropdown that is phase_id-quiz_id
	// this replace will do nothing to all other <option> values since none of them 
	// *should* match the regex.
	id = id.replace(/\d+-/, '');

	// we don't need to retrieve any additional data via ajax if user selected 
	// quiz completion, so just get out of here.
	if (id == 'completion') {
		// in case step 3 has quiz question data from a previous selection in step 2, clear
		// it out now.
		$('#' + pop_elt_id).html('');
		return;
	}

	// if we have an id, we need to retrieve children elements from get_elements,
	// and then put the children in dropdown for selection
	if (id) {
		var date = new Date();
		var page_args = type_path +'/'+ $('input#key_id').attr('value') +'/'+ type +'/'+ id;

		$("#" + pop_elt_id).load('/case/author/get_elements/' + page_args + '?' + date.getTime(), function(response, status, xhr) {
			if (status == "error") {
				var msg = "Sorry but there was an error: ";
				$("#" + pop_elt_id).html(msg + xhr.status + " " + xhr.statusText);
			}

			// attach the selectlist functionality to dropdown
			$('#' + pop_elt_id + ' > select[multiple]').selectList({
				onAdd: function (select, value, text) {
					var item = $('ul.selectlist-list li:last-child');
					// all option elts have same class that indicates the id of type of elements
					// in dropdown. i should say, all have same class except for first one, which is 
					// generated by selectlist and has no class.
					// therefore, just get class of last element, as it will be guaranteed to be what we need.
					var type = $('select.selectlist-select').children('option:last').attr('class');
					if (type) {
						$(item).append('<input type="hidden" name="' + $(select).attr('name') + '" value="' + value + '" class="' + type + '" >');
					}
					else {
						$(item).append('<input type="hidden" name="' + $(select).attr('name') + '" value="' + value + '">');
					}
					// add the "operand type" as class so we can retrieve it when putting element 
					// in sort order box.
				}
			}); 
		});		
	}
	// if no id from dropdown, we selected the default, 'no option' option, so clear 
	// the dropdown of the 'next step' of any sub elements that were present before.
	else {
		$('#' + pop_elt_id).html('');
	}
	if (pop_elt_id == 'crStep2') {
		$('#crStep3').html('');
	}
}


function warnRetakeThenPop(elt, type_path, pop_elt_id){
	var type = $(elt).children(':selected').attr('class').replace(/_opt/,'');	

	// quizzes are a child of a phase, so we partner phase and quiz ids in one 
	// id. to wit, quizzes have a value in the 'rule_phase' dropdown that is phase_id-quiz_id
	// this replace will do nothing to all other <option> values since none of them 
	// *should* match the regex.
	var id   = $(elt).children(':selected').attr('value');
	id = id.replace(/\d+-/, '');

	if ((type == 'quiz_elt' || type == 'score') && !retake_quiz_alerted[id]) {
		alert('You are attempting to create a rule that requires a specific performance on a quiz; it is highly suggested that you enable the option to retake a quiz in order to allow users another chance to satisfy your rule should they fail to satisfy it in their first attempt.');
		retake_quiz_alerted[id] = true;
	}
	popNextStep(elt, type_path, pop_elt_id);
}


function validateRuleForm(myform) {
	var valid_form = true;

	// make sure that for each authored rule, we have at least one operand and 
	// a message.
	$(myform).find('.crRuleDef:visible').each(function(index) {
		var inputs = $(this).find('input[name*="parent_label"]');
		if (!inputs.length) {
			valid_form = false;
		}
		if (CKEDITOR.instances[$(this).find('.crRuleMsg').attr('name')].getData().match(/^\s*$/)) {
			valid_form = false;
		}
	});


	if (valid_form) {
		return true;
	}
	else {
		alert('Each rule must have a message and must be composed of at least one required phase or phase element.');
		return false;
	}
}