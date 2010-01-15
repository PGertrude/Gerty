>start<|compare.mrc|User Comparisons|2.25|rs
; - NEEDS REWRITING
on *:TEXT:*:*: {
  _CheckMain
  if ($misc($right($1,-1)) != compare) { halt }
  var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %thread2 = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = $saystyle($left($1,1),$nick,$chan))
  if (@ isin $2-) {
    if ($compares($2)) {
      var %skill = $compares($2)
      var %x = $calc($numtok($3-,32) -1)
      var %y = 1
      while (%y <= %x) {
        if (%y == 1) { var %nick1 = $3 }
        else { var %nick2 = %nick2 $gettok($3-,%y,32) }
        inc %y
      }
      if (!%nick2) { var %nick2 = $caps($rsn($nick)) }
    }
    else {
      if ($compares($3)) {
      }
      else {
        var %x = $calc($numtok($2-,32) -1)
        var %y = 1
        while (%y <= %x) {
          if (%y == 1) { var %nick1 = $2 }
          else { var %nick2 = %nick2 $gettok($2-,%y,32) }
          inc %y
        }
        if (!%nick2) { var %nick2 = $caps($rsn($nick)) }
        var %skill = Overall
      }
    }
    var %time = $tracks($gettok($2-,2,64))
  }
  else {
    if ($compares($2)) {
      var %skill = $compares($2)
      var %x = $numtok($3-,32)
      var %y = 1
      while (%y <= %x) {
        if (%y == 1) { var %nick1 = $3 }
        else { var %nick2 = %nick2 $gettok($3-,%y,32) }
        inc %y
      }
      if (!%nick2) { var %nick2 = $caps($rsn($nick)) }
    }
    else {
      if ($compares($3)) {
      }
      else {
        var %x = $numtok($2-,32)
        var %y = 1
        while (%y <= %x) {
          if (%y == 1) { var %nick1 = $2 }
          else { var %nick2 = %nick2 $gettok($2-,%y,32) }
          inc %y
        }
        if (!%nick2) { var %nick2 = $caps($rsn($nick)) }
        var %skill = Overall
      }
    }
  }
  if (!%time) { var %time = Today }
  if (!%nick1 || !%nick2 || !%skill) { %saystyle Syntax Error: !compare <skill> <nick1> <nick2> @<time> | unset %* | halt }
  hadd -m $+(a,%thread) out %saystyle
  hadd -m $+(a,%thread2) out %saystyle
  hadd -m $+(a,%thread) nick $caps($rsn(%nick1))
  hadd -m $+(a,%thread2) nick $caps($rsn(%nick2))
  hadd -m $+(a,%thread) skill %skill
  hadd -m $+(a,%thread2) skill %skill
  hadd -m $+(a,%thread) time %time
  hadd -m $+(a,%thread2) time %time
  hadd -m $+(a,%thread) partner %thread2
  hadd -m $+(a,%thread2) partner %thread
  sockopen $+(compare.a,%thread) hiscore.runescape.com 80
  sockopen $+(compare.a,%thread2) hiscore.runescape.com 80
}
on *:sockread:compare.*: {
  if (!%row) { !set %row 1 }
  if ($sockerr) {
    _throw $nopath($script) %thread
    halt
  }
  while ($sock($sockname).rq > 0) {
    var %stats
    sockread %stats
    if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
      set % [ $+ [ %row ] ] %stats
      if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
      if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
      inc %row 1
      if (%row == 30) { comp.out }
    }
    if (Page not found isin %stats) { comp.out }
  }
}
alias comp.out {
  if ($hget($gettok($sockname,2,46),skill) == pass) { unset %* | .hfree $gettok($sockname,2,46) | sockclose $sockname | halt }
  if (!%1) { $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) does not feature Hiscores | hadd -m a $+ $hget($gettok($sockname,2,46),partner) skill pass | .hfree $gettok($sockname,2,46) | sockclose $sockname | unset %* | halt }
  if ($gettok(%1,2,44) > 100) {
    var %x = 1,%y = 1
    hadd -m $gettok($sockname,2,46) rankeds 0
    while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
      hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
      inc %x 1
    }
    set %unranked $round($calc(($gettok(%1,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
    while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
      set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
      inc %y 1
    }
  }
  if ($gettok(%1,2,44) < 100) {
    var %v = 24
    var %w = 0
    while (%v > 0) {
      var %w = %w + $remove($gettok(% [ $+ [ $calc(%v +1) ] ],2,44),-)
      if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v != 4) { set % [ $+ [ $calc(%v +1) ] ] Unranked,1,0 }
      if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v == 4) { set %5 Unranked,10,1154 | var %w = %w + 9 }
      dec %v 1
    }
    var %x = 24
    var %y = 0
    while (%x > 0) {
      var %y = %y + $replace($gettok(% [ $+ [ $calc(%x +1) ] ],3,44),-1,0)
      dec %x 1
    }
    set %1 Unranked, $+ $calc(%w) $+ , $+ $calc(%y)
  }
  var %partner = a $+ $hget($gettok($sockname,2,46),partner)
  if ($skills($hget($gettok($sockname,2,46),skill))) {
    hadd -m $gettok($sockname,2,46) exp $(% $+ $statnum($hget($gettok($sockname,2,46),skill)),2)
  }
  if ($hget($gettok($sockname,2,46),skill) == Combat) {
    hadd -m $gettok($sockname,2,46) exp NR, $+ $floor($calccombat($gettok(%2,2,44),$gettok(%3,2,44),$gettok(%4,2,44),$gettok(%5,2,44),$gettok(%6,2,44),$gettok(%7,2,44),$gettok(%8,2,44),$gettok(%25,2,44)).p2p) $+ , $&
      $+ $calc($gettok(%2,3,44) + $gettok(%3,3,44) + $gettok(%4,3,44) + $gettok(%5,3,44) + $gettok(%6,3,44) + $gettok(%7,3,44) + $gettok(%8,3,44) + $gettok(%25,3,44)).exp
  }
  if ($minigames($hget($gettok($sockname,2,46),skill))) {
    if ($gettok($(% $+ $statnum($hget($gettok($sockname,2,46),skill)),2),1,44) == -1) {
      $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) does not feature minigame hiscores.
      hadd -m %partner skill pass
      .hfree $gettok($sockname,2,46)
      sockclose $sockname
      unset %*
      halt
    }
    hadd -m $gettok($sockname,2,46) exp $replace($(% $+ $statnum($hget($gettok($sockname,2,46),skill)),2),-1,0)
  }
  if ($hget(%partner,complete)) {
    var %compared = $hget(%partner,exp)
    var %current = $hget($gettok($sockname,2,46),exp)
    var %out
    ; for the 25 skills (and combat)
    if ($skills($hget($gettok($sockname,2,46),skill)) || $hget($gettok($sockname,2,46),skill) == combat) {
      ; compare levels
      if ($gettok(%current,2,44) > $gettok(%compared,2,44)) {
        %out =  $+ $hget($gettok($sockname,2,46),nick) (07 $+ $gettok(%current,2,44) $+ ) is07 $bytes($calc($gettok(%current,2,44) - $gettok(%compared,2,44)),db) $+  $hget($gettok($sockname,2,46),skill) $&
          levels higher than $hget(%partner,nick) (07 $+ $gettok(%compared,2,44) $+ ).
      }
      else if ($gettok(%current,2,44) < $gettok(%compared,2,44)) {
        %out =  $+ $hget(%partner,nick) (07 $+ $gettok(%compared,2,44) $+ ) is07 $bytes($calc($gettok(%compared,2,44) - $gettok(%current,2,44)),db) $+  $hget($gettok($sockname,2,46),skill) $&
          levels higher than $hget($gettok($sockname,2,46),nick) (07 $+ $gettok(%current,2,44) $+ ).
      }
      else {
        %out =  $+ $hget(%partner,nick) and $hget($gettok($sockname,2,46),nick) both have level07 $bytes($gettok(%compared,2,44),db)  $+ $hget($gettok($sockname,2,46),skill) $+ .
      }
      ; compare exp
      if ($gettok(%current,3,44) > $gettok(%compared,3,44)) {
        %out = %out  $+ $hget($gettok($sockname,2,46),nick) has07 $bytes($calc($gettok(%current,3,44) - $gettok(%compared,3,44)),db) more experience.
      }
      else if ($gettok(%current,3,44) < $gettok(%compared,3,44)) {
        %out = %out  $+ $hget(%partner,nick) has07 $bytes($calc($gettok(%compared,3,44) - $gettok(%current,3,44)),db) more experience.
      }
      else {
        %out = %out  $+ $hget(%partner,nick) and $hget($gettok($sockname,2,46),nick) both have07 $bytes($gettok(%compared,3,44),db)  $+ $hget($gettok($sockname,2,46),skill) experience.
      }
    }
    ; for minigames
    if ($minigames($hget($gettok($sockname,2,46),skill))) {
      if ($gettok(%current,2,44) > $gettok(%compared,2,44)) {
        %out =  $+ $hget($gettok($sockname,2,46),nick) (07 $+ $gettok(%current,2,44) $+ ) is07 $bytes($calc($gettok(%current,2,44) - $gettok(%compared,2,44)),db) $+  $hget($gettok($sockname,2,46),skill) $&
          levels higher than $hget(%partner,nick) (07 $+ $gettok(%compared,2,44) $+ ).
      }
      else if ($gettok(%current,2,44) < $gettok(%compared,2,44)) {
        %out =  $+ $hget(%partner,nick) (07 $+ $gettok(%compared,2,44) $+ ) is07 $bytes($calc($gettok(%compared,2,44) - $gettok(%current,2,44)),db) $+  $hget($gettok($sockname,2,46),skill) $&
          levels higher than $hget($gettok($sockname,2,46),nick) (07 $+ $gettok(%current,2,44) $+ ).
      }
      else {
        %out =  $+ $hget(%partner,nick) and $hget($gettok($sockname,2,46),nick) both have level07 $bytes($gettok(%compared,2,44),db)  $+ $hget($gettok($sockname,2,46),skill) $+ .
      }
    }
    $hget($gettok($sockname,2,46),out) %out
    ; tracking
    if ($skills($hget($gettok($sockname,2,46),skill))) {
      sockopen $+(rsccomp.,$gettok($sockname,2,46)) www.rscript.org 80
      sockopen $+(rsccomp.,%partner) www.rscript.org 80
    }
    else {
      .hfree %partner
      .hfree $gettok($sockname,2,46)
    }
  }
  hadd -m $gettok($sockname,2,46) complete %partner
  unset %*
}
on *:sockread:rsccomp.*: {
  var %thread = $gettok($sockname,2,46)
  if (!%row) { !set %row 1 }
  if ($sockerr) {
    _throw compare %thread
    halt
  }
  .tokenize 32 $timeToday
  var %today = $1, %week = $2, %month = $3, %year = $4
  while ($sock($sockname).rq > 0) {
    var %stats
    sockread %stats
    if ($(% $+ $hget($gettok($sockname,2,46),time),2) isin %stats) {
      var %partner = a $+ $hget($gettok($sockname,2,46),partner)
      hadd -m $gettok($sockname,2,46) rscript %stats
      if ($hget(%partner,rscript)) {
        $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),time) $+ : $hget($gettok($sockname,2,46),nick) gained07 $bytes($gettok(%stats,2,58),db) experience, $hget(%partner,nick) gained07 $bytes($gettok($hget(%partner,rscript),2,58),db) experience
        hfree %partner
        hfree $gettok($sockname,2,46)
        unset %*
        sockclose $sockname
        halt
      }
    }
  }
}
