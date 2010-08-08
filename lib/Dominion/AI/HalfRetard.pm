package Dominion::AI::HalfRetard;

use 5.010;
use Moose;
use List::Util qw(shuffle);
no warnings 'recursion';

extends 'Dominion::AI';

has 'buycount' => ( is => 'rw', isa => 'Int', default => 0 );

sub action {
    my ($self, $player, $state) = @_;

    my $card;

    $card //= ($player->hand->grep(sub { $_->name eq 'Market' }))[0];
    $card //= ($player->hand->grep(sub { $_->name eq 'Village' }))[0];
    $card //= ($player->hand->grep(sub { $_->name eq 'Festival' }))[0];

    # Fallback
    $card //= ($player->hand->cards_of_type('action'))[0];

    print "I have:\n";
    print join("\n", map { $_->name } ($player->hand->cards_of_type('action')));
    print "\n";
    print "Playing: ", $card->name, "\n";
    print "-------\n";
    $player->play($card->name);
}

sub buy {
    my ($self, $player, $state) = @_;

    $self->buycount($self->buycount+1);

    my $game = $player->game;

    my $coin = $state->{coin};
    my $card;

    my @list;
    given ( $coin ) {
        when ( 0 ) { return $player->cleanup_phase(); }
        when ( 1 ) { return $player->cleanup_phase(); }
        when ( 2 ) { return $player->cleanup_phase(); }
        when ( 3 ) {
            @list = qw(Village Silver);
        }
        when ( 4 ) {
            @list = qw(Smithy);
            push @list, 'Gardens' if $self->buycount > 10;
        }
        when ( 5 ) {
            @list = shuffle(qw(Laboratory Market Festival));
            push @list, 'Duchy' if $self->buycount > 10;
        }
        when ( 6 ) {
            @list = qw(Gold);
        }
    }
    if ( @list ) {
        foreach my $potential ( @list ) {
            ($card) //= $game->supply->card_by_name($potential);
        }
    }

    $card //= do {
        while ( $coin >= 0 ) {
            my @cards = grep { $_->cost_coin == $coin } $game->supply->cards;
            unless ( @cards ) {
                $coin--;
                next;
            }
            $card = @cards[int rand() * @cards];
            last;
        }
        $card;
    };

    $player->buy($card->name);
}

#__PACKAGE__->meta->make_immutable;
1;