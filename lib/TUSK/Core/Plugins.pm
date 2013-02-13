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




package TUSK::Core::Plugins;

use 5.006;
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use Data::Dumper;
use File::Basename;
use File::Find;
use Carp;


=head1 NAME

TUSK::Core::Plugins - Simple plugin method interface.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use TUSK::Core::Plugins;

    my $plugins = TUSK::Core::Plugins->new();
    $plugins->getplugins();
    foreach my $p ($plugins->plugins) {
        printf("name = %s\n",ref $p);
	}
	
	my $plugins = TUSK::Core::Plugins->new(
        debug => 0,
        plugin_dirs => [ 'Source', 'Plugins', '/tmp/foo' ],
        methods     => [ 'metadata' ],
        regex       => "^Plugin[0-9]",
        uselibs     => [ '/usr/local/tusk/current/lib' ] 
      );
	 
    $plugins->getplugins();
	printf("total plugins found %d\n",$plugins->tot_plugins());
	printf("total plugin dirs found %d\n",$plugins->tot_plugin_dirs());
	printf("total errors found %d\n",$plugins->has_errors());
	foreach my $plugin ($plugins->plugins) {
        $plugin->metadata({ data => $data, url => $url });
	}
    
    
=head1 DESCRIPTION
	
	This class allows users to load plugins from multible directory locations.
	Class objects are returned to do whatever with. The goal is to be able to
	new plugins to existing code without hardcoding the class in the caller.
	
=head1 EXPORT

Nothing.

=head1 SUBROUTINES/METHODS

=head2 new
	
	Class constructor takes the following arguments.
	
	plugin_dirs  : array ref of directories to search for plugins. 
	               Absolute or relative values can be used in the case of relative
	               arguments the parents directory location will be prepended.	                
	methods      : array ref of expected methods a class 'can' do to be a valid plugin.
	regex		 : regex scalar which plugin candidates must match.
	uselibs		 : Allows including non standard libraries added to @INC
	debug		 : Turns debugging on/off debug messages use 'carp'
	
=cut

sub new {
        my $class = shift; # don't allow class ref's, die?
        my %args  = @_;
        my $self = {
        		
                regex                   => '^[A-Za-z]+[A-Za-z0-9_-]*[A-Za-z0-9]+\.pm$',
                uselibs					=> [],
                methods					=> [],
                _plugin_dirs			=> [],
                debug                   => 0,
                _default_dir			=> undef, 
                _default_subdir			=> 'Source',  
                _plugins                => [],
                _plugin_cache			=> {},
                _errors				 	=> []
                
               
        };


        bless $self, ref($class) || $class; # TODO: concider getting rid of ref (cloning)
        $self->_init(\%args);

        return $self;
}

#### Public modules

=head2 tot_plugins()

	Returns the number of valid plugins found.
	
=cut
sub tot_plugins {
	my $this = shift;	
	return(scalar $this->plugins());
}
=head2 uselibs()

	Typically a plugin includes it's parent dirctory in @INC before creation.
	This allows users to insert a more diverse @INC path.
	
=cut
sub uselibs {
	my $this = shift;
	my $key = 'uselibs';
	if( @_) {
		my $libs = shift;
		if(ref $libs eq 'ARRAY') {
			$this->{$key} = $libs;
		} else {
			die("The 'uselibs' argument must be a array reference.")
		}
	}
	return(@{$this->{$key}});
}
=head2 methods()

	Allows user to set required methods.
	
=cut

sub methods {
	my $this = shift;
	my $key = 'methods';
	if( @_) {
		my $methods = shift;
		if(ref $methods eq 'ARRAY') {
			$this->{$key} = $methods;
		} else {
			die("The 'methods' argument must be a array reference.")
		}
	}
	return(@{$this->{$key}});
}
=head2 plugin_dirs()

	Returns an array of valid plugin search directories.
	
=cut
sub plugin_dirs {
	my $this = shift;
	my $key = '_plugin_dirs';
	if( @_) {
		my $dirs = shift;
		if(ref $dirs eq 'ARRAY') {
			foreach my $dir (@{$dirs}) {
				$this->_add_dir($dir);
			}
		} else {
			die("The 'plugin_dirs' argument must be a array reference.")
		}
	}
	return(@{$this->{$key}});
}

=head2 errors() 

    Returns array of possible error messages.
 
=cut

sub errors {
	my $this = shift;
	my $key = '_errors';
	return(@{$this->{$key}});
}
sub has_errors {
    my $this = shift;	
	return(scalar $this->errors());
}
=head2 plugins()

	Returns an array of plugin modules found.
	
=cut
sub plugins {
	my $this = shift;
	my $key = '_plugins';
	return(@{$this->{$key}});
}
=head2 tot_plugin_dirs()

	Returns the number of valid plugin directories.
	
=cut
sub tot_plugin_dirs {
	my $this = shift;	
	return(scalar $this->plugin_dirs());
}

=head2 regex()

	Sets and gets the regex used to match plugin modules.
	ie. ^[A-Za-z]*\.pm$
	
=cut
sub regex {
	my $this = shift;
	my $key = 'regex';
	$this->{$key} = shift if(@_);
	return $this->{$key};
}

=head2 debug()

   Turns debugging on off (1|0).
   
=cut
sub debug {
	my $this = shift;
	my $key = 'debug';
	$this->{$key} = shift if(@_);
	return $this->{$key};
}

=head2 getplugins() 

	Tells the module to initilise itself and load  modules.

=cut
sub getplugins {
	my $this = shift;
	if( $this->_validate_dirs() ) {
		if(my $tot = $this->_get_plugins) {
			$this->logger("($tot) plugins found");
		} else {
			$this->_error("No plugin directories found");
		}
	} else {
		$this->_error("No plugin dirs found"); # die ?
	}
	
}
sub _error {
	my $this = shift;
	my $key = '_errors';
	if( @_ ) {
		my $err = shift;
		push(@{$this->{$key}},$err);
		$this->logger($err);
	}
	
}
#### Private modules
## Perform argument handling and defaults here

sub _init {
    my ($this,$args) = @_;
    $this->{_default_dir} = $this->_default_base_dir();
    $this->plugin_dirs($args->{plugin_dirs}) 	if(ref $args->{plugin_dirs});
    $this->methods($args->{methods}) 	if(exists $args->{methods});
    $this->uselibs($args->{uselibs}) 	if(exists $args->{uselibs});
    $this->regex($args->{regex}) 		if(exists $args->{regex});
    $this->debug($args->{debug})		if(exists $args->{debug});
    unshift @INC,$this->uselibs;
}
sub logger {
	my $this = shift;
	my $err = "n/a";
	$err = shift if(@_);
	carp($err) if($this->debug());
}
## This is the directory where plugin subdirs will be checked if
## absolute paths or no plugin directory is specified.
## It will default to the caller's directory location.
sub _default_base_dir {
	my $this = shift;
	# from Carp
	my %call_info;
	@call_info{ qw(pack file) } = caller(2);
	my $path = $call_info{file};
	return dirname(abs_path($path));
}
# Search a plugin director and add any valid plugins
sub _search_plugin_dir {
	my ($this,$dir) = @_;
	$this->logger("search dir $dir");
	my $regex = $this->regex;
	File::Find::find( {
		# anon subroutine to do out work
		wanted   => sub {
			 my $name = basename($_);
			 if( -f $File::Find::name ) {
			 	$this->logger("Found $dir/$name");
			 	if($name =~ /$regex/) {			 		
			 		$this->_is_valid_package($File::Find::name,$dir);
			 	} else {
					$this->logger("File ($name) failed regex [$regex]");
				}
			 	
			 }
			 
		},
		 no_chdir => 1, # don't cd to curr dir
	},$dir);
}

