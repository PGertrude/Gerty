>start<|geDownload.mrc|downloads full ge database|3.2|rs
alias downloadSitePrices {
  var %thread $newThread
  sockopen dlGe. $+ %thread sselessar.net 80
}
on *:sockopen:dlGe.*:{
  write -c dlGe.txt
  .fopen geDownloadFileStream dlGe.txt
  sockwrite -nt $sockname GET /Gerty/GEDownload.php?list=fetch HTTP/1.1
  sockwrite -nt $sockname Host: sselessar.net $+ $crlf $+ $crlf
}
on *:sockread:dlGe.*:{
  sockread -fn &ge
  if ($bvar(&ge,1,$bvar(&ge,0)).text != $null) {
    if ($numtok($bvar(&ge,1,$bvar(&ge,0)).text,44) == 4) {
      .fwrite -n geDownloadFileStream $bvar(&ge,1,$bvar(&ge,0)).text
    }
    else {
      if (%full) {
        .fwrite -n geDownloadFileStream $bvar(&ge,1,$bvar(&ge,0)).text
        %full = $false
      }
      else {
        .fwrite geDownloadFileStream $bvar(&ge,1,$bvar(&ge,0)).text
        %full = $true
      }
    }
  }
}
on *:sockclose:dlGe.*: {
  .fclose geDownloadFileStream
  echo -at downloaded, ready to parse
  parseGe
}
alias updateSitePrices {
  echo -at starting ge update
  while (%x !> 25) {
    .timerSiteUpdate [ $+ [ %x ] ] 1 $calc(%x * 15) updateSitePricesBuffer $calc(%x +65)
    .timerSiteUpdate [ $+ [ %x ] $+ ] .1 1 $calc(%x * 15) updateSitePricesBuffer $calc(%x +65) $+ .1
    inc -u1 %x
  }
  updateSitePricesBuffer Other
}
alias updateSitePricesBuffer {
  if ($numtok($1, 46) == 1) {
    sockopen sitePrices. $+ $1 sselessar.net 80
  }
  else {
    sockopen sitePrices. $+ $1 rsportugal.org 80
  }
}
on *:sockopen:sitePrices.*: {
  if ($numtok($sockname, 46) == 2) {
    sockwrite -n $sockname GET /Gerty/GEDownload.php?id= $+ $iif($gettok($sockname,2,46) isnum,$chr($v1),$v1) HTTP/1.1
    sockwrite -n $sockname Host: sselessar.net $+ $crlf $+ $crlf
  }
  else {
    sockwrite -n $sockname GET /tracker/geDownload.php?id= $+ $iif($gettok($sockname,2,46) isnum,$chr($v1),$v1) HTTP/1.1
    sockwrite -n $sockname Host: rsportugal.org $+ $crlf $+ $crlf
  }
}
on *:sockclose:sitePrices.*: {
  sockclose $sockname
  if ($sock(sitePrices.*,0) == 0 && !$timer(SiteUpdate25)) {
    echo -at updated at site
    noop $_network(downloadSitePrices)
  }
}
alias checkForOfflineGeUpdate {
  if ($gettok($read(geupdate.txt,1),2,124) < $calc($1 - 1600)) {
    write -il1 geupdate.txt $asctime($calc($1 - 1600), HH:nn:ss) $+ $| $+ $calc($1 - 1600) $+ $| $+ $ord($asctime($calc($1 - 1600), dd)) $asctime($calc($1 - 1600), mmm)
    downloadSitePrices
  }
}
