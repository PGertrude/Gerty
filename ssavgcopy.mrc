on $*:TEXT:/^[!@.](ms|ss)avg */Si:#: {
  var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m $+(a,%class) out $saystyle($left($1,1),$nick,$chan)
  if ($right($1,-1) == ssavg) {
    hadd -m $+(a,%class) clan lovvel
    hadd -m $+(a,%class) clanname Supreme Skillers
  }
  if ($right($1,-1) == msavg) {
    hadd -m $+(a,%class) clan malkav
    hadd -m $+(a,%class) clanname Malkavian Scourge
  }
  sockopen $+(runehcalc.a,%class) www5.runehead.com 80
}
on *:sockopen:runehcalc.*: {
  sockwrite -n $sockname GET /clans/ml.php?clan= $+ $hget($gettok($sockname,2,46),clan) HTTP/1.1
  sockwrite -n $sockname Host: www5.runehead.com $+ $crlf $+ $crlf
}
on *:sockread:runehcalc.*: {
  if (!%row) { set %row 1 }
  if ($sockerr) {
    %saystyle [Socket Error] $sockname $time $script
    halt
  }
  var %regex = /<td><[^>]+>(\d+\x2c\d+)<\/a><\/td>$/i
  .sockread %rune.h
  if (*total members* iswm %rune.h) { set %rune.members $gettok($nohtml(%rune.h),2,58) }
  if (*average p2p combat* iswm %rune.h) { set %rune.combat $gettok($nohtml(%rune.h),2,58) }
  if (*average f2p combat* iswm %rune.h) { set %rune.combat2 $gettok($nohtml(%rune.h),2,58) }
  if (*average hitpoints* iswm %rune.h) { set %rune.hp $gettok($nohtml(%rune.h),2,58) }
  if (*average overall* iswm %rune.h) { set %rune.oa $gettok($nohtml(%rune.h),2,58) }
  if (*website* iswm %rune.h) { set %rune.website $remove($gettok(%rune.h,2,61),',act,title)) }
  if ($regex(%rune.h,%regex)) {
    set % [ $+ [ %row ] ] $remove($regsubex(%rune.h,%regex,$remove(\1,$chr(44))),$chr(32))
    inc %row
  }
  if (*</html>* iswm %rune.h) {
    var %x = $calc(%row - 1)
    %oa = 0
    while (%x) {
      var %oa = $calc( %oa + % [ $+ [ %x ] ] )
      dec %x
    }
    var %avgoa = $calc(%oa / (%row - 1))
    $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),clanname) $+  Overall:07 %rune.oa (07 $+ $round( $calc( ($ceil(%avgoa) - %avgoa) * (%row - 1) ) ,0) to go.) | Members:07 %rune.members | P2p Cmb:07 %rune.combat | F2p Cmb:07 %rune.combat2 | Hits:07 %rune.hp | Website:07 %rune.website
    unset %*
    sockclose runehcalc
  }
}
