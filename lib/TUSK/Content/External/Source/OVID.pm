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


package TUSK::Content::External::Source::OVID;

=head1 NAME

B<TUSK::Content::External::Source::OVID> - Class for handling external content from the OVID source

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw(redirect);
    @EXPORT_OK = qw();
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();
use LWP::UserAgent;
use HSDB4::SQLRow::User;
use HSDB4::Constants;
use TUSK::Constants;
use TUSK::Core::Keyword;
use TUSK::Core::LinkContentKeyword;
use HTML::Parser;
use TUSK::Content::External::MetaData;
use TUSK::Constant::Variable;
use HTTP::Cookies;

### Global variables
my $pre_text;  ### keep adding text with HTML::Parser calls

### if key is changed, ensure it is same as token in external_content_source
my $sources = {  
	acp => { lslink => 430, 
		 copyright => 'American College of Physicians - American Society of Internal Medicine.', },
	dare => { lslink => 430,
		  copyright => 'University of York, England', },
	coch => { lslink => 450,
		  copyright => 'The Cochrane Collaboration', },
	caba => { lslink => 80, },
	ovft => { lslink => 80, },
};

my $browser = LWP::UserAgent->new();
$browser->agent($ENV{HTTP_USER_AGENT});

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;

    my $self = {};
    
    bless $self, $class;

    # Finish initialization...
    return $self;
}



sub redirect {
    my ($self, $content, $user, $db) = @_;

    ### some web sites use cookies, so we just get prepared for it.
    my $cookies = new HTTP::Cookies(file => "$ENV{LOG_ROOT}/lwp_cookies.log", autosave => 1);
    $browser->cookie_jar($cookies); 

    if (my $metadata = TUSK::Content::External::MetaData->lookupReturnOne("content_id = " . $content->primary_key())) {
	### go directly to url if we have doi or url
	my $url = $metadata->getUrl();
	if (defined $url && $url =~ /http/) {
	    if ($url =~ /dx\.doi\.org\/(.+)$/) {
		my $doi = $1;
		if ($ENV{REMOTE_ADDR} =~ /130\.64/) {
		    ### can't go to doi url directly but go thru their form
		    return $browser->post('http://dx.doi.org', [ hdl => $doi ]);
		} else {
		    return $self->connect({uid => $user->primary_key(),url => $url });
		}
	    } else {
		return ($ENV{REMOTE_ADDR} =~ /130\.64/) 
		    ? $browser->post($url)
		    : $self->connect({uid => $user->primary_key(),url => $url });
	    }
	}
    }

    ### at this point, we try to to redirect to a url created based on accession number
    my $links = $content->get_external_content_data();
    my $an;
    $db = 'ovft' if ($db eq 'medline');

    foreach my $link (@$links) {
	my $field = $link->getField();
	if ($field->getToken() eq 'AN') {
	    $an = $link->getValue();
	    last;
	}
    }

    return undef unless ($an);

    my $ovid_url = TUSK::Constant::Variable->lookupReturnOne("constant_name = 'OvidUrl'");
    my $response;

    if ($ovid_url) {
	$response = $self->connect({
	    uid => $user->primary_key(),
	    url => $ovid_url->getConstantValue() . "&PAGE=fulltext&AN=$an&LSLINK=$sources->{$db}{lslink}&D=$db",
	});
    }

    return $response;
}


sub connect {
    my ($self, $args) = @_;

    my $ez_proxy_url = TUSK::Constant::Variable->lookupReturnOne("constant_name = 'EzProxyUrl'");

    my $response;
    my $ldap = HSDB45::LDAP->new();
    my ($ldap_resp,$msg) = $ldap->lookup_user_id($args->{uid});

    if ($ez_proxy_url && $ldap_resp) {
	$response = $browser->post($ez_proxy_url->getConstantValue(), [
	       offCampusFlag => ($ENV{REMOTE_ADDR} =~ /130\.64/) ? 'False' : 'True',
	       username => $args->{uid},
	       link => $args->{url}, 
	       schoolInfo => $ldap->school_info(),
	       affiliation => $ldap->affiliation(),
	 ]);
    }

    return $response;
}


sub metadata {
    my ($self, $content, $data) = @_;

    $self->{content} = $content;

    my $ovid_url = TUSK::Constant::Variable->lookupReturnOne("constant_name = 'OvidUrl'");

    return unless defined $ovid_url;

    my $url = $ovid_url->getConstantValue() . "&PAGE=reference&M=tagged&AN=$data->{AN}&D=$data->{token}&LOGOUT=y";

    ### we access the tagged page through ezproxy.  This avoids hard-coding uid/pwd
    my $response = $self->connect({
	uid => $data->{user}->primary_key(),
 	url => $url,
    });


    ## now we try to get/extract content from Ovid's complete reference page
    my $response_metadata = $browser->get($response->header('location'));
    my $text = $response_metadata->content();
    my $err;

    if ($text =~ /<div class="error">(.+)<\/div>/) {
	$err = $1;
    } else {
	my $p = HTML::Parser->new(api_version => 3);
	$p->handler( start => \&start, "tagname,self");
	$p->parse($text);

	my $texts = $self->parseText();
	$self->saveMetaData($texts, $data->{user}, $data->{token});
    }

    ## clear it in case the object was called again. 
    ## this global variable falls into modperl traps
    $pre_text = undef;  
    return ($self->{content}, $self->{metadata}, $self->{keywords}, $err);
}


sub start {
    return if shift ne "pre";
    my $self = shift;

    $self->handler(text => sub { $pre_text .= shift; }, "dtext");
    $self->handler(end  => sub { shift->eof if shift eq "pre"; }, "tagname,self");
}


sub parseText {
    my $self = shift;

    my @lines = split(/\n/, $pre_text);
    my ($curr,%texts);

    foreach my $line (@lines) {

	my $abbrev = substr($line,0,2);
	if ($abbrev =~ /[A-Z]{2}/) {
	    $curr = $abbrev;
	}

	$texts{$curr} .= substr($line, 3, 82);
	$texts{$curr} .= "<br/>" if $curr eq 'AB' && $line !~ /^\w+$/;
    }

    return \%texts;
}


sub saveMetaData {
    my ($self, $texts, $user, $db) = @_;
    my $metadata = TUSK::Content::External::MetaData->new();

    foreach my $tag (keys %$texts) {
	if ($tag eq 'AU') {   ## authors
	    $metadata->setAuthor($texts->{'AU'});
	} elsif ($tag eq 'AM' && $db eq 'acp') {   ## authors for acp
	    $metadata->setAuthor($texts->{'AM'});
	} elsif ($tag eq 'TI') {   ## title
	    $self->{content}->field_value('title', $texts->{'TI'});
	} elsif ($tag eq 'SO') {   ## source
	    $self->{content}->field_value('source', $texts->{'SO'});
	} elsif ($tag eq 'KW') {   ## keywords
	    $self->saveKeywords( [ split(/;/, $texts->{'KW'}) ] );
	} elsif ($tag eq 'SH') {
	    $self->saveKeywords( [ split(/,/, $texts->{'SH'}) ] );
	} elsif ($tag eq 'DE') {   
	    $self->saveKeywords( [ split(/\./, $texts->{'DE'}) ] );
	} elsif ($tag eq 'AB') {   ## abstract
	    $metadata->setAbstract($texts->{'AB'});
	} elsif ($tag eq 'DO') {   ## DOI, first choice for url
	    $metadata->setUrl($texts->{'DO'});
	} elsif ($tag eq 'UR') {   ## URL, second choice
	    $metadata->setUrl($texts->{'UR'}) unless ($metadata->getUrl());  
	}
    }

    if ($db eq 'caba') { 
	my @info = split('\.', $texts->{'SO'});
	$self->{content}->field_value('copyright', "Copyright $texts->{'YR'} $info[0]");
    } else {  ## all EBM
	my $year = $texts->{'SO'};
	$year =~ s/.*([19|20]{2}\d{2})\.?$/$1/;
	$self->{content}->field_value('copyright', "Copyright $year " . $sources->{$db}{copyright});

    }

    $self->{metadata} = $metadata;
}


sub saveKeywords {
    my ($self,$kwords) = @_;
    my %keywords;

    foreach my $kword (@$kwords){
	$kword =~ s/^\s+//;
	my $strings = TUSK::UMLS::UmlsString->lookup("string_text = '$kword'");
	    if (scalar(@{$strings})){
		foreach my $string (@{$strings}) {
		    if (scalar (my @one_keyword =  @{$string->getKeywords}) == 1) {
			$keywords{$one_keyword[0]->getPrimaryKeyID()} = $one_keyword[0];
		    }
		}
	    }
    }

    $self->{keywords} = [ values %keywords ];
}


1;
