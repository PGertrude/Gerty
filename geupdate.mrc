on *:QUIT: {
  hsave ge geupdatebackup.txt
}
on *:connect: {
  .timerge 0 60 .CheckGePrices
  if (!$hget(ge,1)) {
    hmake ge
    hload ge geupdatebackup.txt
  }
}
alias CheckGePrices {
  sockopen CheckGePrices.front itemdb-rs.runescape.com 80
  sockopen CheckGePrices.zam itemdb-rs.runescape.com 80
}
on *:sockopen:CheckGePrices.*: {
  var %page = $iif($gettok($sockname,2,46) == front,/frontpage.ws,/results.ws?query=zamorak&price=all)
  .sockwrite -n $sockname GET %page HTTP/1.1
  .sockwrite -n $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
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
    if ($2 != $hget(ge,%page)) {
      if ($hget(ge,update) == 1) {
        write -il1 geupdate.txt $time $+ $chr(124) $+ $ctime $+ $chr(124) $+ $ord($date(dd)) $date(mmm)
        var %x = $chan(0)
        while (%x) {
          if ($readini(chan.ini,$chan(%x),geupdate) == on) { .msg $chan(%x) GE Database has been updated. }
          dec %x
        }
        .timerge off
        .timer 1 3600 .timerge 0 60 .checkgeprices
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
          if ($readini(chan.ini,$chan(%x),geupdate) == on) { .msg $chan(%x) Possible GE update in progress. }
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
;############################
;#### last 7 day updates ####
;############################
on $*:TEXT:/^[!@.]geupdate\b/Si:*: {
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  var %output, %x = 2, %update
  %output = Recent Ge Updates (GMT): Today07 $gettok($read(geupdate.txt,1),1,124) $+  ( $+ $duration($calc($ctime($date $time) - $gettok($read(geupdate.txt,1),2,124))) ago);
  while (%x <= 7) {
    if (!$read(geupdate.txt,%x)) { break }
    %update = $read(geupdate.txt,%x)
    %output = %output $iif($gettok(%update,3,124),$v1,$calc(%x -1) days ago) $+ 07 $gettok(%update,1,124) $+ ;
    inc %x
  }
  %saystyle %output
}
on $*:TEXT:/^[!@.]setgeupdate\b/Si:*: {
  if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
    if $2 != on && $2 != off halt
    if $2 == on writeini chan.ini $chan geupdate on
    if $2 == off writeini chan.ini $chan geupdate off
    $saystyle($left($1,1),$nick,$chan) GE Update notification in $chan has been turned $2 $+ .
  }
}