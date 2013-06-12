# Copyright 2013 Albert Einstein College of Medicine of Yeshiva University 
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

package Zoo::Tool;

use strict;
use warnings;
use Carp (); $Carp::CarpInternal{(__PACKAGE__)}++;
use Data::Dumper ();

sub new
{
	return __PACKAGE__;
}

sub dump_data # ($var, %opts) 
{
	no warnings 'uninitialized';
	my ($this, $data, %opt) = (shift, shift, Indent => 1, 'Sortkeys' => 1, @_); # name, string, and Data::Dumper options
	my ($name, $string, $dumper, @bad);
	$name =  delete $opt{name};
	$string = delete $opt{string};
	$dumper = Data::Dumper->new([$data], [$name]);
	@bad = grep { ! $dumper->can($_) } keys %opt;
	@bad and Carp::croak("invalid option(s) " . join(', ', @bad));
	$dumper->$_($opt{$_}) for keys %opt;
	return $dumper->Dump if $string;
	print '#'x80, "\n\n";
	print $dumper->Dump;
	print "\n";
	return $this;
}

sub dump_var { goto &dump_data }

my %SIGIL = (GLOB => '*', IO => '*', CODE => '&', SCALAR => '$', ARRAY => '@', HASH => '%', FORMAT => '#');

sub dump_symtab # ($module_name)
{
	no strict 'refs';
	my ($this, $package) = @_;
	my ($source, %dup) = ($package);
	{
		defined %{"${package}::"} and last;
		eval "require $package" and last;
		$@ =~ s/\s+at\s+(.*?)\z//s; # remove trailing " at (eval 1) line 3.\n"
		Carp::croak($@);
	}
	$source =~ s/::/\//g;
	$source = $INC{"$source.pm"};
	print '#'x80, "\n# $package: $source\n",'#'x80, "\n\n";
	for my $symbol (sort keys %{"${package}::"})
	{
		for my $type (qw(IO CODE SCALAR ARRAY HASH FORMAT))
		{
			my ($ref, $dump);
			defined($ref  = *{"${package}::${symbol}"}{$type}) or next;
			$type eq 'SCALAR' and !defined($$ref) and next; # see perlref(1) for the reason
			if ($type eq 'IO') {
				# Data::Dumper can not handle IO correctly, perhaps except standard ones.
				$dump = "= $ref";
			} elsif ($type eq 'CODE') {
				# We want the memory location for CODE to see if two subs are the same.
				$dump = "= $ref";
				$dup{$ref}++ and $dump .= ' *';
			} else {
				my $d = Data::Dumper->new([$ref], [$symbol]);
				$d->Indent(1);
				$d->Deepcopy(1);
				$d->Sortkeys(1);
				($dump = $d->Dump) =~ s/^.*?=/=/; # remove $VAR
				chomp $dump;
			}
			print "$SIGIL{$type}${package}::$symbol ", $dump, "\n";
		}
	}
	print "\n";
	return $this;
}

1;