# Try and decide if this is a valid package.
sub _is_valid_package {
	my ($this,$pkg_path,$root_dir) = @_;
	$this->logger("_is_valid_package $root_dir $pkg_path ");
	my $valid = 0;
	my $pkg_name = $this->_get_pkg_name("$pkg_path");
	if( $pkg_name ) {
		$this->logger("package $pkg_name testing");
		# localize @INC so we don't taint it for later.
		local @INC = @INC;
		unshift @INC, $root_dir;
		eval "CORE::use $pkg_name";
		if( $@ ) {
                 $this->_error(sprintf("Cannot construct package (%s) [%s]",$pkg_name,$@));
                  return $valid;
        	}
        ## could handle require here;
		if($pkg_name->can('new')) {
			my $o = $pkg_name->new();
			if( ref $o eq $pkg_name) {
				my $valid = 1;
				foreach my $method ($this->methods) {
					$this->logger("Testing $pkg_name for method $method");
					if( ! $pkg_name->can($method) ) {
						$this->logger("Package $pkg_name cannot do $method");
						$valid = 0;
						last;
					}
				}
			   if( $this->_is_cached($pkg_path)) {
			   		$this->logger("Duplicate plugin [$pkg_path]");
			   	
			   } else {
			   		# let's cache the plugin signature so as not to add twice. ie. soft link.
               		
               		$this->_add_plugin($o,) if($valid);
			   }
			   
            }
			
			
			
		} else {
			$this->logger("pkg $pkg_name can't instantiate");
		}
		
	} else {
		$this->logger("Can't find package name for ($pkg_path)");
	}
	return $valid;
}
# test if a plugin has already passed tests and is added to the plugin stack
# returns true is already add else adds to the cache and returns false
sub _is_cached {
	my ($this,$path)  = @_;
	my $key = '_plugin_cache';
	return(1) if( exists($this->{$key}->{$path}));
	$this->{$key}->{$path} = 1;
	return(0);
}
# Trys and get the package name by the 'require' statement.
# This is a package name can't necessarily due to @INC being changed. 
sub _get_pkg_name {
        my ($this,$path) = @_;
        my $fh = IO::File->new($path, "r");
        my $name = undef;
        if($fh) {
                while (my $line = <$fh>) {
                        next if($line =~ /^\s*$/);
                        next if($line =~ /^\s*#/);
                        if ( $line =~ m/^\s*package\s+([^;]+)\s*;/i ) {
                                $name = $1; # untaint?
                                $name =~ s/\.pm//;
                        }
                }

        } else {
                $this->_error("Can't open package file $path ($!)");

        }
        return $name;
}

# Iterate thru and valid plugin search directories

sub _get_plugins {
	my $this = shift;
	
	foreach my $dir ($this->plugin_dirs()) {
		my @plugins = $this->_search_plugin_dir($dir);
	}
	return($this->tot_plugins() );
}
## empties the plugin array ref and returns the old array value
sub _all_plugin_dirs {
	my $this = shift;
	my $key = '_plugin_dirs';
	my @dirs = @{$this->{$key}};
	$this->{$key} = [];
	return @dirs;
}
## Make sure given directories are valid and add full path to relative paths
sub _validate_dirs {
	my $this = shift;
	
	if($this->tot_plugin_dirs) {
		my @dirs = $this->_all_plugin_dirs();
		foreach my $dir (@dirs) {
			# check if absolute path if not use default dir as root
			if( $dir =~ /^\// ) {
				$this->_add_dir($dir);
			} else {
				$this->_add_dir($this->{_default_dir} . "/" . $dir);
			}
		}			
		
	} else {
		# no args give use default path
		
		$this->_add_dir($this->{_default_dir} . "/" . $this->{_default_subdir});
	}
	return($this->tot_plugin_dirs);
}

sub _add_plugin {
	my ($this,$obj) = @_;
	my $key = '_plugins';
	push(@{$this->{$key}},$obj);
}
sub _add_dir {
	my ($this,$dir) = @_;
	$this->logger("adding dir $dir");
	my $key = '_plugin_dirs';	
	if( -d $dir ) {
		push(@{$this->{$key}},$dir) unless(grep(/$dir/, @{$this->{$key}}));
	} else {
		$this->_error("Plugin directory invalid ($dir) [$!]");
	}
}


=head1 AUTHOR

TUSK Development Team, C<< <<tuskdev at tufts.edu>> >>

=head1 BUGS

Please report any bugs or feature requests to C<< <<tuskdev at tufts.edu>> >>




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TUSK::Core::Plugins



=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 TUSK Development Team.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of TUSK::Core::Plugins
