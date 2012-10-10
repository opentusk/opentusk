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
            if (e.numeric || (e.min != null) || (e.max != null)) { 
                var v = parseFloat(e.value);
                if (isNaN(v) || 
                    ((e.min != null) && (v < e.min)) || 
                    ((e.max != null) && (v > e.max))) {
                    errors += "- The field " + e.name + " must be a number";
                    if (e.min != null) 
                        errors += " that is greater than " + e.min;
                    if (e.max != null && e.min != null) 
                        errors += " and less than " + e.max;
                    else if (e.max != null)
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
