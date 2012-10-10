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


package XML::Formatter;

use strict;

use HSDB4::SQLRow;
use XML::Twig;
use HSDB4::DateTime;
use XML::Cache;
use XML::Demoroniser;
use HSDB45::Versioner;

BEGIN {
    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.12 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version {
    return $VERSION;
}

sub new {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {_creatingCache => 0};
    bless($self, $class);
    return $self->init(@_);
}

sub init {
    my $self = shift();
    $self->{-object} = shift() || die "Didn't pass in an object to XML::Formatter";
    $self->{-cache} = XML::Cache->new($self);
    $self->{-versioner} = HSDB45::Versioner->new(ref($self));
    return $self;
}

sub get_versioner {
    my $self = shift;
    return $self->{-versioner};
}

sub object {
    my $self = shift();
    return $self->{-object};
}

sub class_expected {
    my $self = shift();
    die "Didn't override XML::Formatter::class_expected.";
}

sub cache {
    my $self = shift();
    return $self->{-cache};
}

sub school {
    my $self = shift();
    return $self->object()->school();
}

sub object_id {
    my $self = shift();
    return $self->object()->primary_key();
}

sub modified_since {
    my $self = shift();
    die "Error: " . ref($self) . " did not override modified_since()";
}

sub is_cache_valid {
    my $self = shift();
    return 0 unless defined $self->cache()->modified();
    return 0 unless $self->get_versioner->get_version_code eq $self->cache->formatter_version;
    return 0 if $self->modified_since($self->cache()->modified());
    return 1;
}

sub get_xml_text {
    my $self = shift();
    my $override = shift();

    if ($override or not $self->{-xml_text}) {
	if($override || !($self->is_cache_valid()))
	{
	    $self->{-xml_text} = $self->get_xml_elt()->sprint();
	    $self->cache()->write_cache();
	}
	else {
	    $self->{-xml_text} = $self->cache()->retrieve_cache();
	}
    }

    return $self->{-xml_text};
}

sub get_xml_elt {
    my $self = shift();
    die "Error: " . ref($self) . " did not override get_xml_elt()";
}

sub get_xml_document {
    my $self = shift();
    my $doctype = $self->doctype_decl();
    my $dtd = $self->dtd_decl();
    my $stylesheet = $self->stylesheet_decl();
    my $head = qq[<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE $doctype SYSTEM "$dtd">
<?xml-stylesheet href="$stylesheet" type="text/xsl"?>];
    return $head . "\n" . $self->get_xml_text();
}

sub doctype_decl {
    my $self = shift();
    return @_ ? $self->{-doctype_decl} = shift() : $self->{-doctype_decl};
}

sub dtd_decl {
    my $self = shift();
    return @_ ? $self->{-dtd_decl} = shift() : $self->{-dtd_decl};
}

sub stylesheet_decl {
    my $self = shift();
    return @_ ? $self->{-stylesheet_decl} = shift() : $self->{-stylesheet_decl};
}

1;
