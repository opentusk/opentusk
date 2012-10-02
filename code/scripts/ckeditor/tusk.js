// add CSS for inside CKEDITOR editor
// done this way so that there is no delay between editors being loaded and CSS being applied 
CKEDITOR.on( 'instanceCreated', function( ev ) {
	ev.editor.addCss("body{font-family:Arial,Verdana,sans-serif;font-size:12px;color:#222;background-color:#fff;}\nol,ul,dl{*margin-right:0px;padding:0 40px;}");
});
