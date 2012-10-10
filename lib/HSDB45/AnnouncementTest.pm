package HSDB45::AnnouncementTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use HSDB45::Announcement;
use HSDB45::UserGroup;

my %ug1_announcements = (1  => 1,
			 2  => 1,
			 4  => 1,
			 11 => 1,
			 12 => 1,
			 14 => 1,
			 21 => 1,
			 22 => 1,
			 24 => 1);

my %ug2_announcements = (1  => 1,
			 2  => 1,
			 4  => 1,
			 11 => 1,
			 12 => 1,
			 14 => 1,
			 21 => 1,
			 22 => 1,
			 24 => 1);

my %c1_announcements = (26 => 1,
			27 => 1,
			29 => 1,
			36 => 1,
			37 => 1,
			39 => 1,
			46 => 1,
			47 => 1,
			49 => 1);

my %c2_announcements = (26 => 1,
			27 => 1,
			29 => 1,
			36 => 1,
			37 => 1,
			39 => 1,
			46 => 1,
			47 => 1,
			49 => 1,
			66 => 1);

# These are defined in base_course.sql
my @course_ids = (1, 6);
# These are defined in base_user_group.sql
my @user_group_ids = (301, 325);

sub sql_files {
    return qw(base_announcement.sql base_course.sql base_user_group.sql);
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {

}

sub tear_down {

}

sub test_sanity {
    assert(1, "Test::Unit is broken!");
}

sub test_direct_instantiation {
    for(my $i = 1; $i <= 50; ++$i) {
	my $announcement = HSDB45::Announcement->new(_school => 'regress', _id => $i);
	assert($announcement->primary_key() == $i,
	       "Instantiating announcements directly failed!");
    }
}

sub test_ug1_inappropriate_announcements {
    my $ug1 = HSDB45::UserGroup->new(_school => 'regress', _id => $user_group_ids[0]);
    inappropriate_announcements($ug1, %ug1_announcements);
}

sub test_ug1_missing_announcements {
    my $ug1 = HSDB45::UserGroup->new(_school => 'regress', _id => $user_group_ids[0]);
    missing_announcements($ug1, %ug1_announcements);
}

sub test_ug2_inappropriate_announcements {
    my $ug2 = HSDB45::UserGroup->new(_school => 'regress', _id => $user_group_ids[1]);
    inappropriate_announcements($ug2, %ug2_announcements);
}

sub test_ug2_missing_announcements {
    my $ug2 = HSDB45::UserGroup->new(_school => 'regress', _id => $user_group_ids[1]);
    missing_announcements($ug2, %ug2_announcements);
}

sub test_c1_inappropriate_announcements {
    my $c1 = HSDB45::Course->new(_school => 'regress', _id => $course_ids[0]);
    inappropriate_announcements($c1, %c1_announcements);
}

sub test_c1_missing_announcements {
    my $c1 = HSDB45::Course->new(_school => 'regress', _id => $course_ids[0]);
    missing_announcements($c1, %c1_announcements);
}

sub test_c2_inappropriate_announcements {
    my $c2 = HSDB45::Course->new(_school => 'regress', _id => $course_ids[1]);
    inappropriate_announcements($c2, %c2_announcements);
}

sub test_c2_missing_announcements {
    my $c2 = HSDB45::Course->new(_school => 'regress', _id => $course_ids[1]);
    missing_announcements($c2, %c2_announcements);
}

sub inappropriate_announcements {
    my $object = shift();
    my %announcements = @_;

    my @inappropriate_announcements;
    foreach my $announcement ($object->announcements()) {
	unless(defined($announcements{$announcement->primary_key()})) {
	    push(@inappropriate_announcements, $announcement->primary_key());
	}
    }

    assert(scalar(@inappropriate_announcements) == 0,
	   "Object " . $object->primary_key() . " incorrectly reports the following announcements as current: " .
	   join(', ', @inappropriate_announcements));
}

sub missing_announcements {
    my $object = shift();
    my %announcements = @_;

    foreach my $announcement ($object->announcements()) {
	delete $announcements{$announcement->primary_key()};
    }

    my @missing_announcements = sort { $a <=> $b } keys(%announcements);
    assert(scalar(@missing_announcements) == 0,
	   "Object " . $object->primary_key() . 
	   " erroneously failed to display the following announcements as current: " .
	   join(', ' => @missing_announcements));
}

sub test_create_and_update_and_destroy {
    my $announcement = HSDB45::Announcement->new(_school => "regress");
    assert($announcement->isa("HSDB4::SQLRow"), "wrong base class");
    assert(ref $announcement eq "HSDB45::Announcement", "wrong class");
    $announcement->set_field_values("start_date" => "2003-03-09",
				"expire_date" => "2003-03-10",
				username => "regress_school_admin",
				body => "this is an announcement"
				);
    my $id = $announcement->save();

    $announcement = HSDB45::Announcement->new(_school => "regress", _id => $id);    
    assert($announcement->primary_key == $id, "unexpected primary key value");
    assert($announcement->field_value("start_date") eq "2003-03-09", "wrong start_date");
    assert($announcement->field_value("expire_date") eq "2003-03-10", "wrong expire_date");
    assert($announcement->field_value("username") eq "regress_school_admin", "wrong username");
    assert($announcement->field_value("body") eq "this is an announcement", "wrong announcement");

    $announcement->field_value("start_date", "2003-04-05");
    $announcement->field_value("expire_date", "2003-04-10");
    $announcement->field_value("username", "regress_course_director");
    $announcement->field_value("body", "this is not an announcement");
    $announcement->save();

    $announcement = HSDB45::Announcement->new(_school => "regress", _id => $id);    
    assert($announcement->primary_key == $id, "unexpected primary key value");
    assert($announcement->field_value("start_date") eq "2003-04-05", "wrong start_date");
    assert($announcement->field_value("expire_date") eq "2003-04-10", "wrong expire_date");
    assert($announcement->field_value("username") eq "regress_course_director", "wrong username");
    assert($announcement->field_value("body") eq "this is not an announcement", "wrong announcement");

    $announcement->delete();

    $announcement = HSDB45::Announcement->new(_school => "regress", _id => $id);
    assert(!$announcement->primary_key,"failed to delete announcement");
}

1;
