on $*:TEXT:/^[!@.]Task */Si:*: {
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if (!$2) { %saystyle Invalid Syntax: !task <number> <monster> | halt }
  var %class = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m %class out %saystyle
  hadd -m %class amount $calculate($2)
  hadd -m %class monster $caps($plural($3-))
  var %nick = $caps($rsn($regsubex($nick,/\W/g,_)))
  hadd -m %class nick %nick
  sockopen $+(task.,%class) hiscore.runescape.com 80
}
on *:sockopen:task.*: {
  .sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget($gettok($sockname,2,46),nick) HTTP/1.1
  .sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:task.*: {
  if (%row == $null) { !set %row 1 }
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
    halt
  }
  var %stats
  .sockread %stats
  if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
    set % [ $+ [ %row ] ] %stats
    if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
    if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
    inc %row 1
    if (%row == 30) { task.out }
  }
  if (*404 - Page not found* iswm %task) { $hget($gettok($sockname,2,46),out) User7 $hget($gettok($sockname,2,46),nick) not found on Hiscores. (User must have !defname set for this command) | .set %404 false }
}
alias task.out {
  var %info = $read(slayer.txt,w,* $+ $hget($gettok($sockname,2,46),monster) $+ *)
  var %taskxp = $calc( $gettok(%info,2,9) * $hget($gettok($sockname,2,46),amount) )
  $hget($gettok($sockname,2,46),out) Next Task:07 $bytes($hget($gettok($sockname,2,46),amount),db) $gettok(%info,1,9) | Current Exp:07 $bytes($gettok(%20,3,44),db) (07 $+ $virtual($gettok(%20,3,44)) $+ ) | Exp this Task:07 $bytes(%taskxp,db) $&
    | Exp After Task:07 $bytes($calc($gettok(%20,3,44) + %taskxp),db) | Which is Level:07 $virtual($calc($gettok(%20,3,44) + %taskxp )) $&
    | With:07 $bytes($calc( $lvltoxp($calc($virtual($calc($gettok(%20,3,44) + %taskxp)) +1)) - ($gettok(%20,3,44) + %taskxp)),db) exp till level07 $calc($virtual($calc($gettok(%20,3,44) + %taskxp)) +1)
  unset %*
  .hfree $gettok($sockname,2,46)
  sockclose $sockname
  halt
}
alias plural {
  if ($right($1,1) == s) return $left($1,-1)
  return $1
}
