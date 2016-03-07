? extends 'html'

<? block title => sub { ?>TicTacToe - Game Stats<? } ?>
<? block body => sub { ?>
  <h1>Links</h1>
  <p>See all <a href="<?= $index ?>">games</a></a>

  <h1>Game Details</h1>
  <? my $row = 0 ?>
  <table><tr>
    <? foreach my $move (@$moves) { ?>
        <td>
          <table border="1">
            <tr id="t">
              <td id="tl"><?= $move->{tl} || 'tl' ?></td>
              <td id="tc"><?= $move->{tc} || 'tc' ?></td>
              <td id="tr"><?= $move->{tr} || 'tr' ?></td>
            </tr>
            <tr id="m">
              <td id="bl"><?= $move->{ml} || 'ml' ?></td>
              <td id="bc"><?= $move->{mc} || 'mc' ?></td>
              <td id="br"><?= $move->{mr} || 'mr' ?></td>
            </tr>
            <tr id="b">
              <td id="bl"><?= $move->{bl} || 'bl' ?></td>
              <td id="bc"><?= $move->{bc} || 'bc' ?></td>
              <td id="br"><?= $move->{br} || 'br' ?></td>
            </tr>
          </table>
        </td>
        <? if(++$row % 3 == 0) { ?></tr><tr><? } ?>
    <? } ?>
  </tr></table>
<? } ?>
