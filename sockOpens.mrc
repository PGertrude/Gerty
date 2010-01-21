on *:sockopen:*: {
  var %thread = $gettok($sockname,2,46)
  if ($sockerr) {
    _throw $sockname %thread
    halt
  }
  if (alog.* iswm $sockname) {
    sockwrite -n $sockname GET /m=adventurers-log/rssfeed?searchName= $+ $hget(%thread,rsn) HTTP/1.1
    sockwrite -n $sockname Host: services.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (alog-r.* iswm $sockname) {
    sockwrite -nt $sockname GET /parser/alog.php?rsn= $+ $hget($gettok($sockname,2,46),rsn) HTTP/1.1
    sockwrite -nt $sockname Host: SSElessar.net $+ $crlf $+ $crlf
  }
  else if (circus.* iswm $sockname) {
    sockwrite -n $sockname GET /wiki/Balthazar_Beauregard's_Big_Top_Bonanza HTTP/1.1
    sockwrite -n $sockname Host: runescape.wikia.com
    sockwrite -n $sockname $crlf
  }
  else if (compare.* iswm $sockname) {
    sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget(%thread,nick) HTTP/1.1
    sockwrite -n $sockname Host: hiscore.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (rsccomp.* iswm $sockname) {
    .tokenize 32 $timeToday
    var %today = $1, %week = $2, %month = $3, %year = $4
    sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $cmd(%thread,nick) $+ &skill= $+ $calc($statnum($hget(%thread,skill)) -1) $+ &time= $+ $(% $+ $hget(%thread,time),2) HTTP/1.1
    sockwrite -n $sockname Host: www.rscript.org
    sockwrite -n $sockname $crlf
  }
  else if (cost.* iswm $sockname) {
    sockwrite -nt $sockname GET /viewitem.ws?obj= $+ $gettok($sockname,3,46) HTTP/1.1
    sockwrite -nt $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (draynor.* iswm $sockname) {
    var %string = username= $+ %thread $+ &user_submit=Update%20Signatures!
    sockwrite -n $sockname POST /signature_updater.php HTTP/1.1
    sockwrite -n $sockname Host: www.draynor.net
    sockwrite -n $sockname Content-Length: $len(%string)
    sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
    sockwrite -n $sockname $crlf %string
  }
  else if (drop.* iswm $sockname) {
    sockwrite -n $sockname GET /monsters.php?search_area=name&search_term= $+ $hget(%thread,npc) HTTP/1.0
    sockwrite -n $sockname host: www.zybez.net
    sockwrite -n $sockname $crlf
  }
  else if (drop2.* iswm $sockname) {
    var %url
    if ($hget(%thread,id)) %url = $v1
    else %url = $regsubex($hget(%thread,page),/^.+id=(\d+).+$/,\1)
    sockwrite -n $sockname GET /monsters.php?id= $+ %url HTTP/1.0
    sockwrite -n $sockname host: www.zybez.net
    sockwrite -n $sockname $crlf
  }
  else if (fml.* iswm $sockname) {
    sockwrite -n $sockname GET $hget(%thread,page) HTTP/1.1
    sockwrite -n $sockname Host: www.fmylife.com
    sockwrite -n $sockname $crlf
  }
  else if (geinfo.* iswm $sockname) {
    sockwrite -n $sockname GET /results.ws?query= $+ $hget(%thread,search) $+ &price=all&members= HTTP/1.0
    sockwrite -n $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (geinfo2.* iswm $sockname) {
    sockwrite -n $sockname GET /viewitem.ws?obj= $+ $hget(%thread,id) HTTP/1.0
    sockwrite -n $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (gelink.* iswm $sockname) {
    sockwrite -n $sockname GET /results.ws?query= $+ $cmd(%thread,arg2) $+ &price=all&members= HTTP/1.1
    sockwrite -n $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (CheckGePrices.* iswm $sockname) {
    var %page = $iif(%thread == front,/frontpage.ws,/results.ws?query=zamorak&price=all)
    %thread = ge
    sockwrite -n $sockname GET %page HTTP/1.1
    sockwrite -n $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (google.* iswm $sockname) {
    sockwrite -n $sockname GET /ajax/services/search/ $+ $hget(%thread,page) $+ ?v=1.0&q= $+ $hget(%thread,search) HTTP/1.1
    sockwrite -n $sockname Referer: http://gerty.rsportugal.org/
    sockwrite -n $sockname User-Agent: curl/7.18.2 (i486-pc-linux-gnu) libcurl/7.18.2 OpenSSL/0.9.8g zlibidn/1.8
    sockwrite -n $sockname Host: ajax.googleapis.com
    sockwrite -n $sockname Accept: */*
    sockwrite -n $sockname $crlf
  }
  else if (ml.* iswm $sockname) {
    sockwrite -n $sockname GET /feeds/lowtech/searchclan.php?search= $+ $hget(%thread,ml) $+ &type=2 HTTP/1.0
    sockwrite -n $sockname Host: www6.runehead.com
    sockwrite -n $sockname $crlf
  }
  else if (pastebin.* iswm $sockname) {
    var %hash = $gettok($sockname,2-,46)
    var %string = format=text&poster=Gerty&expiry=m&paste=Send&code2=
    var %length = $calc($len(%string) + |)
    bread %hash 0 $file(%hash) &pastebin
    var %h = 1
    while ($bvar(&pastebin,$calc(((%h - 1) * 2000) + 1)) && %h <= $ceil($calc($bvar(&pastebin,0) / 2000))) {
      var % $+ [ post $+ [ %h ] ] $escapeurl($bvar(&pastebin,$calc(((%h - 1) * 2000) +1 ),2000).text)
      var %length = $calc(%length + $len($(% $+ post $+ %h,2)) + 2)
      inc %h
    }
    sockwrite -n $sockname POST /pastebin.php HTTP/1.1
    sockwrite -n $sockname Host: pastebin.com
    sockwrite -n $sockname Content-Length: %length
    sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
    sockwrite -n $sockname $crlf %string
    var %i = 1
    while ($(% $+ post $+ %i,2)) {
      sockwrite -n $sockname $(% $+ post $+ %i,2)
      inc %i
    }
  }
  else if (qfc.* iswm $sockname) {
    hadd -m %thread count 1
    sockwrite -n $sockname GET /forums.ws? $+ $replace(%thread,qfc),-,$chr(44)) HTTP/1.1
    sockwrite -n $sockname Host: forum.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (rs2quest.* iswm $sockname) {
    sockwrite -n $sockname GET /runescape/index.php?rs2quest&keywords= $+ $iif($cmd(%thread,switch),$cmd(%thread,search)) HTTP/1.0
    sockwrite -n $sockname Host: www.tip.it
    sockwrite -n $sockname $crlf
  }
  else if (rs2questinfo.* iswm $sockname) {
    sockwrite -n $sockname GET /runescape/index.php?rs2quest_id= $+ $hget(%thread,id) HTTP/1.0
    sockwrite -n $sockname Host: www.tip.it
    sockwrite -n $sockname $crlf
  }
  else if (rank.* iswm $sockname) {
    var %skill = $cmd(%thread,arg1), %rank = $cmd(%thread,arg2)
    sockwrite -n $sockname GET /overall.ws?category_type= $+ $catno(%skill) $+ &table= $+ $calc($statnum(%skill) -1) $+ &rank= $+ %rank
    sockwrite -n $sockname Host: hiscore.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (runehcalc.* iswm $sockname) {
    sockwrite -n $sockname GET /clans/ml.php?clan= $+ $hget(%thread,clan) HTTP/1.1
    sockwrite -n $sockname Host: www5.runehead.com $+ $crlf $+ $crlf
  }  
  else if (runeprice.rune1 == $sockname) {
    sockwrite -nt $sockname GET /results.ws?query="+Rune"&price=0-500&members= HTTP/1.1
    sockwrite -nt $sockname Host: itemdb-rs.runescape.com
    sockwrite -nt $sockname $crlf
  }
  else if (runeprice.rune2 == $sockname) {
    sockwrite -nt $sockname GET /results.ws?query="%20rune"&sup=All&cat=All&sub=All&page=2&vis=1&order=1&sortby=name&price=0-500&members= HTTP/1.1
    sockwrite -nt $sockname Host: itemdb-rs.runescape.com
    sockwrite -nt $sockname $crlf
  }
  else if (shop.* iswm $sockname) {
    sockwrite -n $sockname GET /runescape/index.php?rs2shops=&Search=1&keywords= $+ $hget($gettok($sockname,2,46),item) $+ &Players=all&submit=Simple+Search HTTP/1.1
    sockwrite -n $sockname HOST: www.tip.it
    sockwrite -n $sockname $crlf
  }
  else if (skillplan.* iswm $sockname) {
    sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget(%thread,nick) HTTP/1.1
    sockwrite -n $sockname Host: hiscore.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (top.* iswm $sockname) {
    sockwrite -n $sockname GET /overall.ws?category_type= $+ $catno($hget(%thread,skill)) $+ &table= $+ $smartno($hget(%thread,skill)) $+ &user= $+ $hget(%thread,nick) $+ &rank= $+ $hget(%thread,rank) HTTP/1.1
    sockwrite -n $sockname Host: hiscore.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (trackyes.* iswm $sockname) {
    sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $hget(%thread,nick) $+ &skill=all&time= $+ $hget(%thread,time) $+ , $+ $hget(%thread,time2)
    sockwrite -n $sockname Host: www.rscript.org
    sockwrite -n $sockname $crlf
  }
  else if (potion.* iswm $sockname) {
    sockwrite -nt $sockname GET /viewitem.ws?obj= $+ $gettok($sockname,3,46) HTTP/1.1
    sockwrite -nt $sockname Host: itemdb-rs.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (world.* iswm $sockname) {
    sockwrite -n $sockname GET $cmd(%thread,arg1) $+ /slu.ws?lores.x=0&plugin=0&order=WMLPA
    sockwrite -n $sockname Host: www.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (world2.* iswm $sockname) {
    sockwrite -n $sockname GET /title.ws
    sockwrite -n $sockname Host: www.runescape.com
    sockwrite -n $sockname $crlf
  }
  else if (zybez.* iswm $sockname) {
    sockwrite -n $sockname GET /items.php?search_area=name&search_term= $+ $hget(%thread,search) HTTP/1.0
    sockwrite -n $sockname Host: www.zybez.net
    sockwrite -n $sockname $crlf
  }
  else if (zybez2.* iswm $sockname) {
    sockwrite -n $sockname GET /items.php?id= $+ $hget(%thread,id) HTTP/1.0
    sockwrite -n $sockname Host: www.zybez.net
    sockwrite -n $sockname $crlf
  }





  return
  :error
  reseterror
  _throw $sockname %thread
}
