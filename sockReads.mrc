>start<|sockreads.mrc|compiled sockreads|3.25|rs
on *:sockread:*: {
  var %thread = $gettok($sockname,2,46)
  var %file = %thread $+ .txt
  if ($sockerr) {
    _throw $sockname %thread
    halt
  }
  ; COST
  if (cost.* iswm $sockname) {
    var %sockcost
    sockread %sockcost
    if ($regex(cost,%sockcost,/^<\w>Market Price:<\/\w> ([\d\Wmk]+)/Si)) {
      hadd -m cost $gettok($sockname,3,46) $litecalc($remove($regml(cost,1),$chr(44)))
      cost $+ $gettok($hget($gettok($sockname,2,46),cost),1,9) $remove($gettok($sockname,2,46),a)
      unset %*
      sockclose $sockname
    }
  }
  ; RUNEPRICE
  else if (runeprice.* iswm $sockname) {
    var %rune
    sockread %rune
    if ($regex(rune,%rune,/^<\w+><.+?> (\w+) rune<\/\w><\/\w+>$/i)) { hadd -m temp rune $regml(rune,1) }
    if ($regex(price,%rune,/^<\w+>(\d+)<\/\w+>$/i) && $hget(temp,rune)) { hadd -m runeprice $hget(temp,rune) $+ _Rune $regml(price,1) | hfree temp }
  }
  ; POTION
  else if (potion.* iswm $sockname) {
    var %pots
    sockread %pots
    if ($regex(pots,%pots,/^<\w>Market Price:<\/\w> ([\d\W]+)/Si)) {
      hadd -m potprice p $+ $gettok($sockname,3,46) $remove($regml(pots,1),$chr(44))
      potsay $hget($gettok($sockname,2-,46),out)
      goto unset
    }
  }
  ; PASTEBIN
  else if (pastebin.* iswm $sockname) {
    var %test
    sockread %test
    if (Location: isin %test && $hget(%thread)) {
      $hget(%thread,out) $gettok(%test,2,32)
      goto unset
    }
  }
  ; FML
  else if (fml.* iswm $sockname) {
    var %fml
    sockread %fml
    if ($regex(%fml,/<div class="post"><p>(.+?)<\/p><[^>]+><div[^>]*><a[^>]+>(.+?)<\/a>/)) {
      $hget(%thread,out) 07FML $regml(2) $+ : $nohtml($left($regml(1),-3))
      goto unset
    }
  }
  ; GOOGLE
  else if (google.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &google
      bwrite %file -1 -1 &google
    }
    bread %file 0 $file(%file).size &google2
    if ($bfind(&google2,0,"responseStatus")) {
      var %a = $bfind(&google2,0,$chr(123)), %b = $bfind(&google2,%a,"responseStatus")
      var %string = $bvar(&google2,%a,4000).text
      noop $regex(%string,/"url":"(.+?)"/)
      var %url = $regml(1)
      noop $regex(%string,/"titleNoFormatting":"(.+?)"/)
      var %title = $regml(1)
      noop $regex(%string,/"content":"(.+?)"/)
      var %content = $regml(1)
      var %content = $nohtml($regsubex(%content,/\\u(.{4})/g,$chr($base(\1,16,10))))
      var %title = $nohtml($regsubex(%title,/\\u(.{4})/g,$chr($base(\1,16,10))))
      var %url = $nohtml($regsubex(%url,/(?:\\u(.{4})|%(.{2}))/g,$chr($base(\1,16,10))))
      if (%url) {
        if ($hget(%thread,page) == video) { %url = $regsubex(%url,/^.+?q=(.+?)&(.+?)$/,\1) }
        $hget(%thread,out) Google $caps($hget(%thread,page)) Search " $+ $replace($hget(%thread,search),+,$chr(32)) $+ ":07 %title url:12 %url content:07 %content
      }
      else { $hget(%thread,out) No search results for $+(",$replace($hget(%thread,search),+,$chr(32)),".) }
      if ($hget(%thread,page) == video) {
        var %id = $regex(%url,/\?v=(.+?)(&|$)/)
        var %id = $regml(1)
        if (%id) {
          var %url = http://rscript.org/lookup.php?type=youtubeinfo&id= $+ %id
          noop $download.break(youtube %thread %id,%thread,%url)
        }
        else {
          .hfree %thread
        }
      }
      else {
        .hfree %thread
      }
      .remove %file
      sockclose $sockname
      unset %*
      halt
    }
  }
  ; QFC
  else if (qfc.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &qfc
      bwrite %file -1 -1 &qfc
    }
    bread %file 0 $file(%file).size &qfc2
    if ($bfind(&qfc2,0,</body)) {
      var %start = $bfind(&qfc2,0,backtoforum.gif), %cutA = $bfind(&qfc2,%start,</li>)
      var %strForum = $bvar(&qfc2,%start,$calc(%cutA - %start)).text
      noop $regex(%strForum,/up to (.+?)</i)
      %strForum = $regml(1)
      if (!%strForum) { goto error }
      var %start = $bfind(&qfc2,0,class="title thrd"), %cutB = $bfind(&qfc2,%start,</div)
      var %strTitle = $bvar(&qfc2,%start,$calc(%cutB - %start)).text
      %strTitle = $remove($nohtml(%strTitle),$chr(10))
      var %start = $bfind(&qfc2,%cutB,class="msgcreator), %cutC = $bfind(&qfc2,%start,</div>)
      var %strPoster = $bvar(&qfc2,%start,$calc(%cutC - %start)).text
      %strPoster = $remove($nohtml(%strPoster),$chr(10))
      var %start = $bfind(&qfc2,%cutC,class="msgtime"), %cutD = $bfind(&qfc2,%start,</div>)
      var %strTime = $bvar(&qfc2,%start,$calc(%cutD - %start)).text
      %strTime = $remove($nohtml(%strTime),$chr(10))
      var %start = $bfind(&qfc2,%cutD,class="msgcontents"), %cutE = $bfind(&qfc2,%start,</div>)
      var %strContent = $bvar(&qfc2,%start,$calc(%cutE - %start)).text
      %strContent = $remove($nohtml(%strContent),$chr(10))
      if ($hget(%thread,link)) $hget(%thread,out) $formatwith(\c12\uhttp://forum.runescape.com/forums.ws?{0}\o $| Forum:\c07 %strForum \o| By:\c07 %strPoster \o| Title:\c07 %strTitle \o| Posted at:\c07 %strTime, $replace($hget(%thread,qfc),-,$chr(44)))
      else $hget(%thread,out) $formatwith(Forum:\c07 %strForum \o| By:\c07 %strPoster \o| Title:\c07 %strTitle \o| Posted at:\c07 %strTime, $replace($hget(%thread,qfc),-,$chr(44)))
      $hget(%thread,out) $formatwith(\uThread Content:\u) $mid(%strContent,1,150) $+ $iif($len(%strContent) > 150,...)
      goto unset
    }
  }
  ; QUESTS
  else if (rs2quest.* iswm $sockname) {
    var %quest
    sockread %quest
    if ($hget(%thread,switch)) {
      if (rs2quest_id= isin %quest) {
        var %regex = $regex(%quest,/rs2quest_id=(\d+)/)
        %output = %output 07# $+ $regml(1) $+  $nohtml(%quest) $+ ;
      }
    }
    else {
      if ($regex(quest,%quest,/<.+?quest_id=(\d+)">(.+?)</i)) {
        if ($+(*,$hget(%thread,search),*) iswm $regml(quest,2)) {
          set %output %output $+(07,$chr(35),$regml(quest,1), $regml(quest,2),;)
        }
      }
    }
    if (Save Done isin %quest) {
      if ($count(%output,$chr(35)) < 1) {
        $hget($gettok($sockname,2,46),out) No results for "07 $+ $replace($hget($gettok($sockname,2,46),search),+,$chr(32)) $+ ". Visit12 http://www.tip.it/runescape/?rs2quest
        goto unset
      }
      else if ($count(%output,$chr(35)) == 1) {
        hadd -m $gettok($sockname,2,46) id $regsubex(%output,/#(\d+)\D.+?$/S,\1)
        sockopen $+(rs2questinfo.,$gettok($sockname,2,46)) www.tip.it 80
        unset %*
        sockclose $sockname
        halt
      }
      else {
        $hget($gettok($sockname,2,46),out) Quests found for "07 $+ $replace($hget($gettok($sockname,2,46),search),+,$chr(32)) $+ ": %output
        goto unset
      }
    }
  }
  else if (rs2questinfo.* iswm $sockname) {
    var %quest
    .sockread %quest
    if ($regex(%quest,/\s*<td colspan="\d+" class="databasebig">(.+?)<\/td>/)) {
      hadd -m %thread title $trim($regml(1))
    }
    if (<b>Reward:</b> isin %quest) hadd -m %thread store 1
    if ($cmd(%thread,store) == 1) {
      hadd -m %thread reward $cmd(%thread,reward) $nohtml(%quest) $+ ;
      if (Quest points gained upon completion isin %quest) {
        %store = 0
        $hget(%thread,out) $cmd(%thread,title) 12http://tip.it/runescape/index.php?rs2quest_id= $+ $hget(%thread,id)
        var %qp
        $hget(%thread,out) $regsubex($replace($cmd(%thread,reward),:;,:,.;,;),/(Reward:) (.+?) Quest points gained upon completion: (\d+)(.+?)$/i,\1 \2 QP: $+(07,\3,))
        goto unset
      }
    }
  }
  ; RANK
  else if (Rank.* iswm $sockname) {
    var %skill = $cmd(%thread,arg1), %rank = $cmd(%thread,arg2)
    var %read
    sockread %read
    if (*#F3C334* iswm %read) {
      var %nick $nohtml(%read)
      sockread %read
      var %level $nohtml(%read)
      sockread %read
      var %exp $remove($nohtml(%read),$chr(44))
      if ($minigames(%skill)) {
        $hget(%thread,out)  $+ %nick $+ 07 %skill | Rank:07 $bytes(%rank,db) | Score:07 %level
        rscript.singleminigame $sockname $replace(%nick,$chr(32),_) $replace(%skill,$chr(32),_) $hget(%thread,out)
      }
      else {
        $hget(%thread,out)  $+ %nick 07 $+ %skill | Rank:07 $bytes(%rank,db) | Lvl:07 %level $iif(%skill != overall,(07 $+ $virtual(%exp) $+ )) | Exp:07 $bytes(%exp,db) $&
          $iif(%skill != overall,(07 $+ $round($calc(100 * %exp / 13034431 ),1) $+ 07% of 99) | Exp till $calc($virtual(%exp) +1) $+ :07 $bytes($calc($lvltoxp($calc($virtual(%exp) +1)) - %exp),db)))
        rscript.singleskill $sockname $replace(%nick,$chr(32),_) %skill $hget(%thread,out)
        sockclose $sockname
      }
    }
    if (</tbody> isin %read) {
      $hget(%thread,out) Hiscores does not contain an entry for rank $format_number($hget(%thread,rank)) $hget(%thread,skill) $+ .
      goto unset
    }
  }
  ; SHOP
  else if (shop.* iswm $sockname) {
    var %shop
    .sockread %shop
    if ($regex(%shop,/(\d+) shops displayed/)) { hadd -m %thread number $regml(1) }
    if (%x == 1 && $regex(%shop,/<td>([^<]+)<\/td>/)) {
      hadd -m %thread shops $hget(%thread,shops) (07 $+ $regml(1) $+ );
      unset %x
    }
    if ($regex(%shop,/<td><a href="\?rs2shops_id=\d+">([^<]+)<\/a><\/td>/) && $len($hget(%thread,shops)) < 300) {
      hadd -m %thread shops $hget(%thread,shops) $regml(1)
      %x = 1
    }
    if (<!-- Page Content End --> isin %shop) {
      if (!$hget(%thread,shops)) {
        $hget(%thread,out) 12www.tip.it found07 $hget(%thread,number) shops selling "07 $+ $caps($replace($hget(%thread,item),+,$chr(32))) $+ "
        goto unset
      }
      $hget(%thread,out) 12www.tip.it found07 $hget(%thread,number) shops selling "07 $+ $caps($replace($hget(%thread,item),+,$chr(32))) $+ ": $hget(%thread,shops)
      goto unset
    }
  }
  ; SKILLPLAN - REWRITE
  else if (skillplan.* iswm $sockname) {
    if (!%row) { !set %row 1 }
    while ($sock($sockname).rq > 0) {
      var %stats
      sockread %stats
      if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
        set % [ $+ [ %row ] ] %stats
        if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
        if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
        inc %row 1
        if (%row == 30) { skillplan.out }
      }
      if (Page not found isin %stats) { skillplan.out }
    }
  }
  ; TRACK
  else if (trackyes.* iswm $sockname) {
    if (!%row) { set %row 1 }
    var %rscript
    .sockread %rscript
    if (start isin %rscript) {
      if (Overall isin %rscript) { set %1 $gettok(%rscript,3,58) }
      if (Attack isin %rscript) { set %2 $gettok(%rscript,3,58) }
      if (Defence isin %rscript) { set %3 $gettok(%rscript,3,58) }
      if (Strength isin %rscript) { set %4 $gettok(%rscript,3,58) }
      if (Hitpoints isin %rscript) { set %5 $gettok(%rscript,3,58) }
      if (Ranged isin %rscript) { set %6 $gettok(%rscript,3,58) }
      if (Prayer isin %rscript) { set %7 $gettok(%rscript,3,58) }
      if (Magic isin %rscript) { set %8 $gettok(%rscript,3,58) }
      if (Cooking isin %rscript) { set %9 $gettok(%rscript,3,58) }
      if (Woodcutting isin %rscript) { set %10 $gettok(%rscript,3,58) }
      if (Fletching isin %rscript) { set %11 $gettok(%rscript,3,58) }
      if (Fishing isin %rscript) { set %12 $gettok(%rscript,3,58) }
      if (Firemaking isin %rscript) { set %13 $gettok(%rscript,3,58) }
      if (Crafting isin %rscript) { set %14 $gettok(%rscript,3,58) }
      if (Smithing isin %rscript) { set %15 $gettok(%rscript,3,58) }
      if (Mining isin %rscript) { set %16 $gettok(%rscript,3,58) }
      if (Herblore isin %rscript) { set %17 $gettok(%rscript,3,58) }
      if (Agility isin %rscript) { set %18 $gettok(%rscript,3,58) }
      if (Thieving isin %rscript) { set %19 $gettok(%rscript,3,58) }
      if (Slayer isin %rscript) { set %20 $gettok(%rscript,3,58) }
      if (Farming isin %rscript) { set %21 $gettok(%rscript,3,58) }
      if (Runecraft isin %rscript) { set %22 $gettok(%rscript,3,58) }
      if (Hunter isin %rscript) { set %23 $gettok(%rscript,3,58) }
      if (Construction isin %rscript) { set %24 $gettok(%rscript,3,58) }
      if (Summoning isin %rscript) { set %25 $gettok(%rscript,3,58) }
    }
    if ($hget(%thread,time) isin %rscript && gain isin %rscript) {
      if (Overall isin %rscript) { set %r1 $gettok(%rscript,4,58) }
      if (Attack isin %rscript) { set %r2 $gettok(%rscript,4,58) }
      if (Defence isin %rscript) { set %r3 $gettok(%rscript,4,58) }
      if (Strength isin %rscript) { set %r4 $gettok(%rscript,4,58) }
      if (Hitpoints isin %rscript) { set %r5 $gettok(%rscript,4,58) }
      if (Ranged isin %rscript) { set %r6 $gettok(%rscript,4,58) }
      if (Prayer isin %rscript) { set %r7 $gettok(%rscript,4,58) }
      if (Magic isin %rscript) { set %r8 $gettok(%rscript,4,58) }
      if (Cooking isin %rscript) { set %r9 $gettok(%rscript,4,58) }
      if (Woodcutting isin %rscript) { set %r10 $gettok(%rscript,4,58) }
      if (Fletching isin %rscript) { set %r11 $gettok(%rscript,4,58) }
      if (Fishing isin %rscript) { set %r12 $gettok(%rscript,4,58) }
      if (Firemaking isin %rscript) { set %r13 $gettok(%rscript,4,58) }
      if (Crafting isin %rscript) { set %r14 $gettok(%rscript,4,58) }
      if (Smithing isin %rscript) { set %r15 $gettok(%rscript,4,58) }
      if (Mining isin %rscript) { set %r16 $gettok(%rscript,4,58) }
      if (Herblore isin %rscript) { set %r17 $gettok(%rscript,4,58) }
      if (Agility isin %rscript) { set %r18 $gettok(%rscript,4,58) }
      if (Thieving isin %rscript) { set %r19 $gettok(%rscript,4,58) }
      if (Slayer isin %rscript) { set %r20 $gettok(%rscript,4,58) }
      if (Farming isin %rscript) { set %r21 $gettok(%rscript,4,58) }
      if (Runecraft isin %rscript) { set %r22 $gettok(%rscript,4,58) }
      if (Hunter isin %rscript) { set %r23 $gettok(%rscript,4,58) }
      if (Construction isin %rscript) { set %r24 $gettok(%rscript,4,58) }
      if (Summoning isin %rscript) { set %r25 $gettok(%rscript,4,58) }
    }
    if ($hget(%thread,time2) && $v1 isin %rscript && gain isin %rscript) {
      if (Overall isin %rscript) { set %r26 $gettok(%rscript,4,58) }
      if (Attack isin %rscript) { set %r27 $gettok(%rscript,4,58) }
      if (Defence isin %rscript) { set %r28 $gettok(%rscript,4,58) }
      if (Strength isin %rscript) { set %r29 $gettok(%rscript,4,58) }
      if (Hitpoints isin %rscript) { set %r30 $gettok(%rscript,4,58) }
      if (Ranged isin %rscript) { set %r31 $gettok(%rscript,4,58) }
      if (Prayer isin %rscript) { set %r32 $gettok(%rscript,4,58) }
      if (Magic isin %rscript) { set %r33 $gettok(%rscript,4,58) }
      if (Cooking isin %rscript) { set %r34 $gettok(%rscript,4,58) }
      if (Woodcutting isin %rscript) { set %r35 $gettok(%rscript,4,58) }
      if (Fletching isin %rscript) { set %r36 $gettok(%rscript,4,58) }
      if (Fishing isin %rscript) { set %r37 $gettok(%rscript,4,58) }
      if (Firemaking isin %rscript) { set %r38 $gettok(%rscript,4,58) }
      if (Crafting isin %rscript) { set %r39 $gettok(%rscript,4,58) }
      if (Smithing isin %rscript) { set %r40 $gettok(%rscript,4,58) }
      if (Mining isin %rscript) { set %r41 $gettok(%rscript,4,58) }
      if (Herblore isin %rscript) { set %r42 $gettok(%rscript,4,58) }
      if (Agility isin %rscript) { set %r43 $gettok(%rscript,4,58) }
      if (Thieving isin %rscript) { set %r44 $gettok(%rscript,4,58) }
      if (Slayer isin %rscript) { set %r45 $gettok(%rscript,4,58) }
      if (Farming isin %rscript) { set %r46 $gettok(%rscript,4,58) }
      if (Runecraft isin %rscript) { set %r47 $gettok(%rscript,4,58) }
      if (Hunter isin %rscript) { set %r48 $gettok(%rscript,4,58) }
      if (Construction isin %rscript) { set %r49 $gettok(%rscript,4,58) }
      if (Summoning isin %rscript) { set %r50 $gettok(%rscript,4,58) }
    }
    if (%rscript == 0:-1) { $hget(%thread,out) $hget(%thread,nick) Has not been tracked by Runescript. $hget(%thread,nick) is now being Tracked. | goto unset }
    if (PHP: Invalid argument supplied for foreach isin %rscript) { $hget(%thread,out) There is a gap in RScripts Data, data for $hget(%thread,nick) could not be found. | goto unset }
    if (%rscript === END) { lastNdays }
  }
  ; WORLD
  else if (world.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &world
      bwrite %file -1 -1 &world
    }
    bread %file 0 $file(%file).size &world2
    if ($bfind(&world2,0,</HTML>)) {
      var %world = $cmd(%thread,arg2)
      if (%world == World) {
        var %start = $bfind(&world2,0,Activity)
      }
      else if (%world == Welt) {
        var %start = $bfind(&world2,0,Thema)
      }
      else if (%world == Serveur) {
        var %start = $bfind(&world2,0,Activité)
      }
      else if (%world == Mundo) {
        var %start = $bfind(&world2,0,Tipo)
      }
      var %world = $cmd(%thread,arg2) $+ $iif(%world != Mundo,$chr(32)) $+ $cmd(%thread,arg3)
      ; Get the amount of players.
      var %a = $calc($bfind(&world2,%start,%world) +4), %b = $calc($bfind(&world2,%a,<td>)+4), %c = $bfind(&world2,%b,</td>)
      ; Get the worlds activity
      var %d = $calc($bfind(&world2,%c,class=") +7), %e = $bfind(&world2,%d,<)
      ; Get lootshare? and f2p/p2p
      noop $regex($remove($bvar(&world2,%e,300).text,$chr(10),$chr(13)),/title=\"(\w)\"/i)
      var %lootshare = $regml(1)
      noop $regex($remove($bvar(&world2,%e,300).text,$chr(10),$chr(13)),/(Free|Members)/)
      var %type = $regml(1)
      var %activity = $nohtml($bvar(&world2,%d,$calc(%e - %d)).text)
      var %players = $nohtml($bvar(&world2,%b,$calc(%c - %b)).text)
      if (%a == 4) { $cmd(%thread,out) World07 $cmd(%thread,arg3) Not Found. }
      else { $cmd(%thread,out) World07 $cmd(%thread,arg3) (07 $+ %activity $+ ) | Players:07 %players | Type:07 %type | Lootshare:07 $iif(%lootshare == N,04No,03Yes) | Link: 12http://world $+ $cmd(%thread,arg3) $+ .runescape.com/a2,m0,j0,o0 }
      goto unset
    }
  }
  else if (world2.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &world
      bwrite %file -1 -1 &world
    }
    bread %file 0 $file(%file).size &world2
    if ($bfind(&world2,0,</HTML>)) {
      var %a = $calc($bfind(&world2,0,There are currently)+20), %b = $calc($bfind(&world2,%a,playing)-8)
      $cmd(%thread,out) There are currently 07 $+ $bytes($bvar(&world2,%a,$calc(%b - %a)).text,db) People Playing across 171 servers. Runescape at07 $round($calc(100* $bvar(&world2,%a,$calc(%b - %a)).text / 338000),2) $+ 07% Capacity.
      goto unset
    }
  }
  ; CIRCUS
  else if (circus.* iswm $sockname) {
    var %circus
    sockread %circus
    if ($regex(%circus,/The circus is currently in: (.+?)\./i)) {
      $hget(%thread,out) The circus is currently found in:07 $nohtml($regml(1)) $+ . 12http://runescape.wikia.com
      goto unset
    }
  }
  ; DROPS
  else if (drop.* iswm $sockname) {
    var %drop
    .sockread %drop
    if (Location: isin %drop) {
      hadd -m %thread page $gettok(%drop,2-,32)
      sockopen $+(drop2.,%thread) www.zybez.net 80
      .sockclose $sockname
      unset %*
      halt
    }
    if ($regex(total,%drop,/>Browsing ([0-9\x2c]+) of/i)) { hadd -m %thread total $regml(total,1) }
    if ($regex(monster,%drop,/(?:^<td class="tablebottom">.+?<\/td><td class="tablebottom">(\d+|N\/A)<\/td>.+?|())(?:<a href="\/monsters\.php\?id=(\d+)&amp;runescape_\w+\.htm">(.+)<\/a>|()<\/table>)/)) {
      if ($regml(monster,3) || $regml(monster,1)) { hadd -m %thread npclist $replace($hget(%thread,npclist),#{},$regml(monster,1)) $caps($regml(monster,3)) $+ (#{}) 07 $+ $chr(35) $+ $regml(monster,2) $+ ; }
    }
    if ($replace($nohtml(%drop),$chr(32),_) == Content_Copyright_Notice:) {
      $hget(%thread,out) 12www.zybez.net found07 $hget(%thread,total) results: $remove($hget(%thread,npclist), (#{}) 07#;)
      goto unset
    }
  }
  else if (drop2.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &drop
      bwrite %file -1 -1 &drop
    }
    bread %file 0 $file(%file).size &drop2
    if ($bfind(&drop2,0,</body)) {
      if ($bfind(&drop2,0,Error: Invalid Monster ID.)) {
        $hget(%thread,out) Sorry 12www.zybez.net has no result for Monster ID07 $hget(%thread,id)
        goto unset
      }
      var %start = $bfind(&drop2,0,<center>), %a = $bfind(&drop2,%start,Where Found:), %cutA = $bfind(&drop2,%a,</tr)
      var %stringA = $bvar(&drop2,%start,$calc(%cutA - %start)).text
      var %cutB = $calc($bfind(&drop2,%cutA,Top Drops:)+10), %cutC = $bfind(&drop2,%cutB,</tr>)
      var %stringB = $bvar(&drop2,%cutB,$calc(%cutC - %cutB)).text
      if ($regex(info,%stringA,/">([^<]+)<\/td><\/tr><tr><td[^>]+><img[^>]+><\/td><\/tr>(?:<tr><td[^>]+>Combat:<\/td><td[^>]+>(\d+)<\/td><\/tr>|())(?:<tr><td>Hitpoints:<\/td><td>(\d+)<\/td><\/tr>|())(?:<tr><td>Max Hit:<\/td><td>(\d+)<\/td><\/tr>|())(?:<tr><td>Race:<\/td><td>([a-z_ ]+)<\/td><\/tr>|())(?:<tr><td>Members:<\/td><td>(\w+)<\/td><\/tr>|())(?:<tr><td>Quest:<\/td><td>(:?(\w+)|<a[^>]+>([^<]+)<\/a>)<\/td><\/tr>|())(?:<tr><td>Nature:<\/td><td>([a-z_ ]+)<\/td><\/tr>|())(?:<tr><td>Attack Style:<\/td><td>(\w+)<\/td><\/tr>|())(?:<tr><td>Examine:<\/td><td>([^<]+)<\/td><\/tr>|())<\/table>.+?>(?:Where Found:<\/td><td>([^<]+)<\/td|())>/i)) {
        $hget($gettok($sockname,2,46),out)  $+ $caps($regml(info,1)) $+ (07 $+ $iif($regml(info,2),$v1,N/A) $+ ) | hitpoints:07 $iif($regml(info,3),$v1,N/A) | max hit:07 $iif($regml(4),$v1,N/A) | race:07 $iif($regml(info,5),$v1,N/A) | examine:07 $iif($regml(info,11),$v1,N/A) 12www.zybez.net
        if ($hget(%thread,command) == npc) {
          $hget(%thread,out) Nature:07 $iif($regml(info,9),$v1,N/A) | Quest:07 $iif($yesno($regml(info,8)),$v1,07N/A) | Members: $iif($yesno($regml(info,6)),$v1,07N/A) | Attack Style:07 $iif($regml(info,10),$v1,N/A) | Habitat:07 $iif($regml(info,12),$v1,N/A)
          goto unset
        }
      }
      if ($hget(%thread,command) == drop) {
        if ($gettok(%stringB,1,32) == 200) {
          $hget(%thread,out) No drop list for this npc found on 12www.zybez.net
          goto unset
        }
        $hget(%thread,out) Top Drops: $nohtml(%stringB)
      }
      goto unset
    }
  }
  return
  :unset
  if ($exists(%file)) .remove %file
  if ($sockname) sockclose $sockname
  _clearCommand %thread
  unset %*
  return
  :error
  _throw $sockname %thread $error
  sendToDev Error @ sockread:07 $sockname $error
  if ($exists(%file)) .remove %file
  if ($sockname) sockclose $sockname
  unset %*
  reseterror
}
