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


function searchresult_edit(layer,id){
        var pk ;
        if (layer == 'resultsdiv'){
                pk = layers[layer].structure.data[id].result_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/management/searchresult/resultaddedit/"+context_path+"/"+pk;
                } else {
			alert("No pk for that search result :"+pk);
		}
        } else {
		alert("function called with improper div : "+layer);
	}
}

function searchresult_remove(layer,id){
        var pk ;
        if (layer == 'resultsdiv'){
                pk = layers[layer].structure.data[id].result_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/management/searchresult/resultdelete/"+context_path+"/"+pk;
                }  
        }
}

function addToLayer(newdata){
        layers['termdiv'].adddata(newdata,0);
}

function addDefaultToLayer(){
        addToLayer({ search_term:'',term_id:'0'});
}

function viewResults(layer,id){
        var pk ;
        if (layer == 'searchesdiv'){
                pk = layers[layer].structure.data[id].search_query_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/tusk/search/form/"+pk;
                }
        }
}

function resultsSelect(dropdownName){

        var dropdown = document.getElementById(dropdownName);
        if (dropdown == null){
                alert("invalid id sent to resultsSelect");
                return;
        }
	var dropdownValue = dropdown.options[dropdown.options.selectedIndex].value;
        if (dropdownValue == ""){
                return; 
        }
	window.location = "/tusk/search/mysearches?limit="+dropdownValue;

}

function refineResults(layer,id){
        var pk ;
        if (layer == 'searchesdiv'){
                pk = layers[layer].structure.data[id].search_query_id;
                context_path = layers[layer].structure.context_path;
                if(pk != null && pk != ''){
                        window.location = "/tusk/search/form/"+pk+"?refine=1";
                }
        }

}
