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


// A utility function that returns true if a string contains only 
// whitespace characters.
function isblank(s) {
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c != ' ') && (c != '\n') && (c != '\t')) return false;
    }
    return true;
}

// This is the function that performs form verification. It is invoked
// from the onsubmit event handler. The handler should return whatever
// value this function returns.
function verify(f) {
    var msg;
    var empty_fields = "";
    var errors = "";

    // Loop through the elements of the form, looking for all 
    // text and textarea elements that don't have an "optional" property
    // defined. Then, check for fields that are empty and make a list of them.
    // Also, if any of these elements have a "min" or a "max" property defined,
    // verify that they are numbers and in the right range.
    // If the element has a "numeric" property defined, verify that
    // it is a number, but don't check its range.
    // Put together error messages for fields that are wrong.
    for(var i = 0; i < f.length; i++) {
        var e = f.elements[i];
        if (((e.type == "text") || (e.type == "textarea")) && !e.optional) {
            // first check if the field is empty
            if ((e.value == null) || (e.value == "") || isblank(e.value)) {
                empty_fields += "\n          " + e.name;
                continue;
            }

            // Now check for fields that are supposed to be numeric.
            var emin = parseFloat(e.min);
            var emax = parseFloat(e.max);
            if (e.numeric || !isNaN(emin) || !isNaN(emax)) {
                var v = parseFloat(e.value);
                if (isNaN(v) ||
                    (!isNaN(emin) && (v < emin)) ||
                    (!isNaN(emax) && (v > emax))) {
                    errors += "- The field " + e.name + " must be a number";
                    if (!isNaN(emin))
                        errors += " that is greater than " + e.min;
                    if (!isNaN(emin) && !isNaN(emin))
                        errors += " and less than " + e.max;
                    else if (!isNaN(emax))
                        errors += " that is less than " + e.max;
                    errors += ".\n";
                }
            }
        }
    }

    // Now, if there were any errors, display the messages, and
    // return false to prevent the form from being submitted. 
    // Otherwise return true.
    if (!empty_fields && !errors) return true;

    msg  = "______________________________________________________\n\n"
    msg += "The form was not submitted because of the following error(s).\n";
    msg += "Please correct these error(s) and re-submit.\n";
    msg += "______________________________________________________\n\n"

    if (empty_fields) {
        msg += "- The following required field(s) are empty:" 
                + empty_fields + "\n";
        if (errors) msg += "\n";
    }
    msg += errors;
    alert(msg);
    return false;
}


/*   <javascript, the definitive guide>
 *   Here's a sample form to test our verification with. Note that we
 *   call verify() from the onsubmit event handler, and return whatever
 *   value it returns. Also note that we use the onsubmit handler as
 *   an opportunity to set properties of the form objects that verify()
 *   requires for the verification process. 
 *
 *   <form onsubmit="
 *   	this.firstname.optional = true;
 *	this.phonenumber.optional = true;
 *	this.zip.min = 0;
 *	this.zip.max = 99999;
 *	return verify(this);">
 
 *	First name: <input type="text" name="firstname">
 *	Last name: <input type="text" name="lastname"><br>
 *	Address:<br><textarea name="address" rows="4" cols="40"></textarea><br>
 * 	Zip Code: <input type="text" name="zip"><br>
 *	Phone Number: <input type="text" name="phonenumber"><br>
 *	<input type="submit">
 *   </form>
 */
