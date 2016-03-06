? extends 'html'

<? block title => sub { ?>TicTacToe - Game Stats<? } ?>
<? block body => sub { ?>
  <h1>Links</h1>
  <p>See all <a href="<?= $index ?>">games</a></a>

  <h1>Game Stats</h1>
  <p>Statistics for played games</p>
  <? if(!@$games) { ?>
    No games yet!
  <? } else { ?>
    <ol><? foreach my $game(@$games) { ?>
      <li><a href='<?= $game ?>'><?= $game ?></a></li>
    <? } ?></ol>
  <? } ?>
<? } ?>
