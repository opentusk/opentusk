package TUSK::Application::CurriculumReport::CourseSummary;

use strict;
use TUSK::Core::School;
use TUSK::Core::Objective;
use TUSK::Core::Keyword;
use HSDB4::Constants;


sub new {
	my $self;
	my $class = shift;
	($self->{'school'}, $self->{'course_id'}, $self->{'timeperiod_id'}) = @_;
	die "Missing school, course_id and/or timeperiod_id\n" unless ($self->{'school'} && $self->{'course_id'} && $self->{'timeperiod_id'});
	$class = ref $class || $class;

	bless $self, $class;
	$self->init();
	return $self;
}


sub init {
	my $self = shift;
	
	eval {
		$self->{'dbh'} = HSDB4::Constants::def_db_handle();
	};
	die "$@\t... failed to obtain database handle!" if $@;

	my $school = TUSK::Core::School->new()->lookupReturnOne("school_name = '" . $self->{'school'} . "'");
	$self->{'school_id'}  = $school->getSchoolID( $self->{'school'} ); 
	$self->{'school_db'}  = $school->getSchoolDb;
	$self->{'timeperiod'} = HSDB45::TimePeriod->new( _school => $self->{'school'} )->lookup_key( $self->{'timeperiod_id'} );

	$self->generateContentList();
	$self->{'content_id_str'}->{'all'}    = join(",", keys %{$self->{'content'}->{'course'}});
	$self->{'content_id_str'}->{'course'} = join(",", keys %{$self->{'content'}->{'course'}});
	foreach my $type ( keys %{$self->{'class_meeting_types'}} ) {
		foreach my $class_meeting ( keys %{$self->{'content'}->{'class_meeting'}->{$type}} ) {
			$self->{'content_id_str'}->{'class_meeting'}->{$type} = join(",", keys %{$self->{'content'}->{'class_meeting'}->{$type}->{$class_meeting}});
			$self->{'content_id_str'}->{'class_meeting'}->{$type} =~ s/,time//g;
			$self->{'content_id_str'}->{'class_meeting'}->{$type} =~ s/^time,//;

			$self->{'content_id_str'}->{'all'} .= "," if ($self->{'content_id_str'}->{'all'});
			$self->{'content_id_str'}->{'all'} .= $self->{'content_id_str'}->{'class_meeting'}->{$type};
		}
	}

	$self->{'content_id_str'}->{'all'} = '0' if ( !($self->{'content_id_str'}->{'all'}) );
}


sub getSubContent {
	my $self             = shift;
	my $counter          = shift;
	my $content_id_str   = shift;
	my $originating_src  = shift;
	my $originating_type = shift;

	if ($counter++ > 200) {
		die( "Failed at recursion depth 200.  Check for an infinite loop." );
	}

   	my $query = "	select 
						l.child_content_id,
						l.parent_content_id
					from
						hsdb4.link_content_content l, 
						hsdb4.content c
					where 
						l.parent_content_id in ($content_id_str) and 
						l.child_content_id = c.content_id and
						l.parent_content_id <> l.child_content_id";

	eval {
		my $handle = $self->{'dbh'}->prepare($query);
		my ($content_id, $parent_id);

		$handle->execute();
		$handle->bind_columns(\$content_id, \$parent_id);

		my @content_ids;
		while($handle->fetch()) {
			if ( $originating_type ) {
				foreach ( keys %{$self->{'content'}->{$originating_src}->{$originating_type}} )
				{
					if ( $self->{'content'}->{$originating_src}->{$originating_type}->{$_}->{$parent_id} ) {
						$self->{'content'}->{$originating_src}->{$originating_type}->{$_}->{$content_id} = 1;
					}
				}
			} else {
				$self->{'content'}->{$originating_src}->{$content_id} = 1;
			}
			push @content_ids, $content_id;
		}

		$self->getSubContent( $counter, join(",",@content_ids), $originating_src, $originating_type ) if scalar(@content_ids);
	};
	die "$@\t... failed to obtain subcontent!" if $@;
}


