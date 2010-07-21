#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
use_ok 'MusicBrainz::Server::Entity::Release';
use_ok 'MusicBrainz::Server::Entity::ReleasePackaging';
use_ok 'MusicBrainz::Server::Entity::ReleaseStatus';
use_ok 'MusicBrainz::Server::Entity::Medium';
use_ok 'MusicBrainz::Server::Entity::MediumFormat';
use_ok 'MusicBrainz::Server::Entity::Tracklist';
use_ok 'MusicBrainz::Server::Entity::Track';

my $release = MusicBrainz::Server::Entity::Release->new();
ok( defined $release->date );
ok( $release->date->is_empty );

does_ok( $release, 'MusicBrainz::Server::Entity::Role::Quality' );

$release->edits_pending(2);
is( $release->edits_pending, 2 );

is( $release->status_name, undef );
$release->status(MusicBrainz::Server::Entity::ReleaseStatus->new(id => 1, name => 'Official'));
is( $release->status_name, 'Official', 'Release status is Official' );
is( $release->status->id, 1 );
is( $release->status->name, 'Official', 'Release status is Official' );

is( $release->packaging_name, undef );
$release->packaging(MusicBrainz::Server::Entity::ReleasePackaging->new(id => 1, name => 'Jewel Case'));
is( $release->packaging_name, 'Jewel Case', 'Release packaging is Jewel Case' );
is( $release->packaging->id, 1 );
is( $release->packaging->name, 'Jewel Case', 'Release packaging is Jewel Case' );

ok( @{$release->labels} == 0 );
ok( @{$release->mediums} == 0 );

is( $release->combined_format_name, '' );
is( $release->combined_track_count, '' );

my $medium1 = MusicBrainz::Server::Entity::Medium->new();
$medium1->format(MusicBrainz::Server::Entity::MediumFormat->new(id => 1, name => 'CD'));
$medium1->tracklist(MusicBrainz::Server::Entity::Tracklist->new(track_count => 10));
$release->add_medium($medium1);
is( $release->combined_format_name, 'CD', 'Release format is CD' );
is( $release->combined_track_count, '10' );

my $medium2 = MusicBrainz::Server::Entity::Medium->new();
$medium2->format(MusicBrainz::Server::Entity::MediumFormat->new(id => 2, name => 'DVD'));
$medium2->tracklist(MusicBrainz::Server::Entity::Tracklist->new(track_count => 22));
$release->add_medium($medium2);
is( $release->combined_format_name, 'CD + DVD', 'Release format is CD + DVD' );
is( $release->combined_track_count, '10 + 22' );

$release->add_medium($medium1);
is( $release->combined_format_name, '2xCD + DVD', 'Release format is 2xCD + DVD' );
is( $release->combined_track_count, '10 + 22 + 10' );

$release = MusicBrainz::Server::Entity::Release->new(artist_credit_id => 1);
my $medium = MusicBrainz::Server::Entity::Medium->new();
$release->add_medium($medium);
my $tracklist = MusicBrainz::Server::Entity::Tracklist->new();
$medium->tracklist($tracklist);
my $track = MusicBrainz::Server::Entity::Track->new(artist_credit_id => 1);
$tracklist->add_track($track);
is( $release->has_multiple_artists, 0, 'Release does not have multiple artists' );
$track = MusicBrainz::Server::Entity::Track->new(artist_credit_id => 2);
$tracklist->add_track($track);
is( $release->has_multiple_artists, 1, 'Release has multiple artists' );

done_testing;
