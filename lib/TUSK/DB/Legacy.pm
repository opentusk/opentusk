package TUSK::DB::Legacy;

use strict;
use warnings;
use utf8;

use Carp;
use Readonly;
use HSDB4::Constants qw(get_school_db);
use TUSK::Constants;

use Moose;

extends qw(TUSK::DB::Object);

sub query_defined {
    my $self = shift;
    my $query = shift;
    return ( defined $self->dbh()->selectrow_arrayref($query) );
}

sub column_exists {
    my $self = shift;
    my ($db, $table, $column) = @_;
    return (
        $self->table_exists($db, $table) && $self->query_defined(
            "show columns from `$table` in `$db` like '$column'"
        )
    );
}

sub table_exists {
    my $self = shift;
    my ($db, $table) = @_;
    return $self->query_defined("show tables from `$db` like '$table'");
}

sub value_exists {
    my $self = shift;
    my ($db, $table, $column, $value) = @_;
    my $safe_value = $self->dbh()->quote($value);
    return (
        $self->table_exists($db, $table)
            && $self->column_exists($db, $table, $column)
            && $self->query_defined(
                "select * from `$db`.`$table` where `$column` like $safe_value"
            )
        );
}

sub version_list {
    my $self = shift;

    my @schools = HSDB4::Constants::schools();
    my $hsdb4 = defined %TUSK::Constants::Databases
        ? $TUSK::Constants::Databases{hsdb4} : 'hsdb4';
    my $tusk = defined %TUSK::Constants::Databases
        ? $TUSK::Constants::Databases{tusk} : 'tusk';

    my @legacy_version_checks = (
        ['4.0/OpenTUSK'] => $self->table_exists($tusk, 'schema_change_log'),
        ['Pre 3.6.14'] => (! $self->column_exists($hsdb4, 'user', 'uid')),
        ['3.6.14', '3.6.15'] => (! $self->table_exists($tusk, 'competency')),
        ['3.7.0', '3.7.1'] => (
            (scalar(@schools) > 0) && $self->table_exists(
                get_school_db($schools[0]), 'eval_secret'
            )
        ),
        ['3.7.2'] => (! $self->table_exists($tusk, 'quiz_question_keyword')),
        ['3.7.3'] => (! $self->table_exists($tusk, 'grade_scale')),
        ['3.7.4'] => (! $self->table_exists($tusk, 'competency_relationship')),
        ['3.7.5'] => (! $self->table_exists($tusk, 'form_builder_assessment')),
        ['3.8.0'] => (! $self->column_exists(
            $tusk, 'link_phase_quiz', 'allow_resubmit'
        )),
        ['3.8.1'] => (! $self->value_exists(
            $tusk,
            'search_query_field_type',
            'search_query_field_name',
            'include_deleted_content',
        )),
        ['3.8.2'] => (! $self->table_exists($tusk, 'patient_log_approval')),
        ['3.8.3'] => (! $self->table_exists(
            $tusk, 'form_builder_form_grade_event'
        )),
        ['3.8.4'] => (! $self->table_exists($tusk, 'case_rule_element_type')),
        ['3.9.0', '3.9.1', '3.9.2'] => (! $self->table_exists(
            $tusk, 'class_meeting_type'
        )),
        ['3.9.3', '3.9.4', '3.9.5'] => (! $self->column_exists(
            $tusk, 'assignment', 'sort_order'
        )),
        ['3.9.6'] => (! $self->table_exists($tusk, 'process_tracker')),
        ['3.10.0'] => (
            'varchar(350)' ne lc( $self->dbh()->selectrow_hashref(
                "show columns from competency in `$tusk` like 'title'"
            )->{Type} )
        ),
        ['3.10.1'] => (
            lc( $self->dbh()->selectrow_hashref(
                "show create table `$hsdb4`.user"
            )->{'Create Table'} ) !~ m/utf8/xms
        ),
        ['3.11.0', '3.12.0', '4.0/OpenTUSK'] => (! $self->table_exists(
            $tusk, 'schema_change_log'
        )),
    );
    my $i = 0;
    my $len = scalar @legacy_version_checks;
    while ($i < $len) {
        return @{ $legacy_version_checks[$i] } if $legacy_version_checks[$i+1];
        $i += 2;
    }
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
