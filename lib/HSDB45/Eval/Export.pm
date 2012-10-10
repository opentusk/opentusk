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


package HSDB45::Eval::Export;

use strict;

use HSDB45::Eval;
use HSDB45::Eval::Question;
use HSDB45::Eval::MergedResults;
use Spreadsheet::WriteExcel;
use Carp; 
my $question_row = 1;
my $response_row = 3;
my $defaultFillInLength = 50;


sub export_eval_to_excel {
	my $eval = shift;
	my $fh = shift;
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	if (!$workbook){
		confess "Can't open workbook :$! ";	
	}
	# Add a worksheet
	my $worksheet = $workbook->add_worksheet();
	add_eval_header($eval,$worksheet,$workbook);
	export_questions($eval,$worksheet,$workbook);
	export_responses($eval,$worksheet,$workbook);
}

sub export_merged_eval_to_excel {
	my $merged_eval = shift;
	my $fh = shift;
        my $workbook = Spreadsheet::WriteExcel->new($fh);
        if (!$workbook){
                confess "Can't open workbook :$! ";
        }
        # Add a worksheet
        my $worksheet = $workbook->add_worksheet();
	my $primary_eval = $merged_eval->parent_eval();
	warn "Second ".$merged_eval->secondary_eval_ids();
	add_merged_eval_header($merged_eval,$worksheet,$workbook);
	export_questions($primary_eval,$worksheet,$workbook);
	export_merged_responses($merged_eval,$worksheet,$workbook); 
}

sub add_merged_eval_header {
	my ($merged_eval,$worksheet,$workbook) = @_;
	add_header($merged_eval->title(),$worksheet,$workbook);
}

sub add_eval_header {
	my ($eval,$worksheet,$workbook) = @_;
	add_header($eval->out_label(),$worksheet,$workbook);
}

sub add_header {
	my ($text,$worksheet,$workbook) = @_;
	my $format = $workbook->add_format(bold=>1);
	$worksheet->write(0,0,$text,$format);
}

sub export_questions {
	my ($eval,$worksheet,$workbook) = @_;
	my ($qt,$col) = ('',1);
	my ($col_width,$question_type);
	my $format = $workbook->add_format(bold=>1);
	$worksheet->set_row(0,undef,$format);
	$worksheet->write($question_row+1,0,"Question Type");
	foreach my $q ($eval->questions){
		$qt = $q->body()->question_text();
		$question_type = $q->body()->question_type();
		next if ($question_type eq 'Title' || $question_type eq 'Instruction');
		$worksheet->write($question_row,$col,$qt);
		$worksheet->write($question_row+1,$col,$question_type);
		$col_width = ($question_type eq 'FillIn') ? $defaultFillInLength : length($qt);
		$worksheet->set_column($col,$col,$col_width);
		$col++;
	}
}

sub export_responses {
	my ($eval,$worksheet,$workbook) = @_;
	my $results = HSDB45::Eval::Results->new($eval);
	my @question_results = $results->question_results;
	generate_responses($worksheet,$workbook,\@question_results,$results);
}

sub export_merged_responses {
	my ($merged_eval,$worksheet,$workbook) = @_;
	my @question_results = $merged_eval->question_results;
	generate_responses($worksheet,$workbook,\@question_results,$merged_eval);
}

sub generate_responses {
        my ($worksheet,$workbook,$results,$eval_results) = @_;
        my %align_format = ( 'align' => 'top' );
        my $top_align_format = $workbook->add_format(%align_format);
        my $wrap_format = $workbook->add_format(text_wrap=>1, %align_format);
        my ($row,$col) = ($response_row,1);
        my ($text_wrap);
        my (%responses,$question_type);

	### write the first column for all rows, also store user codes so as to
	### check later as some users might not answer certain questions
	my @user_codes = $eval_results->user_codes();
	my $user_count = 1;
	foreach my $i ( $row .. scalar @user_codes + $row -1 ) {
	    $worksheet->write($i,0,"User " . $user_count,$top_align_format);
	    $user_count++;
	}
	
	### write out all the responses by each column
        foreach my $question_result (@{$results}) {
                $question_type = $question_result->question()->body()->question_type();
                next if ($question_type eq 'Title' || $question_type eq 'Instruction');

                $text_wrap = ($question_type eq 'FillIn') ? 1 : 0;
                $row = $response_row;
		%responses = map {$_->user_code() => $_} $question_result->responses();

                foreach my $user_code (@user_codes) {

		    if (exists $responses{$user_code}) {
                        if ($text_wrap){
                                $worksheet->write($row,$col,
                                        $responses{$user_code}->interpreted_response,$wrap_format);
                        } else {
                                $worksheet->write($row,$col,
                                        $responses{$user_code}->interpreted_response,$top_align_format);
                        }
		    } else {
			$worksheet->write($row,$col,'','');
		    }
		    $row++;
                }
                $col++;
        }
}

	close FH;

1;
