package TUSK::DB::Util;

use Modern::Perl;
use File::Spec;

use TUSK::Constants;

use base qw(Exporter);
our @EXPORT_OK = qw(sql_dir sql_file_path);

sub sql_dir {
    return File::Spec->catdir(
        $TUSK::Constants::ServerRoot,
        'db',
    );
}

sub sql_file_path {
    my $basefile = shift;
    return File::Spec->catfile(
        sql_dir(),
        $basefile,
    );
}

1;
