#!/usr/bin/perl

use strict;
use warnings;
use MySQL::Password;
use HSDB4::Constants;
use HSDB45::Course;
use TUSK::Application::Course::User;

use Data::Dumper;
 
HSDB4::Constants::set_user_pw(get_user_pw);
my $dbh = DBI->connect(HSDB4::Constants::db_connect());
my @schools = HSDB4::Constants::schools();

main();


sub main {
    $dbh = HSDB4::Constants::def_db_handle();
    migrate_course_users();
}

sub migrate_course_users {
    my ($roles, $labels) = get_roles_labels();

    print 'Starting - ' . qx{date} . "...\n" ;

    foreach my $school (@schools) {
	my $school_db = HSDB4::Constants::get_school_db($school);
	my %data = ();
	print "\n$school:\n";

	my $time_period_id = @{get_eternity_time_period($school_db)}[0];
	if (!$time_period_id){
	    print "Warning: No 'eternity' time period exists for school $school .Skipping... \n";
	    next;
	}
	print "Time Period ID: ".$time_period_id."\n";

	eval {
	    my %course_apps = map { $_->primary_key() => TUSK::Application::Course::User->new({ course => $_ }) } HSDB45::Course->new(_school => $school)->lookup_conditions("type=\"committee\"");

	    my $sth = $dbh->prepare(qq(select * from $school_db\.link_course_user));
	    $sth->execute();

	    my $processed = 1;
	    my $added = 1;
	    while (my $row = $sth->fetchrow_hashref()) {
		unless (exists $course_apps{$row->{parent_course_id}}) {
		    $data{missing}{Courses}{$row->{parent_course_id}}++;
		    next;
		}

		my ($user_role_id, @user_label_ids) = (0, ());
		if (defined $row->{roles}) {
		    foreach my $role_token (split(',', $row->{roles})) {
			if (exists $labels->{$role_token}) {
			    push @user_label_ids, $labels->{$role_token};
			} elsif (exists $roles->{$role_token}) {
			    $user_role_id = $roles->{$role_token};
			}
		    }
		}

	    $course_apps{$row->{parent_course_id}}->add({
			user_id         => $row->{child_user_id}, 
			time_period_id  => $time_period_id,
			site_id         => $row->{teaching_site_id},
			sort_order      => $row->{sort_order},
			role_id         => $user_role_id,
			virtual_role_id => \@user_label_ids,
			author          => 'script',
		    });
		    $added++;

		$processed++;
	    } ## all course user records in a school db
	    $sth->finish();

    	    print "\tRecords: $processed processed from course, $added added into course_user\n";		
	    print_error(\%data);

	};
	print $@ if ($@);
    } ### each school loop	
    print "\nCompleted - " . qx{date} . "\n" ;
}

sub print_error {
    my $data = shift;

    foreach my $type (('Periods', 'Courses')) {
	if ($data->{missing}{$type} && keys %{$data->{missing}{$type}}) {
	    print "\tMissing $type: [output format: course-id(number-of-users)]\n\t";
	    print join(',  ', map { $_ . ' (' . $data->{missing}{$type}{$_} . ')' } (keys %{$data->{missing}{$type}}));
	    print "\n";
	}
    }
    print "\n";
}

sub get_roles_labels {
    my $roles = TUSK::Permission::Role->lookup(undef, undef, undef, undef, [TUSK::Core::JoinObject->new('TUSK::Permission::FeatureType', { joinkey => 'feature_type_id', jointype => 'inner', joincond => "feature_type_token ='course'" })]);
    my (%roles, %labels) = ((), ());
    foreach (@$roles) {
	if ($_->getVirtualRole()) {
	    $labels{$_->getRoleDesc()} = $_->getPrimaryKeyID();
	} else {
	    $roles{$_->getRoleDesc()} = $_->getPrimaryKeyID();
	}
    }
    return (\%roles, \%labels);
}

sub get_eternity_time_period {
    my $school_db = shift;
    my $sql = "SELECT time_period_id FROM $school_db.time_period WHERE period = \"eternity\"";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $time_period_id = $sth->fetchall_arrayref;
    $sth->finish();
    return @{$time_period_id}[0];
}
