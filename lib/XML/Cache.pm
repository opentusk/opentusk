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


package XML::Cache;

use HSDB4::DateTime;
use XML::Formatter;
use HSDB45::Versioner;

BEGIN {
    use vars qw($VERSION);

    $VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version {
    return $VERSION;
}

sub new {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {};
    bless($self, $class);
    return $self->init(@_);
}

sub init {
    my $self = shift();
    $self->{-formatter} = shift() || die "Didn't specify formatter";
    return $self;
}

sub formatter {
    my $self = shift();
    return $self->{-formatter};
}

sub modified {
    my $self = shift();
    $self->lookup() unless($self->{-modified});
    return $self->{-modified};
}

sub formatter_version {
    my $self = shift();
    $self->lookup() unless($self->{-formatter_version});
    return $self->{-formatter_version};
}

sub lookup {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle();

    eval {
        my $sth = $dbh->prepare("SELECT modified, formatter_version " .
				"FROM hsdb4.xml_cache " .
				"WHERE formatter_name=? AND school=? AND object_id=?");
        $sth->execute(ref($self->formatter()),
		      $self->formatter()->school(),
		      $self->formatter()->object_id());
        my ($modified, $formatter_version) = $sth->fetchrow_array();
        return unless($modified && $formatter_version);
        $self->{-modified} = HSDB4::DateTime->new()->in_mysql_timestamp($modified);
        $self->{-formatter_version} = $formatter_version;
    };

    if($@) {
        die("$@\t...problem performing lookup with formatter_name='",
	    ref($self->formatter), "', school='",
	    $self->formatter->school, "', object_id='",
	    $self->formatter->object_id, "'");
    }
}

sub retrieve_cache {
    my $self = shift();

    unless($self->formatter_version eq $self->formatter->get_versioner->get_version_code) {
        die "Trying to retrieve cache for mismatched version types!";
    }

    my $dbh = HSDB4::Constants::def_db_handle();
    my ($body, $modified, $formatter_version);

    eval {
        my $sth = $dbh->prepare("SELECT modified, formatter_version, body " .
				"FROM hsdb4.xml_cache " .
				"WHERE formatter_name=? AND school=? AND object_id=?");
        $sth->execute(ref $self->formatter(), $self->formatter()->school(),
		      $self->formatter()->object_id());
        ($modified, $formatter_version, $body) = $sth->fetchrow_array();
    };

    if ($@) {
        die "Error retrieving XML cache body: $@";
    }

    $self->{-modified} = HSDB4::DateTime->new()->in_mysql_timestamp($modified);
    $self->{-formatter_version} = $formatter_version;

    return $body;
}

sub write_cache {
    my $self = shift();

    my $dbh = HSDB4::Constants::def_db_handle();
    my $sth;

    if($self->modified()) {
	$sth = $dbh->prepare("UPDATE hsdb4.xml_cache " .
				"SET modified=NULL, formatter_version=?, body=? " .
				"WHERE formatter_name=? AND school=? AND object_id=?");
    }
    else {
        $sth = $dbh->prepare("INSERT INTO hsdb4.xml_cache " .
				"SET modified=NULL, formatter_version=?, body=?, " .
				"formatter_name=?, school=?, object_id=?");
    }

    $sth->execute($self->formatter->get_versioner->get_version_code,
		  $self->formatter()->get_xml_text(),
		  ref($self->formatter()),
		  $self->formatter()->school(),
		  $self->formatter()->object_id());
}

1;
