on $*:TEXT:/^[!@.]c(oin)?s(hare)? */Si:*: {
  var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if ($chr(35) isin $2-) {
    if ($chr(35) isin $2) {
      hadd -m $+(a,%thread) id $remove($2,$chr(35))
      hadd -m $+(a,%thread) players $calculate($3)
    }
    else {
      hadd -m $+(a,%thread) id $remove($3,$chr(35))
      hadd -m $+(a,%thread) players $calculate($2)
    }
    hadd -m $+(a,%thread) out %saystyle
    sockopen $+(coinshare2.a,%thread) itemdb-rs.runescape.com 80
    halt
  }
  if ($chr(35) !isin $2- && $3) {
    if ($calculate($2) isnum) {
      var %players = $calculate($2)
      var %search = " $+ $replace($3-,$chr(32),+) $+ "
    }
    else if ($regex(coinshare,$2-,/^(.+) (\d+[kmb]?)/Si)) {
      var %search = " $+ $regml(coinshare,1) $+ "
      var %players = $calculate($regml(coinshare,2))
    }
    hadd -m $+(a,%thread) players %players
    hadd -m $+(a,%thread) search %search
    hadd -m $+(a,%thread) out %saystyle
    sockopen $+(coinshare.a,%thread) itemdb-rs.runescape.com 80
    halt
  }
  %saystyle Syntax Error: !coinshare <number of people> <item>
}
on *:sockopen:coinshare.*: {
  .sockwrite -n $sockname GET /results.ws?query= $+ $hget($gettok($sockname,2,46),search) $+ &price=all&members= HTTP/1.0
  .sockwrite -n $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:coinshare.*: {
  var %bleh = $gettok($sockname,2,46)
  if ($sockerr) {
    write ErrorLog.txt SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) $hget($gettok($sockname,2,46),search) $+ $(],)
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &item
      bwrite %bleh -1 -1 &item
    }
    bread %bleh 0 $file(%bleh).size &item2
    if ($bfind(&item2,0,</HTML>)) {
      var %start = $bfind(&item2,0,>Item<)
      while ($bfind(&item2,%start,item.ws?obj=)) {
        var %a = $calc($bfind(&item2,%start,item.ws?obj=)+12), %b = $bfind(&item2,%a,"), %c = $calc($bfind(&item2,%b,>)+1), %d = $bfind(&item2,%c,<)
        var %e = %e | $bvar(&item2,%c,$calc(%d - %c)).text 07 $+ $chr(35) $+ $bvar(&item2,%a,$calc(%b - %a)).text
        var %start = %d
      }
      var %e = $gettok(%e,1-8,124)
      if ($count(%e,$chr(35)) != 1) {
        $hget($gettok($sockname,2,46),out) Matches found07 $count(%e,$chr(35)) %e
        .hfree $gettok($sockname,2,46)
      }
      if ($count(%e,$chr(35)) == 1) {
        hadd -m $+($gettok($sockname,2,46)) id $gettok(%e,2,35)
        sockopen $+(coinshare2.,$gettok($sockname,2,46)) itemdb-rs.runescape.com 80
      }
      .remove %bleh
      sockclose $sockname
    }
  }
}
on *:sockopen:coinshare2.*: {
  .sockwrite -n $sockname GET /viewitem.ws?obj= $+ $hget($gettok($sockname,2,46),id) HTTP/1.0
  .sockwrite -n $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:coinshare2.*: {
  var %bleh = $gettok($sockname,2,46) $+ 2
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &item3
      bwrite %bleh -1 -1 &item3
    }
    bread %bleh 0 $file(%bleh).size &item4
    if ($bfind(&item4,0,</HTML>)) {
      var %start = $calc($bfind(&item4,0,>Browse<)+3)
      var %a = $calc($bfind(&item4,%start,alt=")+5), %b = $bfind(&item4,%a,")
      if ($calc(%a + 5) == %b) {
        $hget($gettok($sockname,2,46),out) Item not found on 12itemdb-rs.runescape.com
        goto unset
      }
      var %c = $calc($bfind(&item4,%b,price:)+11), %d = $bfind(&item4,%c,<)
      var %minprice = $remove($bvar(&item4,%c,$calc(%d - %c)).text,$chr(10))
      var %loot = $bytes($floor($calculate( %minprice / $hget($gettok($sockname,2,46),players) )),db)
      $hget($gettok($sockname,2,46),out)  $+ $caps($bvar(&item4,%a,$calc(%b - %a)).text) $+  Minimum price:07 %minprice (Loot per players ( $+ $hget($gettok($sockname,2,46),players) $+ ):07 %loot $+ gp) 12http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $hget($gettok($sockname,2,46),id)
      :unset
      .remove %bleh
      .hfree $gettok($sockname,2,46)
      sockclose $sockname
    }
  }
}