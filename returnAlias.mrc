>start<|returnAlias.mrc|new|1.0|a
# return $chr(35)
$ return $chr(36)
% return $chr(37)
| return $chr(124)
aLfAddress {
  if ($right($address($1,3), -3)) return $v1
  return $false
}
price {
  var %item $remove($1,$chr(42))
  if ($getPrice(%item)) return $trim($gettok($v1,2,59))
  var %thread $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %url http://gerty.rsportugal.org/parsers/ge.php?item= $+ $replace(%item,$chr(32),+)
  var %string = $downloadstring(%thread, %url)
  downloadGe %thread %string
  return $iif($gettok(%string,3,44), $v1, 0)
}
FormatWith {
  var %out, %x = 0
  while (%x <= $calc($0 - 2)) {
    var % [ $+ [ %x ] ] $ [ $+ [ $calc(%x + 2) ] ]
    inc %x
  }
  %out = $regsubex($1,/(^|[^\\]){(\d+)}/g,\1$($chr(37) $+ \2,2))
  %out = $replace(%out,\b,$chr(2),\c,$chr(3),\o,$chr(15),\u,$chr(31))
  return $regsubex(%out,(?:\\({)|\\(})),\1)
}
Ascii-Hex {
  var %string = $1-, %x = 1, %output, %char
  while (%x <= $len(%string)) {
    %char = $asc($mid(%string,%x,1))
    %output = %output $base(%char,10,16)
    inc %x
  }
  return %output
}
Hex-Ascii {
  var %string = $1-, %x = 1, %output, %char
  while (%x <= $len($remove(%string,$chr(32)))) {
    %char = $gettok(%string,%x,32)
    %output = %output $+ $chr($base(%char,16,10))
    inc %x
  }
  return %output
}
versions return $readini(versions.ini,versions,$1)
chanset return $getChanSetting($1,$2)
userset return $getUserSetting($1,$2,$3)
trim {
  .tokenize 10 $1-
  .tokenize 9 $1-
  return $1-
}
saystyle {
  ;trigger = $1, nick = $2, chan = $3
  !if (!$3 || $3 == PM) { !return !.msg $nick }
  !var %public $chanset($3,public)
  !if (!%public) { !return $iif($1 == @,!.msg $3,!.notice $2) }
  !if (%public == on) { !return $iif($1 == @,!.msg $3,!.notice $2) }
  !if (%public == off) { !return !.notice $2 }
  !if (%public == voice) { !return $iif($2 isvoice $3 || $2 ishop $3 || $2 isop $3,$iif($1 == @,!.msg $3,!.notice $2),!.notice $2) }
  !if (%public == half) { !return $iif($2 ishop $3 || $2 isop $3,$iif($1 == @,!.msg $3,.notice $2),!.notice $2) }
}
fact {
  if ($1 isnum) {
    var %p = 500
    if ($1 > 0) {
      var %y = $calc($replace($1,k,*1000,m,*1000000))
      var %x = $calc(%y - 1)
      while (%x && %p) {
        var %y = $calc(%y * %x)
        dec %x 1
        dec %p
      }
      return %y
    }
    if ($1 == 0) {
      return 1
    }
  }
}
rccom {
  if ($regex($1,$+(/^,$chr(40),$readini(rccomp.ini,member,nick),$chr(41),/i))) { return tracked }
}
tracked {
  if ($regex($1,$+(/^,$chr(40),$readini(tracked.ini,tracked,nick),$chr(41),/i))) { return _tracked }
}
admin {
  if ($regex($rsn($1),$+(/^,$chr(40),$readini(Gerty.Config.ini,admin,rsn),$chr(41),/i))) { return admin }
}
rsn {
  if ($getDefname($1)) return $v1
  return $caps($regsubex($1-,/\W/g,_))
}
capwords {
  var %t
  var %x = 0
  while $1 != $numtok($1-,32) {
    inc %x 1
  var %t = %t $upper($left($gettok($1-,1,32),1)) $+ $right($gettok($1-,1,32),-1) $gettok($1-,2-,32) } return %t
}
caps {
  var %regex = $regsubex($lower($1-),/((^[^a-z])([a-z])|(\w\W+)([a-z])|(\W[^a-z])(\w))/gi,\2 $+ $upper(\3))
  %regex = $capwords($regsubex(%regex,/(\w[^a-zA-Z0-9]+)([a-z])/g,\1 $+ $upper(\2)))
  return $capwords($regsubex(%regex,/(\w[^a-zA-Z0-9]+)([a-z])/g,\1 $+ $upper(\2)))
}
nohtml {
  var %x, %i = $regsub($1-,/(^[^<]*>|<[^>]*>|<[^>]*$)/g,$null,%x)
  %x = $replace($remove(%x,&nbsp;,$chr(9)),&quot;,$chr(34),&amp;,&,&lt;,<,&gt;,>,&#8242;,:,&quot;,")
  %x = $replace(%x,&apos;,')
  return %x
}
urlencode {
  var %a = $regsubex($$1,/([^\w\s])/Sg,$+(%,$base($asc(\t),10,16,2)))
  return $replace(%a,$chr(32),$chr(43))
}
virt {
  if ($1 !isnum) { return 0 }
  var %xp = 0
  var %lvl = 0
  while ($floor($calc(%xp /4)) <= $1 && %lvl < 99) {
    inc %lvl
    %xp = $calc(%xp + %lvl + $floor($calc(300 * 2 ^ (%lvl / 7))))
  }
  return %lvl
}
virtual {
  if ($1 !isnum) { return 0 }
  var %xp = 0
  var %lvl = 0
  while ($floor($calc(%xp /4)) <= $1) {
    inc %lvl
    %xp = $calc(%xp + %lvl + $floor($calc(300 * 2 ^ (%lvl / 7))))
  }
  return %lvl
}
xptolvl {
  if ($1 !isnum) { return 0 }
  if ($1 < 0) { return 0 }
  var %xp = 0
  var %lvl = 0
  while ($floor($calc(%xp /4)) <= $1) {
    inc %lvl
    %xp = $calc(%xp + %lvl + $floor($calc(300 * 2 ^ (%lvl / 7))))
  }
  return %lvl
}
lvltoxp {
  if ($1 == max || $1 > 126) { return 200000000 }
  if ($1 !isnum || $1 < 1) { return 0 }
  var %xp = 0, %lvl = $calc($floor($1) - 1)
  while (%lvl) {
    %xp = $calc(%xp + %lvl + $floor($calc(300 * 2 ^ (%lvl / 7))))
    dec %lvl
  }
  return $floor($calc(%xp / 4))
}
lvlceil {
  var %xp = $litecalc($1)
  var %lvlfloor = $xptolvl(%xp)
  var %lvlceil = $calc(%lvlfloor + 1)
  return %lvlceil
}
format_number {
  if ($abs($trim($1)) > 950000) return $round($calc( $1 / 1000000 ),2) $+ m
  if ($abs($trim($1)) > 9500) return $round($calc( $1 / 1000 ),2) $+ k
  return $bytes($1,bd)
}
;$calccombat(att, def, str, hp, range, pray, mage, sum)
calccombat {
  var %base = $calc( 0.25 * $regsubex($2,/~\d+/,1) + 0.25 * $regsubex($4,/~\d+/,10) + $floor($calc($regsubex($6,/~\d+/,1) / 2)) * 0.25 + $floor($calc($regsubex($8,/~\d+/,1) / 2)) * 0.25 )
  var %gbase = $calc( $remove(0.25 * $2 + 0.25 * $4,~) + $floor($calc($remove($6,~) / 2)) * 0.25 + $floor($calc($remove($8,~) / 2)) * 0.25 )
  var %melee = $calc(0.325 * $regsubex($1,/~\d+/,1) + 0.325 * $regsubex($3,/~\d+/,1))
  var %gmelee = $calc($remove(0.325 * $1 + 0.325 * $3,~))
  var %mage = $calc(0.325 * $floor($calc($regsubex($7,/~\d+/,1) * 1.5)))
  var %gmage = $calc(0.325 * $floor($calc($remove($7,~) * 1.5)))
  var %range = $calc( 0.325 * $floor($calc($regsubex($5,/~\d+/,1) * 1.5)) )
  var %grange = $calc( 0.325 * $floor($calc($remove($5,~) * 1.5)) )
  var %class
  if (%melee > %mage && %melee > %range) { %class = Melee }
  else if (%mage > %melee && %mage > %range) { %class = Mage }
  else if (%range > %melee && %range > %mage) { %class = Range }
  else { %class = Hybrid }
  var %p2p = $calc($gettok($sorttok(%melee %mage %range,32,nr),1,32) + %base)
  var %f2p = $calc($gettok($sorttok(%melee %mage %range,32,nr),1,32) + %base - $floor($calc($8 / 2)) * 0.25)
  var %gp2p = $calc($gettok($sorttok(%gmelee %gmage %grange,32,nr),1,32) + %gbase)
  var %gf2p = $calc($gettok($sorttok(%gmelee %gmage %grange,32,nr),1,32) + %gbase - $floor($calc($remove($8,~) / 2)) * 0.25)
  if ($prop == class) { return %class }
  if ($prop == all) { return 07 $+ $iif($9,07 $+ $bytes($9,db) $+ ,$floor(%p2p) $+  $+ (07~ $+ $floor(%gp2p) $+ )) combat (07 $+ %class $+ ); }
  if ($prop == p2p) { return %p2p }
  if ($prop == f2p) { return %f2p }
  if ($prop == gf2p) { return %gf2p }
  if ($prop == gp2p) { return %gp2p }
}
sort {
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
sortnext {
  var %string = $remove($1-,~)
  %exps = $sorttok($regsubex(%string,/((\w+) (\d+) (\d+))/g,\3),32,n)
  var %x = $numtok(%exps,32)
  var %y = 1
  var %z = 1
  while (%z <= %x) {
    var %p = 1
    while (%p <= $numtok(%string,32)) {
      if ($gettok(%string,$calc(%p +1),32) == $gettok(%exps,%y,32) && $+(|,$gettok(%string,%p,32),|) !isin %done && $gettok(%string,$calc(%p +1),32) > 0) {
        var %bold = $iif($gettok(%string,$calc(%p +2),32) >= 99,)
        var %out = %out %bold $+ 07 $+ $bytes($gettok(%string,$calc(%p +1),32),db)  $+ %bold $+ $statnum($gettok(%string,%p,32)) $+ ;
        var %done = %done $+(|,$gettok(%string,%p,32),|)
        break
      }
      inc %p 3
    }
    inc %y
    inc %z
  }
  return %out
}
sorthilow {
  var %string = $remove($1-,~)
  %exps = $sorttok($regsubex(%string,/((\w+) (\d+))/g,\3),32,$2)
  var %x = $numtok(%exps,32)
  var %y = 1
  var %z = 1
  while (%z <= %x) {
    var %p = 1
    while (%p <= $numtok(%string,32)) {
      if ($gettok(%string,$calc(%p +1),32) == $gettok(%exps,%y,32) && $+(|,$gettok(%string,%p,32),|) !isin %done) {
        var %out = %out $gettok(%string,%p,32)
        var %done = %done $+(|,$gettok(%string,%p,32),|)
        break
      }
      inc %p 2
    }
    inc %y
    inc %z
  }
  return %out
}
yesno {
  if $1 == yes return 03Yes
  if $1 == no return 04No
  else return $1
}
;SYNTAX: $grouper(ITEM|ITEM|ITEM)
grouper {
  var %x = 1
  while ($gettok($1-,%x,124)) {
    var %item = $replace($gettok($1-,%x,124),$chr(32),:space:)
    inc %item. $+ %item
    inc %x
  }
  var %y = 1
  while ($var(%item.*,%y)) {
    var %out = $+(%out,$iif(%out,$+(,$chr(44),$chr(32))),07,$iif($var(%item.*,%y).value > 1,$v1 $+ x 07),$replace($gettok($var(%item.*,%y).item,2,46),:space:,$chr(32)))
    inc %y
  }
  unset %item*
  return %out $+ 
}
alogout {
  var %ticks = $1, %out
  if ($hget($1,lvl)) %out = $chr(44) Gained $right($regsubex($v1,/\|(\w+)/g,$chr(44) 07 $+ $hget(%ticks,\1) \1 $+(level,$iif($hget(%ticks,\1) > 1,s),$chr(40),->,07,$hget(%ticks,\1 $+ high),,$chr(41))),-2)
  if ($hget($1,exp)) %out = %out $+ $chr(44) Reached $right($v1,-2)
  if ($hget($1,item)) %out = %out $+ $chr(44) Found $grouper($v1)
  if ($hget($1,kill)) %out = %out $+ $chr(44) Killed $grouper($v1)
  if ($hget($1,done)) %out = %out $+ $chr(44) Completed07 $left($replace($v1,$chr(124),$+(,$chr(44),07,$chr(32))),-6) $+ 
  if ($hget($1,other) != $blank) var %out = %out $+ $chr(44) Other:07 $left($replace($v1,$chr(124),$+(,$chr(44),07,$chr(32))),-6) $+ 
  return $right(%out,-2)
}
;@SYNTAX regget(string text, string regex)
;@SUMMARY returns the text matched in the regular expression
;@NOTE if no parenthesis in the expression, the alias returns $false.
regget {
  noop $regex($1, $2)
  if ($regml(1) != $null) return $v1
  return $false
}
;@SYNTAX swapTime(string durationOutput)
;@SYNTAX turns a duration output (52wks 31days 4hrs 32mins 3secs) into a string (395d 04:32:03)
swapTime {
  noop $regex($1,/(?:(\d+)wks?|())(?: (\d+)days?|())(.+?)$/g)
  var %days $calc($regml(1) * 7 + $regml(2))
  var %time $duration($duration($regml(3)),3)
  var %inc $floor($calc($gettok(%time,1,58) / 24))
  %time = $calc($gettok(%time,1,58) % 24) $+ : $+ $gettok(%time,2-,58)
  inc %days %inc
  return %days $+ d %time
;@SYNTAX $param([skill],<item>)[.prop]
;@SUMMERY No $prop specified or number 1-20: Output: Skill;lvl;exp;item,Skill;lvl;exp;item, etc - Max 20 or whichever $prop nr specified.
;@PARAM $prop: .skill .lvl .exp .item - Outputs specified item on first match.
;@NOTE Skill and $prop optional.
param {
  if ($prop >= 1 && $prop <= 20) { var %num = $prop }
  elseif ($prop isnum || !$prop) { var %num = 20 }
  var %ran = $ran, %skill = $1, %item = $2
  .fopen param $+ %ran param.txt
  while (!$feof) {
    var %param = $fread(param $+ %ran)
    tokenize 9 %param
    if (!%num) {
      if (!%skill || %skill == $1) && ($+(*,%item,*) iswm $4) {
        var %output = $($+($chr(36),$replace($prop,skill,1,lvl,2,exp,3,xp,3,item,4)),2)
        break
      }
    }
    else {
      if (!%skill || %skill == $1) && ($+(*,%item,*) iswm $4) {
        var %output = $+(%output,$iif(%output,$chr(44)),$1,;,$2,;,$3,;,$4)
      }
      if (%num <= $calc($count(%output,$chr(44)) + 1)) break
    }
  }
  .fclose param $+ %ran
  return %output
}
