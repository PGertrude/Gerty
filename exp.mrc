on $*:text:/^[!@.](le?ve?l|e?xp)/Si:#:{
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if (!$2) { %saystyle $capwords($right($1,-1)) what? Syntax: !xp <level> OR !xp <xp> OR !xp <item>. | halt }
  if ($regex(lvltolvl,$2-,/^(\d{1,3})(?:\D(\d{1,3}))?/Si)) {
    if ($regml(lvltolvl,2)) && ($regml(lvltolvl,1) > 126 || $regml(lvltolvl,1) < 1 || $regml(lvltolvl,2) > 126 || $regml(lvltolvl,2) < 1) { %saystyle Please only specify levels between 1 and 126 | halt }
    var %calc $floor($calculate($2-))
    if ($regml(lvltolvl,2)) {
      var %1 = $iif($regml(lvltolvl,1) > $regml(lvltolvl,2),$regml(lvltolvl,2),$regml(lvltolvl,1))
      var %2 = $iif($regml(lvltolvl,1) > $regml(lvltolvl,2),$regml(lvltolvl,1),$regml(lvltolvl,2))
      %saystyle Exp needed level $+(07,%1,$chr(15)) to $+(07,%2,$chr(15),:) $+(07,$bytes($calc($l(%2) - $l(%1)),bd),$chr(15))
    }
    elseif (%calc <= 126 && %calc >= 1) {
      %saystyle Level $+(07,%calc,:07) $bytes($l(%calc),bd)
    }
    elseif (%calc <= 200000000 && %calc >= 127) {
      %saystyle Exp $+(07,$bytes(%calc,bd),:07) $xptolvl(%calc)
    }
    else { %saystyle Please specify a level between 1 and 126, exp value below 200,000,000, or valid item. }
  }
  else {
    var %ticks = $ticks, %x = 1
    if ($lookups($2) != NoMatch && $lookups($2)) && ($3) {
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
      ;if ($gettok(%xp,1,124) == Hitpoints) {
      ; write newnew.txt $puttok(%xp,$round($calc($gettok(%xp,3,124) / 3),2),3,124)
      ;}
    }
    .fclose xp $+ %ticks
    if (%xpout) { %saystyle %xpout }
    else { %saystyle No matches found " $+ %item $+ ". }
  }
}
on $*:text:/^[!@.](le?ve?l|e?xp)/Si:?:{
  var %saystyle = .msg $nick
  if (!$2) { %saystyle $capwords($right($1,-1)) what? Syntax: !xp <level> OR !xp <xp> OR !xp <item>. | halt }
  if ($regex(lvltolvl,$2-,/^(\d{1,3})(?:\D(\d{1,3}))?/Si)) {
    if ($regml(lvltolvl,2)) && ($regml(lvltolvl,1) > 126 || $regml(lvltolvl,1) < 1 || $regml(lvltolvl,2) > 126 || $regml(lvltolvl,2) < 1) { %saystyle Please only specify levels between 1 and 126 | halt }
    var %calc $floor($calculate($2-))
    if ($regml(lvltolvl,2)) {
      var %1 = $iif($regml(lvltolvl,1) > $regml(lvltolvl,2),$regml(lvltolvl,2),$regml(lvltolvl,1))
      var %2 = $iif($regml(lvltolvl,1) > $regml(lvltolvl,2),$regml(lvltolvl,1),$regml(lvltolvl,2))
      %saystyle Exp needed level $+(07,%1,$chr(15)) to $+(07,%2,$chr(15),:) $+(07,$bytes($calc($l(%2) - $l(%1)),bd),$chr(15))
    }
    elseif (%calc <= 126 && %calc >= 1) {
      %saystyle Level $+(07,%calc,:07) $bytes($l(%calc),bd)
    }
    elseif (%calc <= 200000000 && %calc >= 127) {
      %saystyle Exp $+(07,$bytes(%calc,bd),:07) $xptolvl(%calc)
    }
    else { %saystyle Please specify a level between 1 and 126, exp value below 200,000,000, or valid item. }
  }
  else {
    var %ticks = $ticks, %x = 1
    if ($lookups($2) != NoMatch && $lookups($2)) && ($3) {
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
      ;if ($gettok(%xp,1,124) == Hitpoints) {
      ; write newnew.txt $puttok(%xp,$round($calc($gettok(%xp,3,124) / 3),2),3,124)
      ;}
    }
    .fclose xp $+ %ticks
    if (%xpout) { %saystyle %xpout }
    else { %saystyle No matches found " $+ %item $+ ". }
  }
}