
function check_userid(){
	var user_fld = document.getElementById('userid'); 
	var err_elt = document.getElementById('errmsg');
	var err_flag = false;

	if(!user_fld.value){
		err_elt.innerHTML = 'Please enter a value for UserID';
		err_flag = true;
	}
	if(user_fld.value.indexOf("\/") > 0){
		err_elt.innerHTML = 'UserID cannot contain a forward slash "/"';
		err_flag = true;
	}
	if(err_flag){
		show(err_elt);
		user_fld.focus();
		return false;
	}
}