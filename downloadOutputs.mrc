; CLAN
alias getClans {
  var %user = $1, %out = $2 $3, %clan = $4, %thread = $5
  .tokenize 10 $6-
  var %x = 1, %clans
  while (%x <= $0) {
    if ($numtok($ [ $+ [ %x ] ],124) == 2) { %clans = %clans $+ , 07 $+ $gettok($ [ $+ [ %x ] ],1,124) $+  | %url = $gettok($ [ $+ [ %x ] ],2,124) }
    inc %x
  }
  if ($len($right(%clans,-2)) != 0) { %out %user is in $numtok(%clans,44) %clan $+ $iif($numtok(%clans,44) > 1,s) $+ : $right(%clans,-2) $iif($numtok(%clans,44) == 1,(07 $+ %url $+ )) | hinc %thread loops }
  else { hinc %thread count | hinc %thread loops }
  if ($hget(%thread,count) == 2) { %out No record for07 %user found at 12www.runehead.com }
  if ($hget(%thread,loops) == 2) { hfree %thread }
}
; %
alias cmbpercent {
  var %saystyle = $1 $2, %nick = $3, %socket = $4
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle  $+ %nick $+  does not feature Hiscores | halt }
  ; Standard
  var %cmblvl = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).p2p
  var %combatexp = 0
  var %x = 2
  while (%x <= 8) {
    var %combatexp = $calc(%combatexp + $gettok($($ $+ %x,2),3,44))
    inc %x
  }
  var %combatexp = $calc(%combatexp + $gettok($25,3,44))
  set %cmb 0, $+ %cmblvl $+ , $+ %combatexp
  var %avg = $iif(%state == 4,$round($calc($gettok($1,4,44) /24),1),$regsubex($gettok($1,2,44),/(\d+)/,$round($calc(\1 / 24),1))))
  ; F2P Exp
  var %f2pxp = $calc( $gettok($2,3,44) + $gettok($3,3,44) + $gettok($4,3,44) + $gettok($5,3,44) + $gettok($6,3,44) + $gettok($7,3,44) + $gettok($8,3,44) + $gettok($9,3,44) + $gettok($10,3,44) + $gettok($12,3,44) + $gettok($13,3,44) + $gettok($14,3,44) + $gettok($15,3,44) + $gettok($16,3,44) + $gettok($22,3,44) )
  ; PC% calc
  var %current = $calc($gettok($2,3,44) + $gettok($3,3,44) + $gettok($4,3,44) + $gettok($5,3,44) + $gettok($6,3,44))
  var %expected = $calc($gettok($5,3,44) + $gettok($5,3,44) * 12 / 4 )
  var %pc = $calc(%expected / %current * 100)
  ; Slayer% calc
  var %slaybasedcmb = $calc( (($gettok($20,3,44) * 4 / 3)/ $gettok($5,3,44) )*100)
  ; Output
  %saystyle Statistic Percentages for07 %nick | Total Exp:07 $bytes($gettok($1,3,44),db) | Combat Exp:07 $bytes(%combatexp,db) | F2P Exp:07 $bytes(%f2pxp,db) | Combat%07 $round($calc((%combatexp / $gettok($1,3,44))*100),1) $+ % | $&
    F2P%07 $round($calc((%f2pxp / $gettok($1,3,44))*100),1) $+ % | Slay%07 $round(%slaybasedcmb,1) $+ % | PC%07 $round($calc(100-%pc),2) $+ %
}
; HILOW
alias stats.hilow {
  ; reset variables
  var %saystyle = $1 $2, %nick = $3, %state = $4, %string
  ; guess + format skills
  .tokenize 10 $distribute($5)
  ; catch lookup errors
  if ($1 == unranked) { goto unranked }
  else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  ; SORT
  ; form string for sorting by old alias 'skill exp'
  var %x = 2
  while (%x <= 25) {
    %string = %string %x $gettok($($ $+ %x,2),%state,44)
    inc %x
  }
  ; order high-low or low-high
  var %order
  if (%state == 3) { %order = nr }
  else { %order = n }
  ; give unranked a high rank so it will sort last
  %string = $replace(%string,NR,2000001)
  ; sort the string
  %string = $sorthilow(%string,%order)
  ; output - highest
  var %x = 1
  while (%x <= 2) {
    var %skillid = $gettok(%string,%x,32)
    var %skill = $($ $+ %skillid,2)
    var %high = %high $iif(%x == 2,followed by ) 07 $+ $statnum(%skillid) level07 $gettok(%skill,2,44) $+  $iif(%state == 1,ranked,with) $+ 07 $regsubex($gettok(%skill,%state,44),/(\d+)/,$bytes(\1,db)) $+ $iif(%state == 3,$chr(32) $+ exp,) $+ .
    inc %x
  }
  ; output - lowest
  var %x = 24
  while (%x >= 23) {
    var %skillid = $gettok(%string,%x,32)
    var %skill = $($ $+ %skillid,2)
    var %low = %low $iif(%x == 23,followed by ) 07 $+ $statnum(%skillid) level07 $gettok(%skill,2,44) $+  $iif(%state == 1,ranked,with) $+ 07 $regsubex($gettok(%skill,%state,44),/(\d+)/,$bytes(\1,db)) $+ $iif(%state == 3,$chr(32) $+ exp,) $+ .
    dec %x
  }
  ; spit out output
  %saystyle  $+ %nick $+  highest skills: %high
  %saystyle  $+ %nick $+  lowest skills: %low
  ;cleanup
  goto unset
  :unranked
  %saystyle  $+ %nick $+  does not feature hiscores.
  :unset
  unset %*
}
; NEXT
alias stats.next {
  ; reset variables
  var %saystyle = $1 $2, %nick = $3, %state = $4, %string
  ; guess + format skills
  .tokenize 10 $distribute($5)
  ; catch lookup errors
  if ($1 == unranked) { goto unranked }
  if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  ; SORT
  ; form string for sorting by old alias 'skill exp lvl'
  var %x = 2, %lvl, %xp, %xptogo
  while (%x <= 25) {
    %xp = $gettok($($ $+ %x,2),%state,44)
    %lvl = $xptolvl(%xp)
    %xptogo = $calc($lvltoxp($calc(%lvl + 1)) - %xp)
    %string = %string %x %xptogo %lvl
    inc %x
  }
  ; sort the string
  %string = $sortnext(%string)
  ; output - closest
  var %out1 = $gettok(%string,1-24,32)
  var %out2 = $gettok(%string,25-,32)
  ; spit out output
  %saystyle  $+ %nick $+  closest skills: %out1
  %saystyle  $+ %nick $+  closest skills: %out2
  ;cleanup
  goto unset
  :unranked
  %saystyle  $+ %nick $+  does not feature hiscores.
  :unset
  unset %*
}
; IQ
alias spam.iq {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle  $+ %nick $+ 's IQ level is:07 60 | halt }
  %info =  $+ %nick $+ 's IQ level is:07
  if ($gettok($1,2,44) > 1800) { %info = %info $floor($calc($v1 / 21 + $gettok($20,2,44))) }
  else if ($gettok($4,2,44) < 90) { %info = %info $floor($calc($gettok($1,2,44) / 21 + $gettok($21,2,44))) }
  else { %info = %info $floor($calc($gettok($1,2,44) / 21 - $gettok($4,2,44) + 50)) }
  %saystyle %info
}
; LIFE
alias spam.life {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info, %lvl, %xp, %newlvl, %newxp
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle  $+ %nick $+  07life | Rank:07 424,597 | Level:07 45 (0745) $(|,) Exp:07 63,572 (070.49% of 99) $(|,) Exp till 46:07 4,411 (31.8%) | halt }
  .tokenize 44 $1
  %lvl = 126 - $xptolvl($calc($3 / 24))
  %xp = $calc( ( $floor($calc($3 / 24)) - $lvltoxp($xptolvl($calc($3 / 24))) ) / ( $lvltoxp($calc($xptolvl($calc($3 / 24)) +1)) - $lvltoxp($xptolvl($calc($3 / 24))) ) )
  %newxp = $floor( $calc( $lvltoxp(%lvl) + %xp * ( $lvltoxp($calc(%lvl +1)) - $lvltoxp(%lvl) ) ) )
  %newlvl = $calc( $lvltoxp($calc(%lvl +1)) - %newxp )
  %saystyle  $+ %nick $+  07life | Rank:07 $remove($bytes($floor($calc( (($3 / 24) / 200) * 4 ) ),db),-) | Level:07 %lvl | Exp:07 $bytes(%newxp,db) | Exp till $calc(%lvl +1) $+ :07 $bytes(%newlvl,db) (07 $+ $remove($round($calc( %xp * 100 ),1),-) $+ 07%)
}
; EPENIS
alias spam.epenis {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle 07 $+ %nick $+ 's e-penis is07 6 Inches. | halt }
  %saystyle  $+ %nick $+ 's epenis is07 $round($calc( $gettok($1,2,44) / 200 + $gettok($21,3,44) / 1000000 ),1) Inches.
}
; GELINK
alias downloadGe {
  if (!$2) {
    _throw downloadGe $1
    return
  }
  var %thread $1
  .tokenize 10 $2-
  var %x = 1
  while (%x <= $0) {
    var %line = $($ $+ %x,2)
    var %id = $gettok(%line,1,44), %name = $gettok(%line,2,44), %price = $gettok(%line,3,44), %change = $iif($gettok(%line,4,44) != 0,$v1,NULL)
    var %oldPrice = $getPrice(%id)
    if (%oldPrice > 0) { inc %x | continue }
    else if (%oldPrice == $null) { noop $sqlite_query(1, INSERT INTO prices (id, name, price, change) VALUES (' $+ %id $+ ',' $+ %name $+ ',' $+ %price $+ ',' $+ %change $+ ');) }
    else if (%oldPrice == $false) { noop $dbUpdate(prices,`id`=' $+ %id $+ ', price, %price, change, %change) }
    inc %x
  }
  if ($cmd(%thread, out)) {
    var %num $cmd(%thread,arg1), %search $cmd(%thread,arg2)
    var %numberOfResults $countResults($getPrice(%search).sql)
    var %dbPrices $getPrice(%search)
    .tokenize 44 %dbPrices
    var %x = 1, %results
    while (%x <= $0) {
      var %name = $gettok($($ $+ %x,2),1,59), %price = $gettok($($ $+ %x,2),2,59), %change = $gettok($($ $+ %x,2),3,59)
      %results = %results | %name $+ 07 $format_number(%price) $updo(%change) 
      inc %x
    }
    $cmd(%thread,out) Results:07 %numberOfResults %results
    _clearCommand %thread
  }

  if (!$error) goto end
  :error
  reseterror
  _throw geLink %thread
  halt
  :end
}
alias updo {
  var %price = $litecalc($1)
  if (%price > 0) { return 03[+ $+ $format_number($trim($1)) $+ 03] }
  if (%price < 0) { return 04[ $+ $format_number($trim($1)) $+ 04] }
  return
}
; GEINFO
alias geInfo {
  var %thread $1
  var %geInfo $remove($2-,$cr,$lf)
  .tokenize 44 %geInfo
  if ($0 == 1) { _throw geInfo %thread | halt }
  if (!$getPrice($1)) noop $setPrice($1,$4)
  $cmd(%thread,out)  $+ $2 $+  | Min:07 $format_number($3) Avg:07 $format_number($4) Max:07 $format_number($5) | 30 Days:07 $6 $+ $% | 90 Days:07 $7 $+ $% | 180 Days:07 $8 $+ $% | 12http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $1
}
; SKILLPLAN
alias skillplan.out {
  var %saystyle = $hget($gettok($sockname,2,46),out)
  var %amount = $hget($gettok($sockname,2,46),amount)
  var %nick = $hget($gettok($sockname,2,46),nick)
  var %item = $hget($gettok($sockname,2,46),item)
  var %skill = $hget($gettok($sockname,2,46),skill)
  if (!%1) { %saystyle  $+ %nick does not feature Hiscores. | goto unset }
  if ($gettok(%1,2,44) > 100) {
    var %x = 1,%y = 1
    hadd -m $gettok($sockname,2,46) rankeds 0
    while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
      hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
      inc %x 1
    }
    set %unranked $round($calc(($gettok(%1,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
    while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
      set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
      inc %y 1
    }
  }
  if ($gettok(%1,2,44) < 100) {
    var %v = 24
    var %w = 0
    while (%v > 0) {
      var %w = %w + $remove($gettok(% [ $+ [ $calc(%v +1) ] ],2,44),-)
      if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v != 4) { set % [ $+ [ $calc(%v +1) ] ] Unranked,1,0 }
      if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v == 4) { set %5 Unranked,10,1154 | var %w = %w + 9 }
      dec %v 1
    }
    var %x = 24
    var %y = 0
    while (%x > 0) {
      var %y = %y + $replace($gettok(% [ $+ [ $calc(%x +1) ] ],3,44),-1,0)
      dec %x 1
    }
    set %1 Unranked, $+ $calc(%w) $+ , $+ $calc(%y)
  }
  var %skillinfo = $(% $+ $statnum(%skill),2)
  var %lev = $virtual($gettok(%skillinfo,3,44))
  var %exp = $gettok(%skillinfo,3,44)
  var %file = %skill $+ .txt
  var %iteminfo = $read(%file, w, * $+ %item $+ *)
  var %itemname = $gettok(%iteminfo,1,9)
  var %itemexpe = $gettok(%iteminfo,2,9)
  if (!%iteminfo) { %saystyle Invalid item07 %item $+ . List of valid items available at12 http://p-gertrude.rsportugal.org/gerty/commands.html | goto unset }
  %saystyle  $+ %nick Current  $+ %skill $+  level:07 %lev ( $+ $bytes(%exp,db) $+ ) $chr(124) experience for %amount %itemname $+ 's:07 $bytes($calc( %amount * %itemexpe ),db) $&
    ( $+ %itemexpe each) $chr(124) resulting level:07 $virtual($calc( %exp + ( %amount * %itemexpe ) )) ( $+ $bytes($calc( %exp + ( %amount * %itemexpe ) ),db) $+ )
  :unset
  .hfree $gettok($sockname,2,46)
  unset %*
  sockclose $sockname
  halt
}
; TOP
alias topOut {
  var %thread $1, %hiscores $2-, %user
  .tokenize 10 %hiscores
  var %x 1, %output $+(,$cmd(%thread,arg1),) ranks:, %u
  while (%x <= 10) {
    %user = $($ $+ %x,2)
    if ($gettok(%user,1,58) == $cmd(%thread,arg2) || $gettok(%user,2,58) == $cmd(%thread,arg3)) { %u = $chr(31) }
    %output = %output $+(07#,$gettok(%user,1,58),) %u $+ $gettok(%user,2,58) $+ %u $+(07,$gettok(%user,3,58),) $+ $iif($gettok(%user,4,58),$chr(32) $+ ( $+ $v1 $+ );,;)
    unset %u
    inc %x
  }  
  $cmd(%thread,out) %output
  _clearcommand %thread
}
; TASK
alias taskOut {
  var %thread $1, %hiscores $2-
  .tokenize 10 %hiscores
  .tokenize 44 $20

  var %info = $read(slayer.txt,w,* $+ $replace($hget(%thread,arg3),_,$chr(32)) $+ *)
  var %taskxp = $calc( $gettok(%info,2,9) * $hget(%thread,arg2) )
  $hget(%thread,out) Next Task:07 $bytes($hget(%thread,arg2),db) $gettok(%info,1,9) | Current Exp:07 $bytes($3,db) (07 $+ $virtual($3) $+ ) | Exp this Task:07 $bytes(%taskxp,db) $&
    | Exp After Task:07 $bytes($calc($3 + %taskxp),db) | Which is Level:07 $virtual($calc($3 + %taskxp )) $&
    | With:07 $bytes($calc( $lvltoxp($calc($virtual($calc($3 + %taskxp)) +1)) - ($3 + %taskxp)),db) exp till level07 $calc($virtual($calc($3 + %taskxp)) +1)
  _clearCommand %thread
}
alias plural {
  if ($right($1,1) == s) return $left($1,-1)
  return $1
}
; SKILL TIMER
alias timer.start {
  var %saystyle = $1 $2, %skill = $3, %skillid = $4, %nick = $caps($5)
  .tokenize 10 $distribute($6)
  if ($1 == unranked) { goto unranked }
  else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  .tokenize 44 $($ $+ %skillid,2)
  ; save start
  ; output
  %saystyle  $+ %nick $+ 's starting experience of07 $bytes($3,db) in  $+ %skill $+  has been saved.
  goto unset
  :unranked
  %saystyle  $+ %nick $+  does not feature Hiscores.
  :unset
  noop $_network(writeini -n timer.ini %nick skill %skill)
  noop $_network(writeini -n timer.ini %nick start $3)
  noop $_network(writeini -n timer.ini %nick starttime $ctime($date $time))
}
alias timer.check {
  var %saystyle = $1 $2, %nick = $5
  var %skill = $readini(timer.ini,%nick,skill), %skillid = $statnum(%skill)
  .tokenize 10 $distribute($6)
  else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  .tokenize 44 $($ $+ %skillid,2)
  ; changes
  var %expchange = $calc($3 - $readini(timer.ini,%nick,start))
  var %timechange = $calc($ctime($date $time) - $readini(timer.ini,%nick,starttime))
  var %exp.hour = $calc( 3600 * %expchange / %timechange )
  var %exp.second = $calc( %expchange / %timechange )
  var %target = $lvlceil($3), %goal = $lvltoxp(%target)
  ; check for goal in skill
  var %userAddress $iif($aLfAddress(%nick), $v1, %nick)
  var %boolRsn $iif($aLfAddress(%nick), $false, $true)
  if ($getStringParameter(%userAddress,%skill,goals,%boolRsn)) {
    %goal = $v1
    %target = $xptolvl(%goal)
  }
  ; output
  %saystyle  $+ %nick $+  gained07 $bytes(%expchange,db)  $+ %skill $+  experience in07 $duration(%timechange) $+ . That's07 $bytes($round(%exp.hour,0),db) exp/hour so far. $&
    Estimated time till %target $+ :07 $iif(%exp.hour == 0,Infinite,$duration($calc( (%goal - $3) / %exp.second )))
  :unset
}
alias timer.end {
  var %saystyle = $1 $2, %nick = $5
  var %skill = $readini(timer.ini,%nick,skill), %skillid = $statnum(%skill)
  .tokenize 10 $distribute($6)
  else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  .tokenize 44 $($ $+ %skillid,2)
  ; changes
  var %expchange = $calc($3 - $readini(timer.ini,%nick,start))
  var %timechange = $calc($ctime($date $time) - $readini(timer.ini,%nick,starttime))
  var %exp.hour = $calc( 3600 * %expchange / %timechange )
  var %exp.second = $calc( %expchange / %timechange )
  var %target = $lvlceil($3), %goal = $lvltoxp(%target)
  ; check for goal in skill
  var %userAddress $iif($aLfAddress(%nick), $v1, %nick)
  var %boolRsn $iif($aLfAddress(%nick), $false, $true)
  if ($getStringParameter(%userAddress,%skill,goals,%boolRsn)) {
    %goal = $v1
    %target = $xptolvl(%goal)
  }
  ; output
  %saystyle  $+ %nick $+  gained07 $bytes(%expchange,db)  $+ %skill $+  experience in07 $duration(%timechange) $+ . That's07 $bytes($round(%exp.hour,0),db) exp/hour. $&
    Estimated time till %target $+ :07 $iif(%exp.hour == 0,Infinite,$duration($calc( (%goal - $3) / %exp.second )))
  noop $_network(remini timer.ini %nick)
  :unset
  return
  :unranked
}
; URBAN
alias urban {
  var %thread = $1, %urban = $2-
  .tokenize 10 %urban
  if (MATCHES: 0 isin $3) {
    $cmd(%thread,out) Urban Dictionary has no entry for ' $+ $cmd(%thread,arg1) $+ '.
    _clearCommand %thread
    halt
  }
  if (DEFINED: isin $4) {
    $cmd(%thread,out) Urban Dictionary: ' $+ $cmd(%thread,arg1) $+ ' $nohtml($regsubex($gettok($4,2,58),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32))))
  }
  if (EXAMPLE: isin $5) {
    $cmd(%thread,out) Example: $nohtml($regsubex($gettok($5,2,58),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32))))
  }
  _clearCommand %thread
}
; TRACK
alias trackAll {
  var %saystyle = $1 $2, %nick = $3, %time = $4, %command = $regsubex($5,/(\d)([a-z])/gi,\1$chr(32)\2)
  if ($voidRscript($6)) {
    %saystyle Error Occured:07 $v1
    goto unset
  }
  .tokenize 32 $timetoday
  var %today = $1, %week = $2, %month = $3, %year = $4
  if (%r1 == 0) { %saystyle  $+ %nick Skills  $+ %command $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%r1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp; | unset %* | goto unset }
  var %cmb = $sort(Attack %2 %r2 Defence %3 %r3 Strength %4 %r4 Hitpoints %5 %r5 Range %6 %r6 Pray %7 %r7 Mage %8 %r8 Summon %25 %r25)
  if (%cmb) { var %out1 = %saystyle  $+ %nick Combat  $+ %command $+ : %cmb }
  var %others = $sort(Cook %9 %r9 Woodcut %10 %r10 Fletching %11 %r11 Fishing %12 %r12 Firemake %13 %r13 Crafting %14 %r14 Smithing %15 %r15 Mine %16 %r16 Herblore %17 %r17 Agility %18 %r18 Thieve %19 %r19 Slayer %20 %r20 Farming %21 %r21 Runecraft %22 %r22 Hunter %23 %r23 Construct %24 %r24)
  if (%others) { var %out2 = %saystyle  $+ %nick Others  $+ %command $+ : %others }
  %saystyle  $+ %nick Skills  $+ %command $+ : 07Overall $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%r1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp;
  %out1
  %out2
  :unset
  unset %*
}
alias voidRscript {
  var %string = $1-
  if (PHP isin %string) { return Gap in Database }
  if ($regex(%string,/\n0:-1\n/)) { return Not Tracked }
  .tokenize 10 %string
  var %x = 1, %current, %gain, %line
  while (%x <= $0) {
    %line = $($ $+ %x,2)
    if ($numtok(%line,58) < 3 || !$skills($gettok(%line,2,58))) {
      inc %x
      continue
    }
    if ($gettok(%line,1,58) == start) %current = %current $+ $chr(9) $+ %line
    else %gain = %gain $+ $chr(9) $+ %line
    inc %x
  }
  ; Exp
  %x = 1
  while (%x <= $numtok(%current,9)) {
    %line = $gettok(%current,%x,9)
    % [ $+ [ $statnum($gettok(%line,2,58)) ] ] = $gettok(%line,3,58)
    inc %x
  }
  ; Gains
  %x = 1
  while (%x <= $numtok(%gain,9)) {
    %line = $gettok(%gain,%x,9)
    %r [ $+ [ $statnum($gettok(%line,2,58)) ] ] = $gettok(%line,4,58)
    inc %x
  }
  ; Unranked Skills (no guessing /effort)
  %x = 1
  while (%x <= 25) {
    if (!% [ $+ [ %x ] ]) { % [ $+ [ %x ] ] = 0 }
    if (!%r [ $+ [ %x ] ]) { %r [ $+ [ %x ] ] = 0 }
    inc %x
  }
  return
}
alias lastNdays {
  var %x = 50
  while (%x) {
    if (!%r [ $+ [ %x ] ]) { %r [ $+ [ %x ] ] = 0 }
    dec %x
  }
  var %x = 25
  while (%x) {
    if (!% [ $+ [ %x ] ]) { % [ $+ [ %x ] ] = 0 }
    dec %x
  }
  if ($gettok($hget($gettok($sockname,2,46),command),1,32) == Last || $tracks($hget($gettok($sockname,2,46),command))) {
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
