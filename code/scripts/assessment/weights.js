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


$(function() {
	sumup();
	$('input.weight').bind('keyup', function() {
		sumup();
	});
});

function sumup() {
	var my_total_weight = $('input.weight').sumValues();
	$('#totalweighttext').html(my_total_weight);
	$('#total_weight').val(my_total_weight);
	if (my_total_weight == 100) {
		$('.error').hide();
	} else {
		$('.error').show();	
	}
}


$.fn.sumValues = function() {
 	var sum = 0; 
	this.each(function() {
		var val = ($(this).is(':input')) ? $(this).val() : $(this).text();
		sum += parseFloat( ('0' + val).replace(/[^0-9-\.]/g, ''), 10 );
	});
	return sum;
}




