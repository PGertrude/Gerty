>start<|hilow.mrc|Users High/Low Stats|2.1|rs
on *:TEXT:*:*: {
  _CheckMain
  ; valid trigger, or halt
  if (!$regex($1,/^[!@.](next(lvl)?|close(est)?|hi(gh)?(est|low?)?|low(est)?)$/Si)) { halt }
  ; declare variables
  var %thread = a $+ $ticks, %nick, %state, %string, %url, %command, %saystyle = $saystyle($left($1,1),$nick,$chan)
  %string = $2-
  ; default state (exp)
  %state = 3
  ; if string contains a switch, change the state (exp or rank)
  if ($regex(%string,/@(\w+)( |$)/)) {
    %state = $state($regml(1))
    %string = $regsubex(%string,/@(\w+)( |$)/,$null)
  }
  ; Do not allow sort by level
  if (%state == 2) { %state = 3 }
  ; default nick
  %nick = $nick
  ; if a different nick specified, change nick
  if ($len($trim(%string)) > 0) {
    %nick = $trim(%string)
  }
  ; retrieve the defname of user
  %nick = $caps($rsn(%nick))
  ; set the skill, next or hilow
  %command = $misc($right($1,-1))
  ; hiscore url, append defname to url
  %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
  ; request hiscore data
  noop $download.break(stats. $+ %command %saystyle %nick %state,stats. $+ %thread,%url)
}
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
alias sortnext {
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
alias sorthilow {
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
