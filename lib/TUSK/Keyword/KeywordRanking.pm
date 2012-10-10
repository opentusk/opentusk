package TUSK::Keyword::KeywordRanking;

#use Carp;
use strict;

use TUSK::Keyword::UMLS;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION =  sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

@EXPORT    = qw();  # leave this blank unless you have a very good reason
@EXPORT_OK = qw(
);

##
## importing ':all' will get everything that is "OK" to export
##
%EXPORT_TAGS = (
    'all' => [ @EXPORT_OK ],
);

our $AUTOLOAD;

# Dynamically handle get/set methods
sub AUTOLOAD {
    return if $AUTOLOAD =~ /::DESTROY$/;
    my $self = shift;

    my $name = $AUTOLOAD;

    # trim out the package info and leave on the last word for the name
    ($name ) = $name =~ /(\w+)$/;

    # break-apart words if they are in StudlyCaps and reassemble with _
    # e.g setMappedText becomes set_mapped_text
    $name =~ s#(?<=[a-z])(?=[A-Z])#_#g;

    my $action = 'get';

    if ( $name =~ /^(get|set)_(.*)?/ ) {
        $action = $1;
        $name   = $2;
    } 

    if ( $action eq 'set' ||  @_ ) {
        return $self->set_field_value( $name, $_[0] );
    } else {
        return $self->get_field_value( $name );
    }
}

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = { '_field_values' => {} };

    bless $self, $class;
    return $self;
}

sub get_field_value {
    my $self = shift;

    my $field = shift;

    return $self->{'_field_values'}{$field};
}

sub set_field_value {
    my $self = shift;

    my $field = shift;
    my $value = shift;

    $self->{'_field_values'}{$field} = $value;
}

# need for this to return a list of objects that can be used by the TUSK
# HTML::Mason structure.  Basically have a bunch of get/set methods 
# available for it.
sub save_concept_rankings {
    my $self = shift;
    my %args = @_;

    my $content_id = $args{'content_id'};
    my @concept_data = @{$args{'concepts'}};
    my %selected_ranks = %{$args{'selected_ranks'}};

    my @concepts;

    # add the concept to the umls_concept table
    for my $concept ( @concept_data ) {

        my $return_concept = TUSK::Keyword::KeywordRanking->new();

        my $concept_obj = TUSK::Keyword::UMLS::umls_concept->new
                                ->lookupKey( $concept->{'concept'} );

        if ( ! defined $concept_obj ) {
                    $concept_obj = TUSK::Keyword::UMLS::umls_concept->new();
                    $concept_obj->set_umls_concept_id( $concept->{'concept'});
                    $concept_obj->set_preferred_form(
                                    $concept->{'concept_name'} );
                    $concept_obj->save();
        }

        $return_concept->set_concept_id( $concept_obj->get_umls_concept_id());
        $return_concept->set_preferred_form(
                            $concept_obj->get_preferred_form());

        my $concept_cond = "umls_concept_id = '".$concept->{'concept'}.
                                    "' AND content_id = '".$content_id . "'";
        my $concept_mention_objs = TUSK::Keyword::UMLS::umls_concept_mention
                                        ->new->lookup( $concept_cond);

        if ( ! @{$concept_mention_objs} ) {
            $concept_mention_objs = [
                TUSK::Keyword::UMLS::umls_concept_mention->new() ];

            $concept_mention_objs->[0]->set_umls_concept_id(
                                            $concept->{'concept'} );
            $concept_mention_objs->[0]->set_content_id( $content_id );
            $concept_mention_objs->[0]->set_mapped_weight( $concept->{'score'});

            $concept_mention_objs->[0]->save();
        }

        $return_concept->set_mapped_weight(
                            $concept_mention_objs->[0]->get_mapped_weight );
        $return_concept->set_content_id(
                            $concept_mention_objs->[0]->get_content_id );

        # now check the link_content_umls_concept
        my $link_content_concept_objs =
                TUSK::Keyword::UMLS::link_content_umls_concept->new
                    ->lookup( $concept_cond );

        if ( ! @{$link_content_concept_objs} ) {

            $link_content_concept_objs = [
                TUSK::Keyword::UMLS::link_content_umls_concept->new()];

            $link_content_concept_objs->[0]->set_umls_concept_id(
                                                $concept->{'concept'} );
            $link_content_concept_objs->[0]->set_content_id( $content_id );
            $link_content_concept_objs->[0]->set_author_weight(
                                                $selected_ranks{'rank_'.$concept->{'concept'}});

            $link_content_concept_objs->[0]->save();

            $return_concept->set_author_weight(
                        $link_content_concept_objs->[0]->get_author_weight() );
        } else {
            if ( $args{'update_rankings'} &&
                $selected_ranks{ 'rank_' . $concept->{'concept'} } !=
                 $link_content_concept_objs->[0]->get_author_weight() ) {
                $link_content_concept_objs->[0]->set_author_weight( $selected_ranks{ 'rank_' . $concept->{'concept'} } );
                $link_content_concept_objs->[0]->save();
            }

#            $selected_ranks{'rank_'. $concept->{'concept'}} =
#                    $link_content_concept_objs->[0]->get_author_weight;
        }

        $return_concept->set_author_weight(
                    $link_content_concept_objs->[0]->get_author_weight() );

        push @concepts, $return_concept;

    }

    return @concepts;

};

1;

