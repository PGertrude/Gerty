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
  ; ML / MEMBERLIST
  else if (ml.* iswm $sockname) {
    var %ml
    sockread %ml
    if (@@start !isin %ml) {
      if (@@not isin %ml) {
        $hget(%thread,out) $+(,$hget(%thread,ml),) clan not found. $+($chr(15),$chr(40),$chr(3),07,RuneHead.com,$chr(15),$chr(41))
        goto unset
      }
      else if ($numtok(%ml,124) > 5) {
        tokenize 124 %ml
        $hget(%thread,out) $+($chr(91),07,$5,,$chr(93),07) $1 $+(,$chr(40),07,$4,,$chr(41)) Link:12 $2 | Members: $+(07,$6,) | Avg: P2P-Cmb: $+(07,$7,) F2P-Cmb: $+(07,$16,) Overall: $+(07,$bytes($9,bd),) | Based: Region: $+(07,$13,) World: $+(07,$15,) Core: $+(07,$12,) Cape: $+(07,$14) | Runehead Link:12 $3
        goto unset
      }
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
          hadd -m %thread link %id
          sockopen youtube. $+ %thread rscript.org 80
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
    if (%row == $null) { !set %row 1 }
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
  ; TOP - REWRITE
  else if (top.* iswm $sockname) {
    if (!%row) { %row = 1 }
    var %top
    sockread %top
    if (%row < 350) {
      if ($nohtml(%top)) {
        set % [ $+ [ $calc(%row) ] ] $replace($nohtml(%top),$chr(32),_)
        inc %row 1
      }
    }
    if (</html> isin %top) { topout %thread | sockclose $sockname | halt }
  }
  ; TRACK
  else if (trackyes.* iswm $sockname) {
    if (!%row) { set %row 1 }
    var %rscript
    .sockread %rscript
    if (*start* iswm %rscript) {
      if (*Overall* iswm %rscript) { set %1 $gettok($nohtml(%rscript),3,58) }
      if (*Attack* iswm %rscript) { set %2 $gettok($nohtml(%rscript),3,58) }
      if (*Defence* iswm %rscript) { set %3 $gettok($nohtml(%rscript),3,58) }
      if (*Strength* iswm %rscript) { set %4 $gettok($nohtml(%rscript),3,58) }
      if (*Hitpoints* iswm %rscript) { set %5 $gettok($nohtml(%rscript),3,58) }
      if (*Ranged* iswm %rscript) { set %6 $gettok($nohtml(%rscript),3,58) }
      if (*Prayer* iswm %rscript) { set %7 $gettok($nohtml(%rscript),3,58) }
      if (*Magic* iswm %rscript) { set %8 $gettok($nohtml(%rscript),3,58) }
      if (*Cooking* iswm %rscript) { set %9 $gettok($nohtml(%rscript),3,58) }
      if (*Woodcutting* iswm %rscript) { set %10 $gettok($nohtml(%rscript),3,58) }
      if (*Fletching* iswm %rscript) { set %11 $gettok($nohtml(%rscript),3,58) }
      if (*Fishing* iswm %rscript) { set %12 $gettok($nohtml(%rscript),3,58) }
      if (*Firemaking* iswm %rscript) { set %13 $gettok($nohtml(%rscript),3,58) }
      if (*Crafting* iswm %rscript) { set %14 $gettok($nohtml(%rscript),3,58) }
      if (*Smithing* iswm %rscript) { set %15 $gettok($nohtml(%rscript),3,58) }
      if (*Mining* iswm %rscript) { set %16 $gettok($nohtml(%rscript),3,58) }
      if (*Herblore* iswm %rscript) { set %17 $gettok($nohtml(%rscript),3,58) }
      if (*Agility* iswm %rscript) { set %18 $gettok($nohtml(%rscript),3,58) }
      if (*Thieving* iswm %rscript) { set %19 $gettok($nohtml(%rscript),3,58) }
      if (*Slayer* iswm %rscript) { set %20 $gettok($nohtml(%rscript),3,58) }
      if (*Farming* iswm %rscript) { set %21 $gettok($nohtml(%rscript),3,58) }
      if (*Runecraft* iswm %rscript) { set %22 $gettok($nohtml(%rscript),3,58) }
      if (*Hunter* iswm %rscript) { set %23 $gettok($nohtml(%rscript),3,58) }
      if (*Construction* iswm %rscript) { set %24 $gettok($nohtml(%rscript),3,58) }
      if (*Summoning* iswm %rscript) { set %25 $gettok($nohtml(%rscript),3,58) }
    }
    if (* $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript && *gain* iswm %rscript) {
      if (Overall isin %rscript) { set %r1 $gettok($nohtml(%rscript),4,58) }
      if (Attack isin %rscript) { set %r2 $gettok($nohtml(%rscript),4,58) }
      if (Defence isin %rscript) { set %r3 $gettok($nohtml(%rscript),4,58) }
      if (Strength isin %rscript) { set %r4 $gettok($nohtml(%rscript),4,58) }
      if (Hitpoints isin %rscript) { set %r5 $gettok($nohtml(%rscript),4,58) }
      if (Ranged isin %rscript) { set %r6 $gettok($nohtml(%rscript),4,58) }
      if (Prayer isin %rscript) { set %r7 $gettok($nohtml(%rscript),4,58) }
      if (Magic isin %rscript) { set %r8 $gettok($nohtml(%rscript),4,58) }
      if (Cooking isin %rscript) { set %r9 $gettok($nohtml(%rscript),4,58) }
      if (Woodcutting isin %rscript) { set %r10 $gettok($nohtml(%rscript),4,58) }
      if (Fletching isin %rscript) { set %r11 $gettok($nohtml(%rscript),4,58) }
      if (Fishing isin %rscript) { set %r12 $gettok($nohtml(%rscript),4,58) }
      if (Firemaking isin %rscript) { set %r13 $gettok($nohtml(%rscript),4,58) }
      if (Crafting isin %rscript) { set %r14 $gettok($nohtml(%rscript),4,58) }
      if (Smithing isin %rscript) { set %r15 $gettok($nohtml(%rscript),4,58) }
      if (Mining isin %rscript) { set %r16 $gettok($nohtml(%rscript),4,58) }
      if (Herblore isin %rscript) { set %r17 $gettok($nohtml(%rscript),4,58) }
      if (Agility isin %rscript) { set %r18 $gettok($nohtml(%rscript),4,58) }
      if (Thieving isin %rscript) { set %r19 $gettok($nohtml(%rscript),4,58) }
      if (Slayer isin %rscript) { set %r20 $gettok($nohtml(%rscript),4,58) }
      if (Farming isin %rscript) { set %r21 $gettok($nohtml(%rscript),4,58) }
      if (Runecraft isin %rscript) { set %r22 $gettok($nohtml(%rscript),4,58) }
      if (Hunter isin %rscript) { set %r23 $gettok($nohtml(%rscript),4,58) }
      if (Construction isin %rscript) { set %r24 $gettok($nohtml(%rscript),4,58) }
      if (Summoning isin %rscript) { set %r25 $gettok($nohtml(%rscript),4,58) }
    }
    if ($hget($gettok($sockname,2,46),time2) && * $+ $hget($gettok($sockname,2,46),time2) $+ * iswm %rscript && *gain* iswm %rscript) {
      if (*Overall* iswm %rscript) { set %r26 $gettok($nohtml(%rscript),4,58) }
      if (*Attack* iswm %rscript) { set %r27 $gettok($nohtml(%rscript),4,58) }
      if (*Defence* iswm %rscript) { set %r28 $gettok($nohtml(%rscript),4,58) }
      if (*Strength* iswm %rscript) { set %r29 $gettok($nohtml(%rscript),4,58) }
      if (*Hitpoints* iswm %rscript) { set %r30 $gettok($nohtml(%rscript),4,58) }
      if (*Ranged* iswm %rscript) { set %r31 $gettok($nohtml(%rscript),4,58) }
      if (*Prayer* iswm %rscript) { set %r32 $gettok($nohtml(%rscript),4,58) }
      if (*Magic* iswm %rscript) { set %r33 $gettok($nohtml(%rscript),4,58) }
      if (*Cooking* iswm %rscript) { set %r34 $gettok($nohtml(%rscript),4,58) }
      if (*Woodcutting* iswm %rscript) { set %r35 $gettok($nohtml(%rscript),4,58) }
      if (*Fletching* iswm %rscript) { set %r36 $gettok($nohtml(%rscript),4,58) }
      if (*Fishing* iswm %rscript) { set %r37 $gettok($nohtml(%rscript),4,58) }
      if (*Firemaking* iswm %rscript) { set %r38 $gettok($nohtml(%rscript),4,58) }
      if (*Crafting* iswm %rscript) { set %r39 $gettok($nohtml(%rscript),4,58) }
      if (*Smithing* iswm %rscript) { set %r40 $gettok($nohtml(%rscript),4,58) }
      if (*Mining* iswm %rscript) { set %r41 $gettok($nohtml(%rscript),4,58) }
      if (*Herblore* iswm %rscript) { set %r42 $gettok($nohtml(%rscript),4,58) }
      if (*Agility* iswm %rscript) { set %r43 $gettok($nohtml(%rscript),4,58) }
      if (*Thieving* iswm %rscript) { set %r44 $gettok($nohtml(%rscript),4,58) }
      if (*Slayer* iswm %rscript) { set %r45 $gettok($nohtml(%rscript),4,58) }
      if (*Farming* iswm %rscript) { set %r46 $gettok($nohtml(%rscript),4,58) }
      if (*Runecraft* iswm %rscript) { set %r47 $gettok($nohtml(%rscript),4,58) }
      if (*Hunter* iswm %rscript) { set %r48 $gettok($nohtml(%rscript),4,58) }
      if (*Construction* iswm %rscript) { set %r49 $gettok($nohtml(%rscript),4,58) }
      if (*Summoning* iswm %rscript) { set %r50 $gettok($nohtml(%rscript),4,58) }
    }
    if ($regex(%rscript,/^0:-1$/)) { $hget(%thread,out) $hget(%thread,nick) Has not been tracked by Runescript. $hget(%thread,nick) is now being Tracked. | goto unset }
    if (*PHP: Invalid argument supplied for foreach* iswm %rscript) { $hget(%thread,out) There is a gap in RScripts Data, data for $hget(%thread,nick) could not be found. | goto unset }
    if (*END* iswm %rscript) { lastNdays }
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
  ; ITEM
  else if (zybez.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &item
      bwrite %file -1 -1 &item
    }
    bread %file 0 $file(%file).size &item2
    if ($bfind(&item2,0,</HTML>)) {
      if ($bfind(&item2,0,location:) < 1) {
        var %start = $bfind(&item2,0,>Submit Missing Item<)
        if (%start < 1) { goto unset }
        while ($bfind(&item2,%start,items.php?id=)) {
          var %a = $calc($bfind(&item2,%start,items.php?id=)+13), %b = $bfind(&item2,%a,&amp;), %c = $calc($bfind(&item2,$calc(%b + 50),htm">)+5), %d = $bfind(&item2,%c,<)
          var %e = %e | $bvar(&item2,%c,$calc(%d - %c)).text 07 $+ $chr(35) $+ $bvar(&item2,%a,$calc(%b - %a)).text
          var %start = %d
        }
        var %e = $gettok(%e,1-8,124)
        $hget($gettok($sockname,2,46),out) Matches found07 $count(%e,$chr(35)) %e
        goto unset
      }
      if ($bfind(&item2,0,location:) > 1) {
        var %start = $calc($bfind(&item2,0,?id=)+4)
        hadd -m %thread id $iif($bvar(&item2,%start,4).text isnum,$bvar(&item2,%start,4).text,$iif($bvar(&item2,%start,3).text isnum,$bvar(&item2,%start,3).text,$iif($bvar(&item2,%start,2).text isnum,$bvar(&item2,%start,2).text,$iif($bvar(&item2,%start,1).text isnum,$bvar(&item2,%start,1).text))))
        sockopen $+(zybez2.,$gettok($sockname,2,46)) www.zybez.net 80
        .remove %file
        sockclose $sockname
      }
    }
  }
  else if (zybez2.* iswm $sockname) {
    while ($sock($sockname).rq) {
      sockread &item3
      bwrite %file -1 -1 &item3
    }
    bread %file 0 $file(%file).size &item4
    if ($bfind(&item4,0,</HTML>)) {
      var %start = $calc($bfind(&item4,0,"border-right:none">)+20), %a = $bfind(&item4,%start,<), %b = $calc($bfind(&item4,%a,members:)+17), %c = $bfind(&item4,%b,<), %d = $calc($bfind(&item4,%c,Tradable:)+18), %e = $bfind(&item4,%d,<)
      if (%start < 21) { $hget($gettok($sockname,2,46),out) Item not found | goto unset }
      var %f = $calc($bfind(&item4,%e,Equipable:)+19), %g = $bfind(&item4,%f,<), %h = $calc($bfind(&item4,%g,Stackable:)+19), %i = $bfind(&item4,%h,<), %j = $calc($bfind(&item4,%i,Weight:)+16), %k = $bfind(&item4,%j,<)
      var %l = $calc($bfind(&item4,%k,Quest:)+15), %m = $bfind(&item4,$calc(%l +1),<), %n = $calc($bfind(&item4,%m,Examine:)+17), %o = $bfind(&item4,%n,<)
      var %xx = $calc($bfind(&item4,%n,Price:)+15), %yy = $calc($bfind(&item4,%xx,>)+1), %zz = $bfind(&item4,%yy,<)
      var %aa = $calc($bfind(&item4,%n,Price:)+12), %bb = $calc($bfind(&item4,%aa,>)+1), %cc = $bfind(&item4,%bb,<)
      if ($bfind(&item4,%n,Price:) > 1) {
        var %pp = $bfind(&item4,%n,Price:), %p = $bfind(&item4,%pp,<div), %q = $calc($bfind(&item4,%p,</div>)+6)
        var %price = $nohtml($bvar(&item4,%p,$calc(%q - %p)).text)
      }
      if (!%price) { var %price = Not Applicable }
      if ($yesno($bvar(&item4,%d,$calc(%e - %d)).text) == 03Yes) { var %price = Check Price Guide }
      var %r = $calc($bfind(&item4,%n,alchemy:)+17), %s = $bfind(&item4,%r,<), %t = $calc($bfind(&item4,%s,alchemy:)+17), %u = $bfind(&item4,%t,<), %v = $calc($bfind(&item4,%n,from:)+14), %w = $bfind(&item4,%v,<)
      var %halch = $iif( * $+ $chr(13) $+ * iswm $remove($bvar(&item4,%r,$calc(%s - %r)).text,gp),0,$remove($bvar(&item4,%r,$calc(%s - %r)).text,gp))
      var %lalch = $iif( * $+ $chr(13) $+ * iswm $remove($bvar(&item4,%t,$calc(%u - %t)).text,gp),0,$remove($bvar(&item4,%t,$calc(%u - %t)).text,gp))
      $hget($gettok($sockname,2,46),out)  $+ $bvar(&item4,%start,$calc(%a - %start)).text $+  Alch:07 %halch $+ / $+ %lalch gp | Market Price:07 $remove(%price,>) | Obtained From:07 $remove($bvar(&item4,%v,$calc(%w - %v)).text,>) | 12http://www.zybez.net/items.php?id= $+ $hget($gettok($sockname,2,46),id)
      $hget($gettok($sockname,2,46),out) Members? $yesno($bvar(&item4,%b,$calc(%c - %b)).text) | Tradeable? $yesno($bvar(&item4,%d,$calc(%e - %d)).text) | Equipable: $yesno($bvar(&item4,%f,$calc(%g - %f)).text) | Stackable? $yesno($bvar(&item4,%h,$calc(%i - %h)).text) $&
        | Weight:07 $regsubex($bvar(&item4,%j,$calc(%k - %j)).text,/^kg$/i,0Kg) | Quest?07 $yesno($nohtml($bvar(&item4,%l,$calc(%m - %l)).text)) | Examine:07 $nohtml($bvar(&item4,%n,$calc(%o - %n)).text)
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
  ; ALOG
  else if (alog.* iswm $sockname) {
    var %alog
    sockread %alog
    if (Page not found isin %alog) {
      $hget(%thread,out) No achievement logs were found for player $qt(07 $+ $hget($gettok($sockname,2,46),rsn) $+ ) $+ . Reason for this is that the player can either be non-member, keeping his A-log profile private or that the username doesn't exist.
      goto unset
    }
    if ($regex(%alog,/<title>(.+?)</i)) {
      var %title = $regml(1)
      if (Levelled isin %title) goto skip
      elseif ($regex(%title,/Item found\W (?:an? |some )?(.+)/i)) {
        var %old = $hget(%thread,item)
        hadd -m %thread item %old $+ $regml(1) $+ $chr(124)
        if ($len($alogout(%thread)) > 350) hadd -m %thread item %old
      }
      elseif ($regex(exp,%title,/(\d+)XP in (\w+)/)) {
        var %old = $hget(%thread,exp)
        if ($regml(exp,2) !isin %old) hadd -m %thread exp $+(%old,$chr(44) 07,$bytes($regml(exp,1),bd), $regml(exp,2) exp)
        if ($len($alogout(%thread)) > 350) hadd -m %thread exp %old
      }
      elseif ($regex(%title,/I killed (?:an? )?(.+)/i)) {
        var %old = $hget(%thread,kill)
        hadd -m %thread kill %old $+ $replace($regml(1),&#160;,$chr(32),&apos;,') $+ $chr(124)
        if ($len($alogout(%thread)) > 350) hadd -m %thread kill %old
      }
      elseif ($regex(%title,/Quest complete\W (.+)/i)) {
        var %old = $hget(%thread,done)
        hadd -m %thread done %old $+ $nohtml($regml(1)) $+ $chr(124)
        if ($len($alogout(%thread)) > 350) hadd -m %thread done %old
      }
      elseif (recent event !isin %title) {
        var %old = $hget(%thread,other)
        hadd -m %thread other %old $+ %title $+ $chr(124)
        if ($len($alogout(%thread)) > 350) hadd -m %thread other %old
      }
      :skip
    }
    if ($regex(lvl,%alog,/reached level (\d+) in the (\w+) skill/)) {
      var %old = $hget(%thread,lvl)
      if (!$hget(%thread,$regml(lvl,2))) hadd -m %thread $regml(lvl,2) 0
      if (!$hget(%thread,$regml(lvl,2) $+ high) || $hget(%thread,$regml(lvl,2) $+ high) < $hget(%thread,$regml(lvl,1))) { hadd -m %thread $regml(lvl,2) $+ high $regml(lvl,1) }
      hinc %thread $regml(lvl,2)
      if (!$istok($hget(%thread,lvl),$regml(lvl,2),124)) hadd -m %thread lvl $+($hget(%thread,lvl),|,$regml(lvl,2))
      if ($len($alogout(%thread)) > 350) hadd -m %thread lvl %old
    }
    if (>Quests< isin %alog) {
      %levels = $regsubex(%levels,/\|(\w+)/g,$chr(44) 07 $+ $hget(%thread,\1) \1 $+(level,$iif($hget(%thread,\1) > 1,s),$chr(40),->,07,$hget(%thread,\1 $+ high),,$chr(41)))
      var %log = $iif(%levels,Gained $right(%levels,-2) $+ $chr(44)) $+ $iif(%exp,$chr(32) $+ Reached $right(%exp,-2) $+ $chr(44)) $+ $iif(%items,$chr(32) $+ Found $grouper($replace($right(%items,-2),$chr(44),|)) $+ $chr(44)) $+ $iif(%kills,$chr(32) $+ Killed $right(%kills,-2) $+ $chr(44)) $+ $iif(%quest,$chr(32) $+ Completed quest $right(%quest,-2) $+ $chr(44)) $+ $iif(%else,$chr(32) $+ %else $+ $chr(44))
      $hget(%thread,out) Achievements Log for07 $hget(%thread,rsn) $+ : $left(%log,-1)
      goto unset
    }
    if (</channel> isin %alog) {
      $hget(%thread,out) Achievements Log for07 $hget(%thread,rsn) $+ : $alogout(%thread)
      goto unset
    }
  }
  else if (alog-r.* iswm $sockname) {
    var %alog-r
    sockread %alog-r
    if (%alog-r == START) {
      var %hash = $gettok($sockname,2,46)
      while (%alog-r && $len(%output) < 320) {
        sockread %alog-r
        if (: !isin %alog-r && %alog-r) {
          var %output = %alog-r $+ .
          break
        }
        tokenize 58 %alog-r
        if ($1 == ITEM) %output = $+($iif(%output,%output $+ ;),$chr(32),Found07 $2 ,$chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == EXP) %output = $+($iif(%output,%output $+ ;),$chr(32),Reached07 $bytes($gettok($2,1,32),bd) ,$gettok($2,2,32) exp $chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == LVL) %output = $+($iif(%output,%output $+ ;),$chr(32),Gained level07 $gettok($2,1,32), $gettok($2,2,32) $chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == QUEST) %output = $+($iif(%output,%output $+ ;),$chr(32),Finished07 $2 quest ,$chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == MONSTER) %output = $+($iif(%output,%output $+ ;),$chr(32),Killed07 $2 ,$chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == PK) %output = $+($iif(%output,%output $+ ;),$chr(32),Player killed07 $2 ,$chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
        if ($1 == OTHER) %output = $+($iif(%output,%output $+ ;),$chr(32),07 $2 ,$chr(40),07,$asctime($3,mm.07dd.07yy),,$chr(41))
      }
      $hget(%hash,out) Recent events for07 $hget(%hash,rsn) $+ : %output
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
  if ($exists(%file)) .remove %file
  if ($sockname) sockclose $sockname
  unset %*
  reseterror
}
