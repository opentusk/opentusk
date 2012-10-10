package XML::Twig::EscapeText;

use base('Exporter');

use strict;

use vars qw/@EXPORT/;

@EXPORT = qw/escape_text/;

# Description: Makes sure that some text is XML-escaped
# Input: The text
# Output: The text, but with &, <, >, and " escaped
sub escape_text {
    $_ = shift;
    return unless $_;
    s/\&/\&amp;/g;
    s/\</\&lt;/g;
    s/\>/\&gt;/g;
    # s/\"/\&quot;/g;
    # s/\'/\&apos;/g;
    s/\x92/\&apos;/g;
    s/\015/\n/g;
    s!\cM!\n!g;

    return $_;
}

1;
__END__
