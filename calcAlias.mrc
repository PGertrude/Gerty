calcreg {
  var %string = $replace($1,xp,A,ge,T,price,T,pi,~,ans,p)
  %string = $regsubex(%string,/(?:([\dep~kmbx\x29])([\x28])|([\x29])([\dep~xastcl])|([ep~])([ep~xastcl])|(x)([e~ctsxl])|(\d)([ep~xastcl]))/gi,\1*\2)
  %string = $regsubex(%string,/(?:([\dep~kmbx\x29])([\x28])|([\x29])([\dep~xastcl])|([ep~])([ep~xastcl])|(x)([e~ctsxl])|(\d)([ep~xastcl]))/gi,\1*\2)
  %string = $regsubex(%string,/([^\+\-\*\\\^]|)T\(([^\x29]+)\)/gi,$iif(\1,\1*,1*) $+ $price(\2))
  %string = $regsubex(%string,/(\d+(?:\.\d+)?)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %string = $regsubex(%string,/(a?(?:sin|cos|tan|log|sqrt|l(?:vl)?|A|T))((?:\+|\-)?(?:[ep~x]|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  return $replace(%string,~,3.141593,e,2.718281,p,$hget($nick,p),$chr(44),$null)
}
; will return a nice version of the calculation
calcparse {
  var %eq = $remove($1-,$chr(44))
  %eq = $regsubex(%eq,/([^\+\-\*\\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*) $+ $price(\2))
  %eq = $replace($remove(%eq,$chr(32)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,pi,p,ans)
  return %eq
}
; always returns the result of a calculation
calculate {
  var %input = $1-
  .tokenize 32 $_checkCalc(%input)
  if ($1 == false) { return 0 }
  var %string = $calcreg(%input)
  if (= !isin $1-) {
    %string = %string $+ =x
  }
  var %answer = $solve(%string)
  return %answer
}
; will return $1 if the input is not a calculation
nullcalc {
  var %input = $1-
  .tokenize 32 $_checkCalc(%input)
  if ($1 == false) { return $1 }
  var %string = $calcreg(%input)
  if (= !isin $1-) {
    %string = %string $+ =x
  }
  var %answer = $solve(%string)
  return %answer
}
; returns calculation, will return 0 if error (no x solving!)
litecalc {
  var %input = $1-
  .tokenize 32 $_checkCalc(%input)
  if ($1 == false) { return 0 }
  var %string = $calcreg(%input)
  if (= !isin $1-) {
    %string = %string $+ =x
  }
  return $calc($parser(%string))
}
_checkCalc {
  var %string = $replace($1,xp,A,ge,T,price,T,pi,~,ans,p)
  %string = $regsubex(%string,/([TA])\x28(.+?)\x29/g,\1(1))
  %string = $regsubex(%string,/(?:([\dep~kmbx\x29])([\x28])|([\x29])([\dep~xastcl])|([ep~])([ep~xastcl])|(x)([e~ctsxl])|(\d)([ep~xastcl]))/gi,\1*\2)
  %string = $regsubex(%string,/(?:([\dep~kmbx\x29])([\x28])|([\x29])([\dep~xastcl])|([ep~])([ep~xastcl])|(x)([e~ctsxl])|(\d)([ep~xastcl]))/gi,\1*\2)
  if ($_checkParen(%string)) { return false Unbalanced Parenthesis:07 $v1 }
  if ($_checkFunct(%string,$2)) { return false Unknown function:07 $v1 }
  if ($regex(%string,/(.+|)([\+\-\*\/\^])([\*\/\^])(.+|)|()(^[\*\/\^])()(.+|)|(.+|)([\+\-\*\/\^]$)/)) { return false Operations error: $regml(1) $+ 04 $+ $regml(2) $+ $regml(3) $+  $+ $regml(4) }
  return true
}
_checkParen {
  var %string = $1
  while ($chr(40) isin %string || $chr(41) isin %string) {
    var %input = %string
    %string = $regsubex(%string,/\x28[^\x28\x29]*\x29/g,$chr(32))
    if (%input == %string) { return %string }
  }
  return
}
_checkFunct {
  var %string = $remove($1,$chr(44)), %x = 1, %ErrReply = $2
  %string = $regsubex(%string,/(a?(?:sin|cos|tan|log|sqrt|l(?:vl)?|A|T))((?:\+|\-)?(?:[ep~x]|\d+(?:\.\d+)?))/gi,\1 \2 $+ $chr(32))
  %string = $replace(%string,+,$chr(32),-,$chr(32),*,$chr(32),/,$chr(32),\,$chr(32),^,$chr(32),$chr(40),$chr(32),$chr(41),$chr(32),=,$chr(32))
  .tokenize 32 %string
  ; if (!$2) return Not enough parameters
  while (%x <= $0) {
    if (%ErrReply == no && !$2) { return false }
    var %func = $ [ $+ [ %x ] ]
    if ($func(%func) || $regex(%func,/^(\d+(\.\d+)?[mbk]?|x|e|p|~)$/i)) {
      inc %x
      if ($func(%func) && !$ [ $+ [ %x ] ]) { return function missing the argument. }
      continue
    }
    return %func
  }
}
func {
  if ($1 == sin) { return sin( $+ $2 $+ ) }
  if ($1 == cos) { return cos( $+ $2 $+ ) }
  if ($1 == tan) { return tan( $+ $2 $+ ) }
  if ($1 == asin) { return asin( $+ $2 $+ ) }
  if ($1 == acos) { return acos( $+ $2 $+ ) }
  if ($1 == atan) { return atan( $+ $2 $+ ) }
  if ($1 == log) { return log( $+ $2 $+ ) }
  if ($1 == nlog) { return nlog( $+ $2 $+ ) }
  if ($1 == l) { return l( $+ $2 $+ ) }
  if ($1 == lvl) { return l( $+ $2 $+ ) }
  if ($1 == sqrt) { return sqrt( $+ $2 $+ ) }
  if ($1 == T) { return ge( $+ $2 $+ ) }
  if ($1 == A) { return xp( $+ $2 $+ ) }
  return $false
}
solve {
  var %eq = $lower($1)
  %eq = $remove(%eq,$chr(32))
  if (= isin %eq) %eq = $gettok(%eq,1,61) $+ -( $+ $gettok($1,2,61) $+ )
  return $multiple(%eq,$xsolve(%eq))
}
multiple {
  var %x = $2
  var %eq = $1
  var %solutions = $iif($abs($xcalculate(%eq,%x)) < 0.001,or07 $2 or07,$false)
  if ($regex(%eq,asin|acos|atan|sin|cos|tan) && %solutions) return $mid(%solutions,7,-7)
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
xsolve {
  var %x = 20
  var %a = 0
  while (%a <= 30) {
    %x = $calc(%x - $+($chr(40),$xcalculate($1,%x),/,$derivative($1,%x),$chr(41)))
    inc %a
  }
  return $xcheck($1,%x)
}
derivative {
  var %num2 = $xcalculate($1,$2 + 1)
  var %num3 = $xcalculate($1,$2 - 1)
  return $calc((%num2 - %num3) / 2)
}
xcheck {
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
xcalculate return $calc($parser($replace($1,x,$calc($2))))
parser return $regsubex($1-,/((sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)\050(-?\d+(?:\.\d+)?(?:[\*\/\+-]\d+(?:\.\d+)?)*)\051)/g,$($\2($calc(\3)) $+ .deg,2))
redundant {
  var %temp = $chr(44)
  var %a = 1
  while (%a <= $gettok($1,0,44)) {
    %temp = $+(%temp,$round($gettok($1,%a,44),1),$chr(44))
    inc %a
  }
  if ($+($chr(44),$round($2,1),$chr(44)) isin %temp) return $true
  else return $false
}
lvl return $readini(exp.ini,lvl,$calc($1))
l return $readini(exp.ini,lvl,$calc($1))