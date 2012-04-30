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


package TUSK::GradeBook::GradeStats;

=head1 NAME

B<TUSK::GradeBook::FinalGrades> - Class for calculating final grades

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;


BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;
    require TUSK::Core::School;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}


use TUSK::GradeBook::GradeEvent;
use TUSK::GradeBook::LinkUserCourseGrade;
use TUSK::GradeBook::LinkCourseGradeEventType;
use TUSK::GradeBook::LinkCourseGradeScale;
use TUSK::GradeBook::LinkCourseCustomScale;
use TUSK::Functions;
use POSIX;

####################################################################################################################

sub getMean {
    
    my ($object,@nums) = @_;
    my $mean=0;
    my $size = scalar(@nums);

    for(my $i=0 ; $i < $size; $i++)
    {
	$mean += $nums[$i];

    }
    return ($mean/ $size);
    #return($size);
   
}

####################################################################################################################

sub getStandardDeviation {

    my ($object,$mean,@nums) = @_;
    my $size = scalar(@nums);
    my $standardDev;
   
    if ($size > 1)
    {
	my $totalDiff=0;
	for(my $i=0; $i < $size; $i++)
	{
	
	    $totalDiff += ($mean - $nums[$i]) ** 2; 

	}
   
        $standardDev = ($totalDiff/($size-1)) ** (1/2);
    }
    else {$standardDev = "not available. Not enough grades available to calculate standard deviation."}
    return $standardDev;

}


#####################################################################################################################

=doc
sub getNumberInEachDecade{
    
    my ($object,@nums) = @_;
    my $numOfGrades;
    for(my $i=0; $i < scalar(@nums);$i++) 
    {
        my $grade = $nums[$i];
	my $j=0;
	while ($j < 11) 
	{
		my $mod = floor($grade / 10);
		if ($mod == $j)
		{
			if(!defined(@$numOfGrades[$j])) { @$numOfGrades[$j]=0;}
			@$numOfGrades[$j]++;
			$j=12;
		}
		$j++;
	}
     }


}  #end sub
=cut

#####################################################################################################################


1;
