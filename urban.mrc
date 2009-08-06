>start<|urban.mrc|Urban Dictionary command|1.0|rs
on $*:TEXT:/^[!@.]urban */Si:#: {
  _CheckMain
  var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m $+(a,%thread) out $saystyle($left($1,1),$nick,$chan)
  hadd -m $+(a,%thread) search $replace($2-,$chr(32),+)
  sockopen $+(urban.a,%thread) www.rscript.org 80
}
on *:sockopen:urban.*: {
  sockwrite -n $sockname GET /lookup.php?type=urban&search= $+ $hget($gettok($sockname,2,46),search) HTTP/1.0
  sockwrite -n $sockname HOST: www.rscript.org $+ $crlf $+ $crlf
}
on *:sockread:urban.*: {
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
    halt
  }
  while ($sock($sockname).rq > 0) {
    var %urban
    sockread %urban
    if (DEFINED: isin %urban) {
      $hget($gettok($sockname,2,46),out) Urban Dictionary: ' $+ $hget($gettok($sockname,2,46),search) $+ ' $regsubex($gettok(%urban,2,58),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32)))
    }
    if (EXAMPLE: isin %urban) {
      $hget($gettok($sockname,2,46),out) Example: $regsubex($nohtml($gettok(%urban,2,58)),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32)))
    }
    if (MATCHES: 0 isin %urban) {
      $hget($gettok($sockname,2,46),out) Urban Dictionary has no entry for ' $+ $hget($gettok($sockname,2,46),search) $+ '.
      sockclose $sockname
      unset %*
      halt
    }
  }
}
