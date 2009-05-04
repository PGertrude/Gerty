on $*:TEXT:/^[!@.]track */Si:*: {
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %input = $1-
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  .tokenize 32 $timetoday
  var %today = $1, %week = $2, %month = $3, %year $4
  .tokenize 32 %input
  ;skill specified
  if ($lookups($2) != nomatch) {
    var %string = $3-
    var %time = null
    if ($regex(%string,/(?:^| )@(.+?)$/)) {
      %time = $regml(1)
      if (%time !isnum) { %time = $duration(%time) }
      var %string = $regsubex(%string,/(?:^| )@(.+?)$/,$null)
    }
    if ($len($trim(%string)) > 0) {
      var %nick = $rsn($trim(%string))
    }
    if (!%nick) { %nick = $rsn($nick) }
    var %skill = $scores($2)
    var %socket = stats. $+ %thread
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(stats %saystyle $replace(%skill,$chr(32),_) $statnum(%skill) %nick null nl 1 200000001 %socket yes yes %time, %socket, %url)
  }
  ;skill not specified
  if ($scores($2) == nomatch) {
    var %string = $2-
    var %time = %today, %command = Today
    if ($regex(%string,/(?:^| )@(.+?)$/)) {
      %time = $regml(1)
      if (%time !isnum) { %time = $duration(%time) }
      %command = $duration(%time)
      var %string = $regsubex(%string,/(?:^| )@(.+?)$/,$null)
    }
    var %nick = $nick
    if ($len($trim(%string)) > 0) {
      %nick $trim(%string)
    }
    %nick = $rsn(%nick)
    var %skill = all
    hadd -m %thread nick %nick
    hadd -m %thread skill %skill
    hadd -m %thread time %time
    hadd -m %thread command %command
    hadd -m %thread out %saystyle
    sockopen $+(trackall.,%thread) www.rscript.org 80
  }
}
;###########################
;#######Single Skill########
;###########################
on *:sockopen:track.*: {
  sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $hget($gettok($sockname,2,46),nick) $+ &skill= $+ $hget($gettok($sockname,2,46),skill) $+ &time= $+ $hget($gettok($sockname,2,46),time) $+ , $+ %week $+ , $+ %month $+ , $+ %year
  sockwrite -n $sockname Host: www.rscript.org $+ $crlf $+ $crlf
}
on *:sockread:track.*: {
  if (%row == $null) { set %row 1 }
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  .sockread %rscript
  if (%row < 1000) {
    set % [ $+ [ %row ] ] $nohtml(%rscript)
    if (* $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { hadd -m $gettok($sockname,2,46) timegain %rscript }
    if (* $+ %week $+ * iswm %rscript) { hadd -m $gettok($sockname,2,46) weekgain %rscript }
    if (* $+ %month $+ * iswm %rscript) { hadd -m $gettok($sockname,2,46) monthgain %rscript }
    if (* $+ %year $+ * iswm %rscript) { hadd -m $gettok($sockname,2,46) yeargain %rscript }
    inc %row 1
  }
  if (*0:-1* iswm %rscript) { $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) Has not been tracked by Runescript. $hget($gettok($sockname,2,46),nick) is now being Tracked. | unset %* | sockclose $sockname | halt }
}
on *:sockclose:track.*: {
  singletrack2
  unset %*
}
alias singletrack2 {
  sockopen $+(track2.,$gettok($sockname,2,46)) hiscore.runescape.com 80
}
on *:sockopen:track2.*: {
  .sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget($gettok($sockname,2,46),nick) HTTP/1.1
  .sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:track2.*: {
  if (%row == $null) { set %row 1 }
  if ($sockerr) {
    $right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
    halt
  }
  .sockread %stats
  if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
    set % [ $+ [ %row ] ] %stats
    if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
    if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
    inc %row 1
  }
  if (%row == 30) { track2 }
}
alias track2 {
  set %skill $hget($gettok($sockname,2,46),skill)
  set %lvl $virtual($gettok(% [ $+ [ $statnum(%skill) ] ],3,44))
  set %alvl $gettok(% [ $+ [ $statnum(%skill) ] ],2,44)
  set %exp $gettok(% [ $+ [ $statnum(%skill) ] ],3,44)
  set %rank $gettok(% [ $+ [ $statnum(%skill) ] ],1,44)
  $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) 07 $+ %skill | Rank:07 $iif($gettok(% [ $+ [ $statnum(%skill) ] ],1,44) isnum,$bytes($gettok(% [ $+ [ $statnum(%skill) ] ],1,44),db),$gettok(% [ $+ [ $statnum(%skill) ] ],1,44)) | Level: $skill2b(% [ $+ [ $statnum(%skill) ] ],2) (07 $+ $virtual($gettok(% [ $+ [ $statnum(%skill) ] ],3,44)) $+ ) | Exp:07 $bytes($gettok(% [ $+ [ $statnum(%skill) ] ],3,44),db) $xp2lvl(% [ $+ [ $statnum(%skill) ] ],$hget($gettok($sockname,2,46),@),%skill)
  var %todayxp = $iif(!$gettok($hget($gettok($sockname,2,46),timegain),2,58),-,$bytes($gettok($hget($gettok($sockname,2,46),timegain),2,58),db)),%weekxp = $iif(!$gettok($hget($gettok($sockname,2,46),weekgain),2,58),-,$bytes($gettok($hget($gettok($sockname,2,46),weekgain),2,58),db)),%monthxp = $iif(!$gettok($hget($gettok($sockname,2,46),monthgain),2,58),-,$bytes($gettok($hget($gettok($sockname,2,46),monthgain),2,58),db))
  var %todaylv = $gettok(% [ $+ [ $statnum(%skill) ] ],2,44) - $iif($virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),timegain),2,58))) > 99,99,$virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),timegain),2,58))))
  var %weeklv = $gettok(% [ $+ [ $statnum(%skill) ] ],2,44) - $iif($virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),weekgain),2,58))) > 99,99,$virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),weekgain),2,58))))
  var %monthlv = $gettok(% [ $+ [ $statnum(%skill) ] ],2,44) - $iif($virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),monthgain),2,58))) > 99,99,$virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),monthgain),2,58))))
  var %yearlv = $gettok(% [ $+ [ $statnum(%skill) ] ],2,44) - $iif($virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),yeargain),2,58))) > 99,99,$virtual($calc($gettok(% [ $+ [ $statnum(%skill) ] ],3,44) - $gettok($hget($gettok($sockname,2,46),yeargain),2,58))))
  %yearxp = $iif(!$gettok($hget($gettok($sockname,2,46),yeargain),2,58),-,$bytes($gettok($hget($gettok($sockname,2,46),yeargain),2,58),db))
  $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),command) $+ :03 %todayxp xp,03 %todaylv lvls, | Week:03 %weekxp xp,03 %weeklv lvls, | Month:03 %monthxp xp,03 %monthlv lvls, | Year:03 %yearxp xp,03 %yearlv lvls,
  if (!%1) {
    $hget($gettok($sockname,2,46),out) User07 $hget($gettok($sockname,2,46),nick) not found on RS Hiscores
  }
  :unset
  hfree $gettok($sockname,2,46)
  unset %*
}
;#############################
;#######!track (today)########
;#############################
on *:sockopen:trackall.*: {
  sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $hget($gettok($sockname,2,46),nick) $+ &skill=all&time= $+ $hget($gettok($sockname,2,46),time)
  sockwrite -n $sockname Host: www.rscript.org $+ $crlf $+ $crlf
}
on *:sockread:trackall.*: {
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) There was a socket error.
    halt
  }
  .sockread %rscript
  if (start isin %rscript) {
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
  if (gain isin %rscript) {
    if (*Overall* iswm %rscript) { set %r1 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript) { set %r2 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript) { set %r3 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript) { set %r4 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript) { set %r5 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript) { set %r6 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript) { set %r7 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript) { set %r8 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript) { set %r9 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript) { set %r10 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript) { set %r11 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript) { set %r12 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript) { set %r13 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript) { set %r14 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript) { set %r15 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript) { set %r16 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript) { set %r17 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript) { set %r18 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript) { set %r19 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript) { set %r20 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript) { set %r21 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript) { set %r22 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript) { set %r23 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript) { set %r24 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript) { set %r25 $gettok($nohtml(%rscript),4,58) }
  }
  if ($regex(%rscript,/^0:-1$/)) { $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) Has not been tracked by Runescript. $hget($gettok($sockname,2,46),nick) is now being Tracked. | unset %* | sockclose $sockname | halt }
  if (PHP: Invalid argument supplied for foreach isin %rscript) { $hget($gettok($sockname,2,46),out) There is a gap in RScripts Data, data for $hget($gettok($sockname,2,46),nick) could not be found. | unset %* | sockclose $sockname | halt }
  if (END isin %rscript) { trackall }
}
alias trackall {
  .tokenize 32 $timetoday
  var %today = $1, %week = $2, %month = $3, %year = $4
  var %x = 25
  while (%x) {
    ;if (%x = 25 && !%r25 && $hget($gettok($sockname,2,46),time) > $calc(%year -1209600)) { %r25 = %25 }
    if (!%r [ $+ [ %x ] ]) { %r [ $+ [ %x ] ] = 0 }
    dec %x
  }
  if (%r1 == 0) { $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%r1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp; | unset %* | sockclose $sockname | halt }
  var %cmb = $sort(Attack %2 %r2 Defence %3 %r3 Strength %4 %r4 Hitpoints %5 %r5 Range %6 %r6 Pray %7 %r7 Mage %8 %r8 Summon %25 %r25)
  if (%cmb) { var %out1 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Combat  $+ $hget($gettok($sockname,2,46),command) $+ : %cmb }
  var %others = $sort(Cook %9 %r9 Woodcut %10 %r10 Fletching %11 %r11 Fishing %12 %r12 Firemake %13 %r13 Crafting %14 %r14 Smithing %15 %r15 Mine %16 %r16 Herblore %17 %r17 Agility %18 %r18 Thieve %19 %r19 Slayer %20 %r20 Farming %21 %r21 Runecraft %22 %r22 Hunter %23 %r23 Construct %24 %r24)
  if (%others) { var %out2 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Others  $+ $hget($gettok($sockname,2,46),command) $+ : %others }
  $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%r1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp;
  %out1
  %out2
  unset %*
  hfree $gettok($sockname,2,46)
}
;###########################
;###!yesterday/!lastNdays###
;###########################
on *:TEXT:*:*: {
  if ($regex($1,/^[!@.]([A-Za-z]+)(\d+)([A-Za-z]+)$/Si)) {
    if ($last($regml(1)) == last) {
      if ($duration($time) >= 25200) {
        %today = $duration($time) - 25200
      }
      if ($duration($time) < 25200) {
        %today = $duration($time) + 61200
      }
      set %week $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
      set %month $calc(($gettok($date,1,47) - 1) * 86400 + %today )
      set %year $calc($ctime($date $time) - $ctime(January 1 $date(yyyy) 00:00:00))
      var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
      if ($2) {
        var %nick = $caps($regsubex($rsn($replace($2-,$chr(32),_,-,_)),/\W/g,_))
      }
      if (!$2) {
        var %nick = $caps($regsubex($rsn($nick),/\W/g,_))
      }
      var %reg = $regex($1,/^[!@.]([A-Za-z]+)(\d+)([A-Za-z]+)$/Si)
      var %time = $regml(2) $+ $regml(3)
      var %time = $duration(%time)
      hadd -m $+(a,%thread) nick %nick
      hadd -m $+(a,%thread) time %time
      hadd -m $+(a,%thread) command Last $regsubex($duration($duration($regml(2) $+ $regml(3))),/(\d+)([A-Za-z]+)/g,\1 \2)
      hadd -m $+(a,%thread) skill $skills($2)
      hadd -m $+(a,%thread) out $saystyle($left($1,1),$nick,$chan)
      sockopen $+(trackyes.a,%thread) www.rscript.org 80
    }
  }
  if ($regex($1,/^[!@.](\d+)([A-Za-z]+)ago$/Si)) {
    if ($duration($time) >= 25200) {
      %today = $duration($time) - 25200
    }
    if ($duration($time) < 25200) {
      %today = $duration($time) + 61200
    }
    set %week $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
    set %month $calc(($gettok($date,1,47) - 1) * 86400 + %today )
    set %year $calc($ctime($date $time) - $ctime(January 1 $date(yyyy) 00:00:00))
    var %thread = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
    if ($2) {
      var %nick = $caps($regsubex($rsn($replace($2-,$chr(32),_,-,_)),/\W/g,_))
    }
    if (!$2) {
      var %nick = $caps($regsubex($rsn($nick),/\W/g,_))
    }
    var %reg = $regex($1,/^[!@.](\d+)([A-Za-z]+)ago$/Si)
    var %time = $regml(1) $+ $regml(2)
    var %time = $calc($duration(%time) + %today)
    hadd -m $+(a,%thread) nick %nick
    hadd -m $+(a,%thread) time %time
    hadd -m $+(a,%thread) time2 $calc(%time - 86400)
    hadd -m $+(a,%thread) command $regsubex($duration($calc(%time - %today)),/(\d+)([A-Za-z]+)/g,\1 \2) ago
    hadd -m $+(a,%thread) skill $skills($2)
    hadd -m $+(a,%thread) out $saystyle($left($1,1),$nick,$chan)
    sockopen $+(trackyes.a,%thread) www.rscript.org 80
  }
}
alias last {
  if ($regex($1,/^(last|l|la)$/Si)) { return last }
}
on *:sockopen:trackyes.*: {
  sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $hget($gettok($sockname,2,46),nick) $+ &skill=all&time= $+ $hget($gettok($sockname,2,46),time) $+ , $+ $hget($gettok($sockname,2,46),time2)
  sockwrite -n $sockname Host: www.rscript.org $+ $crlf $+ $crlf
}
on *:sockread:trackyes.*: {
  if (%row == $null) { set %row 1 }
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
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
    if (*Overall* iswm %rscript) { set %r1 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript) { set %r2 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript) { set %r3 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript) { set %r4 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript) { set %r5 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript) { set %r6 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript) { set %r7 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript) { set %r8 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript) { set %r9 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript) { set %r10 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript) { set %r11 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript) { set %r12 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript) { set %r13 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript) { set %r14 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript) { set %r15 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript) { set %r16 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript) { set %r17 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript) { set %r18 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript) { set %r19 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript) { set %r20 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript) { set %r21 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript) { set %r22 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript) { set %r23 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript) { set %r24 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript) { set %r25 $gettok($nohtml(%rscript),4,58) }
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
  if ($regex(%rscript,/^0:-1$/)) { $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) Has not been tracked by Runescript. $hget($gettok($sockname,2,46),nick) is now being Tracked. | unset %* | sockclose $sockname | halt }
  if (*PHP: Invalid argument supplied for foreach* iswm %rscript) { $hget($gettok($sockname,2,46),out) There is a gap in RScripts Data, data for $hget($gettok($sockname,2,46),nick) could not be found. | unset %* | sockclose $sockname | halt }
  if (*END* iswm %rscript) { lastNdays }
}
alias lastNdays {
  var %x = 50
  while (%x) {
    if (!%r [ $+ [ %x ] ]) { %r [ $+ [ %x ] ] = 0 }
    ;if (%x = 25 && !%r25 && $hget($gettok($sockname,2,46),time) > $calc(%year -1209600)) { %r25 = %25 }
    ;if (%x = 50 && !%r50 && $hget($gettok($sockname,2,46),time) > $calc(%year -1209600)) { %r50 = %25 }
    dec %x
  }
  var %x = 25
  while (%x) {
    if (!% [ $+ [ %x ] ]) { % [ $+ [ %x ] ] = 0 }
    dec %x
  }
  if ($gettok($hget($gettok($sockname,2,46),command),1,32) == Last || $tracks($hget($gettok($sockname,2,46),command)) != nomatch) {
    if (%r1 == 0) { $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall 03+0 exp; | goto unset }
    var %cmb = $sort(Attack %2 %r2 Defence %3 %r3 Strength %4 %r4 Hitpoints %5 %r5 Range %6 %r6 Pray %7 %r7 Mage %8 %r8 Summon %25 %r25)
    if (%cmb) { var %out1 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Combat  $+ $hget($gettok($sockname,2,46),command) $+ : %cmb }
    var %others = $sort(Cook %9 %r9 Woodcut %10 %r10 Fletching %11 %r11 Fishing %12 %r12 Firemake %13 %r13 Crafting %14 %r14 Smithing %15 %r15 Mine %16 %r16 Herblore %17 %r17 Agility %18 %r18 Thieve %19 %r19 Slayer %20 %r20 Farming %21 %r21 Runecraft %22 %r22 Hunter %23 %r23 Construct %24 %r24)
    if (%others) { var %out2 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Others  $+ $hget($gettok($sockname,2,46),command) $+ : %others }
    $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%r1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp;
    %out1
    %out2
  }
  else {
    var %cmb = $sort(Attack $calc(%2 - %r27) $calc(%r2 - %r27) Defence $calc(%3 - %r28) $calc(%r3 - %r28) Strength $calc(%4 - %r29) $calc(%r4 - %r29) Hitpoints $calc(%5 - %r30) $calc(%r5 - %r30) Range $calc(%6 - %r31) $calc(%r6 - %r31) Pray $calc(%7 - %r32) $calc(%r7 - %r32) Mage $calc(%8 - %r33) $calc(%r8 - %r33) Summon $calc(%25 - %r50) $calc(%r25 - %r50))
    if (%cmb) { var %out1 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Combat  $+ $hget($gettok($sockname,2,46),command) $+ : %cmb }
    var %others = $sort(Cook $calc(%9 - %r34) $calc(%r9 - %r34) Woodcut $calc(%10 - %r35) $calc(%r10 - %r35) Fletching $calc(%11 - %r36) $calc(%r11 - %r36) Fishing $calc(%12 - %r37) $calc(%r12 - %r37) Firemake $calc(%13 - %r38) $calc(%r13 - %r38) Crafting $calc(%14 - %r39) $calc(%r14 - %r39) Smithing $calc(%15 - %r40) $calc(%r15 - %r40) Mine $calc(%16 - %r41) $calc(%r16 - %r41) Herblore $calc(%17 - %r42) $calc(%r17 - %r42) Agility $calc(%18 - %r43) $calc(%r18 - %r43) Thieve $calc(%19 - %r44) $calc(%r19 - %r44) Slayer $calc(%20 - %r45) $calc(%r20 - %r45) Farming $calc(%21 - %r46) $calc(%r21 - %r46) Runecraft $calc(%22 - %r47) $calc(%r22 - %r47) Hunter $calc(%23 - %r48) $calc(%r23 - %r48) Construct $calc(%24 - %r49) $calc(%r24 - %r49))
    if (%others) { var %out2 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Others  $+ $hget($gettok($sockname,2,46),command) $+ : %others }
    $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif($calc(%r1 - %r26) > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp;
    %out1
    %out2
  }
  :unset
  hfree $gettok($sockname,2,46)
  unset %*
}
alias sort {
  var %string = $1-
  %exps = $sorttok($regsubex(%string,/((\w+) (\d+) (\d+))/g,\4),32,nr)
  var %x = $numtok(%exps,32)
  var %y = 1
  var %z = 1
  while (%z <= %x) {
    var %p = 1
    while (%p <= $numtok(%string,32)) {
      if ($gettok(%string,$calc(%p +2),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p +2),32) > 0 && $gettok(%string,%p,32) !isin %done) {
        var %levels = $virt($gettok(%string,$calc(%p +1),32)) - $virt($calc($gettok(%string,$calc(%p +1),32) - $gettok(%string,$calc(%p +2),32)))
        %total = $calc(%total + %levels)
      }
      if ($gettok(%string,$calc(%p +2),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p +2),32) > 0 && $gettok(%string,%p,32) !isin %done && $numtok(%done,124) <= 7) {
        var %out = %out 07 $+ $gettok(%string,%p,32) $+  $virt($gettok(%string,$calc(%p +1),32)) $iif(%levels > 0,[+ $+ %levels $+ ]) 03+ $+ $iif($gettok(%string,$calc(%p +2),32) > 1000000,$bytes($round($calc($v1 /1000000),2),db) $+ m,$iif($gettok(%string,$calc(%p +2),32) > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db))) xp;
        var %done = %done $+ | $+ $gettok(%string,%p,32)
      }
      inc %p 3
    }
    inc %y
    inc %z
  }
  return %out
}
on *:sockopen:trackoas.*: {
  sockwrite -n $sockname GET /lookup.php?type=track&user= $+ $hget($gettok($sockname,2,46),nick) $+ &skill=all&time= $+ $hget($gettok($sockname,2,46),time) $+ , $+ %week $+ , $+ %month $+ , $+ %year
  sockwrite -n $sockname Host: www.rscript.org $+ $crlf $+ $crlf
}
on *:sockread:trackoas.*: {
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) There was a socket error.
    halt
  }
  .sockread %rscript
  if (*gain* iswm %rscript) {
    if (*Overall* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r1 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r2 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r3 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r4 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r5 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r6 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r7 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r8 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r9 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r10 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r11 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r12 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r13 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r14 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r15 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r16 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r17 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r18 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r19 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r20 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r21 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r22 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r23 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r24 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript && * $+ $hget($gettok($sockname,2,46),time) $+ * iswm %rscript) { set %r25 $gettok($nohtml(%rscript),4,58) }
    ;
    if (*Overall* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r26 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r27 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r28 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r29 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r30 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r31 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r32 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r33 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r34 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %35 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r36 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r37 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r38 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r39 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r40 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r41 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r42 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r43 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r44 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r45 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r46 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r47 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r48 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r49 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript && * $+ %week $+ * iswm %rscript) { set %r50 $gettok($nohtml(%rscript),4,58) }
    ;
    if (*Overall* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r51 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r52 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r53 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r54 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r55 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r56 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r57 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r58 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r59 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r60 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r61 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r62 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r63 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r64 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r65 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r66 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r67 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r68 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r69 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r70 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r71 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r72 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r73 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r74 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript && * $+ %month $+ * iswm %rscript) { set %r75 $gettok($nohtml(%rscript),4,58) }
    ;
    if (*Overall* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r76 $gettok($nohtml(%rscript),4,58) }
    if (*Attack* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r77 $gettok($nohtml(%rscript),4,58) }
    if (*Defence* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r78 $gettok($nohtml(%rscript),4,58) }
    if (*Strength* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r79 $gettok($nohtml(%rscript),4,58) }
    if (*Hitpoints* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r80 $gettok($nohtml(%rscript),4,58) }
    if (*Ranged* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r81 $gettok($nohtml(%rscript),4,58) }
    if (*Prayer* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r82 $gettok($nohtml(%rscript),4,58) }
    if (*Magic* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r83 $gettok($nohtml(%rscript),4,58) }
    if (*Cooking* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r84 $gettok($nohtml(%rscript),4,58) }
    if (*Woodcutting* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r85 $gettok($nohtml(%rscript),4,58) }
    if (*Fletching* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r86 $gettok($nohtml(%rscript),4,58) }
    if (*Fishing* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r87 $gettok($nohtml(%rscript),4,58) }
    if (*Firemaking* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r88 $gettok($nohtml(%rscript),4,58) }
    if (*Crafting* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r89 $gettok($nohtml(%rscript),4,58) }
    if (*Smithing* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %90 $gettok($nohtml(%rscript),4,58) }
    if (*Mining* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r91 $gettok($nohtml(%rscript),4,58) }
    if (*Herblore* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %92 $gettok($nohtml(%rscript),4,58) }
    if (*Agility* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r93 $gettok($nohtml(%rscript),4,58) }
    if (*Thieving* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r94 $gettok($nohtml(%rscript),4,58) }
    if (*Slayer* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r95 $gettok($nohtml(%rscript),4,58) }
    if (*Farming* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r96 $gettok($nohtml(%rscript),4,58) }
    if (*Runecraft* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r97 $gettok($nohtml(%rscript),4,58) }
    if (*Hunter* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r98 $gettok($nohtml(%rscript),4,58) }
    if (*Construction* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r99 $gettok($nohtml(%rscript),4,58) }
    if (*Summoning* iswm %rscript && * $+ %year $+ * iswm %rscript) { set %r100 $gettok($nohtml(%rscript),4,58) }
  }
}
on *:sockclose:trackoas.*: {
  :unset
  unset %row
  oatrack
}
alias oatrack {
  sockopen $+(trackoas2.,$gettok($sockname,2,46)) hiscore.runescape.com 80
}
on *:sockopen:trackoas2.*: {
  .sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget($gettok($sockname,2,46),nick) HTTP/1.1
  .sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:trackoas2.*: {
  if (%row == $null) { set %row 1 }
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
    halt
  }
  .sockread %stats
  if (%row < 100) {
    set % [ $+ [ %row ] ] %stats
    if ($gettok(%stats,2,44) == -1 && %row < 36 && %row > 11) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
    if ($gettok(%stats,2,44) != -1 && %row < 36 && %row > 11) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
    inc %row 1
  }
}
on *:sockclose:trackoas2.*: {
  if (%12) {
    var %x = 1,%y = 1
    hadd -m $gettok($sockname,2,46) rankeds 0
    while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
      hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
      inc %x 1
    }
    set %unranked $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
    while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
      set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ ~ $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
      inc %y 1
    }
  }
  set %skill $skills($hget($gettok($sockname,2,46),skill))
  set %lvl $virtual($gettok(% [ $+ [ $statn(%skill) ] ],3,44))
  set %alvl $gettok(% [ $+ [ $statn(%skill) ] ],2,44)
  set %exp $gettok(% [ $+ [ $statn(%skill) ] ],3,44)
  set %rank $gettok(% [ $+ [ $statn(%skill) ] ],1,44)
  if ($hget($gettok($sockname,2,46),id) != stats) { $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) 07Overall | Rank:07 $iif($gettok(% [ $+ [ $statn(%skill) ] ],1,44) isnum,$bytes($gettok(% [ $+ [ $statn(%skill) ] ],1,44),db),$gettok(% [ $+ [ $statn(%skill) ] ],1,44)) | Level: $skill2b(% [ $+ [ $statn(%skill) ] ],2) $iif(%skill != overall,(07 $+ $virtual($gettok(% [ $+ [ $statn(%skill) ] ],3,44)) $+ )) | Exp:07 $bytes($gettok(% [ $+ [ $statn(%skill) ] ],3,44),db) }
  $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),command) $+ :03 $bytes(%r1,db) xp03 %todaylv | Week:03 $bytes(%r26,db) xp03 %weeklv | Month:03 $bytes(%r51,db) xp03 %monthlv | Year:03 $bytes(%r76,db) xp03 %yearlv
  :unset
  hfree $gettok($sockname,2,46)
  unset %*
}
