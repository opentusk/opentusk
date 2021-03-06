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


package TUSK::Graphs::YesNoSimple;

use strict;
use GD;
use GD::Text::Wrap;
use TUSK::Graphs::CommonFunctions;

sub generate_graph {
	my $graphValue = shift;
        my $graphElements = shift;
        my $graphSize = shift;
        $graphSize ||= 200;

	unless(defined(${$graphElements}{'maxXValue'})) {${$graphElements}{'maxXValue'} = 3;}
	unless(defined(${$graphElements}{'minXValue'})) {${$graphElements}{'minXValue'} = 1;}

        my $imageWidth = 0;
        my $imageHeight = 0;
        my $textHeight = 12;
        my $textWidth = 6;
        my $barHeight = $textHeight;
        my $yOfTopOfGraph = 0;
        my $spaceAroundBars = 4;
        my $font = 'arial';
        my $spaceBetweenGraphAndAfterText = 5;

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
        #       Use the bar size + the spaces around the bars plus an extra 3
        $imageHeight = ($barHeight + $spaceAroundBars) + $spaceAroundBars + 3;
        #       Add in the textheight plus a little if we have top categories
        if(exists(${$graphElements}{topCategories})) { $imageHeight += ($textHeight * $maxHeaderLines) + 2;}
        #       Add in the textheight plus a little for the bottom rankings
        $imageHeight+= $textHeight + 2;

        #Calculate the width of the graph
        #       Graph size plus some space, plus the length of the value plus a little
        $imageWidth = $graphSize + 3;
        if(exists(${$graphElements}{'showValue'})) {
                $imageWidth += (length($graphValue) * $textWidth) + $spaceBetweenGraphAndAfterText;
        }

        # Start the graph
        my $graph = GD::Image->new($imageWidth, $imageHeight);

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

        # This is here so that if (in the future) we want to enable pre-text on this graph we can do that.
        my $leftXValueOfGraph = 0;
        my $rightXValueOfGraph = $leftXValueOfGraph + $graphSize;

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


        # Calculate the bottom y value of the graph
        my $yOfBottomOfGraph = $yOfTopOfGraph + $spaceAroundBars + $barHeight + $spaceAroundBars;

        # Build graph borders
	$graph->rectangle($leftXValueOfGraph, $yOfTopOfGraph, $rightXValueOfGraph, $yOfBottomOfGraph, $graphBorderColor);
	foreach my $xValue (TUSK::Graphs::CommonFunctions::getTickMarkXValues(${$graphElements}{'maxXValue'}, ${$graphElements}{'minXValue'}, $graphSize)) {
		$graph->line($leftXValueOfGraph+$xValue, $yOfTopOfGraph, $leftXValueOfGraph+$xValue, $yOfBottomOfGraph, $graphBorderColor);
	}

        # Some computation. The Graph is 200px (4 50px sections) the user passes in the max size for the graph and the mean for this row so we have to convert it
	my $midPoint = ((${$graphElements}{maxXValue} - ${$graphElements}{minXValue})/2) + ${$graphElements}{minXValue};

	my $barColor = $medianBarColor;

	my $xStartOfBar = $leftXValueOfGraph+($graphSize*.50);
	my $xEndOfBar = $leftXValueOfGraph+($graphSize*.50);

        my $yTopOfBar = $yOfTopOfGraph + $spaceAroundBars;
        my $yBottomOfBar = $yTopOfBar + $barHeight;

	if(abs(($graphValue/1) - $midPoint) < .001 ) {
		$xStartOfBar -= 5;
		$xEndOfBar += 5;
	} elsif($graphValue > $midPoint) {
		# Make a positive graph
		$barColor = $positiveBarColor;
		$xEndOfBar = $leftXValueOfGraph + int($graphSize * (($graphValue - ${$graphElements}{'minXValue'}) / (${$graphElements}{maxXValue} - ${$graphElements}{'minXValue'})));
	} elsif($graphValue < $midPoint) {
		# Make a negative graph
		$barColor = $negativeBarColor;
		$xStartOfBar = $leftXValueOfGraph + int($graphSize * (($graphValue - ${$graphElements}{'minXValue'}) / (${$graphElements}{maxXValue} - ${$graphElements}{'minXValue'})));
	} else {
		# If you ever make it here, you have a problem.
	}
        $graph->filledRectangle($xStartOfBar, $yTopOfBar, $xEndOfBar, $yBottomOfBar, $barColor);
        $graph->rectangle($xStartOfBar, $yTopOfBar, $xEndOfBar, $yBottomOfBar, $black);

        my $textElement;
        # Add ending label if requested
        if(exists(${$graphElements}{'showValue'})) {
		# Our version of GD does not allow 0 (zero) so if we have a 0 value, print an 'O'
		unless($graphValue) {$graphValue = 'O';}
                $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel($graphValue));
                $textElement->set_font($font, $textHeight);
                $textElement->set(align => 'left');
                $textElement->draw($graphSize+$spaceBetweenGraphAndAfterText,$yTopOfBar);
        }

	my $textGraph = "<div style=\"margin-top:12px; border:1px solid black;\">$graphValue</div>";

        # Add bottom labels
        $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$graphElements}{'minXValue'}));
        $textElement->set_font($font, $textHeight);
        $textElement->set(align => 'left', width => $graphSize);
        $textElement->draw(0,$yOfBottomOfGraph);

        $textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$graphElements}{'maxXValue'}));
        $textElement->set_font($font, $textHeight);
        $textElement->set(align => 'right', width => $graphSize);
        $textElement->draw(0,$yOfBottomOfGraph);

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
