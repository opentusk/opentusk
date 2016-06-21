package API::Kaltura;
use strict;
use warnings;
use XML::Twig;
use LWP;
use Carp;

BEGIN {
    our ($VERSION, %SESSION_TYPES, %MEDIA_TYPES);
    $VERSION     = '0.01EXPERIMENTAL';
    %SESSION_TYPES = (
        user => 0,
        admin => 2
    );
    %MEDIA_TYPES = (
        video => 1,
        image => 2,
        audio => 5,
        live_stream_flash => 201,
        live_stream_windows_media => 202,
        live_stream_real_media => 203,
        live_stream_quicktime => 204
    );
}

#### new
=head2 new

 Usage     : $KalturaObj = API::Kaltura->new({
    secret => 'my secret',
    partnerId => 'my partner ID',
    sessionType => 'session type', # admin or user
    apiVersion => 3, # int
    kalturaUrl => 'https://my.kaltura.url'
 });
 Purpose   : Initializes API::Kaltura
 Returns   : API::Kaltura object
 Arguments  :  A hash of data, all gathered from your Kaltura instance.
    Secret:  String containing a valid secret.
    partnerId:  Int partner id.
    sessionType:  String containing a session type.
        Currently only supports 'user' and 'admin'
    apiVersion:  Int api version.
    kalturaUrl:  String URL of your kaltura instance.

=cut

sub new {
    my ($class, $params) = @_;
    my $self = bless ({}, ref ($class) || $class);
    $self->{secret} = $params->{secret};
    $self->{partnerId} = $params->{partnerId};
    $self->{sessionType} = $API::Kaltura::SESSION_TYPES{lc($params->{sessionType})};
    $self->{apiVersion} = $params->{apiVersion};
    $self->{kalturaUrl} = $params->{kalturaUrl};
    if ($params->{format}) {
        $self->{format} = $params->{format};
    } else {
        $self->{format} = 'xml';
    }
    return $self;
}
#### new end

#### runService
=head2 runService

 Usage     : $UAObj = $KalturaObj->runService({param1 => 'param', paramN => paramN})
 Purpose   : Low level service request runner
 Returns   : LWP::UserAgent object.
 Argument  : A hash of parameters
 Comment   : This routine runs all requests internally, and is
            exposed for convenience and testing.  Parameters
            are dependent on what the end goal is for the request.
            A simple request would be to start a session:
                $uaObj = KalturaObject->runService({
                    service => 'session',
                    action => 'start',
                    clientTag => 'testme'
                });
            To get the results, simply call the content method on
            the returned LWP::UserAgent object.
 See Also   : L<LWP::UserAgent>
=cut

sub runService {
    my ($self, $params) = @_;
    # merge in the necessary identification stuff...
    foreach my $required ('secret', 'partnerId') {
        $params->{$required} = $self->{$required};
    }
    if ($self->{current_ks}) {
        $params->{'ks'} = $self->{current_ks};
    }
    my $ua = LWP::UserAgent->new();
    push @{$ua->requests_redirectable}, 'POST';
    $ua->agent("Kaltura API Perl Module");
    my $url = $self->{kalturaUrl} . '/api_v' . $self->{apiVersion};
    return $ua->post(
        $url,
        Content_Type => 'form-data',
        Content => $params
    )
}
#### runService end

#### startSession
=head2 startSession

 Usage     : $bool = $KalturaObj->startSession();
 Purpose   : Initializes a Kaltura API session
 Returns   : bool
 Comment   : On success, sets the current_ks variable to the
            session that was returned.

=cut

sub startSession {
    my ($self, $userId) = @_;
    my $ua = $self->runService({
        service => 'session',
        action => 'start',
        type => $self->{sessionType},
        userId => $userId
    });
    my $result = __getResultFromReturn($ua);
    if ($result) {
        $self->{current_ks} = $result->text();
    } else {
        carp("No session supplied in result!");
        return 0;
    }
    return 1;
}
#### startSession end

#### endSession
=head2 endSession

 Usage     : $bool = $KalturaObj->endSession();
 Purpose   : Destroys a Kaltura API session
 Returns   : bool

=cut

sub endSession {
    # this assumes an internal session.
    my $self = shift;
    my $uaObj = $self->runService({
        service => 'session',
        action => 'end',
        ks => $self->{current_ks}
    });
    $self->{current_ks} = '';
    return 1;
}
#### endSession end

#### getResult
=head2 runService

 Usage     : $XMLTwigResultObject = $KalturaObj->getResult(
                {param1 => 'param', paramN => paramN}
            );
 Purpose   : Service request runner
 Returns   : XML::Twig object
 Argument  : A hash of parameters
 Comment    This is a convenience method that executes runService(), and
            returns the "result" section of the returned XML object from
            Kaltura.
 See Also   : L<XML::Twig>
=cut

sub getResult {
    my ($self, $params) = @_;
    my $result = $self->runService($params);
    return __getResultFromReturn($result);
}
#### getResult end

