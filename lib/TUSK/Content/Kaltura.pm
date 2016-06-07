# Copyright 2016 Tufts University
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


package TUSK::Content::Kaltura;

=head1 NAME

B<TUSK::Content::Kaltura> - Class for manipulating entries in table content_kaltura in tusk database

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 INTERFACE

=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;
    require HSDB4::DateTime;
    require HSDB4::SQLRow::Content;
    require TUSK::Config;
    require API::Kaltura;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars qw( );

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new (
                                    _datainfo => {
                                        'database' => 'tusk',
                                        'tablename' => 'content_kaltura',
                                        'usertoken' => 'ContentManager',
                                        'database_handle' => '',
                                        },
                                    _field_names => {
                                        'content_kaltura_id' => 'pk',
                                        'content_id' => '',
                                        'kaltura_id' => '',
                                        'added_on' => '',
                                        'processed_on' => '',
                                        'error' => '',
                                    },
                                    _attributes => {
                                        no_created => 1,
                                        save_history => 1,
                                        tracking_fields => 1,
                                    },
                                    _levels => {
                                        reporting => 'cluck',
                                        error => 0,
                                    },
                                    @_
                                  );
    # Finish initialization...
    $self->init();
    return $self;
}

### Get/Set methods

sub getContentID {
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}

sub setContentID {
    my ($self, $value) = @_;
    $self->setFieldValue('content_id', $value);
}

sub getKalturaID {
    my ($self) = @_;
    return $self->getFieldValue('kaltura_id');
}

sub setKalturaID {
    my ($self, $value) = @_;
    $self->setFieldValue('kaltura_id', $value);
}

sub getAddedOn {
    my ($self) = @_;
    return $self->getFieldValue('added_on');
}

sub setAddedOn {
    my ($self, $value) = @_;
    $value = HSDB4::DateTime->new()->out_mysql_timestamp() unless ($value);
    $self->setFieldValue('added_on', $value);
}

sub getProcessedOn {
    my ($self) = @_;
    return $self->getFieldValue('processed_on');
}

sub setProcessedOn {
    my ($self, $value) = @_;
    $value = HSDB4::DateTime->new()->out_mysql_timestamp() unless ($value);
    $self->setFieldValue('processed_on', $value);
}

sub getError {
    my ($self) = @_;
    return $self->getFieldValue('error');
}

sub setError {
    my ($self, $value) = @_;
    $self->setFieldValue('error', $value);
}

### Other Methods

sub add {
    my ($self, $content_id, $user_id) = @_;
    my $row = $self->lookupReturnOne("content_id = $content_id");
    unless ($row) {
        $row = $self->new();
        $row->setContentID($content_id);
        $row->setAddedOn();
        $row->save({user => $user_id});
    }
    return $row;
}

sub init {
    my ($self) = @_;
    our ($api, $cfg);
    unless (defined $api) {
        eval {
            $cfg = TUSK::Config->new()->Kaltura();
            if ($cfg->{secret} && $cfg->{kalturaUrl} && $cfg->{partnerId}) {
                $api = API::Kaltura->new({
                    secret => $cfg->{secret},
                    kalturaUrl => $cfg->{kalturaUrl},
                    apiVersion => 3,
                    sessionType => 'admin',
                    partnerId => $cfg->{partnerId}
                });
            }
        };
        $api = 0 if ($@);
    }
    return $api;
}

sub player {
    my ($self, $content_id, $display_type, $width, $height) = @_;
    our $cfg;
    if ($cfg) {
        my $kaltura_url = $cfg->{kalturaUrl};
        my $partner_id = $cfg->{partnerId};
        my $player_id = $cfg->{'playerId' . $display_type};
        if ($kaltura_url && $partner_id && $player_id) {
            my $row = $self->add($content_id, 'player');
            my $kaltura_id = $row->getKalturaID();
            if ($kaltura_id) {
                return qq(<iframe src="$kaltura_url) . qq(/p/$partner_id/sp/$partner_id) .
                    qq(00/embedIframeJs/uiconf_id/$player_id/partner_id/$partner_id?) .
                    qq(iframeembed=true&playerId=$kaltura_id&entry_id=$kaltura_id" ) .
                    qq(width="$width" height="$height" allowfullscreen frameborder="0"></iframe>);
            } else {
                return '<p>This content is being uploaded to Kaltura.</p>';
            }
        }
    }
}

sub upload {
    my ($self, $user_id) = @_;
    our $api;
    $self->setProcessedOn();
    $self->save({user => $user_id});
    if ($api) {
        my $content_id = $self->getContentID();
        my $content = HSDB4::SQLRow::Content->new()->lookup_key($content_id);
        if ($content->primary_key()) {
            eval {
                $api->startSession();
                my $upload_result = $api->uploadFile({
                    file => $content->out_file_path(),
                    type => $content->type(),
                    categories => 'TUSK',
                    name => $content->title()
                });
                $api->endSession();
                $self->setKalturaID($upload_result->first_child('rootEntryId')->text());
            };
            $self->setError($@) if ($@);
        } else {
            $self->setError('Invalid content ID');
        }
    } else {
        $self->setError('Kaltura is not configured');
    }
    $self->save({user => $user_id});
}

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class
B<API::Kaltura> - Kaltura API

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2016.

=cut

1;
