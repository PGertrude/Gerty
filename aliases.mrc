>start<|aliases.mrc|$TimeToday added|1.92|a
# return $chr(35)
$ return $chr(36)
% return $chr(37)
| return $chr(124)
_CheckMain {
  if ($me != Gerty && $chan == #gerty) { halt }
  return
}
; _throw $nopath($script) %thread
_throw {
  var %script = $1
  if ($sockname) {
    var %thread = $2, %info
    var %x = 1
    while (%x <= $hget(%thread,0).item) {
      %info = %info $hget(%thread,$hget(%thread,%x).item)
      inc %x
    }
    write ErrorLog.txt $date $timestamp SocketError: %script %thread $([,) $+ %info $3- $+ $(],)
    $cmd(%thread,out) Connection Error: Please try again in a few moments.
    .hfree %thread
    sockclose $sockname
    return
  }
  if ($hget($2)) {
    var %info, %x = 1, %thread = $2
    while (%x <= $hget(%thread,0).item) {
      %info = %info $hget(%thread,$hget(%thread,%x).item)
      inc %x
    }
    .tokenize 32 $3-
  }
  write ErrorLog.txt $date $timestamp Error: %script $([,) $+ %info $2- $+ $(],)
}
_network {
  .timer 1 0 noop $_networkMsg($1)
}
_networkMsg {
  var %x = 1
  while (%x <= $hget(botlist,0).item) {
    var %bot = $hget(botlist,%x)
    if ($comchan(%bot,#gerty)) { .ctcp %bot rawcommand $1- }
    inc %x
  }
}
price {
  var %item = $replace($1,$chr(32),+)
  if ($hget(prices,%item)) return $v1
  var %socket = $+(price.,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %url = http://p-gertrude.rsportugal.org/gerty/price.php?type=price&item= $+ %item
  var %string = $downloadstring(%socket, %url)
  if ($numtok($gettok(%string,1,10),9) == 2) {
    hadd -m prices $replace($gettok($gettok(%string,1,10),1,9),$chr(32),+) $gettok($gettok(%string,1,10),2,9)
    return $gettok($gettok(%string,1,10),2,9)
  }
  return 0
}
; $checkline(out,string)
checkline {
  var %out $1, %string $2, %output, %y = 1
  if ($prop == word) {
    if ($len(%string) < 400) { %out %string | return }
    while (%string && %y < 10) {
      var %x = 1, %z = 1
      while ($len(%output) < 400 && %z < 10) {
        %output = %output $gettok(%string,%x,32)
        inc %x
        inc %z
      }
      %out %output
      $replace(%string,%output,$null)
      inc %y
    }
  }
}
tomorrow {
  if ($day == Monday) { return Tuesday }
  if ($day == Tuesday) { return Wednesday }
  if ($day == Wednesday) { return Thursday }
  if ($day == Thursday) { return Friday }
  if ($day == Friday) { return Saturday }
  if ($day == Saturday) { return Sunday }
  if ($day == Sunday) { return Monday }
}
yesterday {
  if ($day == Monday) { return Sunday }
  if ($day == Tuesday) { return Monday }
  if ($day == Wednesday) { return Tuesday }
  if ($day == Thursday) { return Wednesday }
  if ($day == Friday) { return Thursday }
  if ($day == Saturday) { return Friday }
  if ($day == Sunday) { return Saturday }
}
days {
  var %month = $1
  if (!%month) { %month = $date(mmmm) }
  if (%month == January) { return 31 }
  if (%month == February) { return 28 }
  if (%month == March) { return 31 }
  if (%month == April) { return 30 }
  if (%month == May) { return 31 }
  if (%month == June) { return 30 }
  if (%month == July) { return 31 }
  if (%month == August) { return 31 }
  if (%month == September) { return 30 }
  if (%month == October) { return 31 }
  if (%month == November) { return 30 }
  if (%month == December) { return 31 }
}
nextMonth {
  if ($date(mmmm) == January) { return February }
  if ($date(mmmm) == February) { return March }
  if ($date(mmmm) == March) { return April }
  if ($date(mmmm) == April) { return May }
  if ($date(mmmm) == May) { return June }
  if ($date(mmmm) == June) { return July }
  if ($date(mmmm) == July) { return August }
  if ($date(mmmm) == August) { return September }
  if ($date(mmmm) == September) { return October }
  if ($date(mmmm) == October) { return November }
  if ($date(mmmm) == November) { return December }
  if ($date(mmmm) == December) { return January }
}
lastMonth {
  if ($date(mmmm) == January) { return December }
  if ($date(mmmm) == February) { return January }
  if ($date(mmmm) == March) { return February }
  if ($date(mmmm) == April) { return March }
  if ($date(mmmm) == May) { return April }
  if ($date(mmmm) == June) { return May }
  if ($date(mmmm) == July) { return June }
  if ($date(mmmm) == August) { return July }
  if ($date(mmmm) == September) { return September }
  if ($date(mmmm) == October) { return October }
  if ($date(mmmm) == November) { return November }
  if ($date(mmmm) == December) { return December }
}
host {
  if ($1 == timezone) {
    return $readini(Gerty.Config.ini,host,tzone)
  }
  if ($1 == offset) {
    return $asctime(z)
  }
  var %hour = $regsubex($time,/^(\d{2}).+$/,$calc(\1 - $host(offset)))
  if ($1 == time) {
    if (%hour < 0) { %hour = $calc(24 + %hour) }
    if (%hour > 24) { %hour = $calc(%hour - 24) }
    return $regsubex($time,/^\d{2}:/,%hour $+ :)
  }
  if ($1 == day) {
    if (%hour > 24) { return $tomorrow }
    if (%hour < 0) { return $yesterday }
    return $day
  }
  if ($1 == date) {
    var %date = $date(dd)
    if (%hour < 0 && %date == 01) { return $days($lastmonth) }
    if (%hour < 0) { return $calc(%date - 1) }
    if (%hour > 24 && %date == $days) { return 01 }
    if (%hour > 24) { return $calc(%date + 1) }
    else return %date
  }
  if ($1 == month) {
    var %date = $date(dd)
    if ($prop == 3) {
      if (%hour > 24 && %date == $days) { return $left($nextMonth,3) }
      if (%hour < 0 && %date == 01) { return $left($lastmonth,3) }
      return $date(mmm)
    }
    if (%hour > 24 && %date == $days) { return $nextMonth }
    if (%hour < 0 && %date == 01) { return $lastmonth }
    return $date(mmmm)
  }
}
bot {
  ; bot ID
  if ($1 == id) {
    noop $regex($me,/(\[.{2}\]|)/i)
    return $iif($regml(1),$v1,[00])
  }
  ; Current Users
  if ($1 == users) {
    var %x 1
    while ($chan(%x)) {
      var %a $calc(%a + $nick($chan(%x),0))
      var %b %b $chan(%x) $+ $chr(91) $+ $nick($chan(%x),0) $+ $chr(93)
      inc %x
    }
    return %a
  }
  ; Current Channels
  if ($1 == chanlist) {
    var %x = 2, %max = $chan(0), %chans = $chan(1)
    while (%x <= %max) {
      %chans = %chans $+ , $chan(%x)
      inc %x
    }
    return %chans
  }
}
; $command(%thread[command ID],var)
; returns info on a command/user
command {
  if (!$2) { return }
  return $hget($1,$2)
}
cmd {
  if (!$2) { return }
  return $hget($1,$2)
}
; _fillCommand %thread[Command ID] trigger nick chan command
; creates command info
_fillCommand {
  if (!$5) { return }
  var %thread = $1
  hadd -m %thread out $saystyle($2,$3,$4)
  hadd -m %thread from $3
  hadd -m %thread from.RSN $rsn($3)
  hadd -m %thread from.IsAdmin $admin($3)
  hadd -m %thread command $5
  if ($6) {
    .tokenize 32 $6-
    var %x = 1
    while (%x <= $0) {
      hadd -m %thread arg $+ %x $ [ $+ [ %x ] ]
      inc %x
    }
  }
}
; _clearCommand %thread[command ID]
; removes command info
_clearCommand {
  if (!$1) { return }
  var %thread = $1
  hfree %thread
}
TimeToday {
  var %today, %week, %month, %year
  if ($duration($time) >= 25200) {
    %today = $calc($duration($time) - 25200)
  }
  else {
    %today = $calc($duration($time) + 61200)
  }
  if ($duration($time) < 25200 && $day == sunday) {
    %week = $calc(579600 + %today)
  }
  else if ($duration($time) < 25200 && $day != sunday) {
    %week = $calc($replace($day,Monday,0,Tuesday,1,Wednesday,2,Thursday,3,Friday,4,Saturday,5) * 86400 + %today )
  }
  else if ($duration($time) >= 25200) {
    %week = $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
  }
  if ($duration($time) < 25200 && $date(dd) == 01) {
    %month = $calc($replace($date(mmm),Jan,2394000,Feb,2653200,Mar,2566800,Apr,2653200,May,2566800,Jun,2653200,Jul,2653200,Aug,2566800,Sep,2653200,Oct,2566800,Nov,2653200,Dec,2653200) + %today)
  }
  else {
    %month = $calc(($gettok($date,1,47) - 1) * 86400 + %today )
  }
  %year = $calc($ctime($date $time) - $ctime(January 1 $date(yyyy) 07:00:00))
  return %today %week %month %year
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
chanset return $readini(chan.ini,$1,$2)
userset return $readini(user.ini,$1,$2)
downloadstring {
  .comopen $1 msxml2.xmlhttp
  var %p = $com($1 ,open,1,bstr,get,bstr,$2,bool,-1)
  %p = $com($1 ,send,1)
  %p = $com($1 ,responseText,2)
  %p = $com($1 ).result
  .comclose $1
  return %p
}
download.break {
  .comopen $2 msxml2.xmlhttp
  noop $com($2 ,open,1,bstr,get,bstr,$3,bool,0)
  noop $comcall($2 ,noop $!com($1,responseText,2) $(|,) $1 $!com($1).result $(|,) .comclose $!1,send,1)
}
trim return $regsubex($1-,/^\s*(\S+)\s*$/,\1)
c {
  if $1 isnum {
    if $len($1) == 2 return $chr(3) $+ $1
    else return $+($chr(3),0,$1)
  }
  else return $chr(15)
}
saystyle {
  ;trigger = $1, nick = $2, chan = $3
  !if (!$3 || $3 == PM) { !return !.msg $nick }
  !if (!$readini(chan.ini,$3,public)) { !return $iif($1 == @,!.msg $3,!.notice $2) }
  !if ($readini(chan.ini,$3,public) == on) { !return $iif($1 == @,!.msg $3,!.notice $2) }
  !if ($readini(chan.ini,$3,public) == off) { !return !.notice $2 }
  !if ($readini(chan.ini,$3,public) == voice) { !return $iif($2 isvoice $3 || $2 ishop $3 || $2 isop $3,$iif($1 == @,!.msg $3,!.notice $2),!.notice $2) }
  !if ($readini(chan.ini,$3,public) == half) { !return $iif($2 ishop $3 || $2 isop $3,$iif($1 == @,!.msg $3,.notice $2),!.notice $2) }
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
  if ($regex($closedrsn($1),$+(/^,$chr(40),$readini(Gerty.Config.ini,admin,rsn),$chr(41),/i))) { return admin }
}
closedrsn {
  var %inputnick = $replace($strip($1),$chr(32),_)
  %inputnick = $iif($right(%inputnick,1) == &,$left(%inputnick,-1),%inputnick)
  if ($readini(rsn.ini,$address(%inputnick,3),rsn)) { return $readini(rsn.ini,$address(%inputnick,3),rsn) }
}
rsn {
  var %inputnick = $replace($strip($1),$chr(32),_)
  %inputnick = $iif($right(%inputnick,1) == &,$left(%inputnick,-1),%inputnick)
  var %rsn
  if ($readini(rsn.ini,$address(%inputnick,3),rsn)) { %rsn = $readini(rsn.ini,$address(%inputnick,3),rsn) }
  else {
    if ($readini(rsn.ini,$regsubex(%inputnick,/\W/Sg,_),rsn)) { %rsn = $readini(rsn.ini,$regsubex(%inputnick,/\W/Sg,_),rsn) }
    else { %rsn = $regsubex(%inputnick,/\W/Sg,_) }
  }
  return $caps($regsubex(%rsn,/\W/g,_))
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
  return %x
}
urlencode {
  var %a = $regsubex($$1,/([^\w\s])/Sg,$+(%,$base($asc(\t),10,16,2)))
  return $replace(%a,$chr(32),$chr(43))
}
smart {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(ncb|noncmb|non-cmb|non-comb|noncomb|non-combat|noncombat|non-warrior)$/Si)) { return Noncmb }
  if ($regex($1,/^(cm|cp|cmp|comp|compare)$/Si)) { return Compare }
  if ($regex($1,/^(lvl|level|skill|skilltotal)$/Si)) { return SkillTotal }
  if ($regex($1,/^(xp|exp|totalxp|totalexp)$/Si)) { return TotalXp }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
  else { return NoMatch }
}
compares {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
}
lookups {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(ncb|noncmb|non-cmb|non-comb|noncomb|non-combat|noncombat|non-warrior)$/Si)) { return Noncmb }
  if ($regex($1,/^(req|reqs|ssreq|ssreqs|requirements)$/Si)) { return reqs }
  if ($regex($1,/^(le|left|lc|lcol|leftcol|leftcolumn)$/Si)) { return left }
  if ($regex($1,/^(ri|right|rightc|rightcol|rightcolumn)$/Si)) { return right }
  if ($regex($1,/^(mid|middle|midc|midcol|middlec|middlecol|middlecolumn)$/Si)) { return mid }
  else { return NoMatch }
}
scores {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  else { return NoMatch }
}
skills {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging|rang)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construct|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  else { return NoMatch }
}
minigames {
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising) ?(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  else { return NoMatch }
}
misc {
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(ncb|noncmb|non-cmb|non-comb|noncomb|non-combat|noncombat|non-warrior)$/Si)) { return Noncmb }
  if ($regex($1,/^(cm|cp|cmp|comp|compare)$/Si)) { return Compare }
  if ($regex($1,/^(ne|next|nextlvl|nextlevel|close|cl|closest)$/Si)) { return Next }
  if ($regex($1,/^(hi|high|highest|lo|low|lowest|hilow|hilo|highlow)$/Si)) { return Hilow }
  if ($regex($1,/^(le|left|lc|lcol|leftcol|leftcolumn)$/Si)) { return left }
  if ($regex($1,/^(ri|right|rightc|rightcol|rightcolumn)$/Si)) { return right }
  if ($regex($1,/^(mid|middle|midc|midcol|middlec|middlecol|middlecolumn)$/Si)) { return mid }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
  else { return NoMatch }
}
perc {
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
  else { return nomatch }
}
state {
  if ($regex($remove($1,@),/^(r|ra|ran|rank|ranking)$/Si)) { return 1 }
  if ($regex($remove($1,@),/^(l|lv|lvl|level)$/Si)) { return 2 }
  if ($regex($remove($1,@),/^(x|xp|ex|exp|experience)$/Si)) { return 3 }
  if ($regex($remove($1,@),/^(v|vi|vir|virt|virtual)$/Si)) { return 4 }
  else { return 2 }
}
ltracks {
  if ($regex($remove($1,@),/^(yday|yesterday)$/Si)) { return Yesterday }
  if ($regex($remove($1,@),/^(lweek|lastweek)$/Si)) { return Lastweek }
  if ($regex($remove($1,@),/^(lmonth|lastmonth)$/Si)) { return Lastmonth }
  if ($regex($remove($1,@),/^(lyear|lastyear)$/Si)) { return Lastyear }
  else { return NoMatch }
}
tracks {
  if ($regex($remove($1,@),/^(2day|today)$/Si)) { return Today }
  if ($regex($remove($1,@),/^(week)$/Si)) { return Week }
  if ($regex($remove($1,@),/^(month)$/Si)) { return Month }
  if ($regex($remove($1,@),/^(year)$/Si)) { return Year }
  else { return NoMatch }
}
statn {
  if ($skills($1) == overall) { return 11 }
  if ($skills($1) == attack) { return 12 }
  if ($skills($1) == strength) { return 14 }
  if ($skills($1) == defence) { return 13 }
  if ($skills($1) == hitpoints) { return 15 }
  if ($skills($1) == ranged) { return 16 }
  if ($skills($1) == prayer) { return 17 }
  if ($skills($1) == magic) { return 18 }
  if ($skills($1) == cooking) { return 19 }
  if ($skills($1) == woodcutting) { return 20 }
  if ($skills($1) == fletching) { return 21 }
  if ($skills($1) == fishing) { return 22 }
  if ($skills($1) == firemaking) { return 23 }
  if ($skills($1) == crafting) { return 24 }
  if ($skills($1) == smithing) { return 25 }
  if ($skills($1) == mining) { return 26 }
  if ($skills($1) == herblore) { return 27 }
  if ($skills($1) == agility) { return 28 }
  if ($skills($1) == thieving) { return 29 }
  if ($skills($1) == slayer) { return 30 }
  if ($skills($1) == farming) { return 31 }
  if ($skills($1) == runecraft) { return 32 }
  if ($skills($1) == hunter) { return 33 }
  if ($skills($1) == construction) { return 34 }
  if ($skills($1) == summoning) { return 35 }
  if ($minigames($1) == Duel) { return 36 }
  if ($minigames($1) == Bounty Hunter) { return 37 }
  if ($minigames($1) == Bounty Hunter Rogues) { return 38 }
  if ($minigames($1) == Fist Of Guthix) { return 39 }
  if ($minigames($1) == Mobilising Armies) { return 40 }
}
statnum {
  if ($skills($1) == overall) { return 1 }
  if ($skills($1) == attack) { return 2 }
  if ($skills($1) == strength) { return 4 }
  if ($skills($1) == defence) { return 3 }
  if ($skills($1) == hitpoints) { return 5 }
  if ($skills($1) == ranged) { return 6 }
  if ($skills($1) == prayer) { return 7 }
  if ($skills($1) == magic) { return 8 }
  if ($skills($1) == cooking) { return 9 }
  if ($skills($1) == woodcutting) { return 10 }
  if ($skills($1) == fletching) { return 11 }
  if ($skills($1) == fishing) { return 12 }
  if ($skills($1) == firemaking) { return 13 }
  if ($skills($1) == crafting) { return 14 }
  if ($skills($1) == smithing) { return 15 }
  if ($skills($1) == mining) { return 16 }
  if ($skills($1) == herblore) { return 17 }
  if ($skills($1) == agility) { return 18 }
  if ($skills($1) == thieving) { return 19 }
  if ($skills($1) == slayer) { return 20 }
  if ($skills($1) == farming) { return 21 }
  if ($skills($1) == runecraft) { return 22 }
  if ($skills($1) == hunter) { return 23 }
  if ($skills($1) == construction) { return 24 }
  if ($skills($1) == summoning) { return 25 }
  if ($minigames($1) == Duel) { return 26 }
  if ($minigames($1) == Bounty Hunter) { return 27 }
  if ($minigames($1) == Bounty Hunter Rogues) { return 28 }
  if ($minigames($1) == Fist Of Guthix) { return 29 }
  if ($minigames($1) == Mobilising Armies) { return 30 }
  if ($1 == 1) { return overall }
  if ($1 == 2) { return attack }
  if ($1 == 3) { return defence }
  if ($1 == 4) { return strength }
  if ($1 == 5) { return hitpoints }
  if ($1 == 6) { return ranged }
  if ($1 == 7) { return prayer }
  if ($1 == 8) { return magic }
  if ($1 == 9) { return cooking }
  if ($1 == 10) { return woodcutting }
  if ($1 == 11) { return fletching }
  if ($1 == 12) { return fishing }
  if ($1 == 13) { return firemaking }
  if ($1 == 14) { return crafting }
  if ($1 == 15) { return smithing }
  if ($1 == 16) { return mining }
  if ($1 == 17) { return herblore }
  if ($1 == 18) { return agility }
  if ($1 == 19) { return thieving }
  if ($1 == 20) { return slayer }
  if ($1 == 21) { return farming }
  if ($1 == 22) { return runecraft }
  if ($1 == 23) { return hunter }
  if ($1 == 24) { return construction }
  if ($1 == 25) { return summoning }
  if ($1 == 26) { return duel }
  if ($1 == 27) { return bounty hunter }
  if ($1 == 28) { return bounty hunter rogues }
  if ($1 == 29) { return fist of guthix }
  if ($1 == 30) { return mobilising armies }
}
cutey {
  if ($regex($1,/^(xp|exp|experience)$/Si)) { return xp }
  if ($regex($1,/^(ra|rank|ranking)$/Si)) { return rank }
  if ($regex($1,/^(ne|next|close|closest|nextlvl|nextlevel)$/Si)) { return next }
}
catno {
  if ($1 != duel && $1 != bounty hunter && $1 != bounty hunter rogues && $1 != fist of guthix && $1 != mobilising armies) { return 0 }
  if ($1 == duel || $1 == bounty hunter || $1 == bounty hunter rogues || $1 == fist of guthix || $1 == mobilising armies) { return 1 }
}
smartno {
  if ($1 == Attack) { return 1 }
  if ($1 == Defence) { return 2 }
  if ($1 == Strength) { return 3 }
  if ($1 == Hitpoints) { return 4 }
  if ($1 == Ranged) { return 5 }
  if ($1 == Prayer) { return 6 }
  if ($1 == Magic) { return 7 }
  if ($1 == Cooking) { return 8 }
  if ($1 == Woodcutting) { return 9 }
  if ($1 == Fletching) { return 10 }
  if ($1 == Fishing) { return 11 }
  if ($1 == Firemaking) { return 12 }
  if ($1 == Crafting) { return 13 }
  if ($1 == Smithing) { return 14 }
  if ($1 == Mining) { return 15 }
  if ($1 == Herblore) { return 16 }
  if ($1 == Agility) { return 17 }
  if ($1 == Thieving) { return 18 }
  if ($1 == Slayer) { return 19 }
  if ($1 == Farming) { return 20 }
  if ($1 == Runecraft) { return 21 }
  if ($1 == Hunter) { return 22 }
  if ($1 == Construction) { return 23 }
  if ($1 == summoning) { return 24 }
  if ($1 == Overall) { return 0 }
  if ($1 == duel) { return 0 }
  if ($1 == bounty hunter) { return 1 }
  if ($1 == bounty hunter Rogues) { return 2 }
  if ($1 == fist of guthix) { return 3 }
  if ($1 == mobilising armies) { return 4 }
  else { return NoMatch }
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
  if ($1 > 950000) {
    return $round($calc( $1 / 1000000 ),2) $+ m
  }
  if ($1 > 9500) {
    return $round($calc( $1 / 1000 ),2) $+ k
  }
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
  if ($prop == all) { return $c(07) $+ $iif($9,$c(07) $+ $bytes($9,db) $+ $c $+ ,$floor(%p2p) $+ $c $+ ( $+ $c(07) $+ ~ $+ $floor(%gp2p) $+ $c $+ )) combat ( $+ $c(07) $+ %class $+ $c $+ ); }
  if ($prop == p2p) { return %p2p }
  if ($prop == f2p) { return %f2p }
  if ($prop == gf2p) { return %gf2p }
  if ($prop == gp2p) { return %gp2p }
}