#################### uploadFile ####################
=head2 uploadFile

 Usage     : $KalturaObj->uploadFile(
                {param1 => 'param', paramN => paramN}
            );
 Purpose   : Service request runner
 Returns   : XML::Twig object
 Argument  : A hash of parameters
 Comment   : uploading a file is an arduous task that requires multiple calls
            this is a convenience method to sidestep all of those.  This is
            considered an experimental method
 See Also   : L<XML::Twig>
=cut

# TODO:  Error catching.
sub uploadFile {
    my ($self, $params) = @_;
    # error catching.
    if ($params->{categories} && $params->{categoriesIds}) {
        croak("Can't use both categories and categoriesIds");
    }
    if ($self->{sessionType} == $API::Kaltura::SESSION_TYPES{'user'}) {
        if ($params->{adminTags}) {
            carp("Not an admin session, ignoring adminTags.");
        }
    }

    my $upload_token_add_result = $self->getResult({
       service => 'uploadToken',
       action => 'add'
    });
    my $upload_token_id = $upload_token_add_result->first_child('id')->text();
    my $upload_token_upload_result = $self->getResult({
        service => 'uploadToken',
        action => 'upload',
        uploadTokenId => $upload_token_id,
        fileData => [$params->{file}]
    });

    my $media_add_hash = {
        service => 'media',
        action => 'add',
        'entry:objectType' => 'KalturaMediaEntry',
        'entry:mediaType' => $API::Kaltura::MEDIA_TYPES{lc($params->{type})},
        'entry:categories' => $params->{categories},
        'entry:categoriesIds' => $params->{categoriesIds},
        'entry:name' => $params->{name},
        'entry:description' => $params->{description},
        'entry:tags' => $params->{tags},
    };
    if ($params->{adminTags} && $self->{sessionType} == 2) {
        $media_add_hash->{'entry:adminTags'} = $params->{adminTags};
    }

    my $media_add_result = $self->getResult($media_add_hash);
    if ($media_add_result->first_child('id')) {
        my $media_add_id = $media_add_result->first_child('id')->text();
        my $media_addContent_result = $self->getResult({
            service => 'media',
            action => 'addContent',
            entryId => $media_add_id,
            'resource:objectType' => 'KalturaUploadedFileTokenResource',
            'resource:token' => $upload_token_id
        });
        return $media_addContent_result;
    } else {
        carp("Media add failed!");
        carp($media_add_result->sprint);
        return 0;
    }

}
#### uploadFile end

#### Internal Methods
sub __getResultFromReturn {
    my $ua = shift;
    my $twig = XML::Twig->new('pretty_print' => 'indented');
    my $doc = $twig->safe_parse($ua->content());
    if ($doc) {
        $doc->sprint;
        # check to see if the API barfed.
        if (my $error = $doc->root->first_child('error')) {
            return $error;
        } else {
            return $doc->root->first_child('result');
        }
    } else {
        carp("Invalid content returned:  " . $ua->content);
        return 0;
    }
}

#################### main pod documentation begin ###################

=head1 NAME

API::Kaltura - Kaltura API utility.

=head1 SYNOPSIS

  use strict;
  use warnings;
  use API::Kaltura;
  my $kt = API::Kaltura->new({
    secret => 'my secret from Kaltura',
    kalturaUrl => 'https://my.kaltura.url',
    apiVersion => 3,
    sessionType => 'admin', # admin or user only
    partnerId => '1234567890'
  });

  $kt->startSession();

  # getResult will be the most commonly used function.
  #### get a user's KMS data.
  $userTwig = $kt->getResult({
    service => 'user',
    action => 'get',
    userId => 'someUserId'
  });

  # to get the raw L<LWP::UserAgent> object from Kaltura, you can use
  # runService.  This can be useful for troubleshooting connectivity
  # problems.
  my $userUA = $kt->runService({
    service => 'user',
    action => 'get',
    userId => 'someUserId'
  });

  #### Upload a file.  This is considered experimental.  Error
  #### catching is not that great currently.
  my $upload_result = $kt->uploadFile({
    file => "/path/to/a/file",
    type => "audio", # see Kaltura API info for valid types.
    categoriesIds => "1234567890",
    name => 'Name for this media',
    description => 'Description for this media',
    tags => 'comma, separated, tags',
    adminTags => 'comma, separated, tags'
  });

  $kt->endSession();

=head1 DESCRIPTION

Easy low-level access to Kaltura API functions.

=head1 USAGE

Documentation for services and actions can be found on
Kaltura's website.  The simplest usage of this module is as
documented in the synopsis.

=head1 BUGS

Probably lots.  All undocumented.  May $DEITY have mercy upon you.

=head1 SUPPORT

For Kaltura, refer to your account rep or the Kaltura documentation and
forums.

For this module, please contact the author.

=head1 AUTHOR

    J. Eric Ellis
    CPAN ID: JELLISII
    jellisii@gmail.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1), L<XML::Twig>, L<LWP>, L<https://www.kaltura.com>.

=cut

1;
