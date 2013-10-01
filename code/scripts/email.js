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
	$('#emailsubmit').click(function() {
		if (!$('input[name="to"]:checked').length) {
			alert(_('Please select at least one email recipient.'));
			return false;
		}

		if (confirm(_("Are you sure you want to send this email?")) == false) {
			return false;
		}
	});

	$("input[name='checkall']").click(function() {
		var newval = $(this).attr('checked');
		$("input[name='to']").each(function() {
			$(this).attr('checked', newval);
		});
	});

	$("input[name='to']").click(function() {
		var checkall_flag = true;
		$("input[name='to']").each(function() {
			if ($(this).attr('checked') == false) {
				checkall_flag = false;
				return;
			}
		});
		$("input[name='checkall']").attr('checked', checkall_flag);
	});

});

