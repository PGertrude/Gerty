>start<|world.mrc|World Script|1.0|rs
on $*:TEXT:/^[!@.](world|w|player)s?\b/Si:*: {
  _CheckMain
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  if ($2 !isnum) { goto players }

  var %lang /l=0
  var %world = World
  if ($regex($2,/(122|139|140|146|147)/)) {
    var %lang /l=1
    var %world Welt
  }
  else if ($regex($2,/(128|150)/)) {
    var %lang /l=2
    var %world Serveur
  }
  else if ($regex($2,/(125|126|127)/)) {
    var %lang /l=3
    var %world Mundo
  }

  _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) World %lang %world $2
  sockopen $+(world.,%thread) www.runescape.com 80
  return

  :players
  _fillcommand %thread $left($1,1) $nick $iif($chan,$v1,PM) Players
  sockopen $+(world2.,%thread) www.runescape.com 80

}
on *:sockopen:world.*:{
  sockwrite -n $sockname GET $command($gettok($sockname,2,46),arg1) $+ /slu.ws?lores.x=0&plugin=0&order=WMLPA
  sockwrite -n $sockname Host: www.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:world.*: {
  var %thread = $gettok($sockname,2,46)
  if ($sockerr) {
    _throw $nopath($script) %thread
    $command(%thread,out) Connection Error: Please try again in a few moments.
    hfree %thread
    sockclose $sockname
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &world
      bwrite %thread -1 -1 &world
    }
    bread %thread 0 $file(%thread).size &world2
    if ($bfind(&world2,0,</HTML>)) {
      var %world = $command(%thread,arg2)
      if (%world == World) {
        var %start = $bfind(&world2,0,Activity)
      }
      else if (%world == Welt) {
        var %start = $bfind(&world2,0,Thema)
      }
      else if (%world == Serveur) {
        var %start = $bfind(&world2,0,Activité)
      }
      else if (%world == Mundo) {
        var %start = $bfind(&world2,0,Tipo)
      }
      var %world = $command(%thread,arg2) $+ $iif(%world != Mundo,$chr(32)) $+ $command(%thread,arg3)
      ; Get the amount of players.
      var %a = $calc($bfind(&world2,%start,%world) +4), %b = $calc($bfind(&world2,%a,<td>)+4), %c = $bfind(&world2,%b,</td>)
      ; Get the worlds activity
      var %d = $calc($bfind(&world2,%c,class=") +7), %e = $bfind(&world2,%d,<)
      ; Get lootshare? and f2p/p2p
      noop $regex($remove($bvar(&world2,%e),300).text,$chr(10),$chr(13)),/title=\"(\w)\"/i)
      var %lootshare = $regml(1)

      var %type = $regml(1)
      var %activity = $nohtml($bvar(&world2,%d,$calc(%e - %d)).text)
      var %players = $nohtml($bvar(&world2,%b,$calc(%c - %b)).text)


      if (%a == 4) { $command(%thread,out) World07 $command(%thread,arg3) Not Found. }
      else { $command(%thread,out) World07 $command(%thread,arg3) (07 $+ %activity $+ ) | Players:07 %players | Type:07 %type | Lootshare:07 $iif(%lootshare == N,04No,03Yes) | Link: 12http://world $+ $command(%thread,arg3) $+ .runescape.com/a2,m0,j0,o0 }

      .remove %thread
      sockclose $sockname
      _clearCommand %thread
    }
  }
}
on *:sockopen:world2.*:{
  sockwrite -n $sockname GET /title.ws
  sockwrite -n $sockname Host: www.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:world2.*: {
  var %thread = $gettok($sockname,2,46)
  if ($sockerr) {
    _throw $nopath($script) %thread
    $command(%thread,out) Connection Error: Please try again in a few moments.
    hfree %thread
    sockclose $sockname
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &world
      bwrite %thread -1 -1 &world
    }
    bread %thread 0 $file(%thread).size &world2
    if ($bfind(&world2,0,</HTML>)) {
      var %a = $calc($bfind(&world2,0,There are currently)+20), %b = $calc($bfind(&world2,%a,playing)-8)
      $command(%thread,out) There are currently 07 $+ $bytes($bvar(&world2,%a,$calc(%b - %a)).text,db) People Playing across 171 servers. Runescape at07 $round($calc(100* $bvar(&world2,%a,$calc(%b - %a)).text / 338000),2) $+ 07% Capacity.
      .remove %thread
      sockclose $sockname
      _clearCommand %thread
    }
  }
}
