package HTML::Tidy;

use strict;
use IPC::Open2;
use IO::Handle;
use IO::Pipe;
use vars qw(@default_options @msword_options);

@msword_options = ('--word-2000'                   => 'yes',
		 '--input-encoding'              => 'win1252',
		 );

@default_options = ('--add-xml-decl'                => 'yes',
		    '--add-xml-space'               => 'yes',
		    '--bare'                        => 'yes',
		    '--break-before-br'             => 'yes',
		    '--clean'                       => 'yes',
		    '--doctype'                     => 'strict',
		    '--drop-empty-paras'            => 'yes',
		    '--drop-font-tags'              => 'yes',
		    '--drop-proprietary-attributes' => 'yes',
		    '--enclose-block-text'          => 'yes',
		    '--enclose-text'                => 'yes',
		    '--fix-uri'                     => 'yes',
		    '--hide-comments'               => 'yes',
		    '--logical-emphasis'            => 'yes',
		    '--lower-literals'              => 'yes',
		    '--output-xhtml'                => 'yes',
		    '--quote-marks'                 => 'yes',
		    '--show-body-only'              => 'yes',
		    '--quiet'                       => 'yes',
		    '--show-warnings'               => 'no',
		    '--indent'                      => 'yes',
		    '--indent-spaces'               => 2,
		    '--wrap'                        => 82,
		    '--output-encoding'             => 'latin1',
		    '--fix-backslash'               => 'yes',
		    '--quote-nbsp'                  => 'yes',
		    );

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {-executable => '',
		-options => { @default_options },
	    };
    bless $self, $class;
    $self->find_executable();
    return $self;
}

sub find_executable {
    my $self = shift;
    for (map { "$_/tidy" } split /:/, $ENV{PATH}) {
	if (-e && -x) {
	    $self->{-executable} = $_;
	    return;
	}
    }
    die "Cannot find a tidy executable in the path [$ENV{PATH}]";
}

sub get_executable {
    my $self = shift;
    return $self->{-executable};
}

sub set_options {
    my $self = shift;
    my $count = 0;
    while (my ($option, $value) = splice(@_, 0, 2)) {
	next unless $option;
	$count++;
	$option = "--$option" unless $option =~ /^--/;
	if ($self->{-options}{$option} && ! defined($value)) {
	    delete $self->{-options}{$option};
	}
	else {
	    $self->{-options}{$option} = $value;
	}
    }
    return $count;
}

sub set_msword_options {
    my $self = shift;
    return $self->set_options(@msword_options);
}

sub get_options {
    my $self = shift;
    return %{$self->{-options}};
}

sub get_options_string {
    my $self = shift;
    my $options_string;
    my %options = %{$self->{-options}};
    foreach my $key (keys %options) {
	if (!$options{$key}) {
	    $options_string .= " $key";
	} else {
	    $options_string .= " $key $options{$key}";
	}
    }
    return $options_string;
}

sub tidy_file {
    my $self = shift;
    my $filename = shift;
    die "Filename $filename does not exist" unless -e $filename;
    local $/ = undef;
    local $| = 1;
    my $pipe = IO::Pipe->new();
    $pipe->reader($self->get_executable(), $self->get_options_string(), $filename);
    my $out_string = <$pipe>;
    $pipe->close();
    return $out_string;
}

sub tidy_string {
    my $self = shift;
    my $string = shift;
    local $/ = undef;
    local $| = 1;
    my ($rfh, $wfh) = (IO::Handle->new(), IO::Handle->new());
    open2($rfh, $wfh, $self->get_executable().$self->get_options_string());
    $wfh->print($string);
    $wfh->close();
    my $out_string = <$rfh>;
    $rfh->close();
    return $out_string;
}

sub tidyString {
    my $self = HTML::Tidy->new();
    return $self->tidy_string(shift);
}

1;
