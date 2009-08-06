>start<|geinfo.mrc|cleaned|1.3|rs
on $*:TEXT:/^[!@.]g(reat|rand)?e(xchange)?(info)/Si:*: {
  _CheckMain
  ; normal stuff.
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if (!$2) { %saystyle Syntax: !geinfo <item> | halt }
  hadd -m %thread out %saystyle
  ; check for id request
  var %id = $litecalc($remove($2-,$chr(35)))
  ; if ID specified, skip to items' page 'geinfo2' socket
  if (%id > 0) {
    var %id = $regsubex($2-,/(\D+)/g,$null)
    hadd -m %thread id %id
    sockopen $+(geinfo2.,%thread) itemdb-rs.runescape.com 80
  }
  ; if an item is specified, normal lookup method using runescape.com search 'geinfo' socket
  else {
    hadd -m %thread search " $+ $replace($2-,$chr(32),+) $+ "
    sockopen $+(geinfo.,%thread) itemdb-rs.runescape.com 80
  }
}
on *:sockopen:geinfo.*: {
  sockwrite -n $sockname GET /results.ws?query= $+ $hget($gettok($sockname,2,46),search) $+ &price=all&members= HTTP/1.0
  sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; gerty.x10hosting.com;)
  sockwrite -n $sockname Referer: http://www.gerty.x10hosting.com/index.php
  sockwrite -n $sockname Host: itemdb-rs.runescape.com
  sockwrite -n $sockname Accept: */*
  sockwrite -n $sockname $crlf
}
on *:sockread:geinfo.*: {
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
    ; while bytes to receive, write the html to a file, ready to be loaded into a bvar
    while ($sock($sockname).rq) {
      sockread &item
      bwrite %file -1 -1 &item
    }
    ; buffer empty, so load bvar
    bread %file 0 $file(%file).size &item2
    ; check the whole site is loaded into bvar
    if ($bfind(&item2,0,</HTML>)) {
      ; read the matches found line '68 items matched the search term: '<i>cape</i>'.<br>'
      var %matchA = $calc($bfind(&item2,0,items matched the search term:)-10)
      var %matchB = $calc($bfind(&item2,%matchA,items matched the search term:)+40)
      ; extract matches from line (strip all non digits)
      var %matches = $regsubex($bvar(&item2,%matchA,$calc(%matchB - %matchA)).text,/\D/g,$null)
      ; start searching for matches
      var %start = $bfind(&item2,0,>Item<)
      ; if 'obj=' can be found further in the bvar, loop
      while ($bfind(&item2,%start,item.ws?obj=)) {
        ; sort name(c-d) and id(a-b) from the html
        var %a = $calc($bfind(&item2,%start,item.ws?obj=)+12), %b = $bfind(&item2,%a,"), %c = $calc($bfind(&item2,%b,>)+1), %d = $bfind(&item2,%c,<)
        ; apend item to output
        var %e = %e | $bvar(&item2,%c,$calc(%d - %c)).text 07 $+ $chr(35) $+ $bvar(&item2,%a,$calc(%b - %a)).text
        ; move pointer along bvar. (New %start is %d.)
        var %start = %d
      }
      ; cut down output to 7 items
      var %e = $gettok(%e,1-8,124)
      ; if matches is one, go straight to the items information page
      if (%matches == 1) {
        hadd -m %thread id $gettok(%e,2,35)
        sockopen $+(geinfo2.,%thread) itemdb-rs.runescape.com 80
      }
      ; otherwise output a list of the items found's ID
      else {
        $hget(%thread,out) Matches found:07 %matches %e
        .hfree %thread
      }
      ; cleanup
      .remove %file
      sockclose $sockname
      unset %*
      halt
    }
  }
}
on *:sockopen:geinfo2.*: {
  sockwrite -n $sockname GET /viewitem.ws?obj= $+ $hget($gettok($sockname,2,46),id) HTTP/1.0
  sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; gerty.x10hosting.com;)
  sockwrite -n $sockname Referer: http://www.gerty.x10hosting.com/index.php
  sockwrite -n $sockname Host: itemdb-rs.runescape.com
  sockwrite -n $sockname Accept: */*
  sockwrite -n $sockname $crlf
}
on *:sockread:geinfo2.*: {
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
    ; same as above
    while ($sock($sockname).rq) {
      sockread &item3
      bwrite %file -1 -1 &item3
    }
    bread %file 0 $file(%file).size &item4
    ; same again...
    if ($bfind(&item4,0,</HTML>)) {
      ; cut out the chunk that we want, ie the 'item_additional' div
      var %start = $bfind(&item4,0,id="item_image"), %end = $bfind(&item4,%start,</div>)
      var %string = $bvar(&item4,%start,$calc(%end - %start)).text
      ; check the chunk is present
      if ($len(%string) > 10) {
        ; extract item name, prices, price tracking
        noop $regex(%string,/id=\d+\" alt=\"(.+?)\">\n.+?\n<br>\n<br>\n<b>Current market price range:<\/b><br>\n<span>\n<b>Minimum price:<\/b> ([^\n]+)\n<\/span>\n<span class=\"spaced_span\">\n<b>Market price:<\/b> ([^\n]+)\n<\/span>\n<span>\n<b>Maximum price:<\/b> ([^\n]+)\n</span>\n<br><br>\n<b>Change in price:<\/b><br>\n<span>\n<b>30 Days:<\/b> <span class="[^"]+">(.+?)%<\/span>\n<\/span>\n<span class="spaced_span">\n<b>90 Days:<\/b> <span class="[^"]+">(.+?)%<\/span>\n<\/span>\n<span class="spaced-span">\n<b>180 Days:<\/b> <span class="[^"]+">(.+?)%<\/span>\n/i)
        var %item = $regml(1), %min = $regml(2), %avg = $regml(3), %max = $regml(4), %7day = $regml(5), %30day = $regml(6), %90day = $regml(7), %180day = $regml(8)
        ; output
        $hget(%thread,out)  $+ %item $+  | Min:07 %min Avg:07 %avg Max:07 %max | 30 Days:07 $updo(%7day) | 90 Days:07 $updo(%30day) | 180 Days:07 $updo(%90day) | 12http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $hget($gettok($sockname,2,46),id)
      }
      ; if no chunk then item doesn't exist or some other fuck up.
      else {
        $hget(%thread,out) No item found for ID07 $hget(%thread,id) $+ .
      }
      ; cleanup
      .remove %file
      .hfree $gettok($sockname,2,46)
      sockclose $sockname
      unset %*
      halt
    }
  }
}
; turns a number green if positive, red if negative, or orange if It's 0, and appends a %
alias -l updo {
  var %price = $litecalc($1)
  if (%price > 0) { return 03 $+ $1 $+ $chr(37) }
  if (%price < 0) { return 04 $+ $1 $+ $chr(37) }
  return 07 $+ $1 $+ $chr(37)
}
