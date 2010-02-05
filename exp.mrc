>start<|exp.mrc|exp still here...|3.0|rs
on $*:text:/^[!@.](le?ve?l|e?xp)\b/Si:*:{
  halt
  _CheckMain
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if (!$2) { %saystyle $formatwith(Syntax Error: \u!xp <level>\u OR \u!xp <xp>\u OR \u!xp <item>\u.) | halt }
  if ($regex(lvl,$2-,/^(\d{1,3})(?:\D(\d{1,3}))?/Si)) {
    if ($regml(lvl,2)) && ($regml(lvl,1) > 126 || $regml(lvl,1) < 1 || $regml(lvl,2) > 126 || $regml(lvl,2) < 1) { %saystyle Please only specify levels between 1 and 126 | halt }
    var %calc $floor($calculate($2-))
    if ($regml(lvl,2)) {
      if ($regml(lvl,1) > $regml(lvl,2)) {
        var %1 = $regml(lvl,2)
        var %2 = $regml(lvl,1)
      }
      else {
        var %1 = $regml(lvl,1)
        var %2 = $regml(lvl,2)
      }
      %saystyle $formatwith(Experience needed level \c07{0}\o to \c07{1}\o: \c07{2}\o, %1, %2, $bytes($calc($l(%2) - $l(%1)),db))
    }
    elseif (%calc <= 126 && %calc >= 1) {
      %saystyle $formatwith(Level \c07{0}\o: \c07{1}\o,%calc,$bytes($l(%calc),db))
    }
    elseif (%calc <= 200000000 && %calc >= 127) {
      %saystyle Exp $+(07,$bytes(%calc,bd),:07) $xptolvl(%calc)
    }
    else { %saystyle Please specify a level between 1 and 126, exp value below 200,000,000, or valid item. }
  }
  else {
    var %ticks = $ticks, %x = 1
    if ($lookups($2)) && ($3) {
      var %skill = $lookups($2)
      if (%skill == Attack || %skill == Strength || %skill == Defence || %skill == Ranged) { var %skill = Combat }
      var %item $3-
    }
    else { var %item $2- }
    .fopen xp $+ %ticks param.txt
    while (!$feof && %x <= 10) {
      var %xp = $fread(xp $+ %ticks)
      if (%skill && %skill != $gettok(%xp,1,124)) { goto skip }
      if (%item isin $gettok(%xp,2,124)) {
        var %xpout %xpout $iif(%xpout,$chr(124)) $+($gettok(%xp,1,124),$chr(40),07,$gettok(%xp,2,124),$chr(15),$chr(41),:) $+(07,$bytes($gettok(%xp,3,124),bd),$chr(15))
        inc %x
      }
      :skip
    }
    .fclose xp $+ %ticks
    if (%xpout) { %saystyle %xpout }
    else { %saystyle No matches found " $+ %item $+ ". }
  }
}
