on $*:TEXT:/^[!@.](sys|system|linearsystem)\b/Si:*: {
  var %system $remove($2-,$chr(32))
  tokenize 59 %system

  ; parse string into var coef|var coef

  var %x 1, %eq, %varList, %parsedVars
  while (%x <= $0) {
    %parsedVars = $sysVars($($ $+ %x,2))
    %varList = %varList $+ $| $+ %parsedVars
    var %vars [ $+ [ %x ] ] %parsedVars
    inc %x
  }

  var %x 1, %cleanVars
  while (%x <= $numtok(%varList,124)) {
    %cleanVars = %cleanVars $+ $| $+ $gettok($gettok(%varList,%x,124),1,32)
    inc %x
  }

  %cleanVars = $sysVarGroup(%cleanVars)

  ; form matrix

  if ($numtok(%system,59) < $calc($numtok(%cleanVars,124) -1)) {
    .msg P_Gertrude No unique solution
  }
  else {
    .msg P_Gertrude A unique solution may be possible
  }
}



alias sysVars {
  var %eq $1
  %eq = $regsubex(%eq,/(\d)([a-zA-z])/gS,\1*\2)
  %eq = $regsubex(%eq,/([a-zA-z])(\d)/gS,\1*\2)
  var %reg /([^\(+-\*\/])\(/gS
  %eq = $regsubex(%eq, %reg, \1* $+ $chr(40))
  %reg = /\)([^(+-\/\*])/gS
  %eq = $regsubex(%eq, %reg, $chr(41) $+ *\1)

  ; find the variables in the string.

  var %x 1, %buf, %char, %par 0, %varList, %side = left, %nextBuf
  while (%x <= $len(%eq)) {
    %char = $mid(%eq,%x,1)
    if (%char isin +-=) {
      if (%par == 0) {
        %varList = %varList $+ $| $+ $iif(%side == right,-,$null) $+ $sysTerms(%nextBuf $+ %buf)
        %buf = $null
        if (%char == -) %nextBuf = -
        else %nextBuf = $null
      }
      else {
        %buf = %buf $+ %char
      }
    }
    else {
      if (%char == $chr(40)) { inc %par }
      if (%char == $chr(41)) { dec %par }
      %buf = %buf $+ %char
    }
    if (%char == $chr(61)) %side = right
    inc %x
  }
  %varList = %varList $+ $| $+ $iif(%side == right,-,$null) $+ $sysTerms(%buf)
  if (%par != 0) echo -a bracket mismatch
  return $right(%varList,-1)
}

alias sysTerms {
  var %term $1, %sp $chr(32), %emptyTerm
  %emptyTerm = $replace(%term,$chr(42),%sp,/,%sp,+,%sp,-,%sp $+ -,$chr(40),%sp,$chr(41),%sp)
  tokenize 32 %emptyTerm
  var %x 1, %var, %pos, %len 0
  while (%x <= $0) {
    if (!$sysFunc($($ $+ %x,2)) && !$regex($($ $+ %x,2),/[\d\.-]/)) {
      %var = %var $+ $($ $+ %x,2)
      inc %len
      %pos = %x
    }
    else if (%len > 0) {
      break
    }
    inc %x
  }
  if (%var == $null && %term) { return {const} %term }

  var %x 1, %prec, %post, %coef, %termPos
  while (%x <= $len(%term)) {
    %termPos = $($ $+ %x,2)
    %prec = $mid(%term,$calc(%x -1),1)
    if (%prec == $chr(42)) {
      %coef = $removePosition(%term,%x,%len)
      %coef = $removePosition(%coef,$calc(%x -1),1)
    }
    if (%prec == $chr(47)) {
      %coef = $removePosition(%term,%x,%len)
      %coef = $removePosition(%coef,$calc(%x -1),1)
      %var = 1/ $+ %var
    }
    inc %x
  }
  if (!%coef) { %coef = 1 }
  if (%var) { return %var %coef }
}

alias sysVarGroup {
  var %x = 1
  while ($gettok($1-,%x,124)) {
    var %item = $replace($gettok($1-,%x,124),$chr(32),:space:)
    inc %item. $+ %item
    inc %x
  }
  var %y = 1
  while ($var(%item.*,%y)) {
    var %out = $+(%out,$iif(%out,$|),$replace($gettok($var(%item.*,%y).item,2,46),:space:,$chr(32)))
    inc %y
  }
  unset %item*
  return %out
}

alias removePosition {
  var %string $1, %pos $2, %len $3, %x 1, %newString
  while (%x <= $len(%string)) {
    if (%x < %pos || %x > $calc(%pos + %len)) {
      %newString = %newString $+ $mid(%string,%x,1)
    }
    inc %x
  }
  return %newString
}

alias sysFunc {
  if ($1 == sin) { return sin( $+ $2 $+ ) }
  if ($1 == cos) { return cos( $+ $2 $+ ) }
  if ($1 == tan) { return tan( $+ $2 $+ ) }
  if ($1 == asin) { return asin( $+ $2 $+ ) }
  if ($1 == acos) { return acos( $+ $2 $+ ) }
  if ($1 == atan) { return atan( $+ $2 $+ ) }
  if ($1 == log) { return log( $+ $2 $+ ) }
  if ($1 == nlog) { return nlog( $+ $2 $+ ) }
  if ($1 == sqrt) { return sqrt( $+ $2 $+ ) }
  return $false
}
