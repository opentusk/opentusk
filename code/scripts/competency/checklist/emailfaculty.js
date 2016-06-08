// Copyright 2014 Tufts University 
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


function showOther(pathIds) {

    var theBox = $("#otherbox").dialog({
        autoOpen: false,
        position: [ 'top', 100 ],
        title: 'Add Assessor',
        draggable: false,
        width : 450,
        height : 180, 
        resizable : false,
        modal : true,
        closeOnEscape: false,
        open: function(event, ui) {
            $(".ui-dialog-titlebar-close", ui.dialog | ui).hide();
        	$('#addassessor').validate({
        		rules: {
		        	email: { required : true },
        			firstname: { required : true },
        			lastname: { required : true }
    		}
	        });
        },
        buttons: {
            Add: function() {
                 $.ajax({
                    url     : '/competency/checklist/student/addassessor/course/' + pathIds,
                    type    : 'POST',
                    data    : $("#addassessor").serialize(),
                    success : function(resp) {
                        if ($('#addassessor').valid()) {
                            $('#addassessor').hide();
                            $('#results').html(resp);
                            $('.ui-button:contains(Add)').hide();

                            var html = $.parseHTML(resp);
                            var newUserToken = $(html).filter('#new_user_token').text();
                            if (newUserToken) {
                                $('#to').append('<option value="' + newUserToken + '" selected="selected">' + $(html).filter('#new_user_name').text() + '</option>');
                            }
                        }
                    },
                    error   : function(resp){
                        $('#result').html(resp);
                    }
                 });
            },
            Close: function() {
                $(this).dialog( "close" );
                if ($('#addassessor').is(':visible') === false) {
                    $('#addassessor').show();
                    $('#results').hide();
                    $('.ui-button:contains(Add)').show();
                }
            }
        }
    });

    $("#otherbox").load('/competency/checklist/student/addassessorform/course/' + pathIds, function() {
            theBox.dialog("open");
    });
}





