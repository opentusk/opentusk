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


package TUSK::Graphs::EvalStackedBar;

use strict;
use GD;
use GD::Text::Wrap;
use TUSK::Graphs::CommonFunctions;

sub generate_graph {
	my $graphElements = shift;
	my $graphSize = shift;
	$graphSize ||= 200;

	unless(exists(${$graphElements}{'maxXValue'})) {${$graphElements}{'maxXValue'} = 3;}
	unless(exists(${$graphElements}{'minXValue'})) {${$graphElements}{'minXValue'} = 1;}
	unless(exists(${$graphElements}{'maxCategories'})) {${$graphElements}{'maxCategories'} = ${$graphElements}{'maxXValue'};}
	unless(exists(${$graphElements}{'minCategories'})) {${$graphElements}{'minCategories'} = 1;}
	unless(exists(${$graphElements}{'precision'})) {${$graphElements}{'precision'} = 1;}
	
	my $imageHeight = 0;
	my $imageWidth = 0;
	my $numberOfBars = 0;
	if(exists(${$graphElements}{graphData})) {$numberOfBars = scalar(@{${$graphElements}{graphData}});}
	my $textHeight = 12;
	my $textWidth = 6;
	my $barHeight = $textHeight;
	my $yOfTopOfGraph = 0;
	my $spaceAroundBars = 4;
	my $leftXValueOfGraph = 0;
	my $rightXValueOfGraph = 0;
	my $widthBetweenAfterColumns = 15;
	my $font = 'arial';
	
	########################################################################
	##    Nothing should change under here                                ##
	########################################################################
	
	my ($localTextHeight, $localGraphSize, @headers);
	my $maxHeaderLines = 0;
	if(exists(${$graphElements}{topCategories}) && scalar(@{${$graphElements}{topCategories}})) {
		($localTextHeight, $localGraphSize, @headers) = TUSK::Graphs::CommonFunctions::getHeaders( ${$graphElements}{topCategories}, $textHeight,  $textWidth, $graphSize );
		foreach(@headers) {if(scalar(@{$_}) > $maxHeaderLines) {$maxHeaderLines = scalar(@{$_});}}
	}

	#Calculate the height of the graph
	$imageHeight = $numberOfBars * ($barHeight + $spaceAroundBars) + $spaceAroundBars + 3;
	# We know we are going to have a total and the value listed to add some space for the graph height.
	$imageHeight+= 2 * ($textHeight + 2);
	$yOfTopOfGraph = ($textHeight + 2) + (($textHeight * $maxHeaderLines) + 2);
	
	#Calculate the width of the graph
	my $maxPreTextLength = 0;
	my %maxAfterColumnsLength;
	foreach my $afterValue (@{${$graphElements}{afterValues}}) {  $maxAfterColumnsLength{$afterValue} = length($afterValue);  }


	foreach my $hashRef (@{${$graphElements}{graphData}}) {
		if(length(${$hashRef}{'name'}) > $maxPreTextLength) {$maxPreTextLength = length(${$hashRef}{'name'});}
		foreach (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'}) {
			my $afterValueLength = length(${$hashRef}{$_});
			if($maxAfterColumnsLength{$_} < $afterValueLength) {$maxAfterColumnsLength{$_} = $afterValueLength;}
		}
	}
	$leftXValueOfGraph = ($maxPreTextLength * $textWidth) + 2;
	$rightXValueOfGraph = $leftXValueOfGraph + $graphSize;
	$imageWidth = $leftXValueOfGraph + $graphSize + 3;
	foreach my $afterLabel (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'}) {
		$imageWidth += ($maxAfterColumnsLength{$afterLabel} * $textWidth) + $widthBetweenAfterColumns;
	}
	
		
	# Start the graph
	my $textGraph = "<table style=\"margin-top:12px;\" cellspacing=\"4\" cellpadding=\"0\">";
	my $graph = GD::Image->new($imageWidth, $imageHeight);
	
	# Build the color pallet
	my $white = $graph->colorAllocate(255,255,255);
	my $graphBorderColor = $graph->colorAllocate(153,153,153);
	my $black = $graph->colorAllocate(0,0,0);
	my $red = $graph->colorAllocate(255,51,51);
	my $orange = $graph->colorAllocate(255,153,51);
	my $yellow = $graph->colorAllocate(255,255,102);
	my $blue = $graph->colorAllocate(102,102,255);
	my $green = $graph->colorAllocate(102,255,102);
	my @barColors = ($red, $orange, $yellow, $blue, $green);
	
	# set some graph elements;
	$graph->interlaced(1);
	$graph->transparent($white);
	
	# Print extra text over the graph
	if(exists(${$graphElements}{topCategories}) && scalar(@{${$graphElements}{topCategories}})) {
		$yOfTopOfGraph = ($textHeight * $maxHeaderLines)+2;
		my $textTop = 0;
		foreach my $headerLineIndex (0..$maxHeaderLines) {
			foreach my $headerIndex (0..$#headers) {
				my $align = '';
				if($headerIndex == 0) { $align = 'left'; }
				elsif($headerIndex == 1) {
					if(!$headers[2])        {$align = 'right';}
					else                    {$align = 'center';}
				} elsif($headerIndex == 2) {$align='right';}

				if($headers[$headerIndex][$headerLineIndex]) {
					my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($headers[$headerIndex][$headerLineIndex]));
					$textElement->set_font($font, $localTextHeight);
					$textElement->set(align => $align, width=> $graphSize);
					$textElement->draw($leftXValueOfGraph,$textTop);
				}
			}
			$textTop += $textHeight;
		}
	}
	
	# Print the min - max x values
	my $nextAfterValueLeft = $rightXValueOfGraph+$widthBetweenAfterColumns;
	foreach my $anAfterValue (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'}) {
		my $widthOfThisColumn = ($maxAfterColumnsLength{$anAfterValue} * $textWidth);
		my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($anAfterValue));
		$textElement->set_font($font, $textHeight);
		$textElement->set(align => 'right', width=> $widthOfThisColumn);
		$textElement->draw($nextAfterValueLeft,($textHeight+2));
		$nextAfterValueLeft += $widthOfThisColumn + $widthBetweenAfterColumns;
	}

	# Print the total
	my $textElement = GD::Text::Wrap->new($graph, color => $black, text => 'Total');
	$textElement->set_font($font, $textHeight);
	$textElement->set(align => 'center', width=> ($nextAfterValueLeft - ($rightXValueOfGraph+$widthBetweenAfterColumns)));
	$textElement->draw( ($rightXValueOfGraph+$widthBetweenAfterColumns), 0);

	# Text graph Headers
	$textGraph.= "<tr><td>&nbsp;</td><td colspan=\"". (${$graphElements}{'maxCategories'} - ${$graphElements}{'minCategories'}) ."\">Totals</td></tr>";
	$textGraph.= "<tr><td>&nbsp;</td>";
	foreach (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'})
		{$textGraph.= "<td align=\"right\" style=\"border-bottom:1px solid black;\">$_</td>";};
	$textGraph.="</tr>";

	# Print the line under the totals
	$graph->line($rightXValueOfGraph+$widthBetweenAfterColumns, $yOfTopOfGraph, $nextAfterValueLeft, $yOfTopOfGraph, $graphBorderColor);

	# Calculate the bottom y value of the graph
	#   = $top offset + 1 $spaceAroundBars + (number of bars * (barHeight + spaceAroundBar))
	my $yOfBottomOfGraph = $yOfTopOfGraph + $spaceAroundBars + (  $numberOfBars * ($barHeight + $spaceAroundBars)  );
	
	
	# Build graph borders
	$graph->rectangle($leftXValueOfGraph, $yOfTopOfGraph, $rightXValueOfGraph, $yOfBottomOfGraph, $graphBorderColor);
	foreach my $xValue (TUSK::Graphs::CommonFunctions::getTickMarkXValues(${$graphElements}{'maxXValue'}, ${$graphElements}{'minXValue'}, $graphSize)) {
		$graph->line($leftXValueOfGraph+$xValue, $yOfTopOfGraph, $leftXValueOfGraph+$xValue, $yOfBottomOfGraph, $graphBorderColor);
	}
	
	# Print the bars and the after values
	my $barCounter = 0;
	my $pixelsPerPoint = int($graphSize/${$graphElements}{maxXValue});
	foreach my $hashRef (@{${$graphElements}{graphData}}) {
		# Print this bar
		my $yTopOfBar = $yOfTopOfGraph + $spaceAroundBars + ($barCounter * ($barHeight + $spaceAroundBars));
		my $yBottomOfBar = $yTopOfBar + $barHeight;
		my $lastBarStartX = $leftXValueOfGraph;

		$textGraph.= "<tr>";
		# Print the pretext (if exists)
		if(exists(${$hashRef}{'name'})) {
			my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$hashRef}{'name'}));
			$textElement->set_font($font, $textHeight);
			$textElement->set(align => 'right', width=> ($leftXValueOfGraph-2));
			$textElement->draw(0,$yTopOfBar);
			$textGraph.= "<td>${$hashRef}{'name'}</td>";
		} else {
			$textGraph.= "<td>&nbsp;</td>";
		}
		
	
		foreach my $counter (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'}) {
			my $pointsForThisColor = ${$hashRef}{$counter};
			my $barLength = $pointsForThisColor * $pixelsPerPoint;
			$graph->filledRectangle($lastBarStartX, $yTopOfBar, $lastBarStartX+$barLength, $yBottomOfBar, $barColors[$counter-1]);
			$lastBarStartX += $barLength;
			$textGraph.= "<td align=\"right\">$pointsForThisColor</td>";
		}
		$graph->rectangle($leftXValueOfGraph, $yTopOfBar, $lastBarStartX, $yBottomOfBar, $black);
		$barCounter++;

		my $nextAfterValueLeft = $rightXValueOfGraph+$widthBetweenAfterColumns;
		foreach my $anAfterValue (${$graphElements}{'minCategories'}..${$graphElements}{'maxCategories'}) {
			my $widthOfThisColumn = ($maxAfterColumnsLength{$anAfterValue} * $textWidth);
			my $text = sprintf("%01.${$graphElements}{'precision'}f", "${$hashRef}{$anAfterValue}");
			# Our version of GD does not allow 0 (zero) so if we have a 0 value, print an 'O'
			unless($text) {$text = 'O';}
			my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($text));
			$textElement->set_font($font, $textHeight);
			$textElement->set(align => 'right', width=> $widthOfThisColumn);
			$textElement->draw($nextAfterValueLeft,$yTopOfBar);
			$nextAfterValueLeft += $widthOfThisColumn + $widthBetweenAfterColumns;
		}
		$textGraph.= "</tr>";
	}
	
	$textGraph.= "</table>";
	
	my $exportedGraph = 0;
	foreach my $graphFormat (@TUSK::Constants::evalGraphicsFormats) {
		if($graph->can($graphFormat)) {
			$exportedGraph = 1;
			return "image/gif", $graph->$graphFormat, $textGraph;
		} else {
			warn("The eval format $graphFormat was not supported by your GD install. This can be modified in TUSK::Constants::evalGraphicsFormats\n");
		}
	}
	return "text/html", "There are no available graphic formats", $textGraph;
}
	
	
return 1;

