CKEDITOR.plugins.add( 'tuskcontent',
{
	init: function( editor )
	{	
		editor.addCommand( 'tuskImageDialog', new CKEDITOR.dialogCommand( 'tuskImageDialog' ) );
		editor.ui.addButton( 'Tuskcontent',
		{
			label: 'Insert TUSK image content',
			command: 'tuskImageDialog',
			icon: this.path + 'images/tuskicon.png'
		} );

		//Plugin logic goes here.
		CKEDITOR.dialog.add( 'tuskImageDialog', function( editor )
		{
			return {
				title : 'Select TUSK Image content',
				minWidth : 300,
				minHeight : 100,
				contents :
				[
					{
						id : 'general',
						label : 'Properties',
						elements :
						[
							{
								type : 'html',
								html : 'If you know the content ID, enter it in the field below.<br />Otherwise, <a href="#" onclick="open_window(\'/management/searchpages/content/?pageId=general&elementId=content_id&media_type=Slide\',\'directories=no,menubar=no,toolbar=no,scrollbars=yes,resizable=yes,width=700,height=750\')">search for the content</a> you want to insert.'		
							},
							{
								type:'hbox',
								widths:['30%','30%'],
								padding: '10',
								children:
								[
									{
										type : 'text',
										id : 'content_id',
										label : 'Content ID #',
										validate : CKEDITOR.dialog.validate.notEmpty( 'Content ID is required.' ),
										required : true
									},
									{
										type : 'select',
										id : 'size',
										label : 'Image Size',
										validate : CKEDITOR.dialog.validate.notEmpty( 'Please pick a size.' ),
										items : 
										[
											[ '', '' ],
											[ 'icon', 'icon' ],
											[ 'thumb', 'thumb' ],
											[ 'small', 'small' ],
											[ 'medium', 'medium' ],
											[ 'large', 'large' ],
											[ 'xlarge', 'xlarge' ],
											[ 'orig', 'orig' ]
										]
									}
								]
							}
						]
					}
				],
				onOk : function()
				{
					editor.insertHtml( '<img src="/' + this.getValueOf('general', 'size') + '/' + this.getValueOf('general', 'content_id') + '" />' );
				}
			};
		});
	}
} );

