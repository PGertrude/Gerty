>start<|table.mrc|another html update|1.55|rs
on $*:TEXT:/^[!@.](table|top) */Si:*: {
  _CheckMain
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  _fillcommand %thread $left($1,1) $nick $iif($chan,$v1,PM) $right($1,-1)
  if (!$2) { hadd -m %thread skill overall }
  if ($2 && $scores($2) == nomatch) { hadd -m %thread skill overall }
  if ($scores($2) != nomatch) {
    if ($left($3,1) == $# || $litecalc($3) > 0) { hadd -m %thread rank $litecalc($remove($3,$chr(35))) }
    else { hadd -m %thread nick $rsn($3-) }
    hadd -m %thread skill $scores($2)
  }
  sockopen $+(top.,%thread) hiscore.runescape.com 80
}
on *:sockopen:top.*: {
  sockwrite -n $sockname GET /overall.ws?category_type= $+ $catno($hget($gettok($sockname,2,46),skill)) $+ &table= $+ $smartno($hget($gettok($sockname,2,46),skill)) $+ &user= $+ $hget($gettok($sockname,2,46),nick) $+ &rank= $+ $hget($gettok($sockname,2,46),rank) HTTP/1.1
  sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:top.*: {
  var %thread = $gettok($sockname,2,46)
  if (!%row) { %row = 1 }
  if ($sockerr) {
    _throw $nopath($script) %thread
    halt
  }
  .sockread %top
  if (%row < 350) {
    if ($nohtml(%top)) {
      set % [ $+ [ $calc(%row) ] ] $replace($nohtml(%top),$chr(32),_)
      inc %row 1
    }
  }
  if (</html> isin %top) { topout %thread | sockclose $sockname | halt }
}
alias topout {
  var %thread = $1
  if ($minigames($hget(%thread,skill)) == nomatch) {
    var %out = $command(%thread,out)  $+ $hget(%thread,skill) $+  Ranks
    if ($hget(%thread,nick)) { var %y = 117 }
    else { var %y = 117 }
    %out = %out 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) $+(07,$(% $+ $calc(%y + 2),2)) ( $+ $(% $+ $calc(%y + 3),2) $+ )
    inc %y 4
    var %x = 1
    while (%x <= 9) {
      var %true = $iif($regsubex($(% $+ $calc(%y + 1),2),/\W/g,_) == $hget(%thread,nick) || $(% $+ %y,2) == $hget(%thread,rank),$true,$false)
      %out = %out 07# $+ $(% $+ %y,2) $+  $iif(%true,) $+ $(% $+ $calc(%y + 1),2) $+ $iif(%true,) $+(07,$(% $+ $calc(%y + 2),2)) ( $+ $(% $+ $calc(%y + 3),2) $+ )
      inc %y 4
      inc %x
    }
    %out
  }
  else {
    var %out = $command(%thread,out)  $+ $hget(%thread,skill) $+  Ranks
    if ($hget(%thread,nick)) { var %y = 96 }
    else { var %y = 96 }
    %out = %out 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) ( $+ $(% $+ $calc(%y + 2),2) $+ )
    inc %y 3
    var %x = 1
    while (%x <= 9) {
      var %true = $iif($regsubex($(% $+ $calc(%y + 1),2),/\W/g,_) == $hget(%thread,nick) || $(% $+ %y,2) == $hget(%thread,rank),$true,$false)
      %out = %out 07# $+ $(% $+ %y,2) $+  $iif(%true,) $+ $(% $+ $calc(%y + 1),2) $+ $iif(%true,) ( $+ $(% $+ $calc(%y + 2),2) $+ )
      inc %y 3
      inc %x
    }
    %out
  }
  :unset
  _clearcommand %thread
  unset %*
}
