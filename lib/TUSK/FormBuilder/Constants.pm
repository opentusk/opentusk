package TUSK::FormBuilder::Constants;

use strict;

########################################################################
## we use the magic(maybe) numbers similar to unix permission
## to store the value of the combination of different report types
# the motivation is to avoid using table but has a single field 
########################################################################

## next flag could be 8
our $default_report_types = [ 
	[ 1, 'Course Summary Report' ],
	[ 2, 'Site Summary Report' ],
	[ 4, 'Student Summary Report' ]
];


## all possible default report values for each report type
our $report_flags_by_report_type = { 
	1 => [ 1, 3, 5, 7 ],
	2 => [ 2, 3, 6, 7 ],
	4 => [ 4, 5, 6, 7 ], 
};


## we are defining the possible value for the default_report value
## only the ones that is the summation of 2 numbers or more
our $map_default_report_flags = {  
	1 => { 1 => 1},
	2 => { 2 => 1},
	3 => { 1 => 1, 2 => 1 },
	4 => { 4 => 1},
	5 => { 1 => 1, 4 => 1 },
	6 => { 2 => 1, 4 => 1 },
	7 => { 1 => 1, 2 => 1, 4 => 1 } 
};

1;
