on $*:TEXT:/^[!@.](npc|monster|mdb(info)?|drops?|loot) */Si:*: {
  var %saystyle = $saystyle($left($1,1),$nick,$chan),%command
  if (!$2) { %saystyle you must specify a monster to look up. }
  if ($regex($right($1,-1),/(drops?|loot)/i)) %command = drop
  else %command = npc
  var %thread = $+($a,r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  if ($left($2,1) != $chr(35) && $2 !isnum) {
    hadd -m %thread npc $replace($2-,$chr(32),+)
    hadd -m %thread out %saystyle
    hadd -m %thread command %command
    sockopen $+(drop.,%thread) www.zybez.net 80
  }
  if ($left($2,1) == $chr(35) || $2 isnum) {
    hadd -m %thread id $remove($2,$chr(35))
    hadd -m %thread out %saystyle
    hadd -m %thread command %command
    sockopen $+(drop2.,%thread) www.zybez.net 80
  }
}
on *:sockopen:drop.*: {
  .sockwrite -n $sockname GET /monsters.php?search_area=name&search_term= $+ $hget($gettok($sockname,2,46),npc) HTTP/1.0
  .sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; www.gerty.x10hosting.com;)
  .sockwrite -n $sockname host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:drop.*: {
  var %table = $gettok($sockname,2,46)
  if ($sockerr) {
    write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) $+ $(],)
    echo -at Socket Error: $nopath($script)
    halt
  }
  var %drop
  .sockread %drop
  if (Location: isin %drop) {
    hadd -m %table page $gettok(%drop,2-,32)
    sockopen $+(drop2.,%table) www.zybez.net 80
    .sockclose $sockname
    unset %*
    halt
  }
  if ($regex(total,%drop,/>Browsing ([0-9\x2c]+) of/i)) { hadd -m %table total $regml(total,1) }
  if ($regex(monster,%drop,/(?:^<td class="tablebottom">.+?<\/td><td class="tablebottom">(\d+|N\/A)<\/td>.+?|())(?:<a href="\/monsters\.php\?id=(\d+)&amp;runescape_\w+\.htm">(.+)<\/a>|()<\/table>)/)) {
    if ($regml(monster,3) || $regml(monster,1)) { hadd -m %table npclist $replace($hget(%table,npclist),#{},$regml(monster,1)) $caps($regml(monster,3)) $+ (#{}) 07 $+ $chr(35) $+ $regml(monster,2) $+ ; }
  }
  if ($replace($nohtml(%drop),$chr(32),_) == Content_Copyright_Notice:) {
    $hget(%table,out) 12www.zybez.net found07 $hget(%table,total) results: $remove($hget(%table,npclist), (#{}) 07#;)
    :unset
    .sockclose $sockname
    .hfree %table
    unset %*
    halt
  }
}
on *:sockopen:drop2.*: {
  if ($hget($gettok($sockname,2,46),id)) {
    var %url = $v1
  }
  else {
    var %url = $regsubex($hget($gettok($sockname,2,46),page),/^.+id=(\d+).+$/,\1)
  }
  .sockwrite -n $sockname GET /monsters.php?id= $+ %url HTTP/1.0
  .sockwrite -n $sockname User-Agent: Gerty (Crawler Bot; www.gerty.x10hosting.com;)
  .sockwrite -n $sockname host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:drop2.*: {
  var %table = $gettok($sockname,2,46)
  if ($sockerr) {
    write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) $+ $(],)
    echo -at Socket Error: $nopath($script)
    halt
  }
  while ($sock($sockname).rq) {
    sockread &drop
    bwrite %table -1 -1 &drop
  }
  bread %table 0 $file(%table).size &drop2
  if ($bfind(&drop2,0,</body)) {
    if ($bfind(&drop2,0,Error: Invalid Monster ID.)) {
      $hget($gettok($sockname,2,46),out) Sorry 12www.zybez.net has no result for Monster ID07 $hget($gettok($sockname,2,46),id)
      goto unset
    }
    var %start = $bfind(&drop2,0,<center>), %a = $bfind(&drop2,%start,Where Found:), %cutA = $bfind(&drop2,%a,</tr)
    var %stringA = $bvar(&drop2,%start,$calc(%cutA - %start)).text
    var %cutB = $calc($bfind(&drop2,%cutA,Top Drops:)+10), %cutC = $bfind(&drop2,%cutB,</tr>)
    var %stringB = $bvar(&drop2,%cutB,$calc(%cutC - %cutB)).text
    if ($regex(info,%stringA,/">([^<]+)<\/td><\/tr><tr><td[^>]+><img[^>]+><\/td><\/tr>(?:<tr><td[^>]+>Combat:<\/td><td[^>]+>(\d+)<\/td><\/tr>|())(?:<tr><td>Hitpoints:<\/td><td>(\d+)<\/td><\/tr>|())(?:<tr><td>Max Hit:<\/td><td>(\d+)<\/td><\/tr>|())(?:<tr><td>Race:<\/td><td>([a-z_ ]+)<\/td><\/tr>|())(?:<tr><td>Members:<\/td><td>(\w+)<\/td><\/tr>|())(?:<tr><td>Quest:<\/td><td>(:?(\w+)|<a[^>]+>([^<]+)<\/a>)<\/td><\/tr>|())(?:<tr><td>Nature:<\/td><td>([a-z_ ]+)<\/td><\/tr>|())(?:<tr><td>Attack Style:<\/td><td>(\w+)<\/td><\/tr>|())(?:<tr><td>Examine:<\/td><td>([^<]+)<\/td><\/tr>|())<\/table>.+?>(?:Where Found:<\/td><td>([^<]+)<\/td|())>/i)) {
      $hget($gettok($sockname,2,46),out)  $+ $caps($regml(info,1)) $+ (07 $+ $iif($regml(info,2),$v1,N/A) $+ ) | hitpoints:07 $iif($regml(info,3),$v1,N/A) | max hit:07 $iif($regml(4),$v1,N/A) | race:07 $iif($regml(info,5),$v1,N/A) | examine:07 $iif($regml(info,11),$v1,N/A) 12www.zybez.net
      if ($hget($gettok($sockname,2,46),command) == npc) {
        $hget($gettok($sockname,2,46),out) Nature:07 $iif($regml(info,9),$v1,N/A) | Quest:07 $iif($yesno($regml(info,8)),$v1,07N/A) | Members: $iif($yesno($regml(info,6)),$v1,07N/A) | Attack Style:07 $iif($regml(info,10),$v1,N/A) | Habitat:07 $iif($regml(info,12),$v1,N/A)
        goto unset
      }
    }
    if ($hget($gettok($sockname,2,46),command) == drop) {
      if ($gettok(%stringB,1,32) == 200) {
        $hget($gettok($sockname,2,46),out) No drop list for this npc found on 12www.zybez.net
        goto unset
      }
      $hget($gettok($sockname,2,46),out) Top Drops: $nohtml(%stringB)
    }
    :unset
    .sockclose $sockname
    .hfree %table
    .remove %table
    unset %*
    halt
  }
}
