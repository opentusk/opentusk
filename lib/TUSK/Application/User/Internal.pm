
# Copyright 2016 Tufts University 
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


package TUSK::Application::User::Internal;

use TUSK::User;
use HSDB4::SQLRow::User;
use TUSK::Constants;
use TUSK::Enum::Data;
use TUSK::Application::Course::User;
use TUSK::User::Creation;

sub new {
    my ($incoming, $args)  = @_;
    my $class = ref($incoming) || $incoming;

    my $self = { 
        author => $args->{author},
        course => $args->{course},
        teaching_site_id => $args->{teaching_site_id},
        time_period_id => $args->{time_period_id},
        object_id => $args->{object_id},
        source => TUSK::Enum::Data->lookupReturnOne("namespace = 'user_creation.source_id' and short_name = '$args->{application}'"),
        role => TUSK::Permission::Role->lookupReturnOne("role_token = 'healthprof'"),
    };

    return bless($self, $class);
}

sub findUserByEmail {
    my ($self, $email) = @_;
    return HSDB4::SQLRow::User->new()->lookup_conditions("email = '$email' OR preferred_email = '$email'");
}

sub findUserByName {
    my ($self, $firstname, $lastname) = @_;
    return HSDB4::SQLRow::User->new()->lookup_conditions("firstname = '$firstname' AND lastname = '$lastname'");
}

sub findAddUserByEmail {
    my ($self, $args) = @_;
    my @users = ();

    if ($args->{email}) {

        if (@users = $self->findUserByEmail($args->{email})) {
            return \@users;
        } else {
            ## at this point we believe we don't have this user in our user table
            return [ $self->createUser($args) ];
        }
    }
    return [];
}


sub createUser {
    my ($self, $args) = @_;

    ### make it conventional to have an internal username but we allow admin to create a different username
    eval {
        unless ($args->{username}) {
            my ($temp_username); 
            my $i = 0;

            do {
                ## first_initial + lastname + running number if needed + _nt
                $temp_username = substr($args->{firstname}, 0, 1) . $args->{lastname} . (($i) ? $i : '') . '_nt';
                $i++;
            } while (my $found = HSDB4::SQLRow::User->new()->lookup_key($temp_username));

            $temp_user_name = s/[^[:alpha:]0-9\s]//g;
            $args->{username} = lc $temp_username;
            }
    };
    return undef && warn $@ if $@;

    ### username must be unique so we do last check before insertion
    my $user = HSDB4::SQLRow::User->new()->lookup_key($args->{username});
    unless ($user) {
        $user = HSDB4::SQLRow::User->new();
        $user->primary_key($args->{username});
        $user->set_field_values( 
                                 firstname => $args->{firstname},
                                 lastname => $args->{lastname},
                                 email => $args->{email},
                                 affiliation => $self->{course}->school(),
                                 source => 'internal',
                                 status => 'active', 
                                 );
        $user->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{readpassword});

        my $create = TUSK::User::Creation->new();
        $create->setFieldValues({
            user_id => $user->primary_key(),
            source_enum_id => $self->{source}->getPrimaryKeyID(), 
            object_id => $self->{object_id}
        });
        $create->save({user => $self->{author}->primary_key()});
    }

    return $user;
}

sub linkCourseUser {
    my ($self, $faculty) = @_;

    ## does the wrapper check if duplicate?
    my $course_user_wrapper = TUSK::Application::Course::User->new({course => $self->{course}});
    $course_user_wrapper->add({ 
        author => $self->{author}->primary_key(), 
        user_id => $faculty->primary_key(), 
        time_period_id => $self->{time_period_id}, 
        role_id => $self->{role}->getPrimaryKeyID(),
        site_id => $self->{teaching_site_id},
        virtural_role => 1,
    });
}

1;
