# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package HSDB4::XML::Content;

use strict;
require HSDB4::XML;

# Shorthand for the XML types
my $simple = 'HSDB4::XML::SimpleElement';
my $attr = 'HSDB4::XML::Attribute';
my $element = 'HSDB4::XML::Element';

# Sections look like...
#   <section section_title="This is the title"> ... </section>
#
my $sec_title = $attr->new (-name => 'section_title',
			    -label => 'Section Title',
			    -required => 1,
			    );
my $section = $simple->new (-tag => 'section', -label => 'Section Text',
			    -attributes => [ $sec_title ],
			    -dtd_definition => '%Flow;',
			    );
# Summary looks like...
#   <summary> ... </summary>
#
my $summary = $simple->new (-tag => 'summary', -label => 'Summary',
			    -dtd_definition => '%Flow;');

# Questions
#   <question_info>
#     <choice label="A"> ... </choice>
#     <response label="A"> ... </response>
#     <correct_answer> ... </correct_answer>
#   </question_info>
my $label = $attr->new (-name => 'label', -label => 'Label', -required => 1);
my $choice = $simple->new (-tag => 'choice', -label => 'Question Choice',
			   -dtd_definition => '%Flow;',
			   -attributes => [ $label ] );
my $response = $simple->new (-tag => 'response', -label => 'Response',
			     -dtd_definition => '%Flow;',
			     -attributes => [ $label ] );
my $answer = $simple->new (-tag=>'correct_answer', 
			   -label=>'Correct Answer',
			   -dtd_definition => '%Flow;');
my $question = [  [ $choice,   0, 0 ],    # As many choices as necessary
		  [ $response, 0, 0 ],    # As many responses as necessary
		  [ $answer,   1, 1 ]  ]; # One and only one answer
my $question_info = $element->new (-tag => 'question_info',
				   -label => 'Question Information',
				   -subelements => $question);

# Slides
#   <slide_info preferred_size="large|small">
#     <stain> ... </stain>
#     <image_type> ... </image_type>
#     <overlay> ... </overlay>
#   </slide_info>
my $size = $attr->new (-name => 'preferred_size', -label => 'Preferred Size',
		       -choices => { large => 'Large', small => 'Small' },
		       -default => 'large');
my $stain = $simple->new (-tag => 'stain', -label => 'Stain');
my $image_type = $simple->new (-tag => 'image_type', -label => 'Image Type');
my $overlay = $simple->new (-tag => 'overlay', -label => 'Overlay');
# stain and image_type are both single and optional
my $slide_info = $element->new (-tag=>'slide_info',-label=>'Slide Information',
				-attributes => [ $size ],
				-subelements => [ [ $stain ],
						  [ $image_type ],
						  [ $overlay ] ] );

# Shockwave
#    <shockwave_uri width="..." height="..."> ... </shockwave_uri>
my $w = $attr->new (-name => 'width', -label => 'Width', -required => 1);
my $h = $attr->new (-name => 'height', -label => 'Height', -required => 1);
my $displaytype = $attr->new (-name => 'display-type', -label => 'Display Type', -required => 0);
my $shockwave = $simple->new (-tag => 'shockwave_uri', 
			      -label => 'Shockwave URI',
			      -attributes => [$w, $h, $displaytype] );

# Flashpix
#    <flashpix_uri> ... </flashpix_uri>
my $flashpix = $simple->new (-tag => 'flashpix_uri', 
			      -label => 'Flashpix URI');

# Video Clip
#    <realvideo_uri> ... </realvideo_uri>

my $width = $attr->new (-name => 'width', -label => 'Width', -required => 0);
my $height = $attr->new (-name => 'height', -label => 'Height', -required => 0);
my $autoplay = $attr->new (-name => 'autoplay', -label => 'Autoplay', -required => 0);
my $f_displaytype = $attr->new (-name => 'display-type', -label => 'DisplayType', -required => 0);

my $video = $simple->new (-tag => 'realvideo_uri', 
			  -label => 'Video URI',
			  -attributes => [$width, $height, $autoplay, $f_displaytype]);

# Realaudio Clip
#    <realaudio_uri> ... </realaudio_uri>
my $realaudio = $simple->new (-tag => 'realaudio_uri', 
			      -label => 'RealAudio URI',
			      -attributes => [$autoplay]);

# URL
#    <external_uri> ... </external_uri>
my $url = $simple->new (-tag => 'external_uri', -label => 'External URI');

# PDF
#    <pdf_uri> ... </pdf_uri>
my $pdf = $simple->new (-tag => 'pdf_uri', -label => 'PDF URI');

# DownloadableFile
#    <file_uri> ... </file_uri>
my $downloadablefile = $simple->new (-tag => 'file_uri', -label => 'File URI');

# Raw HTML looks like...
#   <html> ... </html>
#
my $html = $simple->new (-tag => 'html', -label => 'Raw HTML');

my $source = $simple->new (-tag => 'source', -label => 'Source');
my $indexOn = $simple->new (-tag => 'indexOn', -label => 'Index On');
my $contributor = $simple->new (-tag => 'contributor', 
				-label => 'Contributor');

#             Tag             Min   Max
#             --------------  ---   ---
my $body = [ [$summary,        0,    1  ],  # A single optional summary
	     [$section,        0,    0  ],  # As many option sections
	     [$question_info,  0,    1  ],  # A single optional question
	     [$slide_info,     0,    1  ],  # A single optional slide_info
	     [$flashpix,       0,    1  ],
	     [$video,          0,    1  ],
	     [$realaudio,      0,    1  ],
	     [$url,            0,    1  ],
	     [$pdf,            0,    1  ],
	     [$shockwave,      0,    1  ],
	     [$downloadablefile,      0,    1  ],
	     [$source,         0,    1  ],
	     [$contributor,    0,    1  ],
	     [$indexOn,        0,    1  ],
             [$html,           0,    1  ] ]; # And a single raw HTML section
my $body_dtd = 'summary?, section*,  (question_info|slide_info|flashpix_uri|realvideo_uri|realaudio_uri|external_uri|pdf_uri|shockwave_uri|file_uri)?, source?, contributor?, html?, indexOn?';
my $body_preface = q[<!-- This DTD relies on the W3C's XHTML DTD -->
<!ENTITY % xhtml SYSTEM "http://www.w3.org/TR/xhtml1/DTD/strict.dtd">
%xhtml;
];

my $content_body = $element->new (-tag => 'content_body',
				  -label => 'Document Content',
				  -subelements => $body,
				  -dtd_preface => $body_preface,
				  -dtd_definition => $body_dtd);


sub new {
    my $class = shift;
    my $in = shift;
    return $content_body->new unless $in;
    $in eq 'summary' and return $summary->new;
    $in eq 'section' and return $section->new;
    $in eq 'question_info' and return $question_info->new;
    $in eq 'slide_info' and return $slide_info->new;
    $in eq 'shockwave' and return $shockwave->new;
    $in eq 'flashpix' and return $flashpix->new;
    $in eq 'video' and return $video->new;
    $in eq 'realaudio' and return $realaudio->new;
    $in eq 'url' and return $url->new;
    $in eq 'pdf' and return $pdf->new;
    $in eq 'downloadablefile' and return $downloadablefile->new;
    return $content_body->new;
}

1;
