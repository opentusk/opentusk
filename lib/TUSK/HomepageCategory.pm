package TUSK::HomepageCategory;

use strict;
use HSDB4::Constants qw(:school);
use TUSK::HomepageCourse;

BEGIN {
    use base qw/HSDB4::SQLRow/;
    use vars qw($VERSION);    
    require HSDB4::SQLLink;
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

my $tablename = "homepage_category";
my $primary_key_field = "id";
my @fields = qw(id
		primary_user_group_id
		secondary_user_group_id
                label
		schedule
		sort_order
                modified);

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _primary_key_field => $primary_key_field,
				       @_);
    # Finish initialization...
    return $self;
}

sub split_by_school {
    return 1;
}

sub get_primary_user_group_id {
    my $self = shift;
    return $self->field_value("primary_user_group_id");
}

sub get_secondary_user_group_id {
    my $self = shift;
    return $self->field_value("secondary_user_group_id");
}

sub get_user_group_ids {
    my $self = shift;
    my @ids;
    push(@ids,$self->get_primary_user_group_id) if $self->get_primary_user_group_id;
    push(@ids,$self->get_secondary_user_group_id) if $self->get_secondary_user_group_id;
    return @ids;
}

sub get_label {
    my $self = shift;
    return $self->field_value("label");
}

sub get_schedule {
    my $self = shift;
    return $self->field_value("schedule");
}

sub get_sort_order {
    my $self = shift;
    return $self->field_value("sort_order");
}

sub get_homepage_courses {
    my $self = shift;
    return unless ($self->primary_key);
    ## return an array of HomepageCourse objects for this particulary category
    return TUSK::HomepageCourse->new(_school => $self->school)->lookup_conditions("category_id='".$self->primary_key."'",
										  "order by sort_order");
}

1;

