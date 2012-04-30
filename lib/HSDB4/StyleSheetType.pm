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


package HSDB4::StyleSheetType;

use strict;
use HSDB4::Constants;
use HSDB45::StyleSheet;

BEGIN {
    use vars qw($VERSION);
    use base qw/HSDB4::SQLRow/;
    
    $VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

# File-private lexicals
my $tablename = "stylesheet_type";
my $primary_key_field = "stylesheet_type_id";
my @fields = qw/stylesheet_type_id stylesheet_type_label global_stylesheet modified/;
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # Finish initialization...
    return $self;
}

sub label_to_id {
    my $label = shift();
    my $dbh = HSDB4::Constants::def_db_handle();

    my $id = undef;
    eval {
	my $sth = $dbh->prepare("SELECT stylesheet_type_id " .
				"FROM hsdb4.stylesheet_type " .
				"WHERE stylesheet_type_label=?");
	$sth->execute($label);
	($id) = $sth->fetchrow_array();
	$sth->finish;
    };

    return $id;
}

############################
# field accessor functions #
############################

sub stylesheet_type_id {
    my $self = shift();
    return $self->field_value('stylesheet_type_id');
}

sub stylesheet_type_label {
    my $self = shift();
    return @_ ? $self->field_value('stylesheet_type_label', shift()) : $self->field_value('stylesheet_type_label');
}

sub global_stylesheet {
    my $self = shift();
    return @_ ? $self->field_value('global_stylesheet', shift()) : $self->field_value('global_stylesheet');
}

sub modified {
    my $self = shift();
    return $self->field_value('modified');
}

####################
# lookup functions #
####################

# INPUT:  A school name
# OUTPUT: sets or retrieves the integer that is the default stylesheet's id...
#         if set to zero, it deletes the entry altogether
sub default_stylesheet_id {
    my $self = shift();
    my $school = shift();
    my $stylesheet_id = shift();

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($school);

    if(defined($stylesheet_id)) {
	my $sth = $dbh->prepare("SELECT default_stylesheet_id " .
				"FROM $db.default_stylesheet " .
				"WHERE stylesheet_type_id=?");
	$sth->execute($self->stylesheet_type_id());

	if(defined($sth->fetchrow_array())) {
	    $sth = $dbh->prepare("UPDATE $db.default_stylesheet " . 
				 "SET default_stylesheet_id=? " .
				 "WHERE stylesheet_type_id=?");
	    $sth->execute($stylesheet_id, $self->stylesheet_type_id());
	}
	else {
	    $sth = $dbh->prepare("INSERT INTO $db.default_stylesheet " . 
				 "SET default_stylesheet_id=?, stylesheet_type_id=?");
	    $sth->execute($stylesheet_id, $self->stylesheet_type_id());
	}
	$sth->finish;
    }
    else {
	my $sth = $dbh->prepare("SELECT default_stylesheet_id " .
				"FROM $db.default_stylesheet " .
				"WHERE stylesheet_type_id=?");
	$sth->execute($self->stylesheet_type_id());
	($stylesheet_id) = $sth->fetchrow_array();
	$sth->finish;
    }

    return $stylesheet_id;
}

# INPUT:  A school name
# OUTPUT: an HSDB45::StyleSheet object of the default stylesheet
sub default_stylesheet {
    my $self = shift();
    my $school = shift();
    return HSDB45::StyleSheet->new(_school => $school,
				   _id     => $self->default_stylesheet_id($school));
}

# INPUT:  A school name
# OUTPUT: an array of integers of all of appropriate stylesheets' ids
sub stylesheet_ids {
    my $self = shift();
    my $school = shift();

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($school);

    my @stylesheet_ids = ();
    eval {
	my $sth = $dbh->prepare("SELECT stylesheet_id " .
				"FROM $db.stylesheet " .
				"WHERE stylesheet_type_id=?");
	$sth->execute($self->stylesheet_type_id());
	my $stylesheet_id = undef;
	while(($stylesheet_id) = $sth->fetchrow_array()) {
	    push(@stylesheet_ids, $stylesheet_id);
	}
	$sth->finish;
    };

    return @stylesheet_ids;
}

# INPUT:  A school name
# OUTPUT: an array of HSDB45::StyleSheet objects which are appropriate for this type
sub stylesheets {
    my $self = shift();
    my $school = shift();
    my $blank_stylesheet = HSDB45::StyleSheet->new(_school => $school);
    return $blank_stylesheet->lookup_conditions(sprintf("stylesheet_type_id='%s'",
							$self->stylesheet_type_id()));
}

1;
