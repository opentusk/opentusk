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


package TUSK::Application::Eval::Maker;

use HSDB45::Eval;
use HSDB4::Constants;
use TUSK::Constants;

sub new {
    my ($class, $args) = @_;

    my $self = {  
	username			=> $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},
	password			=> $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword},
	school				=> $args->{school},
	course				=> $args->{course},
	time_period			=> $args->{time_period},
	teaching_site		=> $args->{teaching_site},
	due_date			=> $args->{due_date},
	submittable_date	=> $args->{submittable_date},
	prelim_due_date		=> $args->{prelim_due_date},
	available_date		=> $args->{available_date},
	eval_title			=> $args->{eval_title},
    };

    return bless $self, $class;
}


sub getEvalID {
    my $self = shift;
    return $self->{eval_id};
}

sub getSchool {
    my $self = shift;
    return $self->{school};
}

sub clone {

    my ($self,$prototype_eval_id) = @_;

    unless (defined $prototype_eval_id) {
	warn "ERROR: Need prtotype eval id as a parameter\n";
	return;
    }

    my $evalref = HSDB45::Eval->new( _school => $self->getSchool() ); 

    $evalref->set_field_values(
       'course_id' => ($self->{course} && $self->{course}->primary_key()) ? $self->{course}->primary_key() : undef,
       'time_period_id' => ($self->{time_period} && $self->{time_period}->primary_key()) ? $self->{time_period}->primary_key() : undef,
       'teaching_site_id' => ($self->{teaching_site} && $self->{teaching_site}->primary_key()) ? $self->{teaching_site}->primary_key() : undef,
       'title' => $self->{eval_title},
       'available_date' => $self->{available_date},
       'submittable_date' => $self->{submittable_date},
       'prelim_due_date' => $self->{prelim_due_date},
       'due_date' => $self->{due_date});
    my ($eval_id,$msg) = $evalref->save($self->{username},$self->{password});

    $self->{eval_id} = $eval_id;
    
    my $db = HSDB4::Constants::get_school_db($self->getSchool());
    HSDB4::Constants::set_user_pw($self->{username},$self->{password});
    my $dbh = DBI->connect(HSDB4::Constants::db_connect());					
    # insert the correct eval questions
    my $ins = $dbh->prepare("INSERT INTO $db\.link_eval_eval_question (parent_eval_id,child_eval_question_id,label,sort_order,required,grouping,graphic_stylesheet) VALUES (?, ?, ?, ?, ?, ?, ?)");

    my $sel = $dbh->prepare("SELECT child_eval_question_id, label, sort_order, required, grouping, graphic_stylesheet FROM $db\.link_eval_eval_question WHERE parent_eval_id = $prototype_eval_id");
    $sel->execute();
    while (my ($qid, $lab, $sort, $req, $group, $style) = $sel->fetchrow_array ) {
	$ins->execute($eval_id, $qid, $lab, $sort, $req, $group, $style);
	if ($@) {
	    warn "ERROR: Linking of eval questions failed: $@ \n";
	}
    }

    $dbh->disconnect if ($dbh);

    return 1;
}


1;
