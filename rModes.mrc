alias versions.rmodes return 4.0

on $*:TEXT:/^[\+\-][a-z]+\b/Si:#: {
  _checkMain
  if ($admin($nick) || $nick isop $chan) {
    var %mode = $1
    if ($left(%mode,1) == + || $left(%mode,1) == -) {
      if ($regex(%mode,/(q|a)/)) { .notice $nick mode $regml(1) cannot be set. | halt }
      if ($left($2,1) != $chr(35)) {
        if (*b* iswm %mode) {
          if (*+* iswm %mode) {
            mode $chan +bbb $address($2,2) $2 $address($2,3)
            if (*k* iswm %mode) kick $chan $2 $3-
            halt
          }
          if (*-* iswm %mode) {
            mode $chan -bbbbbbbb $address($2,2) $2 $address($2,3)
            if (*k* iswm %mode) kick $chan $2 $3-
            halt
          }
        }
        else {
          if (*k* iswm %mode) kick $chan $2 $3-
          else { mode $chan %mode $2- | halt }
        }
      }
      else {
        if (*b* iswm %mode) {
          if (*+* iswm %mode) {
            mode $2 +bbbbbbbb $address($3,2) $3 $address($3,3)
            if (*k* iswm %mode) kick $2 $3 $4-
            halt
          }
          if (*-* iswm %mode) {
            mode $2 -bbbbbbbb $address($3,2) $3 $address($3,3)
            if (*k* iswm %mode) kick $2 $3 $4-
            halt
          }
        }
        else {
          if (*k* iswm %mode) kick $2 $3 $4-
          else { mode $2 %mode $3- | halt }
        }
      }
    }
  }
}
