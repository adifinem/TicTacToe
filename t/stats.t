use Test::Most;
use TicTacToe;
use Catalyst::Test 'TicTacToe';
use HTTP::Request::Common;
use JSON::MaybeXS;

# since it's a dynamically generated view, we'll play with the model, then
# test the resulting json

my $location = '/';

sub move {
  my ($move, $new) = @_;
  $location = '/' if $new;
  my $res = request POST $location,
     Content_Type => 'application/json',
     Accept => 'application/json',
     Content => encode_json +{'move'=>$move};
     ok($location = $res->header('location'), "got location: $location") if $new;
}

sub x_wins {
  move('bl', 1);
  move('mr');
  move('tl');
  move('tr');
  move('ml');
  return 1;
}

sub o_wins {
   move('mr', 1);
   move('tl');
   move('ml');
   move('mc');
   move('tc');
   move('bc');
   move('bl');
   move('br');
   return 1;
}

sub draw {
   move('bc', 1);
   move('mc');
   move('bl');
   move('tc');
   move('tl');
   move('br');
   move('mr');
   move('ml');
   move('tr');
   return 1;
}

sub start_game {
   move('mc', 1);
   return 1;
}

sub json_stats {
  my $location = '/stats';
  my $res = request GET $location,
    Content_Type => 'application/json',
    Accept       => 'application/json';
  return decode_json($res->content);
}

{
  ok x_wins() for (1..5);
  my $stats = json_stats();

  ok exists $stats->{wins}, "wins exists";
  is $stats->{wins}{X_wins}, 5, "got 5 wins for X";
  ok !exists $stats->{wins}{O_wins}, "no wins for O";
  ok !exists $stats->{wins}{draw}, "no draws";
  ok !exists $stats->{wins}{in_play}, "no games in play";
}

{
  ok o_wins() for (1..5);
  my $stats = json_stats();

  ok exists $stats->{wins}, "wins exists";
  is $stats->{wins}{O_wins}, 5, "got 5 wins for O";
  is $stats->{wins}{X_wins}, 5, "got 5 wins for X";
  ok !exists $stats->{wins}{draw}, "no draws";
  ok !exists $stats->{wins}{in_play}, "no games in play";
}

{
  ok draw() for (1..5);
  my $stats = json_stats();

  ok exists $stats->{wins}, "wins exists";
  is $stats->{wins}{O_wins}, 5, "got 5 wins for O";
  is $stats->{wins}{X_wins}, 5, "got 5 wins for X";
  is $stats->{wins}{draw}, 5, "got 5 draws";
  ok !exists $stats->{wins}{in_play}, "no games in play";
}

{
  ok start_game() for (1..5);
  my $stats = json_stats();

  ok exists $stats->{wins}, "wins exists";
  is $stats->{wins}{O_wins}, 5, "got 5 wins for O";
  is $stats->{wins}{X_wins}, 5, "got 5 wins for X";
  is $stats->{wins}{draw}, 5, "got 5 draws";
  is $stats->{wins}{in_play}, 5, "got 5 games in play";
}

{
  my $stats = json_stats();

  ok exists $stats->{total}, "total exists";
  is $stats->{total}, 20, "found 20 games";
  ok exists $stats->{moves}, "moves exists";
  # moves always have one blank per game for new game move making it
  # 135 instead of the expected 115 if you counted the calls to move() -
  # i didn't write the game classes. :)
  is $stats->{moves}{total}, 135, "135 moves";
  is $stats->{moves}{avg}, 6, "135 / 20 = 6 moves average";
}

done_testing;
