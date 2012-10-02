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


function isValidDate(m, d, y){

	m--;

	var months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	if(y>999 && y<10000){
		if(isLeapYear(y)){
			months[1] = 29;
		}
		if(m>=0 && m<12){
			if(d>0 && d<=months[m]){
				return true;
			}
		}
	}
	return false;
}

function isLeapYear(year){
	if(year%4 == 0){ // could be leap year
		if(year%100 || (year%100 == 0 && year%400 == 0)){
			return true;
		}
	}
	return false;
}

function submit_with_action ( newaction )
{
	document.forms[0].action = newaction;
	document.forms[0].submit();
	return false;
}
