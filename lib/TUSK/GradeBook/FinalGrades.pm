package TUSK::GradeBook::FinalGrades;

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
use TUSK::GradeBook::CourseStandardScale;
use TUSK::GradeBook::LinkUserCourseGrade;
use TUSK::GradeBook::LinkCourseGradeEventType;
use TUSK::GradeBook::LinkCourseGradeScale;
use TUSK::GradeBook::LinkCourseCustomScale;
use TUSK::GradeBook::LinkGradeEventGradeScale;
use TUSK::Functions;

####################################################################################################################

sub updateFinalGrades {


  my ($courseID, $timeperiod, $school ) = @_;
  my $course  = HSDB45::Course->new(_id=>$courseID, _school=>$school); 
  my @students = $course->get_students($timeperiod);
  my $printData;

    foreach my $st (@students)
    {

	my $student = $st->primary_key;
        calculateFinalGrade($school,$courseID,$student,$timeperiod, $printData);
    }


}


####################################################################################################################

sub calculateFinalGrade {

my ($school, $courseID, $student, $timeperiod, $printData) = @_;

my $events = TUSK::GradeBook::GradeEvent->new->getCourseEvents($school, $courseID, $timeperiod);
my $eventTypes = TUSK::GradeBook::GradeEventType->new->lookup();
my $numTypes = scalar (@$eventTypes);
my $typeWeights;
my $sums;
my $total=0;
my $highest;
my $lowest;
my $addToWeight;
my $lowestGradeID;
my $highestGradeID;
my $numEventsPerType;
my $size = scalar (@$events);
my $totalWeight=0;


#if there are no events, dont do anything
if ($size != 0)
{

#this loop loads the numEventsPerType, lowest, lowestGradeID, highest and highestGradeID arrays
for (my $i=0; $i < $size; $i++)
{
	
	my $evTypeID = @$events[$i]->getGradeEventTypeID();
	my $qString = "course_id = $courseID and grade_event_type_id = $evTypeID";
	my $linkCrsEventType = TUSK::GradeBook::LinkCourseGradeEventType->lookupReturnOne($qString);
        #if the prefs werent set, default to 0
        if (!defined($linkCrsEventType))
	{
	    	$linkCrsEventType = TUSK::GradeBook::LinkCourseGradeEventType->new();
		$linkCrsEventType->setCourseID($courseID);
		$linkCrsEventType->setGradeEventTypeID($evTypeID);
		$linkCrsEventType->setTimePeriodID($timeperiod);
		$linkCrsEventType->save();
	}
	my $indx;
         
	while($evTypeID ne @$eventTypes[$indx]->{'_field_values'}->{'grade_event_type_id'})
	{$indx++;}
	
	#add to the number of events of this type
	if( !defined(@$numEventsPerType[$indx]) ) { @$numEventsPerType[$indx]=1; }
	else { @$numEventsPerType[$indx]+=1; } 
        
	if ($linkCrsEventType->getDropLowest() eq "1" || $linkCrsEventType->getDropHighest() eq "1")
	{
	      	my $event_id = @$events[$i]->{'_field_values'}->{'grade_event_id'}; 
		my $event = TUSK::GradeBook::GradeEvent->new->lookupKey($event_id);
                my $event_name = @$events[$i]->getEventName();
                my $course = HSDB45::Course->new(_id=>$courseID, _school=>$school);
		my ($grades_data, $saved_grades) = $event->getCourseGrades($course, $timeperiod);
               
                my $theGrade;
      		my $j=0;
		while( $grades_data->[$j]->{"user_id"} ne $student )
		{ $j++ }
                
                $theGrade = $grades_data->[$j]->{"grade"};
	
		if( (!defined( @$lowest[$indx]) || @$lowest[$indx] > $theGrade)  && $linkCrsEventType->getDropLowest() eq "1")
		{	
			@$lowest[$indx] = $theGrade;
			@$lowestGradeID[$indx] = $event_id;
		} 
        

		if( (!defined (@$highest[$indx]) || @$highest[$indx] < $theGrade) && $linkCrsEventType->getDropHighest() eq "1")
		{
			@$highest[$indx] = $theGrade;
			@$highestGradeID[$indx] = $event_id;
		}
	}
			
}

#waive grade
#go through each event, if waive grade is true, get type. redistribute weights
 
my $h=0;
while(defined(@$events[$h]))
{

        my $wt = @$events[$h]->getWeight();
	$totalWeight += $wt;
        
	if ( @$events[$h]->{'_field_values'}->{'waive_grade'} eq "1" )
	{
		
		my $evTypeID = @$events[$h]->getGradeEventTypeID();
		my $indx=0;
		while ($evTypeID ne @$eventTypes[$indx]->{'_field_values'}->{'grade_event_type_id'})
		{$indx++;}
                
		if(@$numEventsPerType[$indx] > 1)
		{
		    @$numEventsPerType[$indx] -= 1;
		    @$addToWeight[$indx] = $wt / @$numEventsPerType[$indx];
		}
		
	}

$h++;
}
# end waive grade


# this loop calculates the weights to add to events of a type where a grade is being dropped
# it also loads the typeWeights array
for (my $k=0; $k < scalar(@$numEventsPerType); $k++)
{
	if( defined(@$lowestGradeID[$k]))
	{
		my $event = TUSK::GradeBook::GradeEvent->new->lookupKey(@$lowestGradeID[$k]);
		if( defined($event))
		{
			my $lowestGradeWeight = $event->getWeight();
		      

			if(@$numEventsPerType[$k] > 1)
			{
			    
			    @$numEventsPerType[$k] -= 1;
			    @$addToWeight[$k] = $lowestGradeWeight / @$numEventsPerType[$k];

			 
			}
			
		}
	}
        
	if( defined(@$highestGradeID[$k]))
	{
                
		my $event = TUSK::GradeBook::GradeEvent->new->lookupKey(@$highestGradeID[$k]);
		if( defined($event))
		{
			my $highestGradeWeight = $event->getWeight();
                        
			if(@$numEventsPerType[$k] > 1)
			{
			    @$numEventsPerType[$k] -= 1;
			    @$addToWeight[$k] = $highestGradeWeight / @$numEventsPerType[$k];
			 
			}
		}
	}
       
	my $typeID = @$eventTypes[$k]->{'_field_values'}->{'grade_event_type_id'};
        
        #i'm putting the query String (qString) in this fashion from now on, it makes the following line cleaner and shorter
	my $qString = "course_id = $courseID and grade_event_type_id = $typeID";
	my $linkCourseGradeEventType = TUSK::GradeBook::LinkCourseGradeEventType->lookupReturnOne($qString);
	if (defined($linkCourseGradeEventType))
	{
		push(@$typeWeights, $linkCourseGradeEventType->getTotalWeight());
	}

} 



# for each grade event, tally up the sums for the final avg
for(my $i=0; $i < $size; $i++)
{
	my $event_id = @$events[$i]->{'_field_values'}->{'grade_event_id'}; 
	my $event_name = @$events[$i]->getEventName();        
	my $qString = "child_grade_event_id = $event_id and parent_user_id = '$student'";
	my $linkUserGrade = TUSK::GradeBook::LinkUserGradeEvent->lookupReturnOne($qString);
	my $gradeVal;
        
	if( defined($linkUserGrade))
	{
          $gradeVal = $linkUserGrade->getGrade();
	 
	}

	## Begin code used for getting the final average
        my $eventWeight = @$events[$i]->getWeight();
	my $evTypeID = @$events[$i]->getGradeEventTypeID();
	my $dropping=0;
        
	my $gEventType = TUSK::GradeBook::GradeEventType->lookupReturnOne("grade_event_type_id = $evTypeID");
	my $typeName = $gEventType->getGradeEventTypeName();			
	my $indx;
        
        $qString = "course_id = $courseID and grade_event_type_id = $evTypeID";
	my $linkCrsEventType = TUSK::GradeBook::LinkCourseGradeEventType->lookupReturnOne($qString);
			
	while($evTypeID ne @$eventTypes[$indx]->{'_field_values'}->{'grade_event_type_id'})
	{$indx++;}
	
	
	if( $linkCrsEventType->getDropLowest() eq "1" && $event_id eq @$lowestGradeID[$indx] && defined($gradeVal))
	{  
		$dropping = 1;
		my $tStr="<b>The lowest $typeName is being dropped. Currently the lowest $typeName grade is $gradeVal</b>";
		push(@$printData,$tStr);	
	}			
	if ($linkCrsEventType->getDropHighest() eq "1" && $event_id eq @$highestGradeID[$indx] && defined($gradeVal))
	{ 
	        $dropping = 1;
		my $tStr="<b>The highest $typeName is being dropped. Currently the highest $typeName grade is $gradeVal </b>";
		push(@$printData,$tStr);
	}
	if( @$events[$i]->getWaiveGrade() eq "1" )
	{
		$dropping =1;
		my $tStr="<b>The grade for $typeName *$event_name* is being waived</b>";
		push(@$printData,$tStr);
	}
	        
	             
	        my $y=0;
		if (!defined(@$addToWeight[$indx])) { @$addToWeight[$indx]=0; }
                
		if ( $gradeVal =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $gradeVal !~ /^[\. ]*$/  ) 
		{ 
                        if ($dropping != 1)
			{
			    @$sums[$indx]+= $gradeVal * ($eventWeight + @$addToWeight[$indx]) ;
			}
		}  
		else
		{
		         
			 my $linkGradeEventScale = TUSK::GradeBook::LinkGradeEventGradeScale->lookup("grade_event_id = $event_id");
			 my $flag=0;		
			 while( defined(@$linkGradeEventScale[$y]) )
			 {
			    
				if($gradeVal eq @$linkGradeEventScale[$y]->getSymbolicValue())
				{
				    
				   
					$gradeVal = @$linkGradeEventScale[$y]->getNumericValue();
					if ($dropping !=1)
					{
					    @$sums[$indx]+= $gradeVal * ($eventWeight + @$addToWeight[$indx]) ;
				        }
					$flag=1;
				}
				$y++;
			 }
                        
			if ( $flag ne '1') # if gradeVal isnt a number and theres no corresponding scale value send msg
			{
			        my $tStr="<b>The grade for $event_name is invalid, please replace this value.</b>";
				push(@$printData,$tStr);
			}
                        
		}	 		
	
	## End code used for getting the final average



} ##end for loop



if( defined(@$sums))
{
	for(my $k=0;$k< scalar(@$sums); $k++) { $total+= @$sums[$k]; }
	if($totalWeight > 0)
	{
	    $total= $total/($totalWeight);
            
	}
	else
	{
	    $total=0;
	    my $tStr ="<b> CANNOT CALCULATE AVERAGE: No Data available or weights not set.</b>";
	    push(@$printData,$tStr);
	}
}



my $qString = "course_id = $courseID and time_period_id = $timeperiod and user_id = '$student'";
my $linkGrades = TUSK::GradeBook::LinkUserCourseGrade->lookupReturnOne($qString);

if( !defined($linkGrades) )
{
    
    $linkGrades= TUSK::GradeBook::LinkUserCourseGrade->new();
    $linkGrades->setCourseID($courseID);
    $linkGrades->setTimePeriodID($timeperiod);
    $linkGrades->setUserID($student);
}
 
$linkGrades->setAverage($total);
my $letterGrade = getGradeWithScale(1,$total,$courseID,$timeperiod,$student);
$linkGrades->setCourseGrade($letterGrade);
$linkGrades->save();


} #end if size !=0
else
{
    my $tStr="<b>There are no grade events to display.</b>";
    push(@$printData,$tStr);
   
}


return $total;


}

