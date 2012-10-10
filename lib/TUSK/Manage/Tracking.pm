package TUSK::Manage::Tracking;

use strict;

use TUSK::Tracking;
use HSDB4::Constants;
use TUSK::ContentTree;
use HSDB4::DateTime;
use TUSK::Functions;
use TUSK::Constants;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub delete_process{
    my ($req) = @_;

    $req->{tracking}->delete($un, $pw);

    return (1, "Tracking Deleted");

}

sub addedit_process{
    my ($req, $fdat, $udat) = @_;
    my ($rval, $msg);

    if (!$fdat->{content_id}){
	$fdat->{content_id} = $fdat->{folder};
    }
    if ($fdat->{alldates}){
	$fdat->{start_date} = '1000-01-01';
	$fdat->{end_date} = '2037-12-31';
    }
    if ($fdat->{action} eq "add"){
	$req->{tracking} = TUSK::Tracking->new(_school => $req->{school});
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	$req->{tracking}->set_field_values(time_period_id => $timeperiod);
    }
    
    $req->{tracking}->set_field_values( course_id => $req->{course_id},
					content_id => $fdat->{content_id},
					start_date => $fdat->{start_date},
					end_date => $fdat->{end_date},
					user_group_id => $fdat->{usergroup_id},
					);

    ($rval,$msg) = $req->{tracking}->save($un, $pw);
    return ($rval, $msg) if ($rval == 0);

    $req->{tracking}->calculate($un, $pw);

    if ($fdat->{action} eq "add"){
	return (1, "Report added");
    }else{
	return (1, "Report Updated");
    }

}

sub addedit_pre_process{
    my ($req, $fdat, $udat) = @_;
    my $data;

    if ($fdat->{page} eq "add"){
	$req->{image}="CreateNewReport";

	my $tree = new TUSK::ContentTree($req->{course}->child_contentref, "Collection");

	for (my $i=0; $i<scalar (@{$tree->{branches}}); $i++){
	    my $branch = @{$tree->{branches}}[$i];
	    my $dashes = "&nbsp;" x $branch->{tab};
	    my $label = $branch->{content}->field_value("title");
	    $label = substr($label,0,30) . "..." if (length($label) > 30);
	    my $id = $branch->{content}->primary_key;
	    $data->{options} .=  "<option value=\"" . $id . "\" >" . $dashes . "\\_ " . $label . "\n";

	}
    }else{
	$req->{image}="ModifyReport";
    }
    
    $data->{periods} = [];

    if ($req->{type} eq "course"){
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	$data->{usergroups} = [ $req->{course}->sub_user_groups($timeperiod) ];	
    }
    
    return $data;
}

sub show_pre_process{
    my ($req, $timeperiod, $udat) = @_;
    my $data;
    $timeperiod = TUSK::Functions::course_time_periods_emb($req, $timeperiod, $udat);

    $data->{tracking} = [ TUSK::Tracking->new(_school=>$req->{school})->lookup_conditions("course_id = ".$req->{course_id} . " and time_period_id = " . $timeperiod , "order by sort_order") ];
    $data->{tracking_count} = scalar(@{$data->{tracking}});
    
    return $data;
}

sub show_process{
    my ($req, $sort, $data) = @_;
    my ($rval, $msg, $index, $insert);
   
    ($index, $insert) = split('-', $sort) if ($sort);
	
    splice(@{$data->{tracking}}, ($insert-1), 0, splice(@{$data->{tracking}}, ($index-1),1));
    
    for(my $i=0; $i < $data->{tracking_count}; $i++){
	@{$data->{tracking}}[$i]->set_field_values( sort_order=>10*($i+1));
	($rval, $msg) = @{$data->{tracking}}[$i]->save($un, $pw);
	return ($rval, $msg, $data) if ($rval < 1);
    }

    return (1, "Order Successfully Changed", $data);

}


1;
