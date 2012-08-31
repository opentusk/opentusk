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


package TUSK::FlashCard;

=head1 NAME

B<TUSK::FlashCard::FlashCard> - Class for manipulating entries in table flash_card in hsdb4 database

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

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'flash_card',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'flash_card_id' => 'pk',
					'question' => '',
					'answer' => '',
					'content_id' => '',
					'parent_personal_content_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getFlashCardID>

my $string = $obj->getFlashCardID();

Get the value of the flash_card_id field

=cut

sub getFlashCardID{
    my ($self) = @_;
    return $self->getFieldValue('flash_card_id');
}


#######################################################

=item B<getParentPersonalContentID>

my $string = $obj->getParentPersonalContentID();

Get the value of the parent_personal_content_id field

=cut

sub getParentPersonalContentID{
    my ($self) = @_;
    return $self->getFieldValue('parent_personal_content_id');
}

#######################################################

=item B<setParentPersonalContentID>

$obj->setParentPersonalContentID($value);

Set the value of the parent_personal_content_id field

=cut

sub setParentPersonalContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_personal_content_id', $value);
}


#######################################################

=item B<getQuestion>

my $string = $obj->getQuestion();

Get the value of the question field

=cut

sub getQuestion{
    my ($self) = @_;
    return $self->getFieldValue('question');
}

#######################################################

=item B<setQuestion>

$obj->setQuestion($value);

Set the value of the question field

=cut

sub setQuestion{
    my ($self, $value) = @_;
    $self->setFieldValue('question', $value);
}


#######################################################

=item B<getAnswer>

my $string = $obj->getAnswer();

Get the value of the answer field

=cut

sub getAnswer{
    my ($self) = @_;
    return $self->getFieldValue('answer');
}

#######################################################

=item B<setAnswer>

$obj->setAnswer($value);

Set the value of the answer field

=cut

sub setAnswer{
    my ($self, $value) = @_;
    $self->setFieldValue('answer', $value);
}


#######################################################

=item B<getContentID>

my $string = $obj->getContentID();

Get the value of the content_id field

=cut

sub getContentID{
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}

#######################################################

=item B<setContentID>

$obj->setContentID($value);

Set the value of the content_id field

=cut

sub setContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_id', $value);
}

#######################################################



sub setPersonalContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('personal_content_id', $value);
}


#######################################################

sub outCardTitle{
	my ($self) = @_;
	if( $self->getContentID  )
	{
		my $cntnt = HSDB4::SQLRow::Content->new()->lookup_key($self->getContentID());
		return $cntnt->out_html_label;
	}
	else
	{
		# the card is blank, return the Question
		return $self->getQuestion;
	}

}


#######################################################

sub outCardTitleNoLink{

my ($self) = @_;
	if( $self->getContentID  )
	{
		my $cntnt = HSDB4::SQLRow::Content->new()->lookup_key($self->getContentID());
		return $cntnt->out_label;
	}
	else
	{
		# the card is blank, return the Question
		return $self->getQuestion;
	}
}


#######################################################

sub outCardOwner {

	my ($self) = @_;
	if( $self->getContentID  )
	{
		my $cntnt = HSDB4::SQLRow::Content->new()->lookup_key($self->getContentID());
		return $cntnt->out_authors;
	}
	else
	{
		# the card is blank, return the Question
		return $self->getCreatedBy;
	}

}


#######################################################



sub outCardThumbnail {

	my ($self) = @_;
	if( $self->getContentID  )
	{
		my $cntnt = HSDB4::SQLRow::Content->new()->lookup_key($self->getContentID());
		return $cntnt->out_html_thumbnail;
	}
	else
	{
		# the card is blank, return the blank icon
		return "<img src='/graphics/blank_thinborder.jpg' height='36' width='48' alt='blank'>";
	}

}

#######################################################

sub saveCard {

	my ($self,$content,$folder,$user) = @_;
	my $card = TUSK::FlashCard->new();
	
	$card->setContentID($content->content_id);
	$card->setParentPersonalContentID($folder->primary_key);
    $card->save({'user' => $user->user_id()});

}

#######################################################


sub spliceDeck {

	my ($self,$user,$rmvDecks) = @_;
	my @personalContent = $user->child_personal_content;
	my $length = scalar(@personalContent); 
	my $j=0;
	while( $j < $length) {
		if ($personalContent[$j]){

			if ($rmvDecks == 0) {
				### we're removing non deck elements
				if (  $personalContent[$j]->field_value('type') ne 'Flash Card Deck'){
					splice(@personalContent, $j, 1);
					$length= scalar(@personalContent); 
					$j=0;
				}
				else { $j++; }
			}
			else {

				### we're removing deck elements
				if (  $personalContent[$j]->field_value('type') eq 'Flash Card Deck'){
					splice(@personalContent, $j, 1);
					$length= scalar(@personalContent); 
					$j=0;
				}
				else { $j++; }

			}# end else
		}
	
	}# end while

    return @personalContent;
}


#######################################################

=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

