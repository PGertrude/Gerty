>start<|Cost.mrc|Cost scripts|1.07|rs
on $*:text:/^(\[\w{2}\]Gerty |Gerty |)?[!.@]((pot)(ion)?s?|(po)(uch)?|(farmer|payment)|(\w+)costs?|costs? (\w+))/Si:*: {
  _CheckMain
  if (Gerty isin $1) {
    if ($1 == $me) || ($1 == Gerty && Gerty !ison $chan) { tokenize 32 $2- }
    else { halt }
  }
  if ($regml(3) == pot) { var %skill = Herblore }
  elseif ($regml(3) == po) { var %skill = Summoning, %short = yes }
  elseif ($regml(3) == farmer || $regml(3) == payment) { var %skill = Farming }
  else { var %skill = $skills($regml(3)) }
  var %saystyle = $saystyle($left($1,1),$nick,$chan), %ticks = $ran
  if (!%skill || %skill == Overall) { %saystyle No such skill. | halt }
  if ($lookups($2) == %skill) { tokenize 32 $2- }
  if ($regex($2,/\d/S)) { var %num = $litecalc($2) | tokenize 32 $2- }
  else { var %num = 1 }
  if ($2 == $blank) { %saystyle Cost param syntax: !cost <skill> [amount] <item>. | halt }
  var %item = $regsubex($2-,/(.*?)\x20@/Si,\1)
  .fopen cost $+ %ticks cost.txt
  while (!$feof) {
    var %cost = $fread(cost $+ %ticks)
    if ($gettok(%cost,1,9) != %skill) { goto skip }
    ;## HERBLORE ##
    if (%skill == Herblore) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9)) && $gettok(%cost,5,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        var %x = 1
        while ($gettok($gettok(%cost,7,9),%x,43) != $blank && %x <= 10) {
          if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,43)) && $gettok($gettok(%cost,7,9),%x,43)) { sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,43) itemdb-rs.runescape.com 80 }
          inc %x
        }
        costherblore %ticks
        goto close
      }
    }
    ;## FIREMAKING ##
    if (%skill == Firemaking) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        costfiremaking %ticks
        goto close
      }
    }
    ;## SUMMONING ##
    if (%skill == Summoning) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        if (%short) {
          var %charm = $chr(3) $+ $replace($gettok(%cost,11,9),Crimson,04,Blue,12,Green,03,Gold,07) $+ $gettok(%cost,11,9)
          %saystyle Summoning param07 $iif(%num > 1,$bytes(%num,bd)) $gettok(%cost,4,9) | Level:07 $gettok(%cost,2,9) | Exp:07 $bytes($calc(%num * $gettok(%cost,3,9)),bd) | Shards:07 $bytes($calc(%num * $gettok(%cost,8,9)),bd) | Charm: %charm | Second:07 $gettok(%cost,6,9) | Alch:07 $bytes($gettok(%cost,9,9),bd) | Time:07 $gettok(%cost,10,9) | Combat:07 $gettok(%cost,12,9) | Scroll:07 $gettok(%cost,13,9) | Ability:07 $gettok(%cost,14,9) $+ .
        }
        else {
          hadd -m a $+ %ticks cost %cost
          hadd -m a $+ %ticks out %saystyle
          hadd -m a $+ %ticks num %num
          ;%saystyle Summoning pouch param07 $iif(%num > 1,$bytes(%num,bd)) $gettok(%cost,4,9) | Level:07 $gettok(%cost,2,9) | Exp:07 $bytes($calc(%num * $gettok(%cost,3,9)),bd) | Charm: %color $+ $gettok(%cost,11,9) | Shards:07 $bytes($calc($gettok(%cost,8,9) * %num),bd) $+(,$chr(40),07,$bytes($calc($gettok(%cost,8,9) * %num * 25),bd),gp,,$chr(41)) | Time:07 $gettok(%cost,10,9) $iif(%num > 1,$+(,$chr(40),07,$bytes($calc($gettok(%cost,10,9) * $v1),bd),,$chr(41),07)) minutes | Combat:07 $gettok(%cost,12,9) | Scroll:07 $gettok(%cost,13,9) | Ability:07 $gettok(%cost,14,9) $+ .
          if (!$hget(cost,$gettok(%cost,5,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
          if (!$hget(cost,561)) { sockopen cost.a $+ %ticks $+ . $+ 561 itemdb-rs.runescape.com 80 }
          var %x = 1
          while ($gettok($gettok(%cost,7,9),%x,43)) {
            if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,43))) {
              sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,43) itemdb-rs.runescape.com 80
            }
            inc %x
          }
          costsummoning %ticks
        }
        goto close
      }
    }
    ;## SMITHING ##
    if (%skill == Smithing) {
      var %hit = yes
      var %regex = $+(/,%item,/Si)
      var %regex = $regsubex(%regex,/(?:rune|runite)/Si,$+($chr(40),rune|runite,$chr(41)))
      var %regex = $regsubex(%regex,/(?:adam(?:ant)?(?:ite)?|addy)/Si,$+($chr(40),adam,$chr(40),ant,$chr(41),?,$chr(40),ite,$chr(41),?|addy,$chr(41)))
      var %regex = $regsubex(%regex,/ores?/Si,Bar)
      if ($regex(ore,%regex,/(.+?)ore/Si)) { var %regex = $+(/,$regml(ore,1),Bar/Si) }
      if ($regex($gettok(%cost,4,9),%regex)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        if (!$hget(cost,561)) { sockopen cost.a $+ %ticks $+ . $+ 561 itemdb-rs.runescape.com 80 }
        var %x = 1
        while ($gettok($gettok(%cost,7,9),%x,43)) {
          if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,43))) {
            sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,43) itemdb-rs.runescape.com 80
          }
          inc %x
        }
        costsmithing %ticks
        goto close
      }
    }
    ;## PRAYER ##
    if (%skill == Prayer) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        costprayer %ticks
        goto close
      }
    }
    ;## FLETCHING ##
    if (%skill == Fletching) {
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9)) && $gettok(%cost,5,9) != 0) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        var %x = 1
        while ($gettok($gettok(%cost,7,9),%x,43)) {
          if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,43)) && $gettok($gettok(%cost,7,9),%x,43) != 0) {
            sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,43) itemdb-rs.runescape.com 80
          }
          inc %x
        }
        if (*Dart iswm $gettok(%cost,4,9) && !$hget(cost,314)) { sockopen cost.a $+ %ticks $+ .314 itemdb-rs.runescape.com 80 }
        if (Longbow isin $gettok(%cost,4,9) || Shortbow isin $gettok(%cost,4,9)) && (!$hget(cost,561)) { sockopen cost.a $+ %ticks $+ .561 itemdb-rs.runescape.com 80 }
        costfletching %ticks
        goto close
      }
    }
    ;## FARMING ##
    if (%skill == Farming) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,6,9)) && $gettok(%cost,6,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,6,9) itemdb-rs.runescape.com 80 }
        if (!$hget(cost,$gettok(%cost,8,9)) && $gettok(%cost,8,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,8,9) itemdb-rs.runescape.com 80 }
        if (!$hget(cost,$gettok(%cost,15,9)) && $gettok(%cost,15,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,15,9) itemdb-rs.runescape.com 80 }
        costfarming %ticks
        goto close
      }
    }
    ;## CONSTRUCTION ##
    if (%skill == Construction) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        costconstruction %ticks
        goto close
      }
    }
    ;## COOKING ##
    if (%skill == Cooking) {
      var %hit = yes
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9)) && $gettok(%cost,5,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        if (pie isin $gettok(%cost,4,9)) {
          if (!$hget(cost,9075)) { sockopen cost.a $+ %ticks $+ .9075 itemdb-rs.runescape.com 80 }
          if (!$hget(cost,$gettok(%cost,9,9))) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,9,9) itemdb-rs.runescape.com 80 }
        }
        var %x = 1
        while ($gettok($gettok(%cost,7,9),%x,43)) {
          if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,43)) && $gettok($gettok(%cost,7,9),%x,43)) {
            sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,43) itemdb-rs.runescape.com 80
          }
          inc %x
        }
        costcooking %ticks
        goto close
      }
    }
    ;## CRAFTING ##
    if (%skill == Crafting) {
      var %hit = yes
      var %item = $replace(%item,d'hide,dragonhide,dhide,dragonhide)
      if ($+(*,%item,*) iswm $gettok(%cost,4,9)) {
        hadd -m a $+ %ticks cost %cost
        hadd -m a $+ %ticks out %saystyle
        hadd -m a $+ %ticks num %num
        if (!$hget(cost,$gettok(%cost,5,9)) && $gettok(%cost,5,9)) { sockopen cost.a $+ %ticks $+ . $+ $gettok(%cost,5,9) itemdb-rs.runescape.com 80 }
        if (!$hget(cost,561)) sockopen cost.a $+ %ticks $+ .561 itemdb-rs.runescape.com 80
        var %x = 1
        while ($gettok($gettok(%cost,7,9),%x,59)) {
          if (!$hget(cost,$gettok($gettok(%cost,7,9),%x,59)) && $gettok($gettok(%cost,7,9),%x,59)) {
            sockopen cost.a $+ %ticks $+ . $+ $gettok($gettok(%cost,7,9),%x,59) itemdb-rs.runescape.com 80
          }
          inc %x
        }
        costcrafting %ticks
        goto close
      }
    }
    :skip
  }
  .fclose cost $+ %ticks
  if (%hit == yes) { %saystyle No such item: $+(",%item,".) | halt }
  %saystyle %skill cost parameters aren't ready yet. Stay tuned!
  :close
  .fclose cost $+ %ticks
}
;## HERBLORE ##
alias costherblore {
  if (!$hget(cost,$gettok($hget(a $+ $1,cost),5,9)) && $gettok($hget(a $+ $1,cost),5,9)) { goto skip }
  else { var %potcost = $calc($hget(a $+ $1,num) * $hget(cost,$gettok($hget(a $+ $1,cost),5,9))) }
  echo -st hi there
  var %x = 1
  while ($gettok($gettok($hget(a $+ $1,cost),7,9),%x,43) != $blank && %x <= 10) {
    if (!$hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%x,43)) && $gettok($gettok($hget(a $+ $1,cost),7,9),%x,43)) { goto skip }
    else { var %items = $calc(%items + ($hget(a $+ $1,num) * $hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%x,43))) ) }
    echo -st hi $gettok($gettok($hget(a $+ $1,cost),7,9),%x,43)
    inc %x
  }
  var %loss = $calc(%items - %potcost), %exp = $calc($hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),3,9))
  $hget(a $+ $1,out) $gettok($hget(a $+ $1,cost),1,9) cost params07 $iif($hget(a $+ $1,num) > 1,$bytes($v1,bd)) $gettok($hget(a $+ $1,cost),4,9) $+(,$chr(40),07,$bytes(%potcost,bd),gp,,$chr(41)) $chr(124) Exp: $+(07,$bytes(%exp,bd),) $chr(124) Lvl: $+(07,$gettok($hget(a $+ $1,cost),2,9),) $chr(124) Ingredients: $+(07,$regsubex($gettok($hget(a $+ $1,cost),6,9),/\;/g,$+(,$chr(44),$chr(32),07)),) $+($chr(40),07,$bytes(%items,bd),gp,,$chr(41)) Cost:07 $bytes(%loss,bd) $+(,$chr(40),07,$round($calc(%loss / %exp),1),gp/xp,,$chr(41)) $chr(124) Other info:07 $gettok($hget(a $+ $1,cost),8,9) $+ .
  hfree a $+ $1
  :skip
}
;## FIREMAKING ##
alias costfiremaking {
  if ($hget(cost,$gettok($hget(a $+ $1,cost),5,9))) {
    var %exp = $calc( $hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),3,9) )
    var %price = $calc( $hget(a $+ $1,num) * $hget(cost,$gettok($hget(a $+ $1,cost),5,9)) )
    $hget(a $+ $1,out) $gettok($hget(a $+ $1,cost),1,9) cost params07 $iif($hget(a $+ $1,num) > 1,$bytes($v1,bd)) $gettok($hget(a $+ $1,cost),4,9) $+(,$chr(40),07,$bytes($hget(cost,$gettok($hget(a $+ $1,cost),5,9)),bd),gp,,$chr(41)) | Level:07 $gettok($hget(a $+ $1,cost),2,9) | Exp:07 $bytes(%exp,bd) $formatwith(\o(\w Gloves/ring:\c07 $bytes($calc(%exp * 1.05),bd) $+ \o)) | Cost:07 $bytes(%price,bd) $parenthesis($round($calc(%price / %exp),1) $+ gp/xp) $formatwith(\o(\w Gloves/ring:\c07 $round($calc(%price / (%exp * 1.05)),1) $+ gp/xp\o).)
    hfree a $+ $1
  }
}
;## SUMMONING ##
alias costsummoning {
  if (!$hget(cost,$gettok($hget(a $+ $1,cost),5,9))) { goto skip }
  if (!$hget(cost,561)) { goto skip }
  var %y = 1, %num = $hget(a $+ $1,num)
  while ($gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)) {
    if (!$hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43))) { goto skip }
    else { var %a = %a $iif(%a,+) $+(07,$gettok($gettok($hget(a $+ $1,cost),6,9),%y,59), $chr(40),07,$bytes($hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)),bd),gp,,$chr(41))
      var %total = $calc(%total + ($hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)) * $hget(a $+ $1,num)))
    }
    inc %y
  }
  if (%num > 1) var %a = %a $+(,$chr(40),07,$bytes(%total,bd),gp,$chr(41))
  var %ingtotal = %total
  var %total = $calc(%total + ($gettok($hget(a $+ $1,cost),8,9) * 25 * $hget(a $+ $1,num)))
  var %pouch = $calc($hget(cost,$gettok($hget(a $+ $1,cost),5,9)) * $hget(a $+ $1,num))
  var %alch $calc(%total + ($hget(cost,561) * $hget(a $+ $1,num)) - ($gettok($hget(a $+ $1,cost),9,9) * $hget(a $+ $1,num)))
  var %ge $calc(%total - %pouch)
  var %bogrog $calc(%total - ($floor($calc($gettok($hget(a $+ $1,cost),8,9) * 0.7)) * 25 * $hget(a $+ $1,num)))
  var %exp = $calc($gettok($hget(a $+ $1,cost),3,9) * $hget(a $+ $1,num))
  var %namewrite = $iif($hget(a $+ $1,num) > 1,$bytes($v1,bd)) $gettok($hget(a $+ $1,cost),4,9) $+(,$chr(40),07,$bytes(%pouch,bd),gp,,$chr(41))
  var %charm = $chr(3) $+ $replace($gettok($hget(a $+ $1,cost),11,9),Crimson,04,Blue,12,Green,03,Gold,07) $+ $gettok($hget(a $+ $1,cost),11,9)
  var %shards = $calc($gettok($hget(a $+ $1,cost),8,9) * $hget(a $+ $1,num))
  $hget(a $+ $1,out) Summoning cost param07 %namewrite | Level:07 $gettok($hget(a $+ $1,cost),2,9) | Exp:07 $bytes(%exp,bd) | Charm: %charm | Shards:07 $bytes(%shards,bd) $+(,$chr(40),07,$bytes($calc(%shards * 25),bd),gp,,$chr(41)) | Second: %a | GE sell cost:07 $bytes(%ge,bd) $+(,$chr(40),07,$round($calc(%ge / %exp),1),gp/xp,,$chr(41)) | Bogrog exchange:07 $bytes(%bogrog,bd) $+(,$chr(40),07,$round($calc(%bogrog / %exp),1),gp/xp,,$chr(41)) | Alch(incl. nat):07 $bytes(%alch,bd) $+(,$chr(40),07,$round($calc(%alch / %exp),1),gp/xp,,$chr(41),.)
  $hget(a $+ $1,out) Summoning info07 $gettok($hget(a $+ $1,cost),4,9) | Alch value:07 $bytes($gettok($hget(a $+ $1,cost),9,9),bd) | Time:07 $gettok($hget(a $+ $1,cost),10,9) $iif(%num > 1,$+(,$chr(40),07,$bytes($calc($gettok($hget(a $+ $1,cost),10,9) * $v1),bd),,$chr(41),07)) minutes | Combat:07 $gettok($hget(a $+ $1,cost),12,9) | Scroll:07 $gettok($hget(a $+ $1,cost),13,9) | Ability:07 $gettok($hget(a $+ $1,cost),14,9) $+ .
  :skip
}
;## SMITHING ##
alias costsmithing {
  if (!$hget(cost,$gettok($hget(a $+ $1,cost),5,9))) { goto skip }
  if (!$hget(cost,561)) { goto skip }
  var %y = 1
  while ($gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)) {
    if (!$hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43))) { goto skip }
    else {
      if ($gettok($hget(a $+ $1,cost),8,9) != $null && %y > 1) || ($gettok($hget(a $+ $1,cost),6,9) != Ore) { var %b = $gettok($hget(a $+ $1,cost),8,9) }
      if ($gettok($hget(a $+ $1,cost),10,9) == Special) { var %type = %type $iif(%type,+07) $gettok($gettok($hget(a $+ $1,cost),6,9),%y,43) $+(,$chr(40),07,$bytes($hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)),bd),gp,,$chr(41)) }
      var %a = %a $iif(%a,+07,Ores:07) $iif($gettok($gettok($hget(a $+ $1,cost),4,9),%y,43),$replace($v1,Bar,Ore),$iif(%b,%b) Coal) $+(,$chr(40),07,$bytes($calc($iif(%b,%b *) $hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)) ),bd),gp,,$chr(41))
      var %total = $calc(%total + ($iif(%b,%b * )$hget(cost,$gettok($gettok($hget(a $+ $1,cost),7,9),%y,43)) * $hget(a $+ $1,num)))
    }
    inc %y
  }
  if ($gettok($hget(a $+ $1,cost),4,9) == Dragon Platebody) { var %total = $calc(%total + ($hget(a $+ $1,num) * 1000000)) }
  if ($gettok($hget(a $+ $1,cost),4,9) == Bronze Bar) { var %a = $replace(%a,Bronze,Tin,Coal,Copper Ore) }
  var %price = $calc($iif(arrow isin $gettok($hget(a $+ $1,cost),4,9),15 *) $iif(bolt isin $gettok($hget(a $+ $1,cost),4,9),10 *) $hget(a $+ $1,num) * $hget(cost,$gettok($hget(a $+ $1,cost),5,9)))
  var %alch $calc(($hget(a $+ $1,num) * $hget(cost,561)) + %total - ($gettok($hget(a $+ $1,cost),9,9) * $hget(a $+ $1,num)))
  if ($gettok($hget(a $+ $1,cost),6,9) == Ore) {
    if ($gettok($hget(a $+ $1,cost),8,9) != $null) {
      var %nr = Coal:07 $bytes($calc($hget(a $+ $1,num) * $v1),bd) |
    }
    var %alch = $calc(%alch - $hget(cost,$gettok($hget(a $+ $1,cost),5,9)) * $hget(a $+ $1,num))
    var %alchout = Superheat cost(incl. nat):07 $bytes(%alch,bd) $+(,$chr(40),07,$round($calc(%alch / ($gettok($hget(a $+ $1,cost),3,9) * $hget(a $+ $1,num))),1),gp/xp,,$chr(41))
  }
  else {
    var %nr = Bars:07 $bytes($calc($hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),8,9)),bd) |
    if ($gettok($hget(a $+ $1,cost),9,9)) {
      var %alchout = Alch cost(incl. nat):07 $bytes(%alch,bd) $+(,$chr(40),07,$round($calc(%alch / ($gettok($hget(a $+ $1,cost),3,9) * $hget(a $+ $1,num))),1),gp/xp,,$chr(41))
  } }
  if ($gettok($hget(a $+ $1,cost),4,9) == Gold Bar) {
    var %goldexp = $calc($hget(a $+ $1,num) * 56.2)
    var %goldGE = $+(,$chr(40),\w Gaunts:07 $round($calc((%total - %price) / %goldexp),1),gp/xp,,$chr(41))
    var %goldalch = $+(,$chr(40),\w Gaunts:07 $round($calc((%total + ($hget(a $+ $1,num) * $hget(cost,561)) - %price) / %goldexp),1),gp/xp,,$chr(41))
  }
  $hget(a $+ $1,out) Smithing cost param07 $iif($hget(a $+ $1,num) > 1,$bytes($v1,bd)) $gettok($hget(a $+ $1,cost),4,9) $+(,$chr(40),07,$bytes(%price,bd),gp,,$chr(41)) | Level:07 $gettok($hget(a $+ $1,cost),2,9) | Exp:07 $bytes($calc($hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),3,9)),bd) | Type:07 $iif(%type,%type,$gettok($hget(a $+ $1,cost),6,9)) | $iif($gettok($hget(a $+ $1,cost),6,9) == Ore,%a |) %nr Cost:07 $bytes(%total,bd) | GE sell cost:07 $bytes($calc(%total - %price),bd) $+(,$chr(40),07,$round($calc((%total - %price) / ($hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),3,9))),1),gp/xp,,$chr(41)) $+ $iif(%goldge,$chr(32) $+ %goldge) $+ $iif(%alchout,$chr(32) $+ | %alchout $+ $iif(%goldalch,$chr(32) $+ %goldalch $+ .,.),.)
  hfree a $+ $1
  :skip
}
;## PRAYER ##
alias costprayer {
  var %hash = a $+ $1
  if ($hget(cost,$gettok($hget(%hash,cost),5,9)) || $gettok($hget(%hash,cost),5,9) == 0) {
    var %num = $hget(%hash,num)
    var %cost = $hget(cost,$gettok($hget(%hash,cost),5,9))
    var %exp = $gettok($hget(%hash,cost),3,9)
    if (*Remains iswm $gettok($hget(%hash,cost),4,9)) { var %prayer = Pyre exp:07 $bytes($calc(%exp * %num),bd) $+(,$chr(40),07,$round($calc(%cost / %exp),1),gp/xp,,$chr(41)) }
    else {
      var %prayer = Bury exp:07 $bytes($calc(%exp * %num),bd) $+(,$chr(40),07,$round($calc(%cost / %exp),1),gp/xp,,$chr(41)) |
      var %prayer = %prayer Altar:07 $bytes($calc(%exp * %num * 3.5),bd) $+(,$chr(40),07,$round($calc(%cost / $calc(%exp * 3.5)),1),gp/xp,,$chr(41)) |
      var %prayer = %prayer Ecto:07 $bytes($calc(%exp * %num * 4),bd) $+(,$chr(40),07,$round($calc(%cost / $calc(%exp * 4)),1),gp/xp,,$chr(41))
    }
    $hget(%hash,out) Prayer cost param07 $iif(%num > 1,$bytes($v1,bd)) $gettok($hget(%hash,cost),4,9) $+(,$chr(40),07,$bytes(%cost,bd),gp,,$chr(41)) | Level:07 $gettok($hget(%hash,cost),2,9) | Cost:07 $bytes($calc(%cost * %num),bd) | %prayer
  }
}
;## FLETCHING ##
alias costfletching {
  var %hash = a $+ $1
  var %param = $hget(%hash,cost)
  if (!$hget(cost,$gettok(%param,5,9)) && $gettok($hget(%hash,cost),5,9)) { goto skip }
  var %y = 1
  while ($gettok($gettok(%param,7,9),%y,43)) {
    if (!$hget(cost,$gettok($gettok(%param,7,9),%y,43))) { goto skip }
    inc %y
  }
  if (*Dart iswm $gettok(%param,4,9) && !$hget(cost,314)) { goto skip }
  if (Longbow isin $gettok(%param,4,9) || Shortbow isin $gettok(%param,4,9)) && (!$hget(cost,561)) { goto skip }
  var %num = $hget(%hash,num)
  var %exp = $calc(%num * $gettok(%param,3,9))
  var %price = $hget(cost,$gettok(%param,5,9))
  var %x = 1
  while ($gettok($gettok(%param,6,9),%x,43) && $gettok($gettok(%param,7,9),%x,43) != $blank) {
    var %parts = %parts $iif(%parts,+,Parts:) 07 $+ $gettok($gettok(%param,6,9),%x,43) $+(,$chr(40),07,$iif($hget(cost,$gettok($gettok(%param,7,9),%x,43)),$bytes($v1,bd) $+ gp,N/A),,$chr(41))
    var %loss = $calc(%loss + (%num * $hget(cost,$gettok($gettok(%param,7,9),%x,43))))
    inc %x
  }
  if (Shortbow isin $gettok(%param,4,9) || Longbow isin $gettok(%param,4,9)) {
    var %log = $hget(cost,$gettok($gettok(%param,7,9),1,43))
    var %bs = $hget(cost,$gettok($gettok(%param,7,9),2,43))
    var %unstrung = $hget(cost,$gettok($gettok(%param,7,9),3,43))
    var %full = $calc(%num * (%log + %bs - %price))
    var %alchvalue = $gettok(%param,8,9)
    var %alch = $calc(%num * (%log + %bs - %alchvalue + $hget(cost,561)))
    var %costs = Alch:07 $bytes(%alchvalue,bd)
    var %costs = %costs | GE cost:07 $bytes(%full,bd) $+(,$chr(40),07,$round($calc(%full / %exp),1),gp/xp,,$chr(41))
    var %costs = %costs | Alch cost:07 $bytes(%alch,bd) $+(,$chr(40),07,$round($calc(%alch / %exp),1),gp/xp,,$chr(41))
    var %u = $calc(%num * (%log - %unstrung))
    var %costs = %costs | Logs->Unstrung:07 $bytes(%u,bd) $+(,$chr(40),07,$round($calc(%u / (%exp / 2)),1),gp/xp,,$chr(41))
    var %string = $calc(%num * (%unstrung + %bs - %price))
    var %costs = %costs | Unstrung->Full:07 $bytes(%string,bd) $+(,$chr(40),07,$round($calc(%string / (%exp / 2)),1),gp/xp,,$chr(41))
  }
  elseif (Dart isin $gettok(%param,4,9) || Barbed Bolt == $gettok(%param,4,9)) {
    var %parts = %parts +07 3 Feathers $+(,$chr(40),07,$calc(3 * $hget(cost,314)),gp,,$chr(41))
    var %loss = $calc(%loss + (%num * 3 * $hget(cost,314)) - (%num * %price))
    var %costs = Cost:07 $bytes(%loss,bd) $+(,$chr(40),07,$round($calc(%loss / %exp),1),gp/xp,,$chr(41))
  }
  elseif (Broad Arrow == $gettok(%param,4,9)) {
    var %parts = %parts +07 Broad Arrow Head $+(,$chr(40),07,50,gp,,$chr(41))
    var %loss = $calc(%loss + (%num * 50))
    var %costs = Cost:07 $bytes(%loss,bd) $+(,$chr(40),07,$round($calc(%loss / %exp),1),gp/xp,,$chr(41))
  }
  else {
    var %loss = $calc(%loss - (%num * %price))
    var %costs = Cost:07 $bytes(%loss,bd) $+(,$chr(40),07,$round($calc(%loss / %exp),1),gp/xp,,$chr(41))
  }
  $hget(%hash,out) Fletching cost param07 $iif(%num > 1,$bytes(%num,bd)) $gettok(%param,4,9) $+(,$chr(40),07,$iif(%price,$bytes($calc(%num * %price),bd) $+ gp,N/A),,$chr(41)) | Level:07 $gettok(%param,2,9) | Exp:07 $bytes(%exp,bd) | %parts | %costs
  hfree %hash
  :skip
}
;## FARMING ##
alias costfarming {
  var %hash = a $+ $1
  var %param = $hget(%hash,cost)
  if (!$hget(cost,$gettok(%param,6,9)) && $gettok(%param,6,9)) { goto skip }
  if (!$hget(cost,$gettok(%param,8,9)) && $gettok(%param,8,9)) { goto skip }
  if (!$hget(cost,$gettok(%param,15,9)) && $gettok(%param,15,9)) { goto skip }
  var %num = $hget(%hash,num)
  var %exp = $calc(%num * $gettok(%param,3,9))
  var %patch = $gettok(%param,9,9)
  var %expout = Exp:07 $bytes(%exp,bd)
  var %payment = Payment:07 $gettok(%param,14,9)
  if ($gettok(%param,14,9) != -) {
    var %pay = $calc($hget(cost,$gettok(%param,15,9)) * $gettok(%param,16,9))
    var %payment = %payment $+(,$chr(40),07,$bytes(%pay,bd),gp,,$chr(41))
  }
  if (%patch == Allotment) {
    var %seednr = * 3
    var %costname = Profit:07
    var %expout = %expout $+(,$chr(40),07,$gettok(%param,11,9),/pick,,$chr(41))
  }
  if (%patch == Hop) {
    var %seednr = * 4
    var %costname = Profit:07
    var %expout = %expout $+(,$chr(40),07,$gettok(%param,11,9),/pick,,$chr(41))
  }
  if ($gettok(%param,4,9) == Cactus || %patch == Herb) {
    var %costname = Profit:07
  }
  if (%patch == Herb) {
    var %expout = %expout $+(,$chr(40),07,$gettok(%param,11,9),/pick,,$chr(41))
  }
  if (!%costname) var %costname = Cost:07
  if ($gettok(%param,17,9)) var %collectnr = * $v1
  if ($gettok(%param,7,9) != -) {
    if (%patch == Herb || %patch == Allotment || %patch == Hop) { var %produce = | Average produce:07 $gettok(%param,7,9) }
    else { var %produce = | Produce:07 $gettok(%param,7,9) }
  }
  if ($gettok(%param,8,9)) var %produce = %produce $+(,$chr(40),07,$bytes($calc($hget(cost,$gettok(%param,8,9)) %collectnr ),bd),gp,,$chr(41))
  var %price = $calc($hget(cost,$gettok(%param,6,9)) * %num %seednr)
  var %income = $calc(%num * $hget(cost,$gettok(%param,8,9)) %collectnr)
  var %costs = $calc(%price - %income)
  if (%pay) var %costs = $calc(%costs + (%pay * %num))
  if (- isin %costs) {
    var %costout = Profit:03 $bytes($remove(%costs,-),bd) $+(,$chr(40),03,$round($remove($calc(%costs / %exp),-),1),gp/xp,,$chr(41))
  }
  elseif (!%costs) var %costout = Cost:07 0
  else {
    var %costout = Cost:04 $bytes(%costs,bd) $+(,$chr(40),04,$round($calc(%costs / %exp),1),gp/xp,,$chr(41))
  }
  var %seedout = Seed:07 $gettok(%param,5,9) $+(,$chr(40),07,$bytes($calc($hget(cost,$gettok(%param,6,9)) %seednr),bd),gp,,$chr(41))
  if (%num > 1) var %seedout = %seedout $+(,$chr(40),07,$bytes(%price,bd),gp,,$chr(41))
  if ($gettok(%param,13,9) < 600) var %time = Time:07 $bytes($v1,bd) min $+(,$chr(40),07,$mid($duration($calc($v1 * 60),3),2,4),,$chr(41))
  else { var %time = Time:07 $bytes($v1,bd) min $+(,$chr(40),07,$iif($v1 > 3000,2d 13:20,$mid($duration($calc($v1 * 60),3),1,5)),,$chr(41)) }
  $hget(%hash,out) Farming cost param07 $iif(%num > 1,$bytes(%num,bd)) $gettok(%param,4,9) | %seedout | Level:07 $gettok(%param,2,9) | %expout | %payment %produce | %time | %costout
  hfree %hash
  :skip
}
;## CONSTRUCTION ##
alias costconstruction {
  var %hash = a $+ $1
  if (!$hget(cost,$gettok($hget(%hash,cost),5,9))) { goto skip }
  var %param = $hget(%hash,cost)
  var %num = $hget(%hash,num)
  var %exp = $gettok(%param,3,9)
  var %geprice = $hget(cost,$gettok(%param,5,9))
  var %gepriceout = GE buy cost:07 $bytes($calc(%geprice * %num),bd) $parenthesis($round($calc(%geprice / %exp),1) $+ gp/xp)
  var %shopprice = $gettok(%param,6,9)
  if (%shopprice != -) var %shoppriceout Shop cost:07 $bytes($calc(%shopprice * %num),bd) $parenthesis($round($calc(%shopprice / %exp),1) $+ gp/xp)
  else { var %shoppriceout Shop cost:07 - }
  $hget(%hash,out) $gettok(%param,1,9) cost params07 $iif(%num > 1,$bytes($v1,bd)) $gettok(%param,4,9) $parenthesis($bytes($hget(cost,$gettok(%param,5,9)),bd) $+ gp) | Exp:07 $bytes($calc(%exp * %num),bd) | %gepriceout | %shoppriceout
  ;$hget(%hash,out) $gettok($hget(a $+ $1,cost),1,9) cost params07 $iif($hget(a $+ $1,num) > 1,$bytes($v1,bd)) $gettok($hget(a $+ $1,cost),4,9) $parenthesis($bytes($hget(cost,$gettok($hget(a $+ $1,cost),5,9)),bd),gp) | Level:07 $gettok($hget(a $+ $1,cost),2,9) | Exp:07 $bytes($calc( $hget(a $+ $1,num) * $gettok($hget(a $+ $1,cost),3,9) ),bd) | Cost:07 $bytes($calc( $hget(a $+ $1,num) * $hget(cost,$gettok($hget(a $+ $1,cost),5,9)) ),bd) $+(,$chr(40),07,$round($calc($hget(cost,$gettok($hget(a $+ $1,cost),5,9)) / $gettok($hget(a $+ $1,cost),3,9)),1),gp/xp,,$chr(41),.)
  hfree %hash
  :skip
}
;## COOKING ##
alias costcooking {
  var %hash = a $+ $1
  var %num = $hget(%hash,num)
  tokenize 9 $hget(%hash,cost)
  if (!$hget(cost,$5) && $5) { goto skip }
  if (pie isin $4) {
    if (!$hget(cost,9075)) { goto skip }
    if (!$hget(cost,$9)) { goto skip }
  }
  var %y = 1
  while ($gettok($7,%y,43)) {
    if (!$hget(cost,$gettok($7,%y,43)) && $gettok($7,%y,43)) { goto skip }
    else {
      var %iprice = $hget(cost,$gettok($7,%y,43))
      if ($regex($gettok($6,%y,59),/^(\d+)x/)) var %iprice = $calc(%iprice * $regml(1))
      var %total = $calc(%total + (%num * %iprice))
      var %ing = $+(%ing,$iif(%ing, $+ $chr(44) $+ $chr(32)),07,$gettok($6,%y,59), $chr(40),07,$bytes(%iprice,bd),gp,$chr(41))
    }
    inc %y
  }
  var %exp = $calc($3 * %num)
  var %geprice = $calc(%total - ($hget(cost,$5) * %num))
  var %gepriceout = GE sell cost:07 $bytes(%geprice,bd) $+(,$chr(40),07,$bytes($round($calc(%geprice / %exp),2),bd),gp/xp,$chr(41))
  var %item = $+(07,$4, $chr(40),07,$bytes($hget(cost,$5),bd),gp,$chr(41))
  $hget(%hash,out) Cooking cost params %item | Level:07 $2 | Exp:07 $bytes(%exp,bd) | Ingredients: %ing | Cost:07 $bytes(%total,bd) | %gepriceout | Heal&Effect:07 $8 $+ .
  if (pie isin $4) {
    var %piecost $calc(($hget(cost,$9) * %num) + ($hget(cost,9075) * %num) - ($hget(cost,$5) * %num))
    $hget(%hash,out) Cooking cost params %item | Raw pie cost:07 $bytes($calc($hget(cost,$9) * %num),bd) | Bake pie(spell) cost(buy raw):07 $bytes(%piecost,bd) $+(,$chr(40),07,$bytes($round($calc(%piecost / %exp),2),bd),gp/xp,$chr(41))
  }
  hfree %hash
  :skip
}
;## CRAFTING ##
alias costcrafting {
  var %hash = a $+ $1
  var %num = $hget(%hash,num)
  echo -st hi $hget(%hash,cost)
  tokenize 9 $hget(%hash,cost)
  if (!$hget(cost,$5) && $5) { goto skip }
  if (!$hget(cost,561)) goto skip
  var %y = 1
  while ($gettok($7,%y,59)) {
    if (!$hget(cost,$gettok($7,%y,59)) && $gettok($7,%y,59)) { goto skip }
    else {
      var %iprice = $hget(cost,$gettok($7,%y,59))
      if ($regex($gettok($6,%y,59),/^(\d+)x/)) var %iprice = $calc(%iprice * $regml(1))
      var %total = $calc(%total + (%num * %iprice))
      var %ing = $+(%ing,$iif(%ing, $+ $chr(44) $+ $chr(32)),07,$gettok($6,%y,59), $chr(40),07,$bytes(%iprice,bd),gp,$chr(41))
    }
    inc %y
  }
  var %exp = $calc($3 * %num)
  var %geprice = $calc(%total - ($hget(cost,$5) * %num))
  var %gepriceout = GE sell cost:07 $bytes(%geprice,bd) $+(,$chr(40),07,$bytes($round($calc(%geprice / %exp),2),bd),gp/xp,$chr(41))
  var %alch = $calc(%total + ($hget(cost,561) * %num) - ($8 * %num))
  var %alchout = Alch value:07 $+($bytes($8,bd),$iif(%num > 1,$+($chr(32),,$chr(40),07,$bytes($calc($8 * %num),bd),,$chr(41)))) | Hi alch cost:07 $bytes(%alch,bd) $+(,$chr(40),07,$round($bytes($calc(%alch / %exp),bd),2),gp/xp,$chr(41))
  var %item = $+(07,$4, $chr(40),07,$bytes($hget(cost,$5),bd),gp,$chr(41))
  $hget(%hash,out) Crafting cost params %item | Level:07 $2 | Exp:07 $bytes(%exp,bd) | Materials: %ing | Cost:07 $bytes(%total,bd) | %gepriceout | %alchout
  hfree %hash
  :skip
}

alias convertfile {
  var %skill $lookups($1)
  var %x = 1, %y = $lines(test.txt)
  while (%x <= %y) {
    var %convert = $read(test.txt,n,%x)
    ;write -l $+ %x test.txt $+(Cooking|,$gettok(%convert,4,9),|,$gettok(%convert,3,9),|,$gettok(%convert,2,9))
    write -l $+ %x test.txt Crafting| $+ $replace(%convert,$chr(9),$chr(124))
    inc %x
  }
  ;write test.txt $+(SKILL,$chr(9),LEVEL,$chr(9),EXP,$chr(9),NAME,$chr(9),POUCH ID,$chr(9),INGREDIENT,$chr(9),INGREDIENT ID,$chr(9),SHARDS,$chr(9),ALCH,$chr(9),MINUTES,$chr(9),SKILL FOCUS,$chr(9),OTHER)
  msg $chan Done.
  run test.txt
}
alias parenthesis return $formatwith(\o(\c07{0}\o),$1-)
