on $*:TEXT:/^[!@.]clan */Si:*: {
  var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m $+(a,%class) out $saystyle($left($1,1),$nick,$chan)
  if ($2) {
    hadd -m $+(a,%class) nick $caps($regsubex($rsn($replace($2-,$chr(32),_)),/\W/g,_))
  }
  else if (!$2) {
    hadd -m $+(a,%class) nick $caps($regsubex($rsn($nick),/\W/g,_))
  }
  sockopen $+(clanlookup.a,%class) www5.runehead.com 80
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
  var %bleh = $gettok($sockname,2,46)
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &runehead
      bwrite %bleh -1 -1 &runehead
    }
    bread %bleh 0 $file(%bleh).size &runehead2
    if ($bfind(&runehead2,0,</HTML>)) {
      var %start = $bfind(&runehead2,0,'hovertr')
      while ($bfind(&runehead2,%start,Memberlist'>)) {
        var %a = $calc($bfind(&runehead2,%start,Memberlist'>)+12), %b = $bfind(&runehead2,%a,<), %c = $calc($bfind(&runehead2,%start,clan=)+5), %d = $bfind(&runehead2,%c,')
        var %e = %e 07 $+ $bvar(&runehead2,%a,$calc(%b - %a)).text $+ ;
        var %mlid = $bvar(&runehead2,%c,$calc(%d - %c)).text
        var %start = %b
      }
      if ($count(%e,;) > 1) {
        $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) is in07 $count(%e,;) Clans; %e
      }
      if ($count(%e,;) == 1) {
        $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) is in $left(%e,-1) Clan: (07http://www.runehead.com/clans/ml.php?clan= $+ %mlid $+ )
      }
      if (!%e) {
        hadd -m $gettok($sockname,2,46) noclan noclan
      }
      .remove %bleh
      sockopen $+(clanlookup2.,$gettok($sockname,2,46)) www5.runehead.com 80
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
  var %bleh = $gettok($sockname,2,46)
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &runehead
      bwrite %bleh -1 -1 &runehead
    }
    bread %bleh 0 $file(%bleh).size &runehead2
    if ($bfind(&runehead2,0,</HTML>)) {
      var %start = $bfind(&runehead2,0,'hovertr')
      while ($bfind(&runehead2,%start,Memberlist'>)) {
        var %a = $calc($bfind(&runehead2,%start,Memberlist'>)+12), %b = $bfind(&runehead2,%a,<), %c = $calc($bfind(&runehead2,%start,clan=)+5), %d = $bfind(&runehead2,%c,')
        var %e = %e 07 $+ $bvar(&runehead2,%a,$calc(%b - %a)).text $+ ;
        var %mlid = $bvar(&runehead2,%c,$calc(%d - %c)).text
        var %start = %b
      }
      if ($count(%e,;) > 1) {
        $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) is in07 $count(%e,;) Non-Clans; %e
      }
      if ($count(%e,;) == 1) {
        $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) is in $left(%e,-1) Non-Clan: (07http://www.runehead.com/clans/ml.php?clan= $+ %mlid $+ )
      }
      if (!%e && $hget($gettok($sockname,2,46),noclan) == noclan) {
        $hget($gettok($sockname,2,46),out) No record for07 $hget($gettok($sockname,2,46),nick) found on RuneHead.
      }
      .remove %bleh
      .hfree $gettok($sockname,2,46)
      sockclose $sockname
    }
  }
}