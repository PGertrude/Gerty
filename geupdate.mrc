>start<|geupdate.mrc|fixed spam after timer restarts|1.65|rs
; - NEEDS REWRITING
on *:sockread:CheckGePrices.*: {
  if ($sockerr) {
    echo -a Ge Update Connection Error.
    halt
  }
  var %stats
  .sockread %stats
  if ($gettok($sockname,2,46) == front) {
    if ($regex(%stats,/<a href="\.\/viewitem\.ws\?obj=\d+">[a-z0-9_ ]+<\/a>/i)) {
      var %string = $regsubex(%stats,/<a href="\./viewitem\.ws\?obj=\d+">([a-z0-9_ ]+)<\/a>/i,$replace(\1,$chr(32),_))
      hadd -m ge front_string $hget(ge,front_string) $+ %string
      if (%string == View_graph) { GeClose front $hget(ge,front_string) }
    }
  }
  if ($gettok($sockname,2,46) == zam) {
    if ($regex(%stats,/<td>([^<]+)<\/td>/)) {
      var %string = $regsubex(%stats,/<td>([^<]+)<\/td>/,$remove(\1,$chr(32)))
      hadd -m ge zam_string $hget(ge,zam_string) $+ %string
    }
    if ($replace(%stats,$chr(32),_) == Show_more_results: && $hget(ge,zam_string)) { GeClose zam $hget(ge,zam_string) }
  }
}
alias GeClose {
  var %page = $1
  hadd -m ge %page $+ _string
  if (!$2 || !$hget(ge,%page)) {
    if ($2) { hadd -m ge %page $2 }
    goto unset
  }
  else {
    if ($2 != $hget(ge,%page) && $calc($ctime - $gettok($read(geupdate.txt,1),2,124)) > 1200) {
      if ($hget(ge,update) == 1) {
        write -il1 geupdate.txt $host(time) $+ $chr(124) $+ $ctime $+ $chr(124) $+ $ord($host(date)) $host(month).3
        var %x = $chan(0)
        while (%x) {
          if ($chanset($chan(%x),geupdate) == on) { .msg $chan(%x) GE Database has been updated. }
          dec %x
        }
        echo -at Resetting ge prices...
        resetPrices
        runepriceupdater
        hadd -m ge update 0
        hdel ge zam
        hdel ge front
        goto unset
      }
      else {
        hadd -m ge update 1
        var %x = $chan(0)
        while (%x) {
          if ($chanset($chan(%x),geupdate) == on) { .msg $chan(%x) Possible GE update in progress. }
          dec %x
        }
        .timer 1 1200 hadd -m ge update 0
      }
    }
    hadd -m ge %page $2
  }
  :unset
  unset %*
  sockclose $sockname
}
