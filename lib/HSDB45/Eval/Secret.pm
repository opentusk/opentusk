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


package HSDB45::Eval::Secret;

use strict;
use HSDB4::Constants;
use HSDB4::DateTime;
use Digest::MD5;
use TUSK::Config;

# INPUT:  A string containing a school, a string containing an eval_id,
#         a string containing a user_id, an HSDB4::DateTime object and an md5 hashcode
# OUTPUT: A Boolean value
# EFFECT: Generates an md5 hashcode string for the first four arguments,
#         compares it to the hashcode passed in, and returns true if they match,
#         and false if they don't
sub verify_hashcode {
    my $school = shift;
    my $eval_id = shift;
    my $user_id = shift;
    my $datetime = shift;
    my $hashcode = shift || $datetime;

    my $generated_hashcode = generate_hashcode($school, $eval_id, $user_id, $datetime);
    return $hashcode eq $generated_hashcode;
}

# INPUT:  A string containing a school, a string containing an eval_id,
#         a string containing a user_id, and an HSDB4::DateTime object
# OUTPUT: An md5 hash string
# EFFECT: Takes the four arguments, looks up the secret associated with the specified
#         school and date, then generates an md5 hash string from all those things and returns it
sub generate_hashcode {
    my $school = shift;
    my $eval_id = shift;
    my $user_id = shift;
    my $datetime = shift;

    my $ctx = Digest::MD5->new();
    $ctx->add(lc($school));
    $ctx->add($eval_id);
    $ctx->add(lc($user_id));
    my $timestamp = '';
    if (ref $datetime eq 'HSDB4::DateTime') {
        $timestamp = $datetime->out_mysql_timestamp();
        $timestamp =~ s/\D//g;
    } else {
        $timestamp = TUSK::Config->new()->RssSecret();
    }
    $ctx->add($timestamp);

    return $ctx->b64digest();
}

1;
