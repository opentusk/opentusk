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


package TUSK::User::Link;

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use JSON;

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
					'tablename' => 'user_link',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_link_id' => 'pk',
					'user_id' => '',
					'label' => '',
					'url' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _default_order_bys => ['sort_order'],
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

# Get/Set methods

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}


sub getUrl{
    my ($self) = @_;
    return $self->getFieldValue('url');
}

sub setUrl{
    my ($self, $value) = @_;

	$value = 'http://' . $value unless (!$value || $value =~ /^[A-z]*:\/\//);

    $self->setFieldValue('url', $value);
}

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}

sub delete {
    my ($self, $params) = @_;

	my $sort_order = $self->getSortOrder();
	my $links = getAllLinks($self->getUserID());
	my $start = $self->getSortOrder();	
	my $retval = $self->SUPER::delete($params);

	if($retval){
		foreach my $l (@$links){
			my $order = $l->getSortOrder();
			if ($order > $start) {
				$l->setSortOrder( ($order - 1) );
			}
			$l->save($params);
		}
	}
	return $retval; 
}


# Returns all the user's links
sub getAllLinks {
    my $user_id = shift;

	my $links = [];
	if($user_id){
		$links = TUSK::User::Link->new()->lookup('user_id="' . $user_id . '"', ['sort_order ASC']);
	}

	return $links;
}

# output JSON for object
sub TO_JSON {
	my $self = shift;
	my %objHash;
	$objHash{id} = $self->getPrimaryKeyID();
	$objHash{user_id} = $self->getUserID();
	$objHash{label} = $self->getLabel();
	$objHash{url} = $self->getUrl();
	$objHash{sort_order} = $self->getSortOrder();
	
	return JSON->new()->allow_blessed(1)->convert_blessed(1)->encode(\%objHash);
}


1;

