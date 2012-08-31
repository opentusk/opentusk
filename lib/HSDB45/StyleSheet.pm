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


package HSDB45::StyleSheet;

use strict;
use HSDB4::StyleSheetType;
use Carp;

BEGIN {
    use vars qw($VERSION);
    use base qw/HSDB4::SQLRow/;
    use XML::LibXML;
    use XML::LibXSLT;
    
    $VERSION = do { my @r = (q$Revision: 1.10 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

# File-private lexicals
my $tablename = "stylesheet";
my $primary_key_field = "stylesheet_id";
my @fields = qw/stylesheet_id stylesheet_type_id label body description modified/;
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # Finish initialization...
    return $self;
}

############################
# field accessor functions #
############################

# retrievable only
sub stylesheet_id {
    my $self = shift();
    return $self->field_value('stylesheet_id');
}

sub stylesheet_type_id {
    my $self = shift();
    return @_ ? $self->field_value('stylesheet_type_id', shift()) : $self->field_value('stylesheet_type_id');
}

sub label {
    my $self = shift();
    return @_ ? $self->field_value('label', shift()) : $self->field_value('label');
}

sub body {
    my $self = shift();
    return @_ ? $self->field_value('body', shift()) : $self->field_value('body');
}

sub description {
    my $self = shift();
    return @_ ? $self->field_value('description', shift()) : $self->field_value('description');
}

sub modified {
    my $self = shift();
    return $self->field_value('modified');
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub is_unique_label{
	my $school = shift;
	my $label = shift;
	my @stylesheets = HSDB45::StyleSheet->new(_school=>$school)->lookup_conditions(" label = '$label' ");
	if (scalar(@stylesheets)){
		return 0;
	} else {
		return 1;
	}
}

# INPUT: string containing XML to be transformed
# OUTPUT: transformed XML text
sub apply_stylesheet {
    my $self = shift();
    my $xml_text = shift();
    my $parser = XML::LibXML->new();
    my $xslt = XML::LibXSLT->new();
    my $source = $parser->parse_string($xml_text);
    my $style_doc = $parser->parse_string($self->body());
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results;
    eval {
	 $results =  $stylesheet->transform($source, XML::LibXSLT::xpath_to_string(@_));
    };
    if ($@){
	confess $@;
    }
    return $stylesheet->output_string($results);
}

sub apply_global_stylesheet_dom {
    my $stylesheet_path = shift();
    my $xml_text = shift();
    my $parser = XML::LibXML->new();
    my $xslt = XML::LibXSLT->new();
    my $source;
    eval {
	$source = $parser->parse_string($xml_text);
    };
    if ($@){
	confess "Error parsing XML : $@";
    }
    my $style_doc = $parser->parse_file($stylesheet_path);
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results =  $stylesheet->transform($source, XML::LibXSLT::xpath_to_string(@_));
    return $results;
}

# Static function
# INPUT: string containing a path to a stylesheet file, string containing XML to be transformed
# OUTPUT: transformed XML text
sub apply_global_stylesheet {
    my $stylesheet_path = shift();
    my $xml_text = shift();
    my $parser = XML::LibXML->new();
    my $xslt = XML::LibXSLT->new();
    my $source = $parser->parse_string($xml_text);
    my $style_doc = $parser->parse_file($stylesheet_path);
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results;
    eval {
	$results =  $stylesheet->transform($source, XML::LibXSLT::xpath_to_string(@_));
	};
    if ($@){
	confess $@;
    }
    return $stylesheet->output_string($results);
}

1;