################################################################################################################################################

sub getGradeWithScale
{

my ($obj,$avg, $courseID,$timePeriod,$student) = @_;   
my $linkScaleType = TUSK::GradeBook::LinkCourseGradeScale->lookupReturnOne("course_id = $courseID");
if( !defined($linkScaleType))
{
	$linkScaleType = TUSK::GradeBook::LinkCourseGradeScale->new();
	$linkScaleType->setCourseID($courseID);
	$linkScaleType->setGradeScaleTypeID(2);
	$linkScaleType->setTimePeriodID($timePeriod);
	$linkScaleType->save();	
}

my $scaleTypeID = $linkScaleType->getGradeScaleTypeID();
my $gradeWithScale;

if( $scaleTypeID eq "1" || $scaleTypeID eq "4" )  # standard scale(1) as defined by Database, or custom scale (4)
{
	my $linkScale;
        
        if( $scaleTypeID eq "1")
	{	$linkScale = TUSK::GradeBook::CourseStandardScale->lookup(); 	}
	else
	{	$linkScale = TUSK::GradeBook::LinkCourseCustomScale->lookup("course_id = $courseID order by lower_bound DESC"); }
         
        
	my $j=0;
	while( defined(@$linkScale[$j]) && !defined($gradeWithScale) )
	{
		my $lBound = @$linkScale[$j]->getLowerBound();
		if ($avg >= $lBound )
		{
			$gradeWithScale = @$linkScale[$j]->getGrade();
		}
			
	        
		$j++;
	}
	#this if catches the event in which the average is less than the last defined lower bound
	#it just assigns a message
	if( !defined($gradeWithScale))
	{
		$gradeWithScale = "N/A ::Average is less than lowest defined bound";
	}
	$gradeWithScale="$gradeWithScale";

}
elsif ( $scaleTypeID eq "2") # percentage scale
{
	$gradeWithScale="$avg";
}
elsif ($scaleTypeID eq "3") # no scale
{
	my $qString = "course_id = $courseID and time_period_id = $timePeriod and user_id = '$student'";
	my $linkGrades = TUSK::GradeBook::LinkUserCourseGrade->lookupReturnOne($qString);
    $gradeWithScale = $linkGrades->getCourseGrade();
    if (!defined($gradeWithScale)){
		$gradeWithScale="None";
	}
}
else # some unknown Type has entered the DB
{
	$gradeWithScale = "N/A :: Final Grading Scale is unknown.";
}


return $gradeWithScale;

}


#################################################################################################################################################

1;
