>start<|solve.mrc|Calculator|1.3|rs
on *:text:*:*: {
  _CheckMain
  var %saystyle, %input, %ErrReply
  if ($regex($1,/^[!@.](c|calc)\b/Si)) { %input = $2- | %saystyle = $saystyle($left($1,1),$nick,$chan) | %ErrReply = yes }
  else if ($left($1,1) == ` || $left($1,1) == =) { %input = $right($1-,-1) | %saystyle = $iif($chan,.notice $nick,.msg $nick) | %ErrReply = yes }
  else if ($left($1,1) != . && $left($1,1) != ! && $left($1,1) != @) { %input = $1- | %saystyle = $iif($chan,.notice $nick,.msg $nick) | %ErrReply = no }
  else { halt }
  .tokenize 32 $_checkCalc(%input)
  if ($1 == false) { if (%ErrReply == yes) { %saystyle $2- } | halt }
  var %string = $calcreg(%input)
  var %sum = $calcparse(%input)
  if (= !isin $1-) {
    %string = %string $+ =x
    %sum = %sum $+ =x
  }
  var %answer = $solve(%string)
  %saystyle %sum 12=>07 $regsubex(%answer,/([^\.\d]|^)(\d+)/g,\1$bytes(\2,db))
  hadd -m $nick p $strip($gettok(%answer,1,32))
}
;##################### Solver ###########################
alias solve {
  var %eq = $lower($1)
  %eq = $trans(%eq)
  return $multiple(%eq,$xsolve(%eq))
}
alias trans {
  var %eq = $remove($1,$chr(32))
  if (= isin $1) %eq = $gettok(%eq,1,61) $+ -( $+ $gettok($1,2,61) $+ )
  return %eq
}
alias multiple {
  var %x = $2
  var %eq = $1
  var %trig = $iif($regex(%eq,asin|acos|atan|sin|cos|tan),$true,$false)
  var %solutions = $iif($abs($xcalculate(%eq,%x)) < 0.001,or07 $2 or07,$false)
  if (%trig) return $iif(%solutions,$right($left(%solutions,-7),-7),Unsolvable)
  if (!%solutions) return Unsolvable
  while ($abs($xcalculate(%eq,%x)) < 0.001) {
    %eq = $+($chr(40),%eq,$chr(41),/,$chr(40),x,-,%x,$chr(41))
    %x = $xsolve(%eq)
    if ($redundant(%solutions,%x)) goto finish
    if (($abs($xcalculate(%eq,%x)) < 0.001)) %solutions = %solutions %x or07
  }
  :finish
  return $right($left(%solutions,-7),-7)
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
alias lvl return $readini(exp.ini,lvl,$calc($1))
alias l return $readini(exp.ini,lvl,$calc($1))
