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


package HSDB45::Eval::Results::BarGraphCreator;

use strict;

use HSDB4::Constants qw(get_school_db);
use HSDB45::Eval::Results;
use HSDB45::Eval::Results::BarGraph;
use HSDB45::Eval::Results::SupportingGraphs;
use HSDB45::Eval::Formatter;
use HSDB45::StyleSheet;
use TUSK::Graphs::YesNoSimple;
use TUSK::Graphs::YesNo;
use TUSK::Graphs::Bar;
use TUSK::Graphs::BarSimple;
use TUSK::Graphs::EvalStackedBar;

use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.20 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Results',
		 'HSDB45::Eval::Results::BarGraph',
		 'HSDB45::Eval::Formatter');

my @file_deps = ($ENV{XSL_ROOT} . '/Eval/bar_graph_collection.xsl',
		 $ENV{XSL_ROOT} . '/Eval/bar_graph.xsl');

my %abbreviationHash;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

# Description: Generic constructor
# Input: An Eval::Results object
# Output: Blessed, initialized HSDB45::Eval::Results::BarGraphCreator object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

# Description: Private initializer
# Input: An Eval::Results object
# Output: Initialized BarGraph
sub init {
    my $self = shift;
    $self->{-school} = shift;
    $self->{-eval_id} = shift;
    $self->{-xml_doc} =  shift;
    my $eval = HSDB45::Eval->new(_school => $self->{-school}, _id => $self->{-eval_id});
    my $formatter = HSDB45::Eval::Formatter->new($eval);
    my $eval_xml = $formatter->get_xml_text();
    $self->{-xml_doc} =~ s/^(<Eval_Results [^>\/]+>)/$1\n$eval_xml/s;
    $self->{-xslt_path} = $ENV{XSL_ROOT} . '/Eval/bar_graph_collection.xsl';
    return $self;
}

sub get_xslt_path {
    my $self = shift;
    return $self->{-xslt_path};
}

# Description: Gets the results XML
# Input:
# Output: The XML::LibXML::Document object
sub get_results_xml {
    my $self = shift;
    return $self->{-xml_doc}
}

# Description: Gets the ID of the eval
# Input:
# Output: The ID
sub get_eval_id {
    my $self = shift;
    return $self->{-eval_id};
}

# Description: Gets the school of the eval
# Input:
# Output: The school
sub get_school {
    my $self = shift;
    return $self->{-school};
}

# Description: Makes the SVG-collection XML document
# Input:
# Output: The XML::LibXML::Document object
sub get_svg_xml {
    my $self = shift;
    if (not defined $self->{-xml_svg}) {
	$self->{-xml_svg} =
	  HSDB45::StyleSheet::apply_global_stylesheet_dom($self->get_xslt_path(),
							  $self->get_results_xml());
    }
    return $self->{-xml_svg};
}

