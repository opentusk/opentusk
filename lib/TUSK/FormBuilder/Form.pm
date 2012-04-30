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


package TUSK::FormBuilder::Form;

=head1 NAME

B<TUSK::FormBuilder::Form> - Class for manipulating entries in table form_builder_form in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

use TUSK::FormBuilder::LinkFormField;
use TUSK::FormBuilder::Field;
use TUSK::FormBuilder::FieldType;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'form_builder_form',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'form_id' => 'pk',
					'form_name' => '',
					'form_type_id' => '',
					'form_description' => '',
					'publish_flag' => '',
					'require_approval' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::FormType") ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getFormName>

    $string = $obj->getFormName();

    Get the value of the form_name field

=cut

sub getFormName{
    my ($self) = @_;
    return $self->getFieldValue('form_name');
}

#######################################################

=item B<setFormName>

    $obj->setFormName($value);

    Set the value of the form_name field

=cut

sub setFormName{
    my ($self, $value) = @_;
    $self->setFieldValue('form_name', $value);
}

#######################################################

=item B<getFormTypeID>

    $string = $obj->getFormTypeID();

    Get the value of the form_type_id field

=cut

sub getFormTypeID{
    my ($self) = @_;
    return $self->getFieldValue('form_type_id');
}

#######################################################

=item B<setFormTypeID>

    $obj->setFormTypeID($value);

    Set the value of the form_type_id field

=cut

sub setFormTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_type_id', $value);
}


#######################################################

=item B<getFormDescription>

    $string = $obj->getFormDescription();

    Get the value of the form_description field

=cut

sub getFormDescription{
    my ($self) = @_;
    return $self->getFieldValue('form_description');
}

#######################################################

=item B<setFormDescription>

    $obj->setFormDescription($value);

    Set the value of the form_description field

=cut

sub setFormDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('form_description', $value);
}

#######################################################

=item B<getPublishFlag>

    $string = $obj->getPublishFlag();

    Get the value of the publish_flag field

=cut

sub getPublishFlag{
    my ($self) = @_;
    return $self->getFieldValue('publish_flag');
}

#######################################################

=item B<getPublishFlagSpelledOut>

    $string = $obj->getPublishFlagSpelledOut();

    Get the value of the publish_flag field spelled out

=cut

sub getPublishFlagSpelledOut{
    my ($self) = @_;
    if ($self->getFieldValue('publish_flag')){
	return "Yes";
    }else{
	return "No";
    }
}


#######################################################

=item B<getRequireApproval>

    $string = $obj->getRequireApproval();

    Get the value of the require_approval field

=cut

sub getRequireApproval{
    my ($self) = @_;
    return $self->getFieldValue('require_approval');
}

#######################################################

=item B<setPublishFlag>

    $obj->setPublishFlag($value);

    Set the value of the publish_flag field

=cut

sub setPublishFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('publish_flag', $value);
}

#######################################################

=item B<setRequireApproval>

    $obj->setRequireApproval();

    Set the value of the require_approval field

=cut

sub setRequireApproval{
    my ($self, $value) = @_;
    return $self->setFieldValue('require_approval', $value);
}
#######################################################

=item B<getFields>

    $fields = $obj->getFields();

    Get an array ref of all the fields linked to this form

=cut

sub getFields{
    my ($self, $cond, $orderby, $fields, $limit) = @_;
    $cond .= ' and ' if ($cond);
    $cond .= 'parent_form_id = ' . $self->getPrimaryKeyID();
    $orderby = [] unless ($orderby);
    push(@$orderby, 'link_form_field.sort_order');

    return (TUSK::FormBuilder::Field->new()->lookup($cond, 
						    $orderby, 
						    $fields, 
						    $limit, 
						    [ 
						      TUSK::Core::JoinObject->new("TUSK::FormBuilder::LinkFormField", 
										  { 
										      'origkey' => 'field_id', 
										      'joinkey' => 'child_field_id'
										      }), 
						      TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldType")
						      ]));

}

#######################################################

=item B<getAllTheFields>

    $fields = $obj->getAllTheFields();

    Get an array ref of all the fields linked to this form as well as sub fields

=cut


sub getAllFormFields{
    my ($self, $cond) = @_;

    my $form_id = $self->getPrimaryKeyID();
	$cond = ($cond) ? "and $cond" : '';

	my $sth = $self->databaseSelect(qq(
select * from (
select l1.child_field_id, l2.sort_order*1000 + l1.depth_level*100 + l1.sort_order as csort_order 
from tusk.form_builder_link_field_field l1, tusk.link_form_field l2, tusk.form_builder_field f, tusk.form_builder_field_type ft 
where l1.root_field_id = l2.child_field_id and parent_form_id = $form_id and l1.child_field_id = f.field_id and f.field_type_id = ft.field_type_id $cond
UNION 
select child_field_id, sort_order*1000 as csort_order 
from tusk.link_form_field l1, tusk.form_builder_field f, tusk.form_builder_field_type ft
where parent_form_id = $form_id and child_field_id = field_id and f.field_type_id = ft.field_type_id $cond
) as SortFields
order by csort_order
    ));

	my @fields = ();
	while (my ($field_id, $sort_order) = $sth->fetchrow_array) {
		push @fields, TUSK::FormBuilder::Field->new()->lookupKey($field_id, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldType"), ]);
	}

	$sth->finish();
	return \@fields;
}


#######################################################

=item B<getSchoolForms>

    $forms = $obj->getSchoolForms($school_id, $form_token);

    Get an array ref of all the forms tied to a school

=cut

sub getSchoolForms{
    my ($self, $school_id, $form_token) = @_;
    return $self->new()->lookup("school_id = $school_id and token = '$form_token'", undef, undef, undef, [
													  TUSK::Core::JoinObject->new("TUSK::FormBuilder::LinkCourseForm", { 'origkey' => 'form_id', 'joinkey' => 'child_form_id'}) ]);
}

sub getCourseForms {
    my ($self, $course, $form_type_id, $published) = @_;
	return unless (ref $course eq 'HSDB45::Course');

	my $publish_cond = ($published) ? "AND publish_flag = $published" : '';

	if (my $school = $course->get_school()) {
		return $self->new()->lookup("school_id = " . $school->getPrimaryKeyID() . " AND form_builder_form.form_type_id = $form_type_id $publish_cond", undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::LinkCourseForm", { 'origkey' => 'form_id', 'joinkey' => 'child_form_id', 'joincond' => "parent_course_id = " . $course->primary_key() }) ]);
	}
}

sub getFormTypeName{
    my ($self) = @_;
    my $form_type_obj = $self->getJoinObject("TUSK::FormBuilder::FormType");
    return $form_type_obj->getLabel();
}

sub getCourseLabel{
    my ($self) = @_;
    my $link = $self->getJoinObject("TUSK::FormBuilder::LinkCourseForm");
    my $course = $link->getCourseObject();
    return $course->title . "\&nbsp;(" . $course->course_id() . ")";

}

sub getFormTypeToken{
    my ($self) = @_;
    my $form_type_obj = $self->getJoinObject("TUSK::FormBuilder::FormType");
    return $form_type_obj->getToken();
}


=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

