// Copyright 2016 Tufts University 
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
    $("input[name=submit_import]").click(process);
});

function process() {
    if ($("input[type=file]").val() === '') {
        alert('Please select a file to upload');
        return false;
    }

    $("#loadingCourseUsers").show();  
    $("#results").hide();

    $.ajax({
        url: $("input[name=results_url]").val(),
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false,
        dataType: 'html',
        data: new FormData($("#import_course_users")[0]),
        success: function(response) {
            $("#loadingCourseUsers").hide();  
            $('#results').html(response);
            $("#results").show();   
        },
		error: function(xhr, status, error) {
            $("#loadingCourseUsers").hide();  
            console.log('Error: ' + error);
        }
    });
    return false;
}