sub generateContentList {
	my $self  = shift;

    my $query = "	select 
						l.child_content_id
					from 
						" . $self->{'school_db'} . ".link_course_content l, 
						hsdb4.content c 
					where 
						l.parent_course_id = " . $self->{'course_id'} . " and
						l.child_content_id = c.content_id";

	eval {
		my $handle = $self->{'dbh'}->prepare($query);
		my $content_id;

		$handle->execute();
		$handle->bind_columns(\$content_id);

		my @content_ids;
		while($handle->fetch()) {
			$self->{'content'}->{'course'}->{$content_id} = 1;
			push @content_ids, $content_id;
		}

		$self->getSubContent( 0, join(",",@content_ids), 'course' ) if (scalar(@content_ids));
	};
	die "$@\t... failed to obtain course content!" if $@;

    $query = "	select 
					l.child_content_id,
					cm.type,
					cm.class_meeting_id,
					sum(timediff(cm.endtime,cm.starttime)) as time 
				from 
					" . $self->{'school_db'} . ".link_class_meeting_content l, 
					" . $self->{'school_db'} . ".class_meeting cm, 
					hsdb4.content c 
				where 
					cm.course_id = " . $self->{'course_id'} . " and
					cm.meeting_date >= '" . $self->{'timeperiod'}->raw_start_date . "' and 
					cm.meeting_date <= '" . $self->{'timeperiod'}->raw_end_date . "' and
					l.parent_class_meeting_id = cm.class_meeting_id and
					l.child_content_id = c.content_id
				group by
					cm.type,
					cm.class_meeting_id,
					l.child_content_id";

	eval {
		my $handle = $self->{'dbh'}->prepare($query);
		my ($content_id, $type, $class_meeting_id, $time);

		$handle->execute();
		$handle->bind_columns(\$content_id, \$type, \$class_meeting_id, \$time);

		my %content_ids;
		while($handle->fetch()) {
			$self->{'class_meeting_types'}->{$type} = 1;
			$self->{'content'}->{'class_meeting'}->{$type}->{$class_meeting_id}->{'time'}      = $time;
			$self->{'content'}->{'class_meeting'}->{$type}->{$class_meeting_id}->{$content_id} = 1;
			push @{$content_ids{$type}}, $content_id;
		}

		foreach ( keys %content_ids ) {
			$self->getSubContent( 0, join(",",@{$content_ids{$_}}), 'class_meeting', $_ ) if (scalar(@{$content_ids{$_}}));
		}
	};
	die "$@\t... failed to obtain class meeting content!" if $@;
}


sub classMeetingsReport {
	my $self = shift;

	my $meeting_query = "	select 
								distinct type, 
								count(type) as count, 
								sum(timediff(endtime,starttime)) as time 
							from " . $self->{'school_db'} . ".class_meeting 
							where 
								course_id = " . $self->{'course_id'} . " and 
								meeting_date >= '" . $self->{'timeperiod'}->raw_start_date . "' and 
								meeting_date <= '" . $self->{'timeperiod'}->raw_end_date . "' 
							group by 
								type";

	my %meeting_types;
	eval {
		my $handle = $self->{'dbh'}->prepare($meeting_query);
		my ($type, $count, $time);

		$handle->execute();
		$handle->bind_columns(\$type, \$count, \$time);

		while($handle->fetch()) {
			$type = "Unspecified" if ( $type eq '' );
			$self->{'class_meeting_types'}->{$type} = 1;
			$meeting_types{$type} = { "count" => $count, "time" => $time };
		}
	};
	die "$@\t... failed to obtain class meeting report!" if $@;

	return \%meeting_types;
}


