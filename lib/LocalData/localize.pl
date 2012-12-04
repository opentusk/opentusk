#!/usr/bin/perl

use strict;
use warnings;
use Switch;
use feature qw(say);
use lib qw(../../lib);
use TUSK::Constants;
use Data::Dumper;
use File::Path qw(make_path);
use File::Find;
use File::Basename;
use IO::File;
use POSIX qw(getgrnam setgid);




# Note: defaults with '_' are local while other are derive dfron Constants.pm
#       the defaults precedence fron lowest to highest.
#        1) value in defaults hash
#        2) value from Constances.pm 
#        3) user command line options. (higest)
my $defaults = {
	SiteLang		=> "",
	_xtextget		=> 'xtextget',
	_feature		=> "dummy",
	_verbose		=> 1,
	_group			=> "tuskx",
	_potfiles		=> "fileslist2.txt",
	_setGroup		=> 0,		# used for setting files groups for use in shared environment
	_useGit			=> 0, 		# using a shared? git environment)
	
	# options below are defined in tusk.conf 
	SiteCoding		=> 'utf-8',
	SiteDomain		=> 'tusk',
	SiteCategories	=> [ qw(LC_MESSAGES) ],
	SiteLanguages	=> [ qw(fr,de) ],
	SiteLocale		=> 'lib/LocalData',
	_src_roots		=> [ qw(/usr/local/tusk/current/lib /usr/local/tusk/current/code ) ]
};

# try to set team group to avoid permission issues
set_group()		if($defaults->{_setGroup});

# get defaults (perhaps cmd line options)
get_defaults($defaults);
#print Dumper($defaults);

