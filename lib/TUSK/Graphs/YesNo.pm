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


package TUSK::Graphs::YesNo;

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
	if(exists(${$graphElements}{topCategories}) || exists(${$graphElements}{afterValues})) {$imageHeight += ($textHeight * $maxHeaderLines) + 2;}
	if(exists(${$graphElements}{afterValues})) {$imageHeight += $textHeight + 2;}
	
	
	#Calculate the width of the graph
	my $maxPreTextLength = 0;
	my %maxAfterColumnsLength;
	foreach my $afterValue (@{${$graphElements}{afterValues}}) {  $maxAfterColumnsLength{$afterValue} = length($afterValue);  }
	foreach my $hashRef (@{${$graphElements}{graphData}}) {
		if(length(${$hashRef}{'name'}) > $maxPreTextLength) {$maxPreTextLength = length(${$hashRef}{'name'});}
		if(exists(${$graphElements}{afterValues}) && scalar(@{${$graphElements}{afterValues}})) {
			foreach my $afterValue (@{${$graphElements}{afterValues}}) {
				my $afterValueLength = 0;
				if(exists(${$hashRef}{$afterValue})) {$afterValueLength = length(${$hashRef}{$afterValue});}
				if($maxAfterColumnsLength{$afterValue} < $afterValueLength) {$maxAfterColumnsLength{$afterValue} = $afterValueLength;}
			}
		}
	}
	$leftXValueOfGraph = ($maxPreTextLength * $textWidth) + 2;
	$imageWidth = $leftXValueOfGraph + $graphSize + 3;
	$rightXValueOfGraph = $leftXValueOfGraph + $graphSize;
	foreach my $afterLabel (@{${$graphElements}{afterValues}}) {
		$imageWidth += ($maxAfterColumnsLength{$afterLabel} * $textWidth) + $widthBetweenAfterColumns;
	}
	
		
	# Start the graph
	my $graph = GD::Image->new($imageWidth, $imageHeight);
	my $textGraph = "<table style=\"margin-top:12px;\" border=\"0\" cellspacing=\"4\" cellpadding=\"0\">";
	
	# Build the color pallet
	my $white = $graph->colorAllocate(255,255,255);
	my $graphBorderColor = $graph->colorAllocate(153,153,153);
	my $positiveBarColor = $graph->colorAllocate(153, 255, 153);
	my $negativeBarColor = $graph->colorAllocate(255, 153, 153);
	my $medianBarColor = $graph->colorAllocate(153, 153, 153);
	my $black = $graph->colorAllocate(0,0,0);
	
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

	
	# Print the headers after the graph values
	if(exists(${$graphElements}{afterValues}) && scalar(@{${$graphElements}{afterValues}})) {
		$textGraph.= "<tr><td colspan=\"2\">&nbsp;</td>";
		unless($yOfTopOfGraph) {$yOfTopOfGraph = $textHeight +2;}
		my $nextAfterValueLeft = $rightXValueOfGraph+$widthBetweenAfterColumns;
		foreach my $anAfterValue (@{${$graphElements}{afterValues}}) {
			$textGraph.= "<td>$anAfterValue</td>";
			my $widthOfThisColumn = ($maxAfterColumnsLength{$anAfterValue} * $textWidth);
			my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($anAfterValue));
			$textElement->set_font($font, $textHeight);
			$textElement->set(align => 'right', width=> $widthOfThisColumn);
			$textElement->draw($nextAfterValueLeft,0);
			$nextAfterValueLeft += $widthOfThisColumn + $widthBetweenAfterColumns;
		}
		$textGraph.= "</tr>";
	}
	
	
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
	foreach my $hashRef (@{${$graphElements}{graphData}}) {
		# Print this bar
		# Some computation. The Graph is 200px (4 50px sections) the user passes in the max size for the graph and the mean for this row so we have to convert it
		my $midPoint = ((${$graphElements}{maxXValue} - ${$graphElements}{minXValue})/2) + ${$graphElements}{minXValue};
		my $barColor = $medianBarColor;

		my $xStartOfBar = $leftXValueOfGraph+($graphSize*.50);
		my $xEndOfBar = $leftXValueOfGraph+($graphSize*.50);

		my $yTopOfBar = $yOfTopOfGraph + $spaceAroundBars + ($barCounter * ($barHeight + $spaceAroundBars));
		my $yBottomOfBar = $yTopOfBar + $barHeight;

		if(abs((${$hashRef}{value}/1) - $midPoint) < .001 ) {
			$xStartOfBar -= 5;
			$xEndOfBar += 5;
		} elsif(${$hashRef}{value} > $midPoint) {
			# Make a positive graph
			$barColor = $positiveBarColor;
			$xEndOfBar = $leftXValueOfGraph + int($graphSize * ((${$hashRef}{value} - ${$graphElements}{'minXValue'}) / (${$graphElements}{maxXValue} - ${$graphElements}{'minXValue'})));
		} elsif(${$hashRef}{value} < $midPoint) {
			# Make a negative graph
			$barColor = $negativeBarColor;
			$xStartOfBar = $leftXValueOfGraph + int($graphSize * ((${$hashRef}{value} - ${$graphElements}{'minXValue'}) / (${$graphElements}{maxXValue} - ${$graphElements}{'minXValue'})));
		} else {
			# If you ever make it here, you have a problem.
		}
		$graph->filledRectangle($xStartOfBar, $yTopOfBar, $xEndOfBar, $yBottomOfBar, $barColor);
		$graph->rectangle($xStartOfBar, $yTopOfBar, $xEndOfBar, $yBottomOfBar, $black);

		$barCounter++;
	
		# Print the pretext (if exists)
		$textGraph.= "<tr><td>";
		if(exists(${$hashRef}{'name'})) {
			my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$hashRef}{'name'}));
			$textElement->set_font($font, $textHeight);
			$textElement->set(align => 'right', width=> ($leftXValueOfGraph-2));
			$textElement->draw(0,$yTopOfBar);
			$textGraph.= ${$hashRef}{'name'};
		} else {
			$textGraph.= "&nbsp;";
		}
		$textGraph.= "</td>";

		$textGraph.= "<td>${$hashRef}{value}</td>";
	
	
		if(exists(${$graphElements}{afterValues}) && scalar(@{${$graphElements}{afterValues}})) {
			my $nextAfterValueLeft = $rightXValueOfGraph+$widthBetweenAfterColumns;
			foreach my $anAfterValue (@{${$graphElements}{afterValues}}) {
				$textGraph.= "<td>";
				if(exists(${$hashRef}{$anAfterValue})) {
					my $widthOfThisColumn = ($maxAfterColumnsLength{$anAfterValue} * $textWidth);
					my $text = sprintf("%.${$graphElements}{'precision'}f", ${$hashRef}{$anAfterValue});
					# Our version of GD does not allow 0 (zero) so if we have a 0 value, print an 'O'
					unless($text) {$text = 'O';}
					my $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($text));
					$textElement->set_font($font, $textHeight);
					$textElement->set(align => 'right', width=> $widthOfThisColumn);
					$textElement->draw($nextAfterValueLeft,$yTopOfBar);
					$nextAfterValueLeft += $widthOfThisColumn + $widthBetweenAfterColumns;
					$textGraph.= $text;
				} else {
					$textGraph.= "&nbsp;";
				}
				$textGraph.= "</tr>";
			}
		}
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

