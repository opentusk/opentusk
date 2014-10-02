/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For the complete reference:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config
	config.resize_dir = 'both';
	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'styles'},
		{ name: 'basicstyles', groups: ['basicstyles', 'cleanup'] },
		{ name: 'colors', groups: ['TextColor','BGColor'] },
		{ name: 'insert', groups: ['Image','Flash','Table','HorizontalRule'] },
		{ name: 'others' },
		{ name: 'links' },
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align'] },
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing',     groups: ['find', 'selection', 'spellchecker', 'scayt'] },
		{ name: 'document',	   groups: [ 'mode', 'document', 'doctools' ] }
	];
	// Remove some buttons, provided by the standard plugins, which we don't
	// need to have in the Standard(s) toolbar.
	config.removeButtons = 'Forms,Smiley,SpecialChar,Strike,Cut,Copy,NewPage,Print,Templates,Anchor';

	// Se the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre';
	config.allowedContent = true;
	// Adjust the skin 
	config.skin = 'kama';
	
	// Make dialogs simpler.
	config.removeDialogTabs = 'image:advanced;link:advanced';

	// Customize toolbar customizations
	config.toolbar_TUSK_min = [];
};

