on $*:TEXT:/^[^\.] */Si:#: {
  var %eq = $remove($1-,$chr(44))
  %eq = $regsubex(%eq,/([^\+\-\*\\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*,1*) $+ $price(\2))
  %eq = $replace($remove(%eq,$chr(32)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/(\D)(\.\d+)/g,\1 $+ 0\2)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l|price)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  %valid = $regex(calc,%eq,/^(((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?|price)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*)(\x29*[\+\-\*\/\^\=]+((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?|price)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*))+|(\+|\-)?((a?(sin|cos|tan)|log|sqrt|l(vl)?|price)\((\+|\-)?(\d+(\.\d+)?)\)|\d+(\!)|\d+\*C\d+))$/gi)
  %solve = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,$calc($fact(\1) / ( $fact($calc(\1 - \4)) * $fact(\4) ) ))
  %sum = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,\1C\4)
  %sum = $regsubex(%sum,/(^|[^\d\.])1\*/g,\1$null)
  if (%valid >= 1) {
    if (*=* iswm $1-) {
      if ($numtok($solve($regml(calc,1-)),44) >= 2) {
        .notice $nick %sum 12=> x=07 $regsubex($regsubex($solve(%solve),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
        hadd -m $nick p $remove($gettok($replace($solve(%solve),$chr(44),$+($chr(32),Or07,$chr(32)),$+($,false),Unsolvable),1,32),$chr(44))
      }
      else {
        .notice $nick %sum =07 $iif($solve(%solve) != $false,$bytes($solve(%solve),db),Unsolvable)
        hadd -m $nick p $remove($gettok($replace($solve(%solve),$+($,false),Unsolvable),1,32),$chr(44))
      }
    }
    else {
      if ($numtok($solve(%solve),44) >= 2) {
        .notice $nick %sum $+ =x 12=> x=07 $regsubex($regsubex($solve(%solve $+ =x),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
        hadd -m $nick p $remove($gettok($replace($solve(%solve),$chr(44),$+($chr(32),Or07,$chr(32)),$+($,false),Unsolvable),1,32),$chr(44))
      }
      else {
        .notice $nick %sum =07 $iif($solve(%solve) != $false,$bytes($solve(%solve),db),Unsolvable)
        hadd -m $nick p $remove($gettok($replace($solve(%solve),$+($,false),Unsolvable),1,32),$chr(44))
      }
    }
  }
}
; always returns the result of a calculation ( may be a single number )
alias calculate {
  var %eq = $remove($1-,$chr(44))
  %eq = $regsubex(%eq,/([^\+\-\*\\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*) $+ $price(\2))
  %eq = $replace($remove(%eq,$chr(32)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l|price)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  %valid = $regex(calc,%eq,/^(((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*)(\x29*[\+\-\*\/\^\=]+((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*))+|(\+|\-)?((a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?)\)|\d+(\!)|\d+\*C\d+)|\d+(?:\.\d+)?)$/gi)
  %solve = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,$calc($fact(\1) / ( $fact($calc(\1 - \4)) * $fact(\4) ) ))
  %sum = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,\1C\4)
  if (%valid >= 1) {
    if (*=* iswm $1-) {
      if ($numtok($solve($regml(calc,1-)),44) >= 2) {
        return $regsubex($regsubex($solve(%solve),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
    else {
      if ($numtok($solve(%solve),44) >= 2) {
        return $regsubex($regsubex($solve(%solve $+ =x),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
  }
}
; will return $1 if the input is not a calculation
alias nullcalc {
  var %eq = $remove($1-,$chr(44))
  %eq = $regsubex(%eq,/([^+-\*\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*) $+ $price(\2))
  %eq = $replace($remove(%eq,$chr(32)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  %valid = $regex(calc,%eq,/^(((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*)(\x29*[\+\-\*\/\^\=]+((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*))+|(\+|\-)?((a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?)\)|\d+(\!)|\d+\*C\d+)|\d+(?:\.\d+)?)$/gi)
  %solve = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,$calc($fact(\1) / ( $fact($calc(\1 - \4)) * $fact(\4) ) ))
  %sum = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,\1C\4)
  if (%valid >= 1) {
    if (*=* iswm $1-) {
      if ($numtok($solve($regml(calc,1-)),44) >= 2) {
        return $regsubex($regsubex($solve(%solve),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
    else {
      if ($numtok($solve(%solve),44) >= 2) {
        return $regsubex($regsubex($solve(%solve $+ =x),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
  }
  else return $1
}
; will return a nice version of the calculation
alias calcparse {
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
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  return $regsubex(%eq,/(\d+)\*C(\d+)/gi,\1C\2)
}
; will return the result of a calculation ( if not a calc returns null, will not accept single number )
alias strictcalc {
  var %eq = $remove($1-,$chr(44))
  %eq = $regsubex(%eq,/([^\+\-\*\\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*,1*) $+ $price(\2))
  %eq = $replace($remove(%eq,$chr(32)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  %valid = $regex(calc,%eq,/^(((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*)(\x29*[\+\-\*\/\^\=]+((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*))+|(\+|\-)?((a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?)\)|\d+(\!)|\d+\*C\d+))$/gi)
  %solve = $regsubex(%eq,/(\d+)\*c(\d+)/gi,$calc($fact(\1) / ( $fact($calc(\1 - \2)) * $fact(\2) ) ))
  %sum = $regsubex(%eq,/(\d+)\*c(\d+)/gi,\1C\2)
  if (%valid >= 1) {
    if (*=* iswm $1-) {
      if ($numtok($solve($regml(calc,1-)),44) >= 2) {
        return $regsubex($regsubex($solve(%solve),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
    else {
      if ($numtok($solve(%solve),44) >= 2) {
        return $regsubex($regsubex($solve(%solve $+ =x),/(\x2C)/g,$+($chr(32),Or07,$chr(32))),/\$false/g,Unsolvable)
      }
      else {
        return $iif($solve(%solve) != $false,$solve(%solve),Unsolvable)
      }
    }
  }
  return false
}
; returns calculation, may be single number, will return 0 if error (no x solving!)
alias litecalc {
  %eq = $regsubex(%eq,/([^\+\-\*\\\^]|)(?:price|ge)\(([^\x29]+)\)/gi,$iif(\1,\1*) $+ $price(\2))
  %eq = $replace($remove($1-,$chr(32),$chr(44)),z,f,pi,z,ans,p)
  %eq = $regsubex(%eq,/([0-9\.]+)([kmb])/gi,$calc(\1 $replace(\2,k,*1000,m,*1000000,b,*1000000000)))
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])([zpexastc])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(sin|asin|acos|atan|cos|tan|log|sqrt|lvl|l)-*((?:[zpex]+|\d+(?:\.\d+)?))/gi,\1 $+ $chr(40) $+ \2 $+ $chr(41))
  %eq = $regsubex(%eq,/(\x29|\d)(\x28|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/(\x29)(\d|[zpexastcls])/gi,\1* $+ \2)
  %eq = $regsubex(%eq,/([zpex])(\d|\x28)/gi,\1* $+ \2)
  %eq = $replace(%eq,z,3.141593,e,2.718281,p,$hget($nick,p))
  %valid = $regex(calc,%eq,/^(((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*)(\x29*[\+\-\*\/\^\=]+((\+|\-)?\x28*(\+|\-)?(\d+(\.\d+)?|x|(a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?|x)\)*|\d+(\!)|\d+\*C\d+)\x29*))*|(\+|\-)?((a?(sin|cos|tan)|log|sqrt|l(vl)?)\((\+|\-)?(\d+(\.\d+)?)\)|\d+(\!)|\d+\*C\d+)|\d+(?:\.\d+)?)$/gi)
  %solve = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,$calc($fact(\1) / ( $fact($calc(\1 - \4)) * $fact(\4) ) ))
  %sum = $regsubex(%eq,/(\d+)(\.?)(\d*)\*c(\d+)(\.?)(\d*)/gi,\1C\4)
  return $calc($parser(%eq))
}