sub objectivesReport {
	my $self = shift;

	my %objectives;

	# All objectives linked directly to the course.
	my $objective_course_query = "	select 
										objective_id, 
										body 
									from 
										hsdb4.objective, 
										" . $self->{'school_db'} . ".link_course_objective lco 
									where 
										lco.parent_course_id = " . $self->{'course_id'} . " and 
										lco.child_objective_id = objective_id";
	eval {
		my $handle = $self->{'dbh'}->prepare($objective_course_query);
		my ($objective_id, $body);

		$handle->execute();
		$handle->bind_columns(\$objective_id, \$body);

		while($handle->fetch()) {
			$objectives{$objective_id}->{'body'} = $body;
			$objectives{$objective_id}->{'course'} = 1;
		}
	};
	die "$@\t... failed to obtain course-related objectives report!" if $@;

	# All objectives linked to a piece of content in the course
	my $objective_content_query = "	select 
										objective_id, 
										body, 
										count(objective_id) as count
									from 
										hsdb4.objective, 
										hsdb4.link_content_objective lco 
									where 
										lco.parent_content_id in (" . $self->{'content_id_str'}->{'all'} . ") and 
										lco.child_objective_id = objective_id 
									group by 
										objective_id";
	eval {
		my $handle = $self->{'dbh'}->prepare($objective_content_query);
		my ($objective_id, $body, $count);

		$handle->execute();
		$handle->bind_columns(\$objective_id, \$body, \$count);

		while($handle->fetch()) {
			$objectives{$objective_id}->{'body'} = $body;
			$objectives{$objective_id}->{'content'} = $count;
		}
	};
	die "$@\t... failed to obtain content-related objectives report!" if $@;

	# All objectives linked to a class meeting OR to a piece of content in a class meeting
	foreach my $type ( keys %{$self->{'class_meeting_types'}} ) {
		my $objective_class_meeting_query = "	select 
													o.objective_id, 
													o.body, 
													cm.class_meeting_id,
													sum(timediff(cm.endtime,cm.starttime)) as time 
												from 
													hsdb4.objective o, 
													tusk.class_meeting_objective cmo, 
													" . $self->{'school_db'} . ".class_meeting cm 
												where 
													cmo.school_id = " . $self->{'school_id'} . " and 
													cm.course_id = " . $self->{'course_id'} . " and 
													cmo.class_meeting_id = cm.class_meeting_id and 
													cmo.objective_id = o.objective_id and 
													cm.meeting_date >= '" . $self->{'timeperiod'}->raw_start_date . "' and 
													cm.meeting_date <= '" . $self->{'timeperiod'}->raw_end_date . "' and
													cm.type = '" . $type . "'
												group by 
													objective_id,
													class_meeting_id";

		eval {
			my $handle = $self->{'dbh'}->prepare($objective_class_meeting_query);
			my ($objective_id, $body, $class_meeting_id, $time);

			$handle->execute();
			$handle->bind_columns(\$objective_id, \$body, \$class_meeting_id, \$time);

			while($handle->fetch()) {
				$objectives{$objective_id}->{'body'} = $body;
				$objectives{$objective_id}->{'class_meeting'}->{$type}->{$class_meeting_id} = $time;
			}
		};
		die "$@\t... failed to obtain class-meeting-related objectives report!" if $@;

		if ( $self->{'content_id_str'}->{'class_meeting'}->{$type} ) {
			my $objective_content_query = "	select 
												objective_id, 
												body, 
												parent_content_id
											from 
												hsdb4.objective, 
												hsdb4.link_content_objective lco 
											where 
												lco.parent_content_id in (" . $self->{'content_id_str'}->{'class_meeting'}->{$type} . ") and 
												lco.child_objective_id = objective_id 
											group by 
												objective_id,
												parent_content_id";

			eval {
				my $handle = $self->{'dbh'}->prepare($objective_content_query);
				my ($objective_id, $body, $parent_content_id);
	
				$handle->execute();
				$handle->bind_columns(\$objective_id, \$body, \$parent_content_id);
	
				while($handle->fetch()) {
					foreach my $meeting ( keys %{$self->{'content'}->{'class_meeting'}->{$type}} ) {
						next unless $self->{'content'}->{'class_meeting'}->{$type}->{$meeting}->{$parent_content_id};

						$objectives{$objective_id}->{'body'} = $body;
						$objectives{$objective_id}->{'class_meeting'}->{$type}->{$meeting} = $self->{'content'}->{'class_meeting'}->{$type}->{$meeting}->{'time'};
					}
				}
			};
			die "$@\t... failed to obtain class-meeting-content-related objectives report!" if $@;
		}
	}

	return \%objectives;
}


