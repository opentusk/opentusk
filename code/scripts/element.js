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


function toggle_section (section_id){
        var found_end = 0;
        var counter = 0;
        var disp_text = 'foo';
        var div_tag;
        while (!found_end) {
                div_tag = toggle_row(section_id+"_"+counter);
                counter++;
                if (div_tag == null){
                        found_end = 1;
                }  else if (!div_tag){
                                disp_text = "expand section";
                        } else {
                                disp_text = "close section";
                        }

        }
        anchor_tag = document.getElementById(section_id+"-link");
        anchor_tag.innerHTML = disp_text;
        span_tag = document.getElementById(section_id+"-text");
	if (span_tag.style.visibility == 'hidden'){
		span_tag.style.visibility = 'visible';
	} else {
		span_tag.style.visibility = 'hidden';

	}
}

function display_row(row_id, flag){
	state = toggle_row(row_id);
	if (state != flag){
		state = toggle_row(row_id);
	}
	return state;
}


function toggle_row(row_id){
        var div_tag = document.getElementById(row_id);
        // toggle state returns the state that the function has moved the row to.
        // zero means that the row has just collapsed
        var toggle_state;
        var disp_value;

        if (is_ie){
                disp_value = "inline";
        } else {
                disp_value = "table-row";
        }

        if (div_tag == null){
                return null;
        } else {
                if ((div_tag.style.display == disp_value)
                        || (div_tag.style.display == '')){
                        div_tag.style.display = "none"
                        toggle_state = 0;
                } else {
                        div_tag.style.display = disp_value;
                        toggle_state = 1;
                }
        }

	// 1 indicates a expand occurred, 0 indicates a collapse occurred
        return toggle_state;
}

function dropdown_submit (formname) {
	document.forms[formname].submit();
}

function open_search(url,layer,name){
	var width = 600;
	var height = 500

        var param = "directories=no,menubar=no,toolbar=yes,"
		+"scrollbars=yes,resizable=yes,width="+ width  
		+",height=" + height;
        window.open(url+"?layer=" 
		+ layer.structure.name, name, param);
}

function save_and_continue(formname,next_page,id,addtl_code){
	if (document.forms[formname] != null ){
		if (id != null && id != ''){
			document.forms[formname].elements['next_page'].value = next_page + '/'+id;
		} else {
			document.forms[formname].elements['next_page'].value = next_page ;
		}
		// if we have an onsubmit defined...
		if (document.forms[formname].onsubmit) {
			// fire the onsubmit
			if (document.forms[formname].onsubmit()) {				
				document.forms[formname].submit();
			}
		}
		else {
			// otherwise, just submit the form
			document.forms[formname].submit();
		}
		if (addtl_code != null) {
			eval(addtl_code);
		}
	} else {
		alert('Invalid formname '+formname+' passed to save_and_continue');
	}


}

// function used for security notices
function close_notice(){
	document.getElementById('notice_securitynotice').style.display="none";
	document.getElementById('notice_content').style.display="block";
	return false;
}

function toggle_link(rowid,leftnav){
        var elem = document.getElementById(rowid+'-img');
        if (elem == null){
                alert('element not found for toggle_link');
                return;
        }
        var expand_occurred = toggle_row(rowid);
        if (expand_occurred){
		if (leftnav != null){
			elem.src = '/graphics/case/sb_arrowOpen.gif';	
		} else {
			elem.src = '/graphics/case/arrowOpen.gif';
		}
        } else {
		if (leftnav != null){
			elem.src = '/graphics/case/sb_arrowClose.gif';	
		} else {
			elem.src = '/graphics/case/arrowClose.gif';
		}
        }
}