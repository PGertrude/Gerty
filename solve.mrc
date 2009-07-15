on $*:text:/^[=`](-*[0-9\.sctapelx\x28]) */Si:#: {
  %answer = $regsubex($strictcalc($right($1-,-1)),/(\d+(\.\d+)?)/g,$bytes(\1,db))
  if (%answer != false) {
    if (x !isin $1- && %eq) {
      .notice $nick $calcparse($right($1-,-1)) =07 %answer
    }
    if (x isin $1-) {
      .notice $nick $calcparse($right($1-,-1)) 12x =>07 %answer
    }
    hadd -m $nick p $gettok(%answer,1,32)
  }
  if (%answer == false && $len($1-) > 2) {
    .notice $nick $mid($calcparse($right($1-,-1)),1,20) 12=> 07{Invalid Parameters}
  }
}
on $*:text:/^[=`](-*[0-9\.sctapelx\x28]) */Si:?: {
  %answer = $regsubex($strictcalc($right($1-,-1)),/(\d+(\.\d+)?)/g,$bytes(\1,db))
  if (%answer != false) {
    if (x !isin $1- && %eq) {
      .notice $nick $calcparse($right($1-,-1)) =07 %answer
      hadd -m $nick p %answer
    }
    if (x isin $1-) {
      .notice $nick $calcparse($right($1-,-1)) 12x =>07 %answer
      hadd -m $nick p %answer
    }
    hadd -m $nick p $gettok(%answer,1,32)
  }
  if (%answer == false && $len($1-) > 2) {
    .notice $nick $mid($calcparse($right($1-,-1)),1,20) 12=> 07{Invalid Parameters}
  }
}
on *:TEXT:*:#: {
  if ($regex($1,/^[!@.](calc|c)$/Si)) {
    var %saystyle = $saystyle($left($1,1),$nick,$chan)
    %answer = $regsubex($strictcalc($2-),/(\d+(\.\d+)?)/g,$bytes(\1,db))
    if (%answer != false) {
      if (x !isin $1- && %eq) {
        %saystyle $calcparse($2-) =07 %answer
      }
      if (x isin $1-) {
        %saystyle $calcparse($2-) 12x =>07 %answer
      }
      hadd -m $nick p $gettok(%answer,1,32)
    }
    if (%answer == false && $len($2-) > 1) {
      %saystyle $mid($calcparse($2-),1,20) 12=> 07{Invalid Parameters}
    }
  }
}
on *:TEXT:*:?: {
  if ($regex($1,/^[!@.](calc|c)$/Si)) {
    var %saystyle = .msg $nick
    %answer = $regsubex($strictcalc($2-),/(\d+(\.\d+)?)/g,$bytes(\1,db))
    if (%answer != false) {
      if (x !isin $1- && %eq) {
        %saystyle $calcparse($2-) =07 %answer
      }
      if (x isin $1-) {
        %saystyle $calcparse($2-) 12x =>07 %answer
      }
      hadd -m $nick p $gettok(%answer,1,32)
    }
    if (%answer == false && $len($2-) > 1) {
      %saystyle $mid($calcparse($2-),1,20) 12=> 07{Invalid Parameters}
    }
  }
}
;##################### Solver ###########################
alias solve {
  if (*=* !iswm $1) { var %eq2 = $lower($1) $+ =x }
  if (*=* iswm $1) { var %eq2 = $lower($1) }
  %eq = $trans(%eq2)
  return $multiple(%eq,$xsolve(%eq))
}
alias trans {
  %eq = $remove($1,$chr(32))
  if (= isin $1) %eq = $gettok(%eq,1,61) $+ -( $+ $gettok($1,2,61) $+ )
  ;%eq = $regsubex(%eq,/(\x29|\d)\x28/g,\t* $+ $chr(40))
  ;makes functionx --> function(x), sinx --> sin(x).
  ;%eq = $regsubex(%eq,/([0-9xzpe\x2E]*[km]*[epz]*)(\!)/,$fact(\1))
  ;%eq = $regsubex(a,%eq,/(\d)([a-z])/g,\1*\2)
  return $replace(%eq,e,2.718,z,3.141592653589793238462643,p,$hget($nick,p),k,1000,m,1000000)
}
alias multiple {
  var %x = $2
  var %eq = $1
  var %trig = $iif($regex(%eq,asin|acos|atan|sin|cos|tan),$true,$false)
  var %solutions = $iif($abs($xcalculate(%eq,%x)) < 0.001,$+($chr(44),$2,$chr(44)),$false)
  if (%trig) return $iif(%solutions,$right($left(%solutions,-1),-1),$false)
  if (!%solutions) return $false
  %z = 1
  while ($abs($xcalculate(%eq,%x)) < 0.001) {
    %eq = $+($chr(40),%eq,$chr(41),/,$chr(40),x,-,%x,$chr(41))
    %x = $xsolve(%eq)
    if ($redundant(%solutions,%x)) goto finish
    if (($abs($xcalculate(%eq,%x)) < 0.001)) %solutions = %solutions $+ %x $+ ,
  }
  :finish
  return $right($left(%solutions,-1),-1)
}
alias xsolve {
  var %x = 20
  var %a = 0
  while (%a <= 30) {
    %x = $calc(%x - $+($chr(40),$xcalculate($1,%x),/,$derivative($1,%x),$chr(41)))
    inc %a
  }
  return $xcheck($1,%x)
}
alias derivative {
  var %num2 = $xcalculate($1,$2 + 1)
  var %num3 = $xcalculate($1,$2 - 1)
  return $calc((%num2 - %num3) / 2)
}
alias xcheck {
  if ($abs($xcalculate($1,$2)) < 0.001) {
    if (!$xcalculate($1,$round($2,0))) return $round($2,0)
    if (!$xcalculate($1,$floor($2))) return $floor($2)
    if (!$xcalculate($1,$ceil($2))) return $ceil($2)
    var %y = 5
    while ((%y >= 0) && (!$xcalculate($1,$round($2,%y)))) dec %y
    return $round($2,$calc(%y +1))
  }
  else return $false
}
alias xcalculate return $calc($parser($replace($1,x,$calc($2))))
alias parser return $regsubex($1-,/((sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)\050(-?\d+(?:\.\d+)?(?:[\*\/\+-]\d+(?:\.\d+)?)*)\051)/g,$($\2($calc(\3)) $+ .deg,2))
alias redundant {
  var %temp = $chr(44)
  var %a = 1
  while (%a <= $gettok($1,0,44)) {
    %temp = $+(%temp,$round($gettok($1,%a,44),1),$chr(44))
    inc %a
  }
  if ($+($chr(44),$round($2,1),$chr(44)) isin %temp) return $true
  else return $false
}
alias lvl {
  return $readini(exp.ini,lvl,$calc($1))
}
alias l {
  return $readini(exp.ini,lvl,$calc($1))
}