# main menu loop
while (1)
{
    clear();
    my $functions = build_menu($defaults);
    printf('_' x33 ."Localize Tool".'_' x33);
    printf("\n" x4);
	foreach my $i (sort {$a <=> $b} keys %$functions ) {
		printf("%s)	- %s\n",$i,exists($functions->{$i}->{text}) ? $functions->{$i}->{text} : 'missing text!!!');
	}
    print "Enter your choice: ";
    my $choice = <STDIN>;
    chomp($choice);
    next unless $choice =~ /^\d+$/;
    if(exists($functions->{$choice}->{handler})) {
    	if( ref $functions->{$choice}->{handler} eq 'CODE') {
    		$functions->{$choice}->{handler}->();
    	} else {
    			puterror("This handler for option [$choice] is not a valid subroutine.");
    	}
    } else {
    	puterror("Missing handler for option[$choice]");
    }
 

}
sub run_xgettext {
	my $cmd = xgettext_cmd();
	my $x = `$cmd`;
	say("goy $x"); <STDIN>;
}
sub xgettext_cmd {
	my $srcdir 		= dirname($0);
	my $outfile 	= "$srcdir/tusk.pox";
	my $infile 		= "$srcdir/$defaults->{_potfiles}";
	my $cr_holder	= "foo\@foo.com";
	my $bug_address = "bug\@foo.com";
	my $cmd = "xgettext --output=$outfile --from-code=utf-8 --strict -L Python -k__ -k__x  -f $infile";
#		my $cmd =<<EOT
#	xgettext --output=$outfile --from-code=utf-8 \
#		--add-comments=TRANSLATORS: --files-from=$infile \
#		--copyright-holder="$cr_holder" \
#		--msgid-bugs-address="$bug_address" \
#		--keyword --keyword='$$__' --keyword=__ --keyword=__x \
#		--keyword=__n:1,2 --keyword=__nx:1,2 --keyword=__xn:1,2 \
#		--keyword=__p:1c,2 --keyword=__np:1c,2,3 \
#		--keyword=__npx:1c,2,3 --keyword=N__ --keyword=N__n:1,2 \
#		--keyword=N__p:1c,2 --keyword=N__np:1c,2,3 --keyword=%__ \
#		--language=perl
#EOT
	return($cmd);
}
sub find_sources {
	my $srcs = [];
    
	File::Find::find( sub {
		my $path = $File::Find::name;
		#say "$_ eq 'CVS'";
		return if( lc($path) =~ /\.(mcr|pl|swf|po|mo|pot|bak|swp|xml|log|css|xsl|png|jpg|gif|js|rlx|dtd|~)$/ );
		return if ($path =~ /(CVS)$/);
		return if ($path =~ /\/(CVS)\//);
		#	printf("got $_ : $path"); <STDIN>;
		push(@$srcs,$path) if( -f $path );
		
	},@{$defaults->{_src_roots}});
    
    if(scalar @$srcs ) {
    		my $tot = create_potfiles($srcs);
    		say("Wrote $tot lines")
    } else {
    	say("No source files found? Check src root.");
    }
    <STDIN>;

}
sub create_potfiles {
	my $srcs = shift;
	my $tot = 0;
	my $fh = new IO::File "> $defaults->{_potfiles}";
	if( $fh ) {
		foreach my $file (@$srcs) {
			print $fh "$file\n";
			$tot++;
		}
		$fh->close;
		
	} else {
		die("Can't open \"$defaults->{_potfiles}\" ($!)");
	}
	return($tot);
	
}
sub set_group {
	my $gid   = POSIX::getgrnam($defaults->{_group});
	#my $x = $gid ?  $defaults->{_group} ($gid)" : "no group $defaults->{_group}";	
}
sub dir_walk
{
    my ($hashref, $code, $args) = @_;
    while (my ($k, $v) = each(%$hashref)) {
    	my @newargs = defined($args) ? @$args : ();
        push(@newargs, $k);        
        if (ref($v) eq 'HASH') {
            dir_walk($v, $code, \@newargs);
        } elsif( ref($v) eq 'ARRAY') {
        		my $path = join('/',@newargs);
        		foreach my $s (@$v) {
					say("test2: $path/$s");
				}
        	
        }
        else {
        	push(@newargs,$v);
            $code->(@newargs);
        }
    }
}



sub build_dir_tree {
	my $total = 0;
	my @langs = qw(fr); # get this from Conststants.pm
	my @locale_catagories = qw(LC_MESSAGES); #this too

	my $tree = {
		translated	=> {
			po	=> @langs,
			mo	=> @langs
		}
		,
		pseudo	=> {
			po 	=> '',
			mo	=> ''
		},
		untranslated	=> {
			po	=> '',
			mo 	=> ''
		}
	};
	# seed local category dire for languages
	foreach my $l (@langs) {
		foreach my $c (@locale_catagories) {
			$tree->{$l}->{$c} = '';
		}
	}
	dir_walk($tree
	, sub {
    my $path = join('/',@_);
	    if( ! -d $path ) {
	    	eval {	
	    		make_path($path);
#		    	make_path($path, { 
#		    		verbose 	=> $defaults->{_verbose}, 
#		    		mode 		=> 0775
#		    	});
	    	};
	    		
	    	
#	    	if(@_) {
			if( ! -d $path ) {
	    		say("Error: Could not create \'$path\' ($!)"); <STDIN>;
	    	} else {
	    		$total++;
	    		say("Created \'$path\' ok.");
	    	}
	    }  
	});

 print "Created $total dirs hit enter to continue."; <STDIN>;
}
sub build_menu {
	my $defaults = shift;
	my $functions = {
		0		=>  {
			text		=> "create directory tree",
			handler		=> \&build_dir_tree
		},
		1		=>  {
			text		=> sprintf("change sources [%s]",join(',',@{$defaults->{_src_roots}})),
			handler		=> \&change_src
		},
		2		=> {
			text	=> sprintf("language [%s]",$defaults->{SiteLang}),
			handler	=> \&change_lang
			
		},
		3		=> {
			text	=> sprintf("feature [%s]",$defaults->{_feature}),
			handler	=> \&change_feature
			
		},
		4		=> {
			text	=> sprintf("site local [%s]",$defaults->{SiteLocale}),
			handler	=> \&change_locale
			
		},
		5		=>  {
			text		=> sprintf("scan sources [%s]",join(',',@{$defaults->{_src_roots}})),
			handler		=> \&find_sources
		},
		6		=>  {
			text		=> "run xgettext",
			handler		=> \&run_xgettext
		},
	
		10 		=>  {
			text		=> 'exit',
			handler		=> sub { say("Bye");exit(0); }
		}
	};
	return($functions);
}
sub change_src {
	print "Enter new source directory or file (newline to finish)\n";
	my $srcs = [];
	my $val = "";
	# save origionals sources in case user entered nothing
	my $orig_srcs = $defaults->{_src_roots};
	$defaults->{_src_roots} = [];
	while(1) {
		my $val = query_line("Enter new source");
		chomp($val);
		last if($val =~/^\s*$/); #
		push(@{$defaults->{_src_roots}},$val);
		
	}
	$defaults->{_src_roots} = $orig_srcs unless(scalar(@{$defaults->{_src_roots}}));
	
}
sub change_lang {
	my $key = 'SiteLang';
	my $val = query_line("Enter new language");
	$defaults->{$key} = $val if(defined($val));
}

sub change_locale {
	my $key = 'SiteLocale';
	my $val = query_line("Enter new locale");
	$defaults->{$key} = $val if(defined($val));
}
sub change_feature {
	my $key = '_feature';
	my $val = query_line("Enter new feature");
	$defaults->{$key} = $val if(defined($val));
}
sub query_line {
	my $msg = shift;
	clear() if(@_); # clear is 2 args given
	print "$msg: ";
	my $input = <STDIN>;
	chomp($input);
	return $input if($input =~ /^\w+$/ );
	return undef;
}
sub nop {
	say("In nop");
}
sub get_defaults {
	my $defaults = shift;
	foreach my $key (keys %$defaults ) {
		next if( $key =~ /^_/ ); # underscores are local and not in constants
		if(exists($TUSK::Constants::I18N{$key})) {
			$defaults->{$key} = $TUSK::Constants::I18N{$key} || $defaults->{$key};
		}
		
	}
}
sub puterror {
	my $msg = shift;
	clear();
	print "$msg\nHit and key to continue.";
	<STDIN>;
}

sub pause {
	my $msg = shift;
	print "$msg\nHit and key to continue.";<STDIN>;
}
sub clear { system('clear'); }

