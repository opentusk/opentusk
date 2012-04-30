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



function changeSearch(isAdvanced) {
		if(isAdvanced) {
			document.getElementById('regularForm').style.display = 'none';
			document.getElementById('advancedForm').style.display = '';
		} else {
			document.getElementById('advancedForm').style.display = 'none';
			document.getElementById('regularForm').style.display = '';
		}
}
		
function do_keyword(){
	document.forms.search.make_keyword.value = 1;
	document.forms.search.submit();
}

function definition(layer, index){
	if (layers[layer].structure.data[index]['definition']){
		var RExp = /<% $umlsNewlineEscape %>/g;
		var defn = layers[layer].structure.data[index]['definition'].replace(RExp,"\n");
		alert(defn);
	}else{
		alert("No definition.");
	}
}