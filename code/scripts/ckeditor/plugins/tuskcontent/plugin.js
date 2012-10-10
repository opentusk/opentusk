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

