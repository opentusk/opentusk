#!/usr/bin/perl

##################################################################
# Import Tool for importing National Competencies
#
# NOTE: Requires a competency type of "Competency", "Competency Category" and "Supporting Information" for the school.
# Please create these from the web interface before running the script. 
#
# Usage: import_national_competencies --file=<file.csv> --url=<url Eg.https://services.aamc.org/30/ci-school-web/pcrs/PCRS.html#> --school=<school_name Eg. Medical>
# Example: import_national_competencies --file=national_competencies.csv --url=https://services.aamc.org/30/ci-school-web/pcrs/PCRS.html# --school=Medical
#
# Please try again with the appropriate parameters.
##################################################################

use strict;
use warnings;

use Getopt::Long;
my ($file, $base_url, $school_name);

BEGIN {
    GetOptions("file=s" => \$file,
	       "url=s" => \$base_url,	       
	       "school=s" => \$school_name
	       );

    if (!$file or !$base_url or !$school_name) {
	print "Usage: import_national_competencies --file=<file.csv> --url=<url Eg.https://services.aamc.org/30/ci-school-web/pcrs/PCRS.html#> --school=<school_name Eg. Medical>\n
Example: import_national_competencies --file=national_competencies.csv --url=https://services.aamc.org/30/ci-school-web/pcrs/PCRS.html# --school=Medical\n";
	exit;
    }
}


use HSDB4::Constants;

use TUSK::Import;
use TUSK::Enum::Data;
use TUSK::Feature::Link;

use TUSK::Application::Competency::Competency;
use TUSK::Feature::Link;
use TUSK::Competency::Competency;
use TUSK::Competency::Hierarchy;

my $import;
my @objectives;

main();

sub main {
    # Check the time of the passed file
    die "The file $file does not exist\n" unless(-f $file);
    getCompetencies();
    saveCompetencies();
}

sub getCompetencies {
    $import = TUSK::Import->new;
    $import->set_ignore_empty_fields(1);

    my @fields = qw(index title URI);
    $import->set_fields(@fields);
    $import->read_file($file,"\t");
    my @records = $import->get_records();
    my (%top_level_competency_hash, %competency_hash);
    $top_level_competency_hash{children} = [];
    foreach my $record(@records) {	
	my $current_top_level_competency;
	my $current_competency;
	#checks for top level national competencies by checking with regex if the index is an int (and not a decimal)
	if ($record->{_fields}->{index} =~ /^\d+$/){ 	   
	    $current_top_level_competency = $record->{_fields};
	    my $title = (split(':', $current_top_level_competency->{title}))[0];
	    my $supporting_info = (split(':', $current_top_level_competency->{title}))[1];
	    $supporting_info =~ s/^\s+//; #left-trim, removes leading white space
	    $top_level_competency_hash{index} = $current_top_level_competency->{index};
	    $top_level_competency_hash{title} = $title;
	    $top_level_competency_hash{supporting_info} = $supporting_info;
	    $top_level_competency_hash{uri} = $base_url . $current_top_level_competency->{URI};	 	    
	} else {
	    $current_top_level_competency = substr($record->{_fields}->{index}, 0, 1);
	    $current_competency = $record->{_fields};
	    $competency_hash{index} = $current_competency->{index};
	    $competency_hash{title} = $current_competency->{title};
	    $competency_hash{uri} = $base_url . $current_competency->{URI};
	    push @{$top_level_competency_hash{children}}, {%competency_hash};
	    if (substr($record->{_fields}->{index}, 3) eq "9"){
		push @objectives, {%top_level_competency_hash};
		undef %top_level_competency_hash;
	    }
	}        
    } 
}

