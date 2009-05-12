on $*:TEXT:/^[!@.]clan */Si:*: {
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m %thread out $saystyle($left($1,1),$nick,$chan)
  if ($2) { hadd -m %thread nick $rsn($2-) }
  else if (!$2) { hadd -m %thread nick $rsn($nick) }
  sockopen $+(clanlookup.,%thread) www5.runehead.com 80
}
on *:sockopen:clanlookup.*: {
  var %string = search= $+ $hget($gettok($sockname,2,46),nick) $+ &searchtype=exact&mltype=1&combatType=p2p
  sockwrite -n $sockname POST /clans/search.php HTTP/1.2
  sockwrite -n $sockname Host: www5.runehead.com
  sockwrite -n $sockname Content-Length: $len(%string)
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -n $sockname $crlf %string
}
on *:sockread:clanlookup.*: {
  var %thread = $gettok($sockname,2,46)
  var %file = %thread $+ .txt
  if ($sockerr) {
    write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget(%thread,out) $hget(%thread,nick) $+ $(],)
    echo -at Socket Error: $nopath($script)
    $hget(%thread,out) Connection Error: Please try again in a few moments.
    hfree %thread
    sockclose $sockname
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &runehead
      bwrite %file -1 -1 &runehead
    }
    bread %file 0 $file(%file).size &runehead2
    if ($bfind(&runehead2,0,</HTML>)) {
      var %start = $bfind(&runehead2,0,'hovertr')
      while ($bfind(&runehead2,%start,Memberlist'>)) {
        var %a = $calc($bfind(&runehead2,%start,Memberlist'>)+12), %b = $bfind(&runehead2,%a,<), %c = $calc($bfind(&runehead2,%start,clan=)+5), %d = $bfind(&runehead2,%c,')
        var %e = %e 07 $+ $bvar(&runehead2,%a,$calc(%b - %a)).text $+ ;
        var %mlid = $bvar(&runehead2,%c,$calc(%d - %c)).text
        var %start = %b
      }
      if ($count(%e,;) > 1) {
        $hget(%thread,out) $hget(%thread,nick) is in07 $count(%e,;) Clans; %e
      }
      if ($count(%e,;) == 1) {
        $hget(%thread,out) $hget(%thread,nick) is in $left(%e,-1) Clan: (07http://www.runehead.com/clans/ml.php?clan= $+ %mlid $+ )
      }
      if (!%e) {
        hadd -m %thread noclan noclan
      }
      .remove %file
      sockopen $+(clanlookup2.,%thread) www5.runehead.com 80
      sockclose $sockname
    }
  }
}
on *:sockopen:clanlookup2.*: {
  var %string = search= $+ $hget($gettok($sockname,2,46),nick) $+ &searchtype=exact&mltype=2&combatType=p2p
  sockwrite -n $sockname POST /clans/search.php HTTP/1.1
  sockwrite -n $sockname Host: www5.runehead.com
  sockwrite -n $sockname Content-Length: $len(%string)
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -n $sockname $crlf %string
}
on *:sockread:clanlookup2.*: {
  var %thread = $gettok($sockname,2,46)
  var %file = %thread $+ .txt
  if ($sockerr) {
    write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget(%thread,out) $hget(%thread,nick) $+ $(],)
    echo -at Socket Error: $nopath($script)
    $hget(%thread,out) Connection Error: Please try again in a few moments.
    hfree %thread
    sockclose $sockname
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &runehead
      bwrite %file -1 -1 &runehead
    }
    bread %file 0 $file(%file).size &runehead2
    if ($bfind(&runehead2,0,</HTML>)) {
      var %start = $bfind(&runehead2,0,'hovertr')
      while ($bfind(&runehead2,%start,Memberlist'>)) {
        var %a = $calc($bfind(&runehead2,%start,Memberlist'>)+12), %b = $bfind(&runehead2,%a,<), %c = $calc($bfind(&runehead2,%start,clan=)+5), %d = $bfind(&runehead2,%c,')
        var %e = %e 07 $+ $bvar(&runehead2,%a,$calc(%b - %a)).text $+ ;
        var %mlid = $bvar(&runehead2,%c,$calc(%d - %c)).text
        var %start = %b
      }
      if ($count(%e,;) > 1) {
        $hget(%thread,out) $hget(%thread,nick) is in07 $count(%e,;) Non-Clans; %e
      }
      if ($count(%e,;) == 1) {
        $hget(%thread,out) $hget(%thread,nick) is in $left(%e,-1) Non-Clan: (07http://www.runehead.com/clans/ml.php?clan= $+ %mlid $+ )
      }
      if (!%e && $hget(%thread,noclan) == noclan) {
        $hget(%thread,out) No record for07 $hget(%thread,nick) found on RuneHead.
      }
      .remove %file
      .hfree %thread
      sockclose $sockname
    }
  }
}