# Description: Goes through the pieces, and writes them to the database
# Input:
# Output:
sub save_svg_graphs {
	my $self = shift;
	my $dbh = HSDB4::Constants::def_db_handle();
	my $school_db = get_school_db($self->get_school());
	my $blank_bar = HSDB45::Eval::Results::BarGraph->new(_school => $self->get_school());
	my $blank_histo = HSDB45::Eval::Results::SupportingGraphs->new(_school => $self->get_school());
	my $blank_median = HSDB45::Eval::Results::SupportingGraphs->new(_school => $self->get_school());
	my $blank_mode = HSDB45::Eval::Results::SupportingGraphs->new(_school => $self->get_school());
	my $parser = XML::LibXML->new();
	my $source = $parser->parse_string($self->get_results_xml());
	my $root = $source->getDocumentElement;
	my @results = $root->getElementsByTagName('Question_Results');
	my @emptyBarTopCategories;;

	######
	###### Die with a stack trace
	######
	###### This is here to see if web requests are re-generating the graphs at run time. (They do)
	######
	#print Devel::StackTrace->new()->as_string();
	#die();

	# Foreach of the results in the passed XML
	my %histograms;
	my $maxHistogramValue = 0;
	my $maxCategoryHistogramValue = 0;
	foreach my $questionResult (@results) {
		my $questionID = $questionResult->getAttribute('eval_question_id');

		#
		# Get the low/mid/high categories for the question
		#

		# Try to get the question element from the xml document
		my @questionTopCategories;
		my $questionNodeList = $root->getElementsByTagName("EvalQuestion[\@eval_question_id=\"$questionID\"]");
		unless($questionNodeList) {
			warn("Unable to get the node list for the question (EvalQuestion[\eval_question_id='$questionID'])... unable to process question.\n");
			next;
		}

		my $thisQuestionElement = $questionNodeList->get_node(1);
		unless($thisQuestionElement) {
			warn("Unable to get question node for EvalQuestion[\eval_question_id='$questionID']... unable to process question.\n");
			next;
		}

		# try to get the question type (PlusMinusRating or NumbericRating) this will determine the graph type.
		my $tempNodeList = $thisQuestionElement->getElementsByTagName("PlusMinusRating | NumericRating");
		unless($tempNodeList) {
			# I don't want to be notified if this is a YesNo, MultipleChoice, etc question
			#warn("Unable to get either the PlusMinusRating or NumericRating node for $questionID... unknown question type.\n");
			next;
		}
		my $typeNodeElement = $tempNodeList->get_node(1);
		unless($typeNodeElement) {
			warn("Unable get the type node for $questionID... unable to process question.\n");
			next;
		}

		#
		# Extract Graph Data
		#

		# Get the category labels
		my $lowVal = $typeNodeElement->findvalue("low_text");
		my $midVal = $typeNodeElement->findvalue("mid_text");
		my $highVal = $typeNodeElement->findvalue("high_text");
		if($lowVal) {push @questionTopCategories, $lowVal;}
		if($midVal) {push @questionTopCategories, $midVal;}
		if($highVal) {push @questionTopCategories, $highVal;}
		my $categories = $questionResult->findvalue("Categorization");
		my $mean = $questionResult->findvalue('ResponseGroup/ResponseStatistics/mean');
		# Set the default graph sizes (for mean, mode, etc)
		my $maxXValue = 0;
		my $minXValue = 999999;

		# Did we get categories for the question? If so get all of the data
		my @graphBars;
		if($categories) {
			my @responseGroups = $questionResult->findnodes('Categorization/ResponseGroup');

			# Grab the all data
			my $tempHash = {
				'name'	=> 'All',
				'value'	=> $mean,
				'mean'	=> $mean,
				'SD'	=> $questionResult->findvalue('ResponseGroup/ResponseStatistics/standard_deviation'),
				'N'	=> $questionResult->findvalue('ResponseGroup/ResponseStatistics/response_count'),
				'NA'	=> $questionResult->findvalue('ResponseGroup/ResponseStatistics/na_response_count'),
			};
			if(${$tempHash}{'SD'} < .009) {${$tempHash}{'SD'} ="--";}
			push @graphBars, $tempHash;

			foreach my $responseGroup (@responseGroups) {
				my $tempName = $responseGroup->findvalue('grouping_value');
				$tempName =~ s/ /&nbsp;/g;
				my $tempSD = $responseGroup->findvalue('ResponseStatistics/standard_deviation');
				if(!$tempSD || $tempSD < .009) {$tempSD ="--";}

				my $tempHash = {
					'name'	=> abbreviate($tempName, \%abbreviationHash),
					'value'	=> $responseGroup->findvalue('ResponseStatistics/mean'),
					'mean'	=> $responseGroup->findvalue('ResponseStatistics/mean'),
					'SD'	=> $tempSD,
					'N'	=> $responseGroup->findvalue('ResponseStatistics/response_count'),
					'NA'	=> $responseGroup->findvalue('ResponseStatistics/na_response_count'),
				};
				push @graphBars, $tempHash;
			}
		}

		#
		# Extract the histogram data and the min/max x values
		#
		my $histogramNode = $questionResult->find('ResponseGroup/ResponseStatistics/Histogram');
		# Check to see if there is a category group

		if($histogramNode->size() > 0) {
			my $categorizationResponses = $questionResult->findnodes("Categorization/ResponseGroup");

			if($categorizationResponses->size() == 0) {
				@{$histograms{$questionID}{afterValues}} = qw/Total/;
				my @histogramValuesList = $histogramNode->get_node(0)->findnodes('HistogramBin');
				unless(@histogramValuesList) {
					warn("Unable to generate histogram for $questionID... no ResponseGroup/ResponseStatistics/Histogram/HistogramBin present\n");
				} else {
					foreach my $histogramElement (@histogramValuesList) {
						my $count = $histogramElement->getAttribute('count');
						my $label = abbreviate($histogramElement->textContent(), \%abbreviationHash);
						my $tempHash = {
							'name'	=> abbreviate($label, \%abbreviationHash),
							'value'	=> $count,
							'Total' => $count,
						};
						if($label > $maxXValue) {$maxXValue = $label;}
						if($label < $minXValue) {$minXValue = $label;}
						if($count > $maxHistogramValue) {$maxHistogramValue = $count;}
						push @{$histograms{$questionID}{graphData}}, $tempHash;
					}
				}
				$histograms{$questionID}{graphType} = 'Bar';
			} else {
				#
				# This is the histogram (frequency) for a question with categories.
				# For this we are going to make a different kind of graph (stacked bar graph) with values for 1..5
				#
				foreach my $response ($categorizationResponses->get_nodelist()) {
					my $group = $response->findvalue('grouping_value');
					if($group) {
						my $tempHash = { 'name' => $group, };

						my $histogamElements = $response->findnodes('ResponseStatistics/Histogram/HistogramBin');
						my $localMax = 0;
						foreach my $histogramElement ($histogamElements->get_nodelist()) {
							my $count = $histogramElement->getAttribute('count');
							my $label = $histogramElement->textContent();
							${$tempHash}{$label} = $count;
							$localMax += $count;
							if($label > $maxXValue) {$maxXValue = $label;}
							if($label < $minXValue) {$minXValue = $label;}
						}
						$histograms{$questionID}{minCategories} = $minXValue;
						$histograms{$questionID}{maxCategories} = $maxXValue;
						if($localMax > $maxCategoryHistogramValue) {$maxCategoryHistogramValue = $localMax;}
						push @{$histograms{$questionID}{graphData}}, $tempHash;
					}
				}
				$histograms{$questionID}{graphType} = 'StackedBar';
			}
		} else {
			$histograms{$questionID}{error} = "<font color=\"red\">Could not find histogram information in eval xml.</font>\n";
		}

		#
		# Build the graph
		#

		my $mimeType;
		my $output = '';
		my $textOutput = '';
		my $nodeType = $typeNodeElement->nodeName;

		# What type of graph should we generate?
		if($nodeType eq 'PlusMinusRating') {
			if($categories) {
				($mimeType, $output, $textOutput) = TUSK::Graphs::YesNo::generate_graph({
					'topCategories' => \@questionTopCategories,
					'maxXValue' => $maxXValue,
					'minXValue' => $minXValue,
					'graphData' => \@graphBars,
				});
			} elsif($mean) {
				# Were we a simple graph?
				($mimeType, $output, $textOutput) = TUSK::Graphs::YesNoSimple::generate_graph(
					$mean, {
						'topCategories' => \@questionTopCategories,
						'showValue' => 1,
						'maxXValue' => $maxXValue,
						'minXValue' => $minXValue
					}
				);
			} else {
				warn("Got a PlusMinus question but had neither categories or a mean... unable to getenerate graph\n");
				$output = "<font color=\"red\">Unable to generate graph for PlusMinus question.</font>\n";
				$textOutput = "<font color=\"red\">Unable to generate graph for PlusMinus question.</font>\n";
				$mimeType = 'text/html';
			}
		} elsif($nodeType eq 'NumericRating') {
			if($categories) {
				my @afterValues = ('mean', 'SD', 'N', 'NA');
				($mimeType, $output, $textOutput) = TUSK::Graphs::Bar::generate_graph({
					'topCategories' => \@questionTopCategories,
					'minXValue' => $minXValue,
					'maxXValue' => $maxXValue,
					'graphData' => \@graphBars,
					'afterValues' => \@afterValues
				});
			} elsif($mean) {
				$mean = $questionResult->findvalue('ResponseGroup/ResponseStatistics/mean');
				# Were we a simple graph?
				($mimeType, $output, $textOutput) = TUSK::Graphs::BarSimple::generate_graph(
					$mean, {
						'topCategories' => \@questionTopCategories,
						'showValue' => 1,
						'maxXValue' => $maxXValue,
						'minXValue' => $minXValue,
					}
				);
			} else {
				warn("Got a NumericRating question but had no categories... unable to getenerate graph\n");
				$output = "<font color=\"red\">Unable to generate graph for NumericRating question.</font>\n";
				$textOutput = "<font color=\"red\">Unable to generate graph for NumericRating question.</font>\n";
				$mimeType = 'text/html';
			}
		} else {
			warn("Unknown question type for $questionID\n");
			$output = "<font color=\"red\">Unknown Graph Type Requested</font>\n";
			$textOutput = "<font color=\"red\">Unknown Graph Type Requested</font>\n";
			$mimeType = 'text/html';
		}


		# Shove the graph into the DB
		my $id = $blank_bar->get_id($self->get_eval_id(), $questionID);
		if($id)	{
			my $sthu;
			if($mimeType) {
				$sthu = $dbh->prepare(qq[UPDATE $school_db\.eval_results_graphics SET graphic=?, mime_type='$mimeType', graphic_text=?  WHERE eval_results_graphics_id=?]);
			} else {
				$sthu = $dbh->prepare(qq[UPDATE $school_db\.eval_results_graphics SET graphic=?, graphic_text=? WHERE eval_results_graphics_id=?]);
			}
			my $r = $sthu->execute($output, $textOutput,$id);
		} else {
			my $sthi = $dbh->prepare(qq[INSERT INTO $school_db\.eval_results_graphics (eval_id, eval_question_id, graphic, mime_type, graphic_text) VALUES (?, ?, ?, ?, ?)]);
			$sthi->execute($self->get_eval_id(), $questionID, $output, $mimeType, $textOutput);
		}


		#
		# This is Median and Mode
		#
		my @afterValues = ('Value');

		#
		# Build Median Graph
		#
		my @medianBars;
		my $median = $questionResult->findvalue("ResponseGroup/ResponseStatistics/median");
		my $tempHash =	{
			'name'  => "Median",
			'value' => $median,
			'Value' => $median,
		};
		push @medianBars, $tempHash;
		my ($medianGraphOutput, $textMedianGraphOutput);
		($mimeType, $medianGraphOutput, $textMedianGraphOutput) = TUSK::Graphs::BarSimple::generate_graph(
			$median, {
				'topCategories' => \@emptyBarTopCategories,
				'showValue' => 1,
				'maxXValue' => $maxXValue,
				'minXValue' => $minXValue,
			}
		);

		# Sove the median into the DB
		my $medianId = $blank_histo->get_id($self->get_eval_id(), "$questionID", "median");
		if($medianId)    {
			my $sthu;
			# Medians are new, so we can just always set the new mime type
			$sthu = $dbh->prepare(qq[UPDATE $school_db\.eval_results_supporting_graphs SET graphic=?, mime_type=?, graphic_text=?  WHERE eval_results_support_graph_id=?]);
			my $r = $sthu->execute($medianGraphOutput, $mimeType, $textMedianGraphOutput, $medianId);
		} else {
			my $sthi = $dbh->prepare(qq[INSERT INTO $school_db\.eval_results_supporting_graphs (eval_id, eval_question_id, graph_type, graphic, mime_type, graphic_text) VALUES (?, ?, "median", ?, ?, ?)]);
			$sthi->execute($self->get_eval_id(), "$questionID", $medianGraphOutput, $mimeType, $textMedianGraphOutput);
		}


		#
		# Build Mode Graph
		#

		#	my @modeBars;
		#	my $mode = $questionResult->findvalue("ResponseGroup/ResponseStatistics/mode");
		#	my $modeTempHash =	{
		#		'name'  => "Mode",
		#		'value' => $mode,
		#		'Value' => $mode,
		#	};
		#	push @modeBars, $modeTempHash;
		#	my ($mimeType, $modeGraphOutput) = TUSK::Graphs::BarSimple::generate_graph($mode, {  'topCategories' => \@emptyBarTopCategories, 'showValue' => 1  });
		#
		#	# Sove the mode into the DB
		#	my $modeId = $blank_histo->get_id($self->get_eval_id(), "$questionID", "mode");
		#	if($modeId)    {
		#		my $sthu;
		#		# Medians are new, so we can just always set the new mime type
		#		$sthu = $dbh->prepare(qq[UPDATE $school_db\.eval_results_supporting_graphs SET graphic=?, mime_type=?  WHERE eval_results_support_graph_id=?]);
		#		my $r = $sthu->execute($modeGraphOutput, $mimeType, "$modeId");
		#	} else {
		#		my $sthi = $dbh->prepare(qq[INSERT INTO $school_db\.eval_results_supporting_graphs (eval_id, eval_question_id, graph_type, graphic, mime_type) VALUES (?, ?, "mode", ?, ?)]);
		#		$sthi->execute($self->get_eval_id(), $questionID, $modeGraphOutput, $mimeType);
		#	}
	}


	# Now actaully generate the historgrams

	foreach my $questionID (keys %histograms) {
		my $histoOutput;
		my $histoOutputText;
		my $mimeType = "text/html";

		if(exists($histograms{$questionID}{error})) {$histoOutput = $histograms{$questionID}{error};}
		else {
			# Generate the histogram
			eval {
				my $graphData = \@{$histograms{$questionID}{graphData}};
				my $afterValues = \@{$histograms{$questionID}{afterValues}};


				if(scalar(@{$graphData}) > 0) {
					if($histograms{$questionID}{graphType} eq 'Bar') {
						($mimeType, $histoOutput, $histoOutputText) = TUSK::Graphs::Bar::generate_graph({maxXValue => $maxHistogramValue, minXValue => 0, precision => 0, graphData => $graphData, afterValues => $afterValues});
					} elsif($histograms{$questionID}{graphType} eq 'StackedBar') {
						($mimeType, $histoOutput, $histoOutputText) = TUSK::Graphs::EvalStackedBar::generate_graph({maxXValue => $maxCategoryHistogramValue, precision => 0,  minXValue => 0, graphData => $graphData, minCategories => $histograms{$questionID}{minCategories}, maxCategories => $histograms{$questionID}{maxCategories}});
					}
				} else {
					$histoOutput = "<font color=\"red\">Unable to generate histogram.</font>\n";
					$histoOutputText = "<font color=\"red\">Unable to generate histogram.</font>\n";
				}
			};
			if($@) {
				$histoOutput = "<font color=\"red\">Failure to generate histogram.</font><!-- $@ !-->\n";
				$histoOutputText = "<font color=\"red\">Failure to generate histogram.</font><!-- $@ !-->\n";
			}
		}

		# Dealocate the histogram to free up some memory
		$histograms{$questionID} = undef;

		# Shove the histogram into the DB
		my $histoID = $blank_histo->get_id($self->get_eval_id(), "$questionID", "histogram");
		if($histoID)	{
			my $sthu;
			# Histograms are new, so we can just always set the new mime type
			$sthu = $dbh->prepare(qq[UPDATE $school_db\.eval_results_supporting_graphs SET graphic=?, graphic_text=?, mime_type=?  WHERE eval_results_support_graph_id=?]);
			my $r = $sthu->execute($histoOutput, $histoOutputText, $mimeType, $histoID);
		} else {
			my $sthi = $dbh->prepare(qq[INSERT INTO $school_db\.eval_results_supporting_graphs (eval_id, eval_question_id, graph_type, graphic, mime_type, graphic_text) VALUES (?, ?, "histogram", ?, ?, ?)]);
			$sthi->execute($self->get_eval_id(), "$questionID", $histoOutput, $mimeType, $histoOutputText);
		}

	}
}

