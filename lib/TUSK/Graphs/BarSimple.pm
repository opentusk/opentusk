package TUSK::Graphs::BarSimple;

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
	unless(defined(${$graphElements}{'precision'})) {${$graphElements}{'precision'} = 1;}

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
	#	Use the bar size + the spaces around the bars plus an extra 3
	$imageHeight = ($barHeight + $spaceAroundBars) + $spaceAroundBars + 3;
	#	Add in the textheight plus a little if we have top categories
	if(exists(${$graphElements}{topCategories})) { $imageHeight += ($textHeight * $maxHeaderLines) + 2;}
	#	Add in the textheight plus a little for the bottom rankings
	$imageHeight+= $textHeight + 2;

	#Calculate the width of the graph
	# 	Graph size plus some space, plus the length of the value plus a little
	$imageWidth = $graphSize + 3;
	if(exists(${$graphElements}{'showValue'})) {
		$imageWidth += (length($graphValue) * $textWidth) + $spaceBetweenGraphAndAfterText;
	}

	# Start the graph
	my $graph = GD::Image->new($imageWidth, $imageHeight);

	# Build the color pallet
	my $white = $graph->colorAllocate(255,255,255);
	my $graphBorderColor = $graph->colorAllocate(153,153,153);
	my $barColor = $graph->colorAllocate(153, 153, 255);
	my $black = $graph->colorAllocate(0,0,0);
	my $red = $graph->colorAllocate(255,0,0);

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
	my $barLength = int($graphSize * (($graphValue - ${$graphElements}{'minXValue'}) / (${$graphElements}{maxXValue} - ${$graphElements}{'minXValue'})));
	my $yTopOfBar = $yOfTopOfGraph + $spaceAroundBars;
	my $yBottomOfBar = $yTopOfBar + $barHeight;
	$graph->filledRectangle($leftXValueOfGraph, $yTopOfBar, $leftXValueOfGraph+$barLength, $yBottomOfBar, $barColor);
	$graph->rectangle($leftXValueOfGraph, $yTopOfBar, $leftXValueOfGraph+$barLength, $yBottomOfBar, $black);

	my $textGraph = "<div style=\"margin-top:12px; border: 1px solid black;\">$graphValue</div>";

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

	# Add bottom labels
	$textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$graphElements}{'minXValue'}));
	$textElement->set_font($font, $textHeight);
	$textElement->set(align => 'left', width => $graphSize);
	$textElement->draw(0,$yOfBottomOfGraph);

	$textElement = GD::Text::Wrap->new($graph, color => $black, text => TUSK::Graphs::CommonFunctions::escapeLabel(${$graphElements}{'maxXValue'}));
	$textElement->set_font($font, $textHeight);
	$textElement->set(align => 'right', width => $graphSize);
	$textElement->draw(0,$yOfBottomOfGraph);

	# Add warning
	if((($graphValue < ${$graphElements}{'minXValue'}) && ($graphValue != 0)) || ($graphValue > ${$graphElements}{'maxXValue'})) {
		$textElement = GD::Text::Wrap->new($graph, color => $red, text => TUSK::Graphs::CommonFunctions::escapeLabel("Warning: values out of range"));
		$textElement->set_font($font, $textHeight);
		$textElement->set(align => 'center', width => $graphSize);
		$textElement->draw(0,$yOfBottomOfGraph);
	}

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
