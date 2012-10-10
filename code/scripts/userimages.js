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


function checkfiles(aform) {

	var check = aform.file;
	var extArray = new Array(".jpg", ".png", ".bmp", ".gif", ".jpeg");
	var maxSize = 4000000;
	var errArray = new Array();
	var errDiv = document.getElementById("errList");
	var gotError=0;

	aform.submit_btn.disabled=false;	
	errDiv.innerHTML="";

	
	for (var i=0; i<check.files.length; i++) {
		var extFailCount=0;
		var file = check.files[i];
		
		var myFileName = file.fileName.toLowerCase();
		

		for (var j=0; j < extArray.length; j++) {
			if (myFileName.lastIndexOf(extArray[j]) == -1){
					extFailCount++;
			}
		}// for loop extensions

		//if it's failed on all extension checks, ERROR
		if(extFailCount == extArray.length) { 
			errDiv.innerHTML+="File "+myFileName+" cannot be uploaded. Only files of type: "+(extArray.join(", "))+ " are allowed<br>";
			gotError++;
		}
		if (file.fileSize > maxSize) {
			errDiv.innerHTML+="File "+myFileName+" is too large, the maximum file size is 4 megabytes<br>";
			gotError++;
		}
		
	}// for loop
    
	if (gotError > 0){
		aform.submit_btn.disabled=true;
		errDiv.innerHTML+="<br>Please fix the above and try again";
	}

}