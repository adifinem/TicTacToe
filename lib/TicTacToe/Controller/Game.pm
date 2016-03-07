package TicTacToe::Controller::Game;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

has 'games_index' => (is=>'ro', required=>1);

sub root :Chained(../root) PathPart('') CaptureArgs(1) {
  my ($self, $c, $id) = @_;
  return $c->model("Schema::Game::Result") ||
    $c->go('/not_found');
}

  sub game :Chained('root') PathPart('') FormModelTarget('Form::Game') Args(0) {
    my ($self, $c) = @_;
    my $form = $c->model('Form::Game',
      my $game = $c->model);

    $c->view->data->set(
      game => $game,
      form => $form,
      index => $c->uri($self->games_index));

    if($form->posted && !$form->is_valid) {
      ## TODO, needs a template for HTML view
      ## -- does it? it shows a nice error on bad input as-is...
      $c->view->detach_unprocessable_entity();
    }

    $c->view->ok;
  }

  sub detail :GET Chained('root') PathPart('detail') Args(0) {
    my ($self, $c) = @_;
    my @moves;

    $c->model("Schema::Game")->map(
      sub {
        my ($self, $result) = @_;
        @moves = $result->board_rs->all_moves();
        $c->log->info(@moves);
      }
    );
    $c->view->ok({
      moves => \@moves,
      index => $c->uri($self->games_index),
    });
  }

__PACKAGE__->meta->make_immutable;