sub abbreviate {
	 my $term = shift;
	 my $usedHash = shift;

	 my $infiniteLoopCounter = 0;
	 my $tempTerm;
	 my $substrLen = 3;

	return $term;
#warn("Abbreviating $term\n");
	 # if we have already abbreviated this term return it.
	 if(exists(${$usedHash}{fillToAbbrev}{$term})) {
#warn("Already abbreviated as: ${$usedHash}{fillToAbbrev}{$term}\n");
		return ${$usedHash}{fillToAbbrev}{$term};
	 }

	 while($infiniteLoopCounter < 100) {
		if($term !~ /\s/) {
#warn("No white space, attempting abbreviation at substring\n");
			# If there is no white space truncate it to the first three letters.
			if(length($term) > 5)	{$tempTerm = substr($term, 0,$substrLen) .".";}
			else			{$tempTerm = $term;}
		} else {
#warn("Attempting Split");
			$tempTerm = '';
			my @terms = split /\s/, $term;
			foreach my $term (@terms) {
				if((length($term) < 4) || ($term =~ /[\.\,]/)) {
					$tempTerm.= "$term ";
				} else {
					$tempTerm.= substr($term, 0, ($substrLen-2)).". ";
				}
			}
			$tempTerm =~ s/ $//;
		}
#warn("Derived $tempTerm\n");

		# now check to see if the temp term has been used.
		if(!exists(${$usedHash}{abbrevToFull}{$tempTerm})) {
#warn("Derived did not exist and was accepted\n");
			${$usedHash}{abbrevToFull}{$tempTerm} = $term;
			${$usedHash}{fillToAbbrev}{$term} = $tempTerm;
			return $tempTerm;
		} elsif($term eq $tempTerm) {
#warn("Term matched origional so its being used as was\n");
			${$usedHash}{abbrevToFull}{$tempTerm} = $term;
			${$usedHash}{fullToAbbrev}{$term} = $tempTerm;
			return $term;
		} else {
#warn("Restarting check\n");
			$substrLen++;
		}
		$infiniteLoopCounter++;
	}
	${$usedHash}{abbrevToFull}{$term} = $term;
	${$usedHash}{fullToAbbrev}{$term} = $term;
	return $term;
}


1;
