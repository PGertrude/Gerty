on $*:TEXT:/^[!@.](shop|store) */Si:#: {
  var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  if (!$2) { %saystyle Syntax Error: !shop <item> }
  hadd -m $+(a,%thread) item $replace($2-,$chr(32),+)
  hadd -m $+(a,%thread) out %saystyle
  sockopen $+(shop.a,%thread) www.tip.it 80
}
on $*:TEXT:/^[!@.](shop|store) */Si:?: {
  var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = .msg $nick
  if (!$2) { %saystyle Syntax Error: !shop <item> }
  hadd -m $+(a,%thread) item $replace($2-,$chr(32),+)
  hadd -m $+(a,%thread) out %saystyle
  sockopen $+(shop.a,%thread) www.tip.it 80
}
on *:sockopen:shop.*: {
  .sockwrite -n $sockname GET /runescape/index.php?rs2shops=&Search=1&keywords= $+ $hget($gettok($sockname,2,46),item) $+ &Players=all&submit=Simple+Search HTTP/1.1
  .sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; gerty.x10hosting.com;)
  .sockwrite -n $sockname HOST: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:shop.*: {
  var %table = $gettok($sockname,2,46)
  if ($sockerr) {
    $hget(%table,out) [Socket Error] $sockname $time $script
    halt
  }
  var %shop
  .sockread %shop
  if ($regex(%shop,/(\d+) shops displayed/)) { hadd -m %table number $regml(1) }
  if (%x == 1 && $regex(%shop,/<td>([^<]+)<\/td>/)) {
    hadd -m %table shops $hget(%table,shops) (07 $+ $regml(1) $+ );
    unset %x
  }
  if ($regex(%shop,/<td><a href="\?rs2shops_id=\d+">([^<]+)<\/a><\/td>/)) {
    hadd -m %table shops $hget(%table,shops) $regml(1)
    %x = 1
  }
  if (<!-- Page Content End --> isin %shop) {
    if (!$hget(%table,shops)) {
      $hget(%table,out) 12www.tip.it found07 $hget(%table,number) shops selling "07 $+ $caps($replace($hget(%table,item),+,$chr(32))) $+ "
      goto unset
    }
    $hget(%table,out) 12www.tip.it found07 $hget(%table,number) shops selling "07 $+ $caps($replace($hget(%table,item),+,$chr(32))) $+ ": $hget(%table,shops)
    :unset
    sockclose $sockname
    hfree %table
    unset %*
    halt
  }
}
