>start<|statsfetch.mrc|another rscript bug covered|3.2|rs
on $*:TEXT:/^[!@.]/Si:*: {
  _CheckMain
  if ($lookups($right($1,-1)) == nomatch) { halt }
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %saystyle = $saystyle($left($1,1),$nick,$chan)
  var %string = $2-
  var %param = null, %presetparam = yes
  if ($regex(%string,/@([^@#]+)/)) {
    %param = $regml(1)
    %presetparam = no
    %string = $regsubex(%string,/@([^@#]+)/,$null)
  }
  var %goal = nl, %presetgoal = yes
  if ($regex(%string,/(?:#|goal=)([nl0-9]+[mkb]?)/)) {
    %goal = $regml(1)
    %presetgoal = no
    %string = $regsubex(%string,/(?:#|goal=)([nl0-9]+[mkb]?)/,$null)
  }
  var %lessthan = 200000001
  if ($regex(%string,/<([0-9]+[mkb]?)/)) {
    %lessthan = $litecalc($regml(1))
    %string = $regsubex(%string,/<([nlr0-9]+[mkb]?)/,$null)
  }
  var %morethan = 0
  if ($regex(%string,/>([0-9]+[mkb]?)/)) {
    %morethan = $litecalc($regml(1))
    %string = $regsubex(%string,/>([nlr0-9]+[mkb]?)/,$null)
  }
  if ($regex(eq,%string,/=([0-9]+[mkb]?)/)) {
    if ($litecalc($regml(eq,1)) < 127) {
      %morethan = $lvltoxp($v1)
      %lessthan = $calc($lvltoxp($calc($litecalc($regml(eq,1)) + 1)) + 1)
    }
    else {
      %morethan = $litecalc($regml(eq,1))
      %lessthan = $litecalc($regml(eq,1) + 1)
    }
    %string = $regsubex(%string,/=([nlr0-9]+[mkb]?)/,$null)
  }
  var %nick = $rsn($nick)
  if ($len($trim(%string)) > 0) {
    %nick = $trim(%string)
    %nick = $rsn(%nick)
  }
  %nick = $left($caps(%nick),12)
  if (%param == next) {
    var %command = next
    var %state = 3
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(stats. $+ %command %saystyle %nick %state,stats. $+ %thread,%url)
    goto unset
  }
  %param = $replace(%param,$chr(32),~)
  var %skill = $lookups($right($1,-1))
  var %skillid = null
  if ($statnum(%skill)) { %skillid = $v1 }
  var %socket = stats. $+ %thread
  var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill=all&time=10000
  noop $download.break(die,%socket $+ 1,%url)
  var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
  noop $download.break(stats %saystyle $replace(%skill,$chr(32),_) %skillid %nick %param %goal %morethan %lessthan %socket %presetgoal %presetparam null,%socket,%url)
  :unset
  unset %*
}
alias stats {
  var %saystyle = $1 $2, %skill = $replace($3,_,$chr(32)), %skillid = $4, %nick = $5, %param = $replace($6,~,$chr(32)), %goal = $7, %morethan = $8, %lessthan = $9, %socket = $10, %presetgoal = $11, %presetparam = $12, %time = $13
  .tokenize 10 $distribute($14)
  if ($1 == unranked) { goto unranked }
  else if (!$1 || !$2) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
  if ($skills(%skill) != nomatch) {
    .tokenize 44 $($ $+ %skillid,2)
    var %endgoal = $iif($3 < 13034431,13034431,200000000)
    var %endgoalname = $iif($3 < 13034431,99,max)
    var %vlvl = $xptolvl($3)
    var %info =  $+ %nick $+ 07 $lower(%skill) $(|,) Rank:07 $regsubex($1,/^(\d+)$/,$bytes(\1,db)) $(|,) Level:07 $regsubex($2,/^(\d+)$/,$bytes(\1,db)) $&
       $+ $iif(%skill != overall,(07 $+ %vlvl $+ ) $+ $chr(32)) $+ $(|,) Exp:07 $bytes($3,db) $+ 
    if (%skill == overall || $3 == 200000000) { goto skillreply }
    var %info = %info (07 $+ $round($calc( 100 * $3 / %endgoal),1) $+ % of %endgoalname $+ )
    ; Exp to goal
    if (%presetgoal == yes) {
      if ($userset(%nick,%skillid $+ goal)) {
        %goal = $v1
        %target = $userset(%nick,%skillid $+ target)
      }
    }
    if ((%goal > 126 && %goal <= $3) || (%goal < 127 && %goal <= $2)) { %goal = nl | unset %target }
    if (%goal == nl) { %goal = $calc(%vlvl + 1) }
    if (%goal == 127) { %goal = 200000000 }
    if ($calculate(%goal) < 127 && !%target) { var %target = %goal | %goal = $lvltoxp(%goal) }
    else if (!%target) { var %target = $format_number(%goal) }
    %goal = $calculate(%goal)
    if (%goal <= $3 && $3 < 188884740) { %target = $calc(%vlvl + 1) | %goal = $lvltoxp(%target) }
    else if (%goal <= $3) { %target = 200m | %goal = 200000000 }
    if (%goal > 200000000) { %goal = 200000000 | %target = 200m }
    var %exptogo = $calc(%goal - $3)
    if (%presetgoal == no) {
      noop $_network(writeini -n user.ini %nick %skillid $+ goal %goal)
      noop $_network(writeini -n user.ini %nick %skillid $+ target %target)
    }
    var %info = %info | exp till %target $+ :07 $bytes(%exptogo,db) (07 $+ $round($calc(100 * ($3 - $lvltoxp(%vlvl)) / (%goal - $lvltoxp(%vlvl))),1) $+ $(%,) $+ )
    ; Items to next level
    if (%presetparam == yes) {
      if ($userset(%nick,%skillid $+ param)) {
        %param = $v1
      }
    }
    if ($litecalc(%param)) {
      %param = $litecalc(%param)
      var %itemstogo = $ceil($calc( %exptogo / %param ))
      var %items = (07 $+ $bytes(%itemstogo,db) items to go.)
    }
    else if (%param != null) {
      var %file = %skill $+ .txt
      .fopen %socket %file
      if ($ferr) { goto skillreply }
      while (!$feof) {
        var %line = $fread(%socket)
        if (%param isin %line) {
          var %itemstogo = $ceil($calc( %exptogo / $gettok(%line,2,9) ))
          var %items = (07 $+ $bytes(%itemstogo,db) $gettok(%line,1,9) $+ )
          break
        }
      }
      if (!%itemstogo) { var %items = (Unknown Item) }
      else if (%presetparam == no) {
        noop $_network(writeini -n user.ini %nick %skillid $+ param $gettok(%line,1,9))
      }
      .fclose %socket
    }
    :skillreply
    %saystyle %info %items
    if (!%itemstogo && %param != null) { %saystyle Here is a list of valid params for use with Gerty:12 http://hng.av.it.pt/~jdias/gerty/param.html }
    rscript.singleskill %socket %nick %skill %saystyle %time
    goto unset
  }
  if (%skill == stats) {
    if (%param == null) { %param = lvl }
    var %state = $state(%param)
    var %average = $iif(%state == 4,$round($calc($gettok($1,4,44) /24),1),$regsubex($gettok($1,2,44),/(\d+)/,$round($calc(\1 / 24),1))))
    if (((%morethan > 100 && %morethan < 200000001) || ($xptolvl(%morethan) > 100 && %morethan < 200000001) || (%lessthan > 100 && %lessthan < 200000001) || ($xptolvl(%lessthan) > 100 && %lessthan < 200000001)) && %state == 2) { %state = 4 }
    var %info =  $+ %nick $+  07all skills | Rank:07 $regsubex($gettok($1,1,44),/(\d+)/,$bytes(\1,db)) | Level:07 $iif(%state == 4,$bytes($gettok($1,4,44),db),$regsubex($gettok($1,2,44),/(\d+)/,$bytes(\1,db))) (avg lvl:07 %average $+ ) | Exp:07 $regsubex($gettok($1,3,44),/(\d+)/,$bytes(\1,db))
    if (%state == 3) {
      var %combatexp = 0
      var %x = 2
      while (%x <= 8) {
        var %combatexp = $calc(%combatexp + $gettok($($ $+ %x,2),3,44))
        inc %x
      }
      var %combatexp = $calc(%combatexp + $gettok($25,3,44))
    }
    if (%state != 4) { var %cmbstate = 2 }
    else { var %cmbstate = 4 }
    var %cmball = $calccombat($gettok($2,%cmbstate,44),$gettok($3,%cmbstate,44),$gettok($4,%cmbstate,44),$gettok($5,%cmbstate,44),$gettok($6,%cmbstate,44),$gettok($7,%cmbstate,44),$gettok($8,%cmbstate,44),$gettok($25,%cmbstate,44),%combatexp).all
    var %combat
    var %x = 2
    while (%x <= 8) {
      %combat = %combat $validate($($ $+ %x,2),%state,%morethan,%lessthan,%x,%average)
      inc %x
    }
    %combat = %combat $validate($25,%state,%morethan,%lessthan,25,%average) %cmball
    var %others
    %x = 9
    while (%x <= 24) {
      %others = %others $validate($($ $+ %x,2),%state,%morethan,%lessthan,%x,%average)
      inc %x
    }
    inc %x
    var %minigames
    while (%x <= 29) {
      if (%state > 2) { %state = 2 }
      if ($gettok($($ $+ %x,2),%state,44) != NR) { %minigames = %minigames 03 $+ $bytes($gettok($($ $+ %x,2),%state,44),db) $+  $statnum(%x) $+ ; }
      inc %x
    }
    :statreply
    %saystyle %info
    if (%combat) { %saystyle combat: %combat }
    if (%others) { %saystyle Other: %others }
    if (%minigames) { %saystyle Minigame: %minigames }
    goto unset
  }
  if (%skill == combat) {
    var %f2p = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).f2p
    var %p2p = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).p2p
    var %gf2p = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).gf2p
    var %gp2p = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).gp2p
    var %class = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).class
    var %combatexp = 0
    var %x = 2
    while (%x <= 8) {
      var %combatexp = $calc(%combatexp + $gettok($($ $+ %x,2),3,44))
      inc %x
    }
    var %combatexp = $calc(%combatexp + $gettok($25,3,44))
    var %info =  $+ %nick $+  07combat | level:07 $floor(%p2p) $+ (07~ $+ $floor(%gp2p) $+ ) (f2p:07 $floor(%f2p) $+ ) | exp:07 $bytes(%combatexp,db) | class:07 %class
    var %average = $round($calc($gettok($1,2,44) / 24),1)
    if (%param == null) { %param = 2 }
    var %state = $state(%param)
    var %combat
    var %x = 2
    while (%x <= 8) {
      %combat = %combat $validate($($ $+ %x,2),%state,%morethan,%lessthan,%x,%average)
      inc %x
    }
    %combat = %combat $validate($25,%state,%morethan,%lessthan,25,%average)
    :cmbreply
    %saystyle %info
    %saystyle Skills: %combat
    goto unset
  }
  if ($minigames(%skill) != nomatch) {
    .tokenize 44 $($ $+ %skillid,2)
    var %info =  $+ %nick $+ 07 %skill | score:07 $bytes($2,db) | rank:07 $bytes($1,db)
    if ($bytes($1,db) == 0) { goto unranked }
    :minireply
    %saystyle %info
    rscript.singleminigame %socket %nick $replace(%skill,$chr(32),_) %saystyle
    goto unset
  }
  if (%skill == reqs) {
    var %cmb = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).p2p
    .tokenize 44 $1
    var %min = $reqs(%cmb)
    var %junior = Junior: $iif($2 >= %min,reqs met (07 $+ $calc($2 - %min) above $+ );,07 $+ $calc(%min - $2) to go;)
    inc %min 100
    var %member = Member: $iif($2 >= %min,reqs met (07 $+ $calc($2 - %min) above $+ );,07 $+ $calc(%min - $2) to go;)
    inc %min 100
    var %elite = Elite: $iif($2 >= %min,reqs met (07 $+ $calc($2 - %min) above $+ );,07 $+ $calc(%min - $2) to go;)
    %saystyle  $+ %nick $+  Supreme Skillers Reqs %junior %member %elite | Forum: 12www.supremeskillers.com | Memberlist: 12http://runehead.com/clans/ml.php?clan=lovvel
    goto unset
  }
  %saystyle Syntax Error: !<skill> user @param #goal
  goto unset
  :unranked
  %saystyle  $+ %nick $+  does not feature07 $replace(%skill,stats,$null,reqs,$null) hiscores.
  :unset
  unset %*
}
;$validate(skill, state, morethan, lessthan, statn, avg)
alias validate {
  var %avg = $remove($6,~)
  var %vstate = $iif($2 == 4,4,2)
  if ($3 > 126) { if ($gettok($1,3,44) < $3) return }
  else if ($3 < 127) { if ($xptolvl($gettok($1,3,44)) < $3) return }
  if ($4 > 126) { if ($gettok($1,3,44) >= $4) return }
  else if ($4 < 127) { if ($xptolvl($gettok($1,3,44)) >= $4) return }
  if ($calc($remove($gettok($1,%vstate,44),~) - %avg) >= 7) { var %lvl = 03 $+ $regsubex($gettok($1,$2,44),/(\d+)/,$bytes(\1,db)) $+  }
  else if ($calc($remove($gettok($1,%vstate,44),~) - %avg) <= -7) { var %lvl = 04 $+ $regsubex($gettok($1,$2,44),/(\d+)/,$bytes(\1,db)) $+  }
  else { var %lvl = 07 $+ $regsubex($gettok($1,$2,44),/(\d+)/,$bytes(\1,db)) $+  }
  return %lvl $statnum($5) $+ ;
}
;$reqs(combat level)
alias reqs {
  if ($1 >= 131) { return 2100 }
  if ($1 >= 121) { return 2050 }
  return 2000
}
;#######################
;#######Guessing!#######
;#######################
;$distribute(litehiscorestring)
alias distribute {
  var %string = $1
  .tokenize 10 $1
  if (<html> isin $1) { return unranked }
  if (-1 !isin $gettok(%string,1-25,10)) {
    var %x = 2,%reply,%voa = 0
    while (%x <= 30) {
      if ($gettok($ [ $+ [ %x ] ],2,44) == -1) { var % [ $+ [ %x ] ] NR,NR }
      else {
        var %vlvl = $xptolvl($gettok($ [ $+ [ %x ] ],3,44))
        var % [ $+ [ %x ] ] $ [ $+ [ %x ] ] $+ , $+ %vlvl
        inc %voa %vlvl
      }
      %reply = %reply $+ \n $+ % [ $+ [ %x ] ]
      inc %x
    }
    %reply = $1 $+ , $+ %voa $+ %reply
    return $replace(%reply,\n,$chr(10))
  }
  if ($gettok($1,2,44) != -1) {
    var %x = 2, %lvl = 0, %unranked
    while (%x <= 25) {
      if ($gettok($($ $+ %x,2),2,44) != -1) { %lvl = $calc(%lvl + $gettok($($ $+ %x,2),2,44)) }
      else { %unranked = %unranked %x }
      inc %x
    }
    %unranked = $trim(%unranked)
    var %missing = $calc($gettok($1,2,44) - %lvl)
    if ($gettok($5,2,44) == -1) {
      var %5 = 0,10,0
      %missing = $calc(%missing - 10)
    }
    var %x = 1,%y = 1
    while (%x <= %missing) {
      if (%y == $calc($numtok(%unranked,32) +1)) { %y = 1 }
      var % [ $+ [ $gettok(%unranked,%y,32) ] ] 0, $+ $calc($gettok(% [ $+ [ $gettok(%unranked,%y,32) ] ],2,44) + 1)
      inc %y
      inc %x
    }
    var %x = 1, %y = 1
    while (%x <= $numtok(%unranked,32)) {
      var %lvl = $gettok(% [ $+ [ $gettok(%unranked,%y,32) ] ],2,44)
      var % [ $+ [ $gettok(%unranked,%y,32) ] ] $+(NR,$chr(44),~ $+ %lvl,$chr(44),$lvltoxp(%lvl),$chr(44),%lvl)
      inc %y
      inc %x
    }
    var %reply,%x = 2,%voa,%vlevels
    while (%x <= 30) {
      var %vlvl = $xptolvl($gettok($ [ $+ [ %x ] ],3,44))
      if (!% [ $+ [ %x ] ]) {
        var %vlvl = $xptolvl($gettok($ [ $+ [ %x ] ],3,44))
        var % [ $+ [ %x ] ] $ [ $+ [ %x ] ] $+ , $+ %vlvl
      }
      else %vlvl = $xptolvl($gettok($($chr(37) $+ %x,2),3,44))
      %reply = %reply $+ \n $+ $replace($($chr(37) $+ %x,2),-1,NR)
      if (%x <= 25) { inc %voa %vlvl }
      inc %x
    }
    %reply = $1 $+ , $+ %voa $+ %reply
    return $replace(%reply,\n,$chr(10))
  }
  ; unranked oa
  var %x = 2, %total = 0,%voa
  while (%x <= 25) {
    inc %total $remove($gettok($ [ $+ [ %x ] ],2,44),-)
    inc %x
  }
  if ($gettok($5,2,44) == -1) {
    inc %total 9
    inc %voa 10
    var %5 = NR,~10,1154,10
  }
  var %x = 2, %exp = 0
  while (%x <= 25) {
    if ($gettok($ [ $+ [ %x ] ],2,44) != -1) {
      var %vlvl = $xptolvl($gettok($ [ $+ [ %x ] ],3,44))
      var % [ $+ [ %x ] ] $ [ $+ [ %x ] ] $+ , $+ %vlvl
      inc %voa %vlvl
    }
    else if (!% [ $+ [ %x ] ]) {
      var % [ $+ [ %x ] ] NR,~1,0,1
      inc %voa 1
    }
    inc %exp $remove($gettok(% [ $+ [ %x ] ],3,44),-1)
    inc %x
  }
  var %1 = NR,~ $+ %total $+ ,~ $+ %exp $+ , $+ %voa
  var %x = 2, %reply = %1
  while (%x <= 30) {
    if (!% [ $+ [ %x ] ]) { var % [ $+ [ %x ] ] NR,NR }
    %reply = %reply $+ \n $+ % [ $+ [ %x ] ]
    inc %x
  }
  return $replace(%reply,\n,$chr(10))
}
;############################
;######TRACKER DETAILS#######
;############################
; rscript.singleskill %socket %nick %skill %saystyle
alias rscript.singleskill {
  var %socket = $1 $+ 2, %nick = $2, %skill = $3,%saystyle = $4 $5, %time = $6
  .tokenize 32 $timetoday
  var %today = $1, %week = $2, %month = $3, %year = $4
  var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill= $+ $calc($statnum(%skill) - 1) $+ &time= $+ %today $+ , $+ %week $+ , $+ %month $+ , $+ %year $+ , $+ $iif(%time != null,%time)
  noop $download.break(rscript.singleskillreply %saystyle %skill %nick %time,%socket,%url)
}
alias rscript.singleminigame {
  var %socket = $1 $+ 2, %nick = $2, %skill = $replace($3,_,$chr(32)),%saystyle = $4 $5
  .tokenize 32 $timetoday
  var %today = $1, %week = $2, %month = $3, %year = $4
  var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill= $+ $smartno(%skill) $+ .1&time= $+ %today $+ , $+ %week $+ , $+ %month $+ , $+ %year
  noop $download.break(rscript.singleminigamereply %saystyle $replace(%skill,$chr(32),_) %nick,%socket,%url)
}
alias rscript.singleskillreply {
  var %saystyle = $1 $2
  var %skill = $3, %nick = $4
  var %time = $5
  .tokenize 10 $6-
  var %x = 1, %data, %start
  while (%x <= $0) {
    if (%x > 10) { break }
    var %regex = / $+ %time $+ :\d+/
    if ($regex($($ $+ %x,2),%regex)) { %extr = $($ $+ %x,2) | inc %x | continue }
    if (PHP isin $($ $+ %x,2)) { %data = %data PHP:Error | inc %x | continue }
    var %regex = /\d{2,}:\d+/
    if ($regex($($ $+ %x,2),%regex)) { %data = %data $($ $+ %x,2) }
    if ($regex($($ $+ %x,2),/^0:(\d+)$/i)) { %start = $regml(1) }
    inc %x
  }
  .tokenize 32 %data %extr
  var %todaExp = $iif($bytes($gettok($1,2,58),db),$v1 xp;03)
  var %weekExp = $iif($bytes($gettok($2,2,58),db),$v1 xp;03)
  var %montExp = $iif($bytes($gettok($3,2,58),db),$v1 xp;03)
  var %yearExp = $iif($bytes($gettok($4,2,58),db),$v1 xp;03)
  var %extrExp = $iif($bytes($gettok($5,2,58),db),$v1 xp;03)
  if (%skill != overall) {
    var %todaLvl = $iif($calc($virt(%start) - $virt($calc(%start - $gettok($1,2,58)))),$v1 lvls)
    var %weekLvl = $iif($calc($virt(%start) - $virt($calc(%start - $gettok($2,2,58)))),$v1 lvls)
    var %montLvl = $iif($calc($virt(%start) - $virt($calc(%start - $gettok($3,2,58)))),$v1 lvls)
    var %yearLvl = $iif($calc($virt(%start) - $virt($calc(%start - $gettok($4,2,58)))),$v1 lvls)
    var %extrLvl = $iif($calc($virt(%start) - $virt($calc(%start - $gettok($5,2,58)))),$v1 lvls)
  }
  if (%todaExp) { var %todaOut = Today:03 %todaExp %todaLvl }
  if (%todaExp && %weekExp) { var %sepT-W = | }
  if (%weekExp) { var %weekOut = Week:03 %weekExp %weekLvl }
  if (%weekExp && %montExp) { var %sepW-M = | }
  if (%montExp) { var %montOut = Month:03 %montExp %montLvl }
  if (%montExp && %yearExp) { var %sepM-Y = | }
  if (%yearExp) { var %yearOut = Year:03 %yearExp %yearLvl }
  if (%yearExp && %extrExp) { var %sepY-E = | }
  if (%extrExp) { var %extrOut =  $+ $duration(%time) $+ :03 %extrExp %extrLvl }
  var %out = %todaOut %sepT-W %weekOut %sepW-M %montOut %sepM-Y %yearOut %sepY-E %extrOut
  if (%out) { %saystyle  $+ %nick $+  %out 12www.rscript.org }
  else { %saystyle No Record for %nick found at12 www.rscript.org this year }
}
alias rscript.singleminigamereply {
  var %saystyle = $1 $2
  var %skill = $replace($3,_,$chr(32)),%nick = $4
  .tokenize 10 $5
  var %x = 1, %data, %start
  while (%x <= $0) {
    var %regex = /\d{2,}:\d+/
    if ($regex($($ $+ %x,2),%regex)) { %data = %data $($ $+ %x,2) }
    if ($regex($($ $+ %x,2),/^0:(\d+)$/i)) { %start = $regml(1) }
    inc %x
  }
  .tokenize 32 %data
  var %todaExp = $iif($bytes($gettok($1,2,58),db),$v1 score;03)
  var %weekExp = $iif($bytes($gettok($2,2,58),db),$v1 score;03)
  var %montExp = $iif($bytes($gettok($3,2,58),db),$v1 score;03)
  var %yearExp = $iif($bytes($gettok($4,2,58),db),$v1 score;03)
  if (%todaExp) { var %todaOut = Today:03 %todaExp }
  if (%todaExp && %weekExp) { var %sepT-W = | }
  if (%weekExp) { var %weekOut = Week:03 %weekExp }
  if (%weekExp && %montExp) { var %sepW-M = | }
  if (%montExp) { var %montOut = Month:03 %montExp }
  if (%montExp && %yearExp) { var %sepM-Y = | }
  if (%yearExp) { var %yearOut = Year:03 %yearExp }
  var %out = %todaOut %sepT-W %weekOut %sepW-M %montOut %sepM-Y %yearOut
  if (%out) { %saystyle  $+ %nick $+  %out 12www.rscript.org }
  else { %saystyle No Record for %nick found at12 www.rscript.org this year }
}
alias die return
