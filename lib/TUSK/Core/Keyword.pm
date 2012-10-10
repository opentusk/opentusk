package TUSK::Core::Keyword;

=head1 NAME

B<TUSK::Core::Keyword> - Class for manipulating entries in table keyword in tusk database

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
use TUSK::UMLS::LinkKeywordUmlsString;
use TUSK::UMLS::LinkKeywordUmlsSemanticType;
use TUSK::UMLS::LinkKeywordKeyword;
use TUSK::UMLS::UmlsDefinition;

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
					'tablename' => 'keyword',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'keyword_id' => 'pk',
					'keyword' => '',
					'concept_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getKeyword>

    $string = $obj->getKeyword();

    Get the value of the keyword field

=cut

sub getKeyword{
    my ($self) = @_;
    return $self->getFieldValue('keyword');
}

#######################################################

=item B<setKeyword>

    $obj->setKeyword($value);

    Set the value of the keyword field

=cut

sub setKeyword{
    my ($self, $value) = @_;
    $self->setFieldValue('keyword', $value);
}


#######################################################

=item B<getConceptID>

    $string = $obj->getConceptID();

    Get the value of the concept_id field

=cut

sub getConceptID{
    my ($self) = @_;
    return $self->getFieldValue('concept_id');
}

#######################################################

=item B<setConceptID>

    $obj->setConceptID($value);

    Set the value of the concept_id field

=cut

sub setConceptID{
    my ($self, $value) = @_;
    $self->setFieldValue('concept_id', $value);
}


=back

=cut

### Other Methods

#######################################################

=item B<isUMLS>

    if ($keyword->isUMLS())

Function that returns a boolean indicating if this is a UMLS keyword

=cut

sub isUMLS {
	my $self = shift;
	if ($self->getConceptID()){
		return 1;
	}
	return 0;

}


#######################################################

=item B<getConceptStrings>

Returns an arrayref of concept types for this keyword.  If
it is not a UMLS keyword it returns undef;

=cut

sub getConceptStrings {
        my $self = shift;
        if ($self->isUMLS()){
		my $links = TUSK::UMLS::LinkKeywordUmlsString->lookup(" parent_keyword_id = ".$self->getPrimaryKeyID());
		my @strings = map { $_->getUmlsStringObject() } @{$links};
		return \@strings;
        }
        return undef;

}

#######################################################

=item B<makeKeyword>

$keyword = TUSK::Core::Keyword->makeKeyword($keywordText) 

Returns either a new keyword entry if the text is unique for non UMLS
concepts, or an existing keyword entry if the keyword text is already
in the keyword table.

=cut

sub makeKeyword {
	my $self = shift;
	my $text = shift;
	my $user_id = shift;
	$text =~  s/\\'/'/g;
	my $keywords = TUSK::Core::Keyword->lookup(" concept_id is null and keyword = '$text' ");
	if (scalar(@{$keywords})){
		return $keywords->[0];
	}
	my $keyword = TUSK::Core::Keyword->new();
	$keyword->setKeyword($text);
	$keyword->setUser($user_id);
	$keyword->save();
	return $keyword;
}


sub getRelatedKeywords {
	my $self = shift;
	my $relationTypes = shift || [];
	my $id = $self->getPrimaryKeyID();
	my $relationType = "concept_relationship IN (" .join (",", map {"'$_'"} @{$relationTypes}).") AND ";
	my @links = @{TUSK::UMLS::LinkKeywordKeyword->lookup("$relationType parent_keyword_id = $id")};
	@links = (@links, @{TUSK::UMLS::LinkKeywordKeyword->lookup("$relationType parent_keyword_id = $id")});
	my $keywords = [];
	foreach my $link (@links){
		if ($id != $link->getParentKeywordID()){
			push @{$keywords}, TUSK::Core::Keyword->lookupKey($link->getParentKeywordID());
		} else {
			push @{$keywords}, TUSK::Core::Keyword->lookupKey($link->getChildKeywordID());
		}
	}
	return $keywords;
}

sub getDefinitions {
	my $self = shift;
	my $id = $self->getPrimaryKeyID();
	my $definitions = TUSK::UMLS::UmlsDefinition->lookup(" keyword_id = $id ");
	return $definitions;

}

sub getSemanticTypes {
	my $self = shift;
	my $id = $self->getPrimaryKeyID();
	my $links = TUSK::UMLS::LinkKeywordUmlsSemanticType->lookup("parent_keyword_id = $id ");
	my @semanticTypes = map { $_->getUmlsSemanticTypeObject } @{$links};
	return \@semanticTypes;
}

sub getSemanticTypeString {
	my $self = shift;
	my $semanticTypes = $self->getSemanticTypes();
	return join(",",map {$_->getSemanticType} @{$semanticTypes});

}

sub getKeywordNormalized {
    my ($self) = @_;
    my $keyword = $self->getKeyword();
    $keyword =~ s/\b(.)/uc($1)/eg;
    return ($keyword);
}

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

