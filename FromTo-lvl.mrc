on $*:text:/^([^ ]+ )?@?~/Si:*:{
  if ($regml(1)) { 
    $botid($1)
    tokenize 32 $2-
  }
  if ($left($1,1) == @) { 
    var %saystyle = $saystyle(@,$nick,$chan)
    var %skill = $skills($right($1,-2))
  }
  else { 
    var %saystyle = $saystyle(!,$nick,$chan)
    var %skill = $skills($right($1,-1))
  }
  if (%skill == NoMatch && %skill != Combat) || (%skill == Overall) { halt }
  elseif ($istok(Ranged.Attack.Strength.Defence,%skill,46)) var %skill = Combat
  if ($regex(string,$remove($2-,$chr(44)),/^(?:(?:l|lvl|)(\d+)[- ](?:l|lvl|)(\d+)()|()()(\d[\d.mk]+))(?: @?(.*))?/Si)) {
    var %1 = $regml(string,1), %2 = $regml(string,2), %3 = $regml(string,3), %item = $regml(string,4)
    if (%1 && %2) {
      if (%1 >= 1 && %1 <= 126 && %2 >= 1 && %2 <= 126) {
        var %exp = $remove($calc($lvltoxp(%2) - $lvltoxp(%1)),-)
        var %show = Level $+(07,%1 to07 %2,) $parenthesis($bytes(%exp,bd) exp)
      }
      else { goto syntax }
    }
    else {
      var %exp = $remove($litecalc(%3),-)
      if (%exp >= 1 && %exp <= 200000000) {
        var %show = 07 $+ $bytes(%exp,bd) exp
      }
      else { goto syntax }
    }
    var %useritem = $readini(user.ini,$rsn($nick),$statnum(%skill) $+ param)
    if (!%item && !%useritem) { goto syntax }
    var %fname = param $+ $ran, %counter = 0
    .fopen %fname param.txt
    while (!$feof && %counter < 6) {
      var %string = $fread(%fname)
      if ($gettok(%string,1,124) != %skill) goto skip
      tokenize 124 %string
      if (%useritem == $2) {
        if (lvl isin $4) var %fupaul $4
        else var %fupaul lvl $4
        var %itemout $+(; $2,:07 $bytes($ceil($calc( %exp / $3 )),bd) $parenthesis(%fupaul),%itemout)
        inc %counter
      }
      if (%item isin $2 && %counter < 5) {
        if (lvl isin $4) var %fupaul $4
        else var %fupaul lvl $4
        var %itemout $+(%itemout,; $2,:07 $bytes($ceil($calc( %exp / $3 )),bd) $parenthesis(%fupaul))
        inc %counter
      }
      :skip
    }
    .fclose %fname
    if (!%itemout) var %itemout No items found matching $qt(%item) $+ .
    else var %itemout $right(%itemout,-2)
    %saystyle 07 $+ %skill estimation %show $+ : %itemout
  }
  else { goto syntax }
  halt
  :syntax {
    %saystyle Level estimation syntax: ~skill <from lvl> <to lvl> @<item> or ~skill <exp> @<item>. You can use !set item <skill> <item> as replacement for item.
  } 
}
alias botid {
  if ($1 == $me) return
  if ($regex(botid,$1,/^\[?(.{2})\]?$/S)) {
    if ($me == Gerty) var %botid = $str($chr(48),2)
    else var %botid = $regsubex($me,/^(?:\[(.{2})\])?Gerty/i,\1)
    if (%botid == $regml(botid,1)) return
  }
  if ($1 == Gerty && Gerty !ison $chan) { return }
  return halt
}
alias ran return $+($r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9))
