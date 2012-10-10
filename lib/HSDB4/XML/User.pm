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


package HSDB4::XML::User;

use strict;
require HSDB4::XML;

# Shorthand for the XML types
my $simple = 'HSDB4::XML::SimpleElement';
my $attr = 'HSDB4::XML::Attribute';
my $element = 'HSDB4::XML::Element';

sub html_email {
    my $val = shift;
    return "<A HREF=\"mailto:$val\">$val</A>";
}

sub html_url {
    my $val = shift;
    return "<A HREF=\"$val\">$val</A>";
}

# Simple objects for inside the contact info
my $address = $simple->new (-tag => 'address', -label => 'Address');
my $affiliation = $simple->new (-tag=>'affiliation', -label=>'Affiliation' );
my $phone = $simple->new (-tag => 'phone', -label => 'Phone No');
my $fax = $simple->new (-tag => 'fax', -label => 'Fax No');
my $department = $simple->new (-tag => 'department', -label => 'Department');
my $appointment = $simple->new (-tag=>'appointment', -label=>'Appointment');
my $url = $simple->new (-tag => 'url', -label => 'Web Page',
			-html_filter => \&html_url);
my $email = $simple->new (-tag => 'email', -label => 'E-mail Address',
			  -html_filter => \&html_email);

# Table for contact info sub-elements
#                   Tag           Min   Max
#                   ------------  ---   ---
my $cinfo_subs = [ [$affiliation             ],
		   [$appointment             ],
		   [$department              ],
		   [$address,      0,    3   ],
		   [$phone                   ],
		   [$fax                     ],
		   [$url                     ],
		   [$email                   ],
		   ];

# Publicity attribute for contact_info
my $publicity = $attr->new (-name => 'publicity',
			    -choices => {'none' => 'Not shared',
					 'class' => 'Classmates Only',
					 'tufts' => 'Tufts Community Only',
					 'public' => 'Publicly Available'},
			    -label => 'Publicity',
			    -default => 'none',
			    -required => 1);

# The contact_info element itself
my $cinfo = $element->new (-tag=>'contact_info',
			   -label => 'Contact Information',
			   -subelements => $cinfo_subs,
			   -attributes => [ $publicity ],
			   );

# Which in turn is part of user_body
my $user_body = $element->new (-tag=>'user-body',
			       -label => 'User Information',
			       -subelements => [ [ $cinfo, 0 ] ],
			       );

sub new {
    my $class = shift;
    my $in = shift;
    return $user_body->new unless $in;
    $in eq 'contact_info' and return $cinfo->new;
    return $user_body->new;
}

1;




