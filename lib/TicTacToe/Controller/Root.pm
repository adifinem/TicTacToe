package TicTacToe::Controller::Root;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

has 'show_board'  => (is=>'ro', required=>1);
has 'games_index' => (is=>'ro', required=>1);
has 'stats_index' => (is=>'ro', required=>1);

sub root :Chained('/') PathPart('') CaptureArgs(0) {
  my ($self, $c) = @_;
  my $view = $c->req->on_best_media_type(
    'text/html' => sub { 'HTML' },
    'application/json' => sub { 'JSON' },
    'no_match' => sub {
      my ($req, %callbacks) = @_;
      $c->view('HTML')->template('406');
      $c->view('HTML')->detach_not_acceptable({allowed=>[keys %callbacks]});
    },
  );
  $c->current_view($view);
}

  sub new_game :POST Chained(root) PathPart('') FormModelTarget('Form::Game') Args(0) {
    my ($self, $c) = @_;
    my $form = $c->model('Form::Game',
      my $game = $c->model('Schema::Game::Result'));

    if($form->is_valid) {
      my $game_url = $c->uri($self->show_board, [$game->id]);
      $c->view->created(
        location => $game_url, {
        game => $game,
        form => $form,
        new_game_url => $game_url,
      });
    } else {
      $c->stash->{form_errors} = $form->get_errors();
      $c->go('/view_games'); # if view is HTML?
      $c->view->unprocessable_entity($form);
    }
  }

  sub view_games :GET Chained(root) PathPart('') Args(0) {
    my ($self, $c) = @_;
    my $form = $c->model("Form::Game");
    my @links_to_games = map {
       $c->uri($self->show_board, [$_->id])
    } $c->model("Schema::Game")->all;

    $c->view->ok({
      errors => $c->stash->{form_errors},
      form => $form,
      stats => $c->uri($self->stats_index),
      games => \@links_to_games});
  }

  # game, play thyself!
  sub gen_random :GET Chained(root) PathPart('rand') Args(1) {
    my ($self, $c, $i) = @_;
    my @games = $c->model("Schema::Game")->all;

    for (1..$i) {
      my $game = $c->model("Schema::Game")->new_game();
      my ($who, @moves) = ();
      while($game->status eq "in_play") {
        @moves = $game->available_moves();
        $game->select_move($moves[int(rand(scalar @moves))]);
      }
      $c->log->info("Generated Game: " . $game->id . " - " . $game->status);
    }
    $c->go('/view_stats');
  }

  sub view_stats :GET Chained(root) PathPart('stats') Args(0) {
    my ($self, $c) = @_;
    my @games = $c->model("Schema::Game")->all;

    my @links_to_games = map {
       $c->uri($self->show_board, [$_->id])
    } @games;

    $c->view->ok({
      total => scalar @games,
      index => $c->uri($self->games_index),
      games => \@links_to_games});
  }

  sub not_found :Chained(root) PathPart('') Args {
    my ($self, $c) = @_;
    $c->view->not_found({error=>'Path Not Found'});
  }

__PACKAGE__->meta->make_immutable;
