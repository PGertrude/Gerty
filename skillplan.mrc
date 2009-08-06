>start<|skillplan.mrc|Shows exp from an item|2.0|rs
on *:TEXT:*:*: {
  _CheckMain
  if (!$regex($1,/^[!@.]([a-z]+)-*plan$/i)) halt
  if ($skills($regml(1)) == nomatch) halt
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  if (!$3) { %saystyle Syntax Error: !<skill>plan [rsn] <amount> <item> | halt }
  var %skill = $skills($regml(1))
  if ($calculate($2)) {
    var %amount = $calculate($2)
    var %item = $3-
    var %nick = $caps($rsn($nick))
  }
  else {
    var %amount = $calculate($3)
    var %item = $4-
    var %nick = $caps($rsn($2))
  }
  hadd -m %thread out %saystyle
  hadd -m %thread nick %nick
  hadd -m %thread amount %amount
  hadd -m %thread item %item
  hadd -m %thread skill %skill
  sockopen $+(skillplan.,%thread) hiscore.runescape.com 80
}
on *:sockopen:skillplan.*: {
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
    halt
  }
  sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget($gettok($sockname,2,46),nick) HTTP/1.1
  sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:skillplan.*: {
  if (%row == $null) { !set %row 1 }
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
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
      if (%row == 30) { skillplan.out }
    }
    if (Page not found isin %stats) { skillplan.out }
  }
}
alias skillplan.out {
  var %saystyle = $hget($gettok($sockname,2,46),out)
  var %amount = $hget($gettok($sockname,2,46),amount)
  var %nick = $hget($gettok($sockname,2,46),nick)
  var %item = $hget($gettok($sockname,2,46),item)
  var %skill = $hget($gettok($sockname,2,46),skill)
  if (!%1) { %saystyle  $+ %nick does not feature Hiscores. | goto unset }
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
  var %skillinfo = $(% $+ $statnum(%skill),2)
  var %lev = $virtual($gettok(%skillinfo,3,44))
  var %exp = $gettok(%skillinfo,3,44)
  var %file = %skill $+ .txt
  var %iteminfo = $read(%file, w, * $+ %item $+ *)
  var %itemname = $gettok(%iteminfo,1,9)
  var %itemexpe = $gettok(%iteminfo,2,9)
  if (!%iteminfo) { %saystyle Invalid item07 %item $+ . If you think this is a valid item please contact an admin. | goto unset }
  %saystyle  $+ %nick Current  $+ %skill $+  level:07 %lev ( $+ $bytes(%exp,db) $+ ) $chr(124) experience for %amount %itemname $+ 's:07 $bytes($calc( %amount * %itemexpe ),db) $&
    ( $+ %itemexpe each) $chr(124) resulting level:07 $virtual($calc( %exp + ( %amount * %itemexpe ) )) ( $+ $bytes($calc( %exp + ( %amount * %itemexpe ) ),db) $+ )
  :unset
  .hfree $gettok($sockname,2,46)
  unset %*
  sockclose $sockname
  halt
}
