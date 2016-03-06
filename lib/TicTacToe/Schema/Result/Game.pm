use strict;
use warnings;

package TicTacToe::Schema::Result::Game;

use base 'TicTacToe::Schema::Result';
use TicTacToe::Schema::Result::Board;

__PACKAGE__->table('game');
__PACKAGE__->add_columns(
  game_id => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
);

__PACKAGE__->set_primary_key('game_id');
__PACKAGE__->has_many(
  board_rs => '::Board',
  { 'foreign.fk_game_id' => 'self.game_id' });

# Overrides

# A Game requires an initial board to be valid.
sub insert {
  my ( $self, @args ) = @_;
  $self->next::method(@args);
  $self->create_related('board_rs', +{});
  return $self;
}

# Private methods

sub _dump_info {
  return shift->self_rs
    ->prefetch(['board_rs'])
      ->hri->first;
}

sub _current_board {
  my $self = shift;
  return $self->board_rs->last_in_game;
}

sub _is_valid_next_move {
  my ($self, $location) = @_;
  return grep { $location eq $_ }
    ($self->_current_board->available_moves);
}

# Begin the public API for Game

sub status { shift->_current_board->status }

sub current_layout {
  return shift->_current_board->board_layout;
}

sub whos_turn {
  my $self = shift;
  $self->current_move ? $self->_current_board->whos_turn : undef;
}

sub select_move {
  my ($self, $location) = @_;
 
  $self->status eq 'in_play' ||
    die "This game has reached an end state and can no longer be played.  Its outcome is '${\$self->status}'";

  $self->_is_valid_next_move($location) ||
    die "$location is not a valid next move";

  $self->_current_board->copy({ $location => $self->whos_turn });
}

sub current_move {
  my $current_move = (my $self=shift)->_current_board->move;
  
  return undef if $current_move > 9;
  return undef unless $self->status eq 'in_play';
  return $current_move;
}

sub available_moves {
  my $self = shift;
  if($self->in_storage) {
    return $self->current_move ?
      $self->_current_board->available_moves : ();
  } else {
    return @TicTacToe::Schema::Result::Board::locations;
  }
}

sub TO_JSON {
  my $self = shift;
  return +{
    whos_turn => $self->whos_turn,
    status => $self->status,
    available_next_moves => [$self->available_moves],
    current_layout => +{$self->current_layout},
  };
}

1;

=head1 TITLE

JJNAPIORK::TicTacToe::Schema::Result::Game - A game of TicTacToe

=head1 DESCRIPTION

A game of TicTacToe.  Each game is a set of Boards.

=head1 RELATIONSHIPS

This class defines the following relationships

=head1 METHODS

This class defines the following methods

=head1 AUTHORS & COPYRIGHT

See L<JJNAPIORK::TicTacToe>.

=head1 LICENSE

See L<JJNAPIORK::TicTacToe>.

=cut
