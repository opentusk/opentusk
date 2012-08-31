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


$(document).ready(function() {
	$(window).bind("load", function() {
		showhidetable('reportdiv1');
	});
});

// variable and function to show/hide category tables
var visible = "reportdiv1";

function showhidetable(id) {
	if (visible == "all") {
		$('.reportdiv').hide();
		$("#reportdiv1").show();
		$("#showhidebutton").attr("value","show all");
		$("#showhidetable").attr("disabled", "");
		id = "reportdiv1";
	}
	else if (id == "all") {
		$("#showhidebutton").attr("value","show only one");
		$('.reportdiv').show();
		$("#showhidetable").val("reportdiv1")
		$("#showhidetable").attr("disabled", "disabled");
	}
	else {
		$('.reportdiv').hide();
		$("#" + id).show();
		$("#showhidebutton").attr("value","show all");
		$("#showhidetable").attr("disabled", "");
	}
	visible = id;
	return false;
}
