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


#!/usr/bin/perl

use strict;
use warnings;
use TUSK::Application::Eval::Maker;
use TUSK::Application::Eval::MakerTemplate;
use MySQL::Password;
use HSDB4::Constants;
use Getopt::Long;

main();

sub main {

    my ($school, $time_period, $academic_year);

    eval {
	my $rc = GetOptions( "school=s"          => \$school,
			     "time_period=s"     => \$time_period,
			     "academic_year=s"   => \$academic_year,
			   );
    };

    unless (defined $school && defined $time_period && defined $academic_year) {
	die "Usage batch_create_new_evals.pl --school=XXXX --time_period=XX --academic_year=XXXX\n";
    }

    my $tmpl = TUSK::Application::Eval::MakerTemplate->new( 
		  { school => $school,
		    period => $time_period,
		    academic_year => $academic_year,
		  });
    my ($created_evals, $existing_evals, $errors) = createEvals($tmpl);
    printMessage($created_evals, $existing_evals,$errors);
}

sub createEvals {
    my $tmpl = shift;
    my ($usn, $pwd) = get_user_pw();
    my $codes = $tmpl->getCourseCodes();
    my ($available_date, $due_date) = $tmpl->getStartEndDates();
    my (%created_evals, %existing_evals, %errors);

    foreach my $code (@{$codes}) {
	$tmpl->setCourse($code->[0]);
	my $teaching_site = $tmpl->getTeachingSite();
	my $eval_title = $tmpl->getEvalTitle();

	unless ($tmpl->evalExists()) {
	    ### creat an eval even though there is no teaching site
	    ### in fact, there are more than one teaching site for some course
            my $evalmaker;
		$evalmaker = TUSK::Application::Eval::Maker->new(
		          { username       => $usn,
			    password       => $pwd,
			    school         => $tmpl->getSchool()->getSchoolName(),
			    course         => $tmpl->getCourse(),
			    time_period    => $tmpl->getTimePeriod(),
			    teaching_site  => $tmpl->getTeachingSite(),
			    available_date => $available_date,
			    due_date       => $due_date,
			    eval_title     => $eval_title,
			});

		if ($evalmaker->clone($tmpl->getPrototypeEvalID())) {
		    $created_evals{$code->[0]} = $evalmaker->getEvalID() . " $eval_title";
		} else {
		    $errors{$code->[0]} = '';
		}
	} else {
	    $existing_evals{$code->[0]} = $eval_title;
	}
    }

    return (\%created_evals, \%existing_evals, \%errors);
}

sub printMessage {

    my ($created_evals, $existing_evals, $errors) = @_;

    if (%{$errors}) {
	print "Problems creating evals for these courses:\n";
	foreach my $code (sort keys %{$errors}) {
	    print "$code\n";
	}
	print "\n";
    }
    
    if (%{$created_evals}) {
	print "New Evals:\n";
	foreach my $code (sort keys %{$created_evals}) {
	    print "$code, ",  $created_evals->{$code}, "\n";
	}
	print "\n";
    }
	
    if (%{$existing_evals}) {
	print "Evals already exist:\n";
	foreach my $code (sort keys %{$existing_evals}) {
	    print "$code, ", $existing_evals->{$code}, "\n";
	}
    }
}
