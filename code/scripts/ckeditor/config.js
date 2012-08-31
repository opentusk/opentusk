// make customizations to the definition of existing dialogs
CKEDITOR.on( 'dialogDefinition', function( ev ) {
	// take the dialog name and its definition from the event data
	var dialogName = ev.data.name;
	var dialogDefinition = ev.data.definition;

	// remove "advanced" tabs from dialogs
	if ( dialogName == 'image' || dialogName == 'flash' || dialogName == 'table' || dialogName == 'link' ) {
		dialogDefinition.removeContents( 'advanced' );
	}
});

CKEDITOR.editorConfig = function( config ) {	
	// custom TUSK toolbar
	config.toolbar_TUSK =
	[
		{ name: 'styles',      items : [ 'Styles','Format','Font','FontSize' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','Subscript','Superscript' ] 	},
		{ name: 'colors',      items : [ 'TextColor','BGColor','RemoveFormat' ] },
		{ name: 'insert',      items : [ 'Tuskcontent', 'Image','Flash','Table','HorizontalRule','SpecialChar' ] },
		{ name: 'paragraph',   items : [ 'NumberedList','BulletedList','Blockquote','-','Outdent','Indent','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ] },
		{ name: 'links',       items : [ 'Link','Unlink' ] },
		{ name: 'clipboard',   items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
		{ name: 'editing', 	   items : [ 'Find','Replace','-','SelectAll','-','Scayt' ] },
		{ name: 'document',    items : [ 'Source','Preview' ] },
		{ name: 'info',        items : [ 'About' ] },	
	];

	config.toolbar_TUSK_min = [];
};
