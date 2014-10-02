// TUSK Customizations
// add CSS for inside CKEDITOR editor
// done this way so that there is no delay between editors being loaded and CSS being applied 
CKEDITOR.on( 'instanceCreated', function( ev ) {
	this.document.appendStyleSheet('/style/ckeditor.css');
});

