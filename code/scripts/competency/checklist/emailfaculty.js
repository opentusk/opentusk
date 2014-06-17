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
	$('#to').on('change', function() {
		if (this.value == 'other') {
			$('#otherbox').show('slow');
		} else {
			$('#otherbox').hide('slow');
			$('#other_to').val("");
		}
	});

	$("#emailfaculty").validate({
		rules: {
			other_to: {
				email: true,
				required: {
					depends: function() {
						return ($('#to').val() == 'other') ? true : false;
					}
				}
			},
		},
		messages: {
			other_to: "Please enter a valid email address",
		}
	});
});









