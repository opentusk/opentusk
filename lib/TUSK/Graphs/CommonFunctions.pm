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


package TUSK::Graphs::CommonFunctions;

use strict;
use HTML::Entities;
	
sub getHeaders {
	my $arrayRef = shift;
	my $localTextHeight = shift;
	my $localTextWidth = shift;
	my $localGraphSize = shift;

	# Pull the labels out so that we have a right, left and mid label
	my @computedIndexes;
	my @returnHeaders;
	if(scalar(@{$arrayRef}) == 1) {@computedIndexes = (0);}
	elsif(scalar(@{$arrayRef}) == 2) {@computedIndexes = (0, 1);}
	else {
		my $midIndex = int(scalar(@{$arrayRef})/2);
		@computedIndexes = (0, $midIndex, $#{$arrayRef});
	}
	
	# Not check to see if the length of the label will fit in the graphs dimensions
	my $totalLength = 0;
	foreach (@computedIndexes) {
		$totalLength += length(${$arrayRef}[$_]);
		push @returnHeaders, [ ${$arrayRef}[$_] ];
	}

	if(($totalLength * $localTextWidth) > $localGraphSize) {
		# The headers wont fit.
		my $foundSolution = 0;

		# First lets drop the middle value and see if that will fit
		if($computedIndexes[2]) {
			@computedIndexes = ($computedIndexes[0], $computedIndexes[2]);
			$totalLength = length(${$arrayRef}[ $computedIndexes[0] ]) + length(${$arrayRef}[ $computedIndexes[1] ]);
			if(($totalLength * $localTextWidth) < $localGraphSize) {
				$foundSolution = 1;
				# Parse out the middle item of the returnHeaders
				$returnHeaders[1] = $returnHeaders[2];
				delete $returnHeaders[2];
			}
		}

		# Putting new lines in the labels
		unless($foundSolution) {
			# Wipe out the return headers because were going to remake them.
			@returnHeaders = ();

			# At this point we are down to two labels so we are going to take 47% of the graph width.
			my $maxLabelSize = int($localGraphSize * .47);

			# Assume this will work for us.
			$foundSolution = 1;

			# Now we are going to break the text at spaces.
			foreach my $index (@computedIndexes) {
				if(${$arrayRef}[$index] =~ / /) {
					my @wordsInLabel = split / /, ${$arrayRef}[$index];

					# For each item we split into we are going to look at the size of that item and append it to the last item if it was smaller
					my $tempLine = '';
					my @returnArrayItem;
					foreach my $word (@wordsInLabel) {
						if(((length($tempLine) + length($word)) * $localTextWidth) <= $maxLabelSize) {
							# if we can fit this word into the existing words and its small than maxLabelSize, do it.
							if($tempLine) {$tempLine.=" ";}
							$tempLine.=$word;
						} else {
							# If the line contained something, push it onto the return array (if not throw a warning).
							if($tempLine) {
								push @returnArrayItem, $tempLine;
							} else {
								warn("New lines in label did not work!");
								$foundSolution = 0;
							}

							# Now assign the word to the tempLine and start the process over.
							$tempLine = $word;
						}
					}
					# If we had something left in the tempLine...
					if($tempLine) {push @returnArrayItem, $tempLine;}

					# We now have the text packed into an array so we will put this array onto the return array
					push @returnHeaders, \@returnArrayItem;
				} else {
					# There were no spaces!!! Hopfully this just fits, otherwise we are going to have to figure out how to do dashes
					if((length(${$arrayRef}[$index]) * $localTextWidth) <= $maxLabelSize) {
						push @returnHeaders, [ ${$arrayRef}[$index] ];
					} else {
						my $halfWay = int(length(${$arrayRef}[$index])/2);
						my @tempValues;
						push @tempValues, ( substr(${$arrayRef}[$index], 0, $halfWay) . '-' );
						push @tempValues, ( substr(${$arrayRef}[$index], $halfWay, length(${$arrayRef}[$index])) );

						my $tempLength = 0;
						foreach (@tempValues) {
							if((length($_) * $localTextWidth) > $tempLength) {$tempLength = length($_) * $localTextWidth;}
						}
						if($tempLength <= $maxLabelSize) {
							push @returnHeaders, \@tempValues;
						} else {
							warn("There is a label with no spaces, and putting a dash in the middle did not help!!!");
							$foundSolution = 0;
						}
					}
				}
			}

			if(!$foundSolution) {
			}
		}

		unless($foundSolution) {
			# We might have to do something more creative here. Options include
			# Increasing the graph size
			# Truncating the label.
		}
	}
	return ($localTextHeight, $localGraphSize, @returnHeaders);
}

sub getTickMarkXValues {
	my $maxXValue = shift;
	my $minXValue = shift;
	my $graphSize = shift;

	my @xValues;

	# Get the number of tics
	my $numLines = $maxXValue - $minXValue;
	# If this number is huge then factor it down
	if($numLines > 10) {
		while($numLines > 10) { $numLines = $numLines/2; }
		$numLines = int($numLines);
	}

	if($numLines > 1) {
		my $increment = (1/$numLines);
		foreach my $counter (1..$numLines) {
			push @xValues, $graphSize*( $counter * $increment );
		}
	}

	return @xValues;
}


sub escapeLabel {
	# We are currently only stripping out &nbsp; but could do much more.
	# If we decide to do the rest (other entities or HTML Tags) we should use some sort of module to do it.
	my $label = shift;
	$label =~ s/&nbsp;/ /g;
	$label =~ s/&amp;/&/g;
	return $label;
}


return 1;

