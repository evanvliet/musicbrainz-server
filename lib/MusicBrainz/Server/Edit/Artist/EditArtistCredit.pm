package MusicBrainz::Server::Edit::Artist::EditArtistCredit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

use aliased 'MusicBrainz::Server::Entity::Artist';
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDITCREDIT );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
);
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    clean_submitted_artist_credits
    load_artist_credit_definitions
    verify_artist_credits
);
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { l('Edit artist credit') }
sub edit_type { $EDIT_ARTIST_EDITCREDIT }


sub _build_related_entities {
    my ($self) = @_;
    my $related = { };

    my %new = load_artist_credit_definitions($self->data->{new}{artist_credit});
    my %old = load_artist_credit_definitions($self->data->{old}{artist_credit});
    push @{ $related->{artist} }, keys(%new), keys(%old);

    return $related;
};

has '+data' => (
    isa => Dict[
        old => Dict[
            artist_credit => ArtistCreditDefinition
        ],
        new => Dict[
            artist_credit => ArtistCreditDefinition
        ]
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};

    $relations->{Artist} = {
        map {
            load_artist_credit_definitions($self->data->{$_}{artist_credit})
        } qw( new old )
    };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = {};
    $data->{artist_credit} = {
        new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
        old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
    };

    return $data;
}

sub initialize {
    my ($self, %opts) = @_;
    my $old_ac = delete $opts{to_edit} or die 'Missing old artist credit object';

    $self->data({
        new => {
            artist_credit => clean_submitted_artist_credits($opts{artist_credit})
        },
        old => {
            artist_credit => clean_submitted_artist_credits(artist_credit_to_ref($old_ac))
        }
    });
}

sub accept {
    my $self = shift;

    verify_artist_credits($self->c, $self->data->{artist_credit});

    $self->c->model('ArtistCredit')->replace(
        $self->data->{old}{artist_credit},
        $self->data->{new}{artist_credit}
    );
}

1;
