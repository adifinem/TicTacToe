? extends 'html'

<? block title => sub { ?>TicTacToe - Game Stats<? } ?>
<? block body => sub { ?>
  <h1>Links</h1>
  <p>See all <a href="<?= $index ?>">games</a></a>

  <h1>Game Stats</h1>
  <h3>Report Time:  <?= scalar(localtime) ?></h3>
  <p>Total Games: <?= $total ?></p>
  <p>Open Games: <?= $wins->{in_play} || 0 ?></p>
  <p>X Wins: <?= $wins->{X_wins} || 0 ?></p>
  <p>O Wins: <?= $wins->{O_wins} || 0 ?></p>
  <p>Draw: <?= $wins->{draw} || 0 ?></p>
  <p>Total Moves for All Games: <?= $moves->{total} ?></p>
  <p>Average Moves per Game: <?= $moves->{avg} ?></p>

<? } ?>
