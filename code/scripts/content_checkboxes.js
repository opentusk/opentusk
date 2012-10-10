function formsubmit(action){
	flag = false;
	if (document.content.content.length){
		for (i=0; i<document.content.content.length;i++){
			if (document.content.content[i].checked){
				flag = true;
			}
		}
	}else{
		if (document.content.content.checked){
			flag = true;
		}
	}
	if (flag == false){
		alert('Please check at least one piece of content.');
		return;
	}
	document.content.action=action;
	document.content.submit();
}