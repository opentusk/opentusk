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


package HSDB4::SQLRow::ContentDraft;

use strict;
use HSDB4::XML::HSCML;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

#
# File-private lexicals
#
my $tablename         = 'content_draft';
my $primary_key_field = 'draft_id';
my @fields =       qw(draft_id content_id user_id body modified);
my %numeric_fields = ();
my %blob_fields =    (body => 1
		      );
my %cache = ();

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Do the default creation stuff
    #

    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

sub lookup_content {
    my $self = shift;
    my $content_id = shift;
    my @drafts = $self->lookup_conditions("content_id=$content_id");
    return unless (@drafts);
    $self->lookup_key($drafts[0]->primary_key);
}

sub lookup_user {
    my $self = shift;
    my $user_id = shift;
    return $self->lookup_conditions("user_id=$user_id");
}

#
# >>>>> Ouput methods <<<<<
#
sub content {
    my $self = shift;
    return unless ($self->primary_key);
    my $content = HSDB4::SQLRow::Content->new->lookup_key($self->field_value('content_id'));
    return unless ($content->primary_key);
    return $content;
}

sub out_hscml_content {
    my $self = shift;
    return $self->field_value('body');
}

sub out_draft_body {
    my $self = shift;
    my $hscml = HSDB4::XML::HSCML->new($self->out_hscml_content);
    return $hscml->out_html_body($self->content);
}

sub out_draft_title {
    my $self = shift;
    my $hscml = HSDB4::XML::HSCML->new($self->out_hscml_content);
    return $hscml->out_title;
}

#
# >>>>> Input methods <<<<<
#
sub save_draft {
    my $self = shift;
    my $un = shift;
    my $pw = shift;
    my $content_id = shift;
    my $user_id = shift;
    my $body = shift;
    $self->lookup_content($content_id);
    $self->set_field_values(content_id => $content_id, user_id => $user_id, body => $body);
    my ($r,$msg) = $self->save($un,$pw);
    return ($r,$msg);
}

sub delete_draft {
    my $self = shift;
    my $un = shift;
    my $pw = shift;
    my $content_id = shift;
    my ($r,$msg);
    if ($content_id) {
	$self->lookup_content($content_id);
	($r,$msg) = $self->delete($un,$pw);
    }
    elsif ($self->primary_key) {
	($r,$msg) = $self->delete($un,$pw);
    }
}

sub requires_draft {
    my $self = shift;
    my $status = shift;
    ## if it's draft or in revision we need to make a draft and not touch the content
    return 1 if ($status =~ /^Draft|In\ Revision/);
    ## otherwise it's available draft or final we need to put it in content and delete draft
    return;
}

#
# >>>>> Linked objects <<<<<
#


1;

__END__

=head1 NAME

B<HSDB4::SQLRow::ContentDraft> - Instatiation of the a B<SQLRow> to
represent a draft of content.

=head1 SYNOPSIS

    use HSDB4::SQLRow::ContentDraft;
    
    # Make a new object
    my $draft = HSDB4::SQLRow::ContentDraft->new();
    # And feed in the data from the database
    $draft->lookup_key($key);
    # or use the content_id to look up and item
    $draft->lookup_content($content_id);

=head1 AUTHOR

Michael Kruckenberg <michael.kruckenberg@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>, L<HSDB4::SQLLink>, L<HSDB4::XML>.

=cut