sub saveCompetencies {
    my $dbh = HSDB4::Constants::def_db_handle();
    my $school_id = TUSK::Core::School->new()->getSchoolID($school_name);
    die "Error: The school \"$school_name\" does not exist\n" unless($school_id > 0);

    my $category_user_type_id = TUSK::Competency::UserType->lookupReturnOne("short_name=\"category\" AND school_id = $school_id", undef, undef, undef, 
										  [TUSK::Core::JoinObject->new("TUSK::Enum::Data", {joinkey => 'enum_data_id', origkey => 'competency_type_enum_id', jointype=> 'inner'})]);

    my $competency_level_enum_id = TUSK::Enum::Data->lookupReturnOne("namespace=\"competency.level_id\" AND short_name =\"national\"");
    
    my $info_user_type_id = TUSK::Competency::UserType->lookupReturnOne("short_name=\"info\" AND school_id = $school_id", undef, undef, undef, 
										  [TUSK::Core::JoinObject->new("TUSK::Enum::Data", {joinkey => 'enum_data_id', origkey => 'competency_type_enum_id', jointype=> 'inner'})]);

    my $competency_user_type_id = TUSK::Competency::UserType->lookupReturnOne("short_name=\"competency\" AND school_id = $school_id", undef, undef, undef, 
										  [TUSK::Core::JoinObject->new("TUSK::Enum::Data", {joinkey => 'enum_data_id', origkey => 'competency_type_enum_id', jointype=> 'inner'})]);

    foreach my $objective(@objectives) {	
#Insert Competency Category
	my $competency_args = {
	    title => $objective->{title},
	    user_type_id => $category_user_type_id->getPrimaryKeyID,
	    school_id => $school_id,
	    competency_level_enum_id => $competency_level_enum_id->getPrimaryKeyID,
	    version_id => $school_id,
	    user => 'script'
	};

	my $level_enum_id = $competency_level_enum_id->getPrimaryKeyID;

	my $competency = TUSK::Application::Competency::Competency->new($competency_args);
	my $competency_id = $competency->add;

	my $feature_link_enum_id = TUSK::Enum::Data->lookupReturnOne("namespace = \"feature_link.feature_type\" AND short_name = \"competency\"")->getPrimaryKeyID;

	my $competency_feature_link = TUSK::Feature::Link->new();

	$competency_feature_link->setFieldValues({
	    feature_type_enum_id => $feature_link_enum_id,
	    feature_id => $competency_id,
	    url => $objective->{uri}
	});

	$competency_feature_link->save({user => 'script'});

	my $sql =qq (SELECT MAX(competency_hierarchy.sort_order) FROM tusk.competency_hierarchy INNER JOIN tusk.competency ON competency_id = child_competency_id WHERE parent_competency_id = 0 AND competency_level_enum_id = $level_enum_id and competency.school_id = $school_id AND depth = 0);
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $current_max_sort_order = $sth->fetchall_arrayref->[0]->[0];    
	$sth->finish();

	if (!$current_max_sort_order) {
	    $current_max_sort_order = 1;
	}
				
	my $competency_hierarchy = TUSK::Competency::Hierarchy->new();
	
	$competency_hierarchy->setFieldValues({
	    school_id => $school_id,
	    lineage => '/',
	    parent_competency_id => 0,
	    child_competency_id => $competency_id,
	    sort_order => $current_max_sort_order + 1,
	    depth => 0,
	});

	$competency_hierarchy->save({user => 'script'});
#End Insert Competency Category

#Insert Supporting Info
	$competency_args = {
	    title => $objective->{supporting_info},
	    user_type_id => $info_user_type_id->getPrimaryKeyID,
	    school_id => $school_id,
	    competency_level_enum_id => $competency_level_enum_id->getPrimaryKeyID,
	    version_id => $school_id,
	    user => 'script'
	};

        my $child_competency = TUSK::Application::Competency::Competency->new($competency_args);
	my $child_competency_id = $child_competency->add;

        $competency_hierarchy = TUSK::Competency::Hierarchy->new();

	$competency_hierarchy->setFieldValues({
	    school_id => $school_id,
	    lineage => "/$competency_id/",
	    parent_competency_id => $competency_id,
	    child_competency_id => $child_competency_id,
	    sort_order => 1,
	    depth => 1,
	});

	$competency_hierarchy->save({user => 'script'});
#End Insert Supporting Info

#Insert Competencies
	foreach my $national_competency (@{$objective->{children}}){
	    $competency_args = {
		title => $national_competency->{title},
		user_type_id => $competency_user_type_id->getPrimaryKeyID,
		school_id => $school_id,
		competency_level_enum_id => $competency_level_enum_id->getPrimaryKeyID,
		version_id => $school_id,
		user => 'script'
		};

	    $child_competency = TUSK::Application::Competency::Competency->new($competency_args);
	    $child_competency_id = $child_competency->add;
	    
	    $competency_feature_link = TUSK::Feature::Link->new();

	    $competency_feature_link->setFieldValues({
		feature_type_enum_id => $feature_link_enum_id,
		feature_id => $child_competency_id,
		url => $national_competency->{uri}
	    });

	    $competency_feature_link->save({user => 'script'});

	    my $sql =qq (SELECT MAX(competency_hierarchy.sort_order) FROM tusk.competency_hierarchy INNER JOIN tusk.competency ON competency_id = child_competency_id WHERE parent_competency_id = $competency_id AND competency_level_enum_id = $level_enum_id and competency.school_id = $school_id AND depth = 1);
	    my $sth = $dbh->prepare($sql);
	    $sth->execute();
	    my $current_max_sort_order = $sth->fetchall_arrayref->[0]->[0];    
	    $sth->finish();

	    $competency_hierarchy = TUSK::Competency::Hierarchy->new();

	    $competency_hierarchy->setFieldValues({
		school_id => $school_id,
		lineage => "/$competency_id/",
		parent_competency_id => $competency_id,
		child_competency_id => $child_competency_id,
		sort_order => $current_max_sort_order + 1,
		depth => 1,
	    });

	    $competency_hierarchy->save({user => 'script'});
	}
#End Insert Competencies
    }
}
