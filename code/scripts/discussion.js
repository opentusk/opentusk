function verifyDiscussionAddedit(form) {
	if(!form.title.value) {
		alert('Please enter a discussion title.');
		return false;
	}
	return true;
} 
