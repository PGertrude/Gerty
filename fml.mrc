>start<|fml.mrc|fuck my life|1.05|rs
on *:sockopen:fml.*: {
  sockwrite -n $sockname GET $hget($gettok($sockname,2,46),page) HTTP/1.1
  sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; gerty.x10hosting.com;)
  sockwrite -n $sockname referer: http://www.gerty.x10hosting.com
  sockwrite -n $sockname Host: www.fmylife.com
  sockwrite -n $sockname Accept: */*
  sockwrite -n $sockname $crlf
}
on *:sockread:fml.*: {
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) $timestamp Connection Error: $script
    halt
  }
  .sockread %fml
  if ($regex(%fml,/<div class="post"><p>(.+?)<\/p><[^>]+><a[^>]+>(.+?)<\/a>/)) {
    $hget($gettok($sockname,2,46),out) 07FML $regml(2) $+ : $nohtml($left($regml(1),-3))
    hfree $gettok($sockname,2,46)
    sockclose $sockname
    unset %*
    halt
  }
}
