package TUSK::Application::FormBuilder::Report;

use strict;

use TUSK::FormBuilder::Form;
use TUSK::FormBuilder::Entry;
use TUSK::FormBuilder::Response;
use TUSK::FormBuilder::Field;
use TUSK::FormBuilder::Constants;
use TUSK::FormBuilder::AttributeItem;


sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { @_ };

	$self->{_form} = TUSK::FormBuilder::Form->lookupKey($self->{_form_id}) 	if ($self->{_form_id});
    bless $self, $class;
	$self->init();
    return $self;
}


sub init { 
	my $self = shift;

	### could get an array ref of time period id in the argument as a report could be generated per one time period or many
	if ($self->{_tp_params}) {  ## passing through from query string
		if (ref $self->{_tp_params} eq 'ARRAY') {
			$self->{_time_period_ids} = [ grep { /\d+/ } @{$self->{_tp_params}} ];
		} else {
			$self->{_time_period_ids} = [ $self->{_tp_params} ] if ($self->{_tp_params} =~ /^\d+$/);
		}
	} else {
		if (my $current_tp = $self->{_course}->get_current_timeperiod()) {
			$self->{_time_period_ids} = [$current_tp->primary_key()];
		} else {
			if (my $most_recent_tp = $self->{_course}->get_most_recent_timeperiod()) {
				$self->{_time_period_ids} = [$most_recent_tp->primary_key()];
			}
		}
	}

	$self->{_time_period_ids_string} = $self->getTimePeriodIDString();
	$self->{_db} = $self->getSchoolDB();
	$self->{_course_id} = $self->getCourseID();
}


sub getFormID(){
    my ($self) = @_;
    return $self->{_form_id};
}

sub getUserID(){
    my ($self) = @_;
    return $self->{_user_id};
}

sub getSchoolDB {
    my ($self) = @_;
    return $self->{_course}->school_db();
}

sub getCourseID {
    my ($self) = @_;
    return $self->{_course}->primary_key();
}

sub setTimePeriods {
	my ($self, $time_period_ids) = @_;
	if (ref $time_period_ids eq 'ARRAY') {
		$self->{_time_period_ids} = [ grep { /\d+/ } @$time_period_ids ];
	} else {
		$self->{_time_period_ids} = [ $time_period_ids ] if ($time_period_ids =~ /^\d+$/);
	}
	$self->{_time_period_ids_string} = $self->getTimePeriodIDString();
}

sub getTimePeriodIDString {
	my ($self) = @_;

	return $self->{_time_period_ids_string} if $self->{_time_period_ids_string};

	return join(',', @{$self->{_time_period_ids}}) if ($self->{_time_period_ids});
}

sub getTimePeriodIDs {
	my ($self) = @_;
	return $self->{_time_period_ids};
}

sub displayTimePeriods {
	my ($self) = @_;
	my @tps = ();

	foreach my $tpid (@{$self->{_time_period_ids}}) {
		my $tp = HSDB45::TimePeriod->new(_school => $self->{_course}->get_school()->getSchoolName(), _id => $tpid);
		push @tps, $tp;
	}

	return join(", ", map { $_->out_display() } @tps);
}

sub getCommentSummary  {
	my ($self, $fields_condition, $reponse_condition) = @_;

	my $fields = $self->{_form}->getAllFormFields($fields_condition);

	my %data;
	foreach my $field (@$fields) {
		if (my $field_id = $field->getPrimaryKeyID()) {
			my $responses = TUSK::FormBuilder::Response->lookup("time_period_id in ($self->{_time_period_ids_string}) AND field_id = $field_id $reponse_condition", undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::Entry", { origkey => 'entry_id', joinkey => 'entry_id',}) ]);
									     
			@{$data{$field_id}} = grep { /\w+/ } map { $_->getText() } @$responses;

		}
	}

	return { rows => $fields, data => \%data, fullname => ($self->{_user}) ? $self->{_user}->out_full_name() : '' };
}


sub isCategory  {
	my ($self, $item) = @_;

	### if first item is the cat start then we asssume all is the same
	return ($item && $item->isCatStart()) ? 1 : 0;
}


sub getReportFlagString {
	my $self = shift;
	return ($self->{_report_flags}) ? $self->{_report_flags} : 0;
}


sub getAttributeItems {
	my ($self, $field_id) = @_;

	my $attribute_items = TUSK::FormBuilder::AttributeItem->lookup(undef, ['sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::Attribute", { origkey => 'attribute_id', joinkey => 'attribute_id', joincond => "field_id = $field_id", jointype => 'inner'}),]);

	my %aids;
	if ($attribute_items) {
		my $i = 0;
		%aids = map { $_->getPrimaryKeyID() => $i++ } @$attribute_items;
	}

	return ($attribute_items, \%aids);
}

sub processLogSummary {
	my ($self, $responses) = @_;

	my (%reports, %data);
	foreach my $response (@$responses) {
		my ($entry, $field, $item);
		$entry = $response->getJoinObject("TUSK::FormBuilder::Entry");
		$field = $response->getJoinObject("TUSK::FormBuilder::Field");

		if (ref $entry eq 'TUSK::FormBuilder::Entry' && ref $field eq 'TUSK::FormBuilder::Field') {
			my $response_text;
			my $item = $response->getJoinObject("TUSK::FormBuilder::FieldItem");
			if (ref $item eq "TUSK::FormBuilder::FieldItem") {
				$response_text = $item->getItemName();
			}

			if (my $text = $response->getText()) {
				if (ref $item eq "TUSK::FormBuilder::FieldItem") {
					$response_text .= " ($text)";
				} else {
					$response_text = $text;
				}
			}
			if ($response_text =~ /\w+/) {
				push @{$data{$entry->getDate()}{$entry->getPrimaryKeyID()}{$field->getPrimaryKeyID()}}, [ $response_text, $response->getActiveFlag() ] ;
			}
		}
		$reports{$entry->getPrimaryKeyID()} = 1;
	}

	return (\%data, scalar (keys %reports));
}



1;
