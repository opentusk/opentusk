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


package TUSK::Application::FormBuilder::DynamicList;

use strict;
use TUSK::FormBuilder::LinkFieldField;
use TUSK::FormBuilder::LinkFieldItemItem;
use TUSK::FormBuilder::Field;
use TUSK::FormBuilder::FieldItem;

sub new {
    my ($class, $args) = @_;

    my $self = { 
	root_field_id => $args->{root_field_id},
	parent_field_id => $args->{parent_field_id},
	child_field_id => $args->{child_field_id},
    };

    bless($self, $class);
    $self->init();
    return $self;
}

sub init {
    my $self = shift;

    ### to simply, at least we need root_field_id
    die unless defined $self->{root_field_id};  

    ###############################################################
    ### there could be a single or multiple link_field_field objects
    ### dependent on how the constructor is initialized
    ###############################################################
    my $cond = "root_field_id = $self->{root_field_id}";
    $cond .= " AND parent_field_id = $self->{parent_field_id}" if $self->{parent_field_id};
    $cond .= " AND child_field_id = $self->{child_field_id}" if  $self->{child_field_id};
    $self->{link_field_field} = TUSK::FormBuilder::LinkFieldField->lookup($cond);
	$self->{root_field} = TUSK::FormBuilder::Field->lookupKey($self->{root_field_id});
}


sub getLinkFieldFieldID {
    my $self = shift;
    ### this method is meant for single link_field_field object
    return ($self->{link_field_field}->[0]) ? $self->{link_field_field}->[0]->getPrimaryKeyID() : undef;
}


sub getItemsData {
    my $self = shift;
    
    return undef unless (defined $self->{child_field_id});

    my $items_data = [];

    ## somewhat kludgy but I couldn't get complex joins to work with three join objects
    my $sql = <<SQL;
SELECT item_id, item_name, parent_field_id, root_field_id, child_field_id, parent_item_id, child_item_id, link_field_item_item_id
FROM tusk.form_builder_link_field_field a, tusk.form_builder_field_item b, tusk.form_builder_link_field_item_item c
WHERE a.child_field_id = b.field_id and b.field_id = $self->{child_field_id} and a.link_field_field_id = c.link_field_field_id and child_item_id = item_id
order by b.sort_order
SQL

    my $results = $self->{link_field_field}->[0]->databaseSelect($sql);
    while (my $array_ref = $results->fetchrow_arrayref()) {
		push (@$items_data, { 
	    item_id => $array_ref->[0], 
	    name => $array_ref->[1],
	    parent_field_id => $array_ref->[2], ### for link_field_field
	    field_id => $array_ref->[2],    ### for field_item
	    root_field_id => $array_ref->[3], 
	    child_field_id => $array_ref->[4],  
	    parent_item_id => $array_ref->[5], 
	    child_item_id => $array_ref->[6], 
	    link_field_item_item_id => $array_ref->[7],
	    link_field_field_id => $self->getLinkFieldFieldID(), 
	});
    }
    return $items_data;
}


#########################################################
## method returns parent/child items 
## 
## [ 
##   { parent_field_id => _parent_field_id,
##     child_field_name => child_field_name,
##     items => { parent_item_id  => [ 
##                 child_item_id => { parent => [ parent_item_id, ... ],
##                                    children => [ [item_name, item_id], ...], },
##               ...] }
##   }
## ]
#########################################################
sub getChildFieldsWithItems {
    my $self = shift;

    my @child_fields = ();
	my %parent_items = ();   ### key = child_item, value = parent_item
	my %existing_items = ();    ### key1 = child_item, key2 = parent_item, value = 1 if exists
    my $i = 0;

    foreach my $link_field (@{$self->{link_field_field}}) {
		my $child_field = TUSK::FormBuilder::Field->lookupKey($link_field->getChildFieldID());	
		my $child_field_id = $child_field->getPrimaryKeyID();

		$child_fields[$i] = { parent_field_id => $link_field->getParentFieldID(),
							  child_field_id => $child_field_id,
							  child_field_name => $child_field->getFieldName() };

		push @{$child_fields[0]->{child_field_ids}}, $child_field_id;

		### child item ids/names
		my $link_items = TUSK::FormBuilder::LinkFieldItemItem->lookup("link_field_field_id = " .  $link_field->getPrimaryKeyID(), ['sort_order'], undef, undef, [TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldItem", { origkey => 'child_item_id', joinkey => 'item_id', jointype => 'inner'})]);

		foreach my $link_item (@$link_items) {
			my $parent_item_id = $link_item->getParentItemID();
			my $parent_item = TUSK::FormBuilder::FieldItem->lookupKey($parent_item_id);
			my $child_item_id = $link_item->getChildItemID();
			
			if ($parent_item_id && $child_item_id) {
				### parent item of current item
				unless (exists $child_fields[$i]->{items}{$parent_item_id}) {
					$child_fields[$i]->{parent_items}{$parent_item_id} = $parent_item->getItemName() if ($parent_item);
				}
				
				### get children items info
				push @{$child_fields[$i]->{items}{$parent_item_id}{children}}, [ $link_item->getFieldItemObject()->getItemName(), $child_item_id ];

				### skip the duplicates and add only those are not null
				unless ($existing_items{$parent_item_id}{$parent_items{$parent_item_id}}) {
					if (exists $parent_items{$parent_item_id}) {
						push @{$child_fields[$i]->{items}{$parent_item_id}{parent}}, $parent_items{$parent_item_id};
					}
				}
				$parent_items{$child_item_id} = $parent_item_id;
				### keep track of items that already in the list
				$existing_items{$parent_item_id}{$parent_items{$parent_item_id}} = 1 if exists ($parent_items{$parent_item_id});
			}
		}

		### add all the parent items to current item
		foreach my $pid (keys %{$child_fields[$i]->{items}}) {
			my $curr_pid = $pid;
			my $loop = 1;
			while ($loop) {
				if (exists($parent_items{$pid})) {
					unless ($existing_items{$curr_pid}{$parent_items{$pid}}) {
						unshift @{$child_fields[$i]->{items}{$curr_pid}{parent}}, $parent_items{$pid};
					}
					$pid = $parent_items{$pid};  ### go up the tree
				} else {
					$loop = 0;
				}
			}
		}

		$i++;
    }

    return \@child_fields;
}



sub getNextDepthLevel {
	my $self = shift;

	my $sth = $self->{root_field}->databaseSelect("select max(depth_level) from tusk.form_builder_link_field_field where root_field_id = $self->{root_field_id}");
	my $max = $sth->fetchrow_array;
	$sth->finish;
	return ($max) ? $max+1 : 1;
}


sub getParentItemNames {
	my $self = shift;
	return unless $self->{parent_field_id};

	my $sth = $self->{root_field}->databaseSelect("select item_id, item_name, (select item_name from tusk.form_builder_field_item b, tusk.form_builder_link_field_item_item c where c.parent_item_id = b.item_id and c.parent_item_id = b.item_id and c.child_item_id = a.item_id) as parent_item from tusk.form_builder_field_item a where field_id = $self->{parent_field_id} order by a.sort_order");

	my @arr = ();
	while (my ($item_id, $item_name, $parent_item) = $sth->fetchrow_array()) {
		push @arr, [$item_id, $item_name, $parent_item];
	}
	$sth->finish;
	return \@arr;
}


1;
