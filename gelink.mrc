>start<|gelink.mrc|cleaned + fix|1.3|rs
on *:TEXT:*:*: {
  _CheckMain
  if (!$regex($1,/^[!@.](g(reat|rand)?e(xchange)?|price)$/Si)) { halt }
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m %thread out $saystyle($left($1,1),$nick,$chan)
  if ($litecalc($2)) {
    hadd -m %thread amount $litecalc($2)
    hadd -m %thread search " $+ $replace($3-,$chr(32),+) $+ "
  }
  else {
    hadd -m %thread search " $+ $replace($2-,$chr(32),+) $+ "
  }
  sockopen $+(gelink.,%thread) itemdb-rs.runescape.com 80
}
on *:sockopen:gelink.*:{
  sockwrite -n $sockname GET /results.ws?query= $+ $hget($gettok($sockname,2,46),search) $+ &price=all&members= HTTP/1.1
  sockwrite -n $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:gelink.*: {
  var %thread = $gettok($sockname,2,46)
  var %file = %thread $+ .txt
  if ($sockerr) {
    _throw $nopath($script) %thread
    halt
  }
  else {
    while ($sock($sockname).rq) {
      sockread &gelink
      bwrite %file -1 -1 &gelink
    }
    bread %file 0 $file(%file).size &gelink2
    if ($bfind(&gelink2,0,</HTML>)) {
      var %amount = $hget(%thread,amount)
      var %number = $calc($bfind(&gelink2,0,results_text">)+15), %end = $bfind(&gelink2,%number,item)
      var %start = $bfind(&gelink2,0,Change Today (gp)</td>), %limit = 8
      while ($bfind(&gelink2,%start,ws?obj) && %limit) {
        var %a = $bfind(&gelink2,%start,ws?obj), %b = $calc($bfind(&gelink2,%a,>)+2), %c = $bfind(&gelink2,%b,<)
        var %d = $calc($bfind(&gelink2,%c,<td>)+4), %e = $bfind(&gelink2,%d,<)
        var %f = $calc($bfind(&gelink2,%e,">)+2), %g = $bfind(&gelink2,%f,<)
        var %h = $calc($bfind(&gelink2,%g,img src=")+10), %i = $bfind(&gelink2,%h,/serverlist/), %k = $bfind(&gelink2,%i,.png)
        var %j = $iif(*member* iswm $bvar(&gelink2,%i,$calc(%k - %i)).text,$+($chr(32),,$chr(40),07M,$chr(41)))
        var %price = $litecalc($bvar(&gelink2,%d,$calc(%e - %d)).text)
        var %z = $iif($len(%z) > 5,%z) | $+ %j $bvar(&gelink2,%b,$calc(%c - %b)).text $+ :07 $iif(%amount,$format_number($calc(%amount * %price)),$format_number(%price)) $+  $updo($bvar(&gelink2,%f,$calc(%g - %f)).text)
        var %start = %c
        dec %limit 1
        hadd -m prices $replace($bvar(&gelink2,%b,$calc(%c - %b)).text,$chr(32),+) $litecalc(%price)
      }
      if (*your search* iswm $bvar(&gelink2,%number,$calc(%end - %number)).text) {
        var %z = No match found for $replace($hget(%thread,search),+,$chr(32))
      }
      if (*your search* !iswm $bvar(&gelink2,%number,$calc(%end - %number)).text) {
        var %out = $bvar(&gelink2,%number,$calc(%end - %number)).text
      }
      $hget(%thread,out) Results: $+ $iif(%amount, $+($chr(32),(Price x $+ $format_number(%amount) $+ ))) $+ 07 %out %z
      .remove %file
      .hfree %thread
      unset %*
      sockclose $sockname
    }
  }
}
alias -l updo {
  var %price = $litecalc($1)
  if (%price > 0) { return 03[ $+ $trim($1) $+ 03] }
  if (%price < 0) { return 04[ $+ $trim($1) $+ 04] }
  return
}
