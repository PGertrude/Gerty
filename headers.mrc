on $*:TEXT:/^[!@.]headers?/Si:*: {
  var %saystyle = $saystyle($left($1,1),$nick,$chan), %thread a $+ $ticks, %site, %page
  noop $regex($2,/(?:http:\/\/)?((?:.+?)\.(?:.+?))\/((?:.+?)*)/i)
  %site = $regml(1)
  %page = / $+ $regml(2)
  hadd -m %thread page %page
  if ($3) { hadd -m %thread http $3 }
  hadd -m %thread site %site
  hadd -m %thread out %saystyle
  if (!%site) { %saystyle Invalid url. (make sure you include the / on sites even if you don't specify a page.) | halt }
  %saystyle Host: %site
  %saystyle Page: %page
  sockopen $+(header.,%thread) %site 80
}
on *:sockopen:header.*: {
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) Site is down/Invalid URL
    halt
  }
  sockwrite -n $sockname GET $hget($gettok($sockname,2,46),page) $iif($hget($gettok($sockname,2,46),http),$v1,HTTP/1.1)
  sockwrite -n $sockname Host: $hget($gettok($sockname,2,46),site)
  sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; http://www.gerty.x10hosting.com;)
  sockwrite -n $sockname Accept: */*
  sockwrite -n $sockname $crlf
}
on *:sockread:header.*: {
  sockread %header
  if (!%header) {
    hfree $gettok($sockname,2,46)
    sockclose $sockname
    halt
  }
  $hget($gettok($sockname,2,46),out) %header
}