sub keywordsReport {
	my $self = shift;

	my %keywords;

	# All keywords linked to a piece of content in the course
	my $keyword_content_query = "	select 
										keyword_id, 
										keyword, 
										concept_id,
										count(keyword_id) as count
									from 
										tusk.keyword, 
										tusk.link_content_keyword lck 
									where 
										lck.parent_content_id in (" . $self->{'content_id_str'}->{'all'} . ") and 
										lck.child_keyword_id = keyword_id 
									group by 
										keyword_id";
	eval {
		my $handle = $self->{'dbh'}->prepare($keyword_content_query);
		my ($keyword_id, $keyword, $concept_id, $count);

		$handle->execute();
		$handle->bind_columns(\$keyword_id, \$keyword, \$concept_id, \$count);

		while($handle->fetch()) {
			$keywords{$keyword_id}->{'keyword'} = $keyword;
			$keywords{$keyword_id}->{'concept'} = $concept_id;
			if ($concept_id) { $keywords{$keyword_id}->{'type'} = "UMLS"; }
			else             { $keywords{$keyword_id}->{'type'} = "user-defined"; }
			$keywords{$keyword_id}->{'content'} = $count;
		}
	};
	die "$@\t... failed to obtain content-related keywords report!" if $@;

	# All keywords linked to a class meeting OR to a piece of content in a class meeting
	foreach my $type ( keys %{$self->{'class_meeting_types'}} ) {
		my $keyword_class_meeting_query = "	select 
												k.keyword_id, 
												k.keyword, 
												k.concept_id,
												cm.class_meeting_id,
												sum(timediff(cm.endtime,cm.starttime)) as time 
											from 
												tusk.keyword k, 
												tusk.class_meeting_keyword cmk, 
												" . $self->{'school_db'} . ".class_meeting cm 
											where 
												cmk.school_id = " . $self->{'school_id'} . " and 
												cm.course_id = " . $self->{'course_id'} . " and 
												cmk.class_meeting_id = cm.class_meeting_id and 
												cmk.keyword_id = k.keyword_id and 
												cm.meeting_date >= '" . $self->{'timeperiod'}->raw_start_date . "' and 
												cm.meeting_date <= '" . $self->{'timeperiod'}->raw_end_date . "' and
												cm.type = '" . $type . "'
											group by 
												keyword_id,
												class_meeting_id";

		eval {
			my $handle = $self->{'dbh'}->prepare($keyword_class_meeting_query);
			my ($keyword_id, $keyword, $concept_id, $class_meeting_id, $time);

			$handle->execute();
			$handle->bind_columns(\$keyword_id, \$keyword, \$concept_id, \$class_meeting_id, \$time);

			while($handle->fetch()) {
				$keywords{$keyword_id}->{'keyword'} = $keyword;
				$keywords{$keyword_id}->{'concept'} = $concept_id;
				if ($concept_id) { $keywords{$keyword_id}->{'type'} = "UMLS"; }
				else             { $keywords{$keyword_id}->{'type'} = "user-defined"; }
				$keywords{$keyword_id}->{'class_meeting'}->{$type}->{$class_meeting_id} = $time;
			}
		};
		die "$@\t... failed to obtain class-meeting-related keywords report!" if $@;

		if ( $self->{'content_id_str'}->{'class_meeting'}->{$type} ) {
			my $keyword_content_query = "	select 
												keyword_id, 
												keyword, 
												concept_id,
												parent_content_id
											from 
												tusk.keyword, 
												tusk.link_content_keyword lck 
											where 
												lck.parent_content_id in (" . $self->{'content_id_str'}->{'class_meeting'}->{$type} . ") and 
												lck.child_keyword_id = keyword_id 
											group by 
												keyword_id,
												parent_content_id";

			eval {
				my $handle = $self->{'dbh'}->prepare($keyword_content_query);
				my ($keyword_id, $keyword, $concept_id, $parent_content_id);
	
				$handle->execute();
				$handle->bind_columns(\$keyword_id, \$keyword, \$concept_id, \$parent_content_id);
	
				while($handle->fetch()) {
					foreach my $meeting ( keys %{$self->{'content'}->{'class_meeting'}->{$type}} ) {
						next unless $self->{'content'}->{'class_meeting'}->{$type}->{$meeting}->{$parent_content_id};

						$keywords{$keyword_id}->{'keyword'} = $keyword;
						$keywords{$keyword_id}->{'concept'} = $concept_id;
						if ($concept_id) { $keywords{$keyword_id}->{'type'} = "UMLS"; }
						else             { $keywords{$keyword_id}->{'type'} = "user-defined"; }
						$keywords{$keyword_id}->{'class_meeting'}->{$type}->{$meeting} = $self->{'content'}->{'class_meeting'}->{$type}->{$meeting}->{'time'};
					}
				}
			};
			die "$@\t... failed to obtain class-meeting-content-related keywords report!" if $@;
		}
	}

	return \%keywords;
}

1;
