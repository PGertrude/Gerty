>start<|circus.mrc|!circus|1.1|rs
on $*:text:/^[!.@]circus/Si:*: {
  _checkMain
  var %saystyle = $saystyle($left($1,1),$nick,$chan), %ticks = $+(a,$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9),$r(1,9))
  hadd -m %ticks out %saystyle
  sockopen circus. $+ %ticks runescape.wikia.com 80
}
on *:sockopen:circus.*:{
  sockwrite -nt $sockname GET /wiki/Balthazar_Beauregard's_Big_Top_Bonanza HTTP/1.1
  sockwrite -nt $sockname Host: runescape.wikia.com $+ $crlf $+ $crlf
}
on *:sockread:circus.*:{
  var %thread = $gettok($sockname,2,46)
  if ($sockerr) {
    _throw $nopath($script) %thread
    halt
  }
  sockread %circus
  if ($regex(%circus,/The circus is currently in: (.+?)\./i)) {
    $hget($gettok($sockname,2,46),out) The circus is currently found in:07 $nohtml($regml(1)) $+ . 12runescape.wikia.com
    unset %*
    hfree $gettok($sockname,2,46)
    sockclose $sockname
  }
}
