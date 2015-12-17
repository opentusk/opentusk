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


package HSDB45::Authentication::MySQL;

use strict;
use HSDB4::SQLRow::User;

#
# Sub takes a user object and a password string
#
sub verify_password {
    #
    # Checks that the password is good
    #
    my $self = shift;
    my $user = shift;
    my $inpw = shift;
    # Check that we got an input value
    return unless ($inpw);
    my ($dbpw, $sqlpw, $old_sqlpw) = ('', '', '');
    # Protect us from us
    eval {
        # Make a connection
        my $dbh = HSDB4::Constants::def_db_handle();
        # Quote the incoming PW
        my ($quser, $qpw) = map { $dbh->quote($_) } ($user->primary_key(), $inpw);
        my $sql = "SELECT password, PASSWORD($qpw), OLD_PASSWORD($qpw) FROM user WHERE user_id = $quser";
        ($dbpw, $sqlpw, $old_sqlpw) = $dbh->selectrow_array($sql);
    };

    ## first check to see if we got a password
    return unless ($dbpw && $sqlpw && $old_sqlpw);

    if ($dbpw eq $sqlpw) {
       ## matches on new password, return success
       return 1;
    } elsif ($dbpw eq $old_sqlpw) {
       ## matches on old password, update to new and return success
       $user->field_value('password', $sqlpw);
       $user->save();
       return 1;
    }

    return;
}

sub verify {
    my $self = shift;
    my $user_id = shift;
    my $pw = shift;
    my $user = HSDB4::SQLRow::User->new;
    $user->lookup_key($user_id);
    return (undef, "Invalid Account $user_id") unless $user->primary_key;
    return (undef, "Inactive Account $user_id") unless $user->active;
    return (undef, "Account Expired") if $user->is_expired;
    return (undef, "Password Mismatch") unless $self->verify_password($user,$pw);
    return (1, 'Found user');
}

1;
