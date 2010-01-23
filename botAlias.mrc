>start<|botAlias.mrc|new|1.0|a
timeCount {
  if ($read(timer.txt,nw,$ctime($asctime($gmt)) $+ *) && $server) { $gettok($read(timer.txt,nw,$ctime($asctime($gmt)) $+ *),2,124) }
  if ($calc($ctime % 60) == 0) { CheckGePrices }
  if ($calc($ctime % 300) == 0) {
    var %thread = $+(a,$r(0,999))
    var %search = $dbSelectWhere(prices, name, `price`='0' LIMIT 1)
    var %url http://gerty.rsportugal.org/parsers/ge.php?item= $+ $replace(%search,$chr(32),+)
    noop $download.break(downloadGe %thread,%thread,%url)
  }
  if ($calc($ctime % 10) == 0 && !$server) {
    server irc.swiftirc.net
    if ($hget(botlist,0).item == 0) _setAdmin
  }
}
CheckGePrices {
  sockopen CheckGePrices.front. $+ $r(0,9999) itemdb-rs.runescape.com 80
  sockopen CheckGePrices.zam. $+ $r(0,9999) itemdb-rs.runescape.com 80
}
_setAdmin {
  if ($aLfAddress(P_Gertrude)) { noop $setDefname( $v1 , P_Gertrude ) }
  if ($aLfAddress(Elessar)) { noop $setDefname( $v1 , Tiedemanns ) }
  if ($hget(botlist)) { .hfree botlist }
  .hmake botlist
  var %x = 2, %y = 1
  while (%x <= $lines(botlist.txt)) {
    var %bot = $read(botlist.txt,%x)
    if ($nick(#gerty,%bot) || $nick(#gertyDev,%bot)) {
      hadd -m botlist %y %bot
      noop $setDefname( $aLfAddress(%bot) , Gerty )
      inc %y
    }
    inc %x
  }
}
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
    .msg #gertyDev Error: %script %thread $([,) $+ %info $+ $(],) $3-
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
  .msg #gertyDev $date $timestamp Error: %script %thread $([,) $+ %info $+ $(],) $3-
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
host {
  if ($1 == timezone) return $readini(Gerty.Config.ini,host,tzone)
  if ($1 == offset) return $asctime(z)
  if ($1 == time) return $asctime($gmt,HH:nn:ss)
  if ($1 == day) return $asctime($gmt,dddd)
  if ($1 == date) return $asctime($gmt,dd)
  if ($1 == month) {
    if ($prop == 3) {
      return $asctime($gmt,mmm)
    }
    return $asctime($gmt,mmmm)
  }
}
bot {
  ; bot ID
  if ($1 == id) {
    noop $regex($me,/(\[.{2}\])|)/i)
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
    var %x = 1, %max = $chan(0), %chans
    while (%x <= %max) {
      %chans = %chans $+ , $+ $chan(%x)
      inc %x
    }
    return $right(%chans,-1)
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
; _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) <command> [args...]
; creates command info
_fillCommand {
  if (!$5) { return }
  var %thread = $1
  hadd -m %thread out $saystyle($2,$3,$4)
  ;hadd -m %thread from $3
  ;hadd -m %thread from.RSN $rsn($3)
  ;hadd -m %thread from.IsAdmin $admin($3)
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
  if ($hget(%thread)) hfree %thread
}
TimeToday {
  var %today, %week, %month, %year
  if ($duration($host(time)) >= 25200) {
    %today = $calc($duration($host(time)) - 25200)
  }
  else {
    %today = $calc($duration($host(time)) + 61200)
  }
  if ($duration($host(time)) < 25200 && $host(day) == sunday) {
    %week = $calc(579600 + %today)
  }
  else if ($duration($host(time)) < 25200 && $day != sunday) {
    %week = $calc($replace($host(day),Monday,0,Tuesday,1,Wednesday,2,Thursday,3,Friday,4,Saturday,5) * 86400 + %today )
  }
  else if ($duration($host(time)) >= 25200) {
    %week = $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
  }
  if ($duration($host(time)) < 25200 && $host(date) == 01) {
    %month = $calc($replace($host(month),Jan,2394000,Feb,2653200,Mar,2566800,Apr,2653200,May,2566800,Jun,2653200,Jul,2653200,Aug,2566800,Sep,2653200,Oct,2566800,Nov,2653200,Dec,2653200) + %today)
  }
  else {
    %month = $calc(($gettok($date,1,47) - 1) * 86400 + %today )
  }
  %year = $calc($gmt - $ctime(January 1 $date(yyyy) 07:00:00))
  return %today %week %month %year
}
downloadstring {
  .comopen $1 msxml2.xmlhttp
  var %Url = $2 $+ $iif($numtok($gettok($2, $numtok($2,47), 47),63) == 1,?,&) $+ DontCachePlease= $+ $ctime
  var %p = $com($1 , open, 1, bstr, get, bstr, %Url, bool, -1)
  %p = $com($1 ,send,1)
  %p = $com($1 ,responseText,2)
  %p = $com($1 ).result
  .comclose $1
  return %p
}
download.break {
  .comopen $2 msxml2.xmlhttp
  var %Url = $3 $+ $iif($numtok($gettok($3, $numtok($3,47), 47),63) == 1,?,&) $+ DontCachePlease= $+ $ctime
  noop $com($2 , open, 1, bstr, get, bstr, %Url, bool, 0)
  noop $comcall($2 ,noop $!com($1,responseText,2) $(|,) $1 $!com($1).result $(|,) .comclose $!1,send,1)
}
cleanhash {
  .hfree -w a*
  var %x 1, %y = $com(0)
  while (%x <= %y) {
    .comclose $com(1)
    inc %x
  }
}
removeSpam if ($hget($1)) hfree $1
spamCheck {
  if ($hget($1,spam) >= 5) {
    ignore -pcntikdu18000 $1
    if ($address($1,3)) { ignore -pcntikdu18000 $address($1,3) }
    .msg $1 $1 Blacklisted for 5 hours for spamming. (5 commands in 5 seconds).
    .msg #gertyDev SPAM:07 $1 detected spamming.
    return $true
  }
  return $false
}
;@SYNTAX /die
;@SUMMARY used as a callback to a threaded com call, when the data recieved is not required.
die return

;@SYNTAX shuffleHash(string commandLine)
;@SUMMARY manages the store of recent commands. (up to 5)
shuffleHash {
  var %newLine $1
  var %x 4
  while (%x) {
    hadd -m commands $calc(%x + 1) $hget(commands, %x))
    dec %x
  }
  hadd -m commands 1 %newLine
  hinc commands amount
}
botid {
  var %id = $bot(id)
  if ($1 == $me) return tokenize 32 $!2-
  elseif ($istok($1-,%id,44) || $+([,$1,]) == %id) { return tokenize 32 $!2- }
  elseif ($1 == Gerty && Gerty !ison $chan) { return tokenize 32 $!2- }
  elseif ($+([,$1,]Gerty) ison #gertyDev) { return goto clean }
  tokenize 44 $1-
  var %x = 1
  while (%x <= $0) {
    if ($regsubex($($ $+ %x,2),/^\[(\w{2})\](?:Gerty)?$/Si,[ $+ \1 $+ ]Gerty) ison #gertyDev) { return goto clean }
    inc %x
  }
}
;@SYNTAX /sendToDev errorMessage
;@SUMMARY sends an error message to the developers channel, also echos to the status window.
sendToDev {
  if (!$1) return
  linesep
  echo $color(info) $timestamp * $1-
  linesep
  .msg #gertyDev $1-
}
;@SYNTAX /sendToDevOnly errorMessage
;@SUMMARY sends an error message to the developers channel only.
sendToDevOnly .msg #gertyDev $1-
RealCount {
  var %x = 1, %n = 0, %m = 0, %u
  while ($chan(%x)) {
    var %chan = $chan(%x), %a = 1, %b = 0
    while ($nick(%chan,%a)) {
      if (!$istok(BanHammer Captain_Falcon ClanWars Client Coder Machine milk mIRC Noobs Q RuneScape snoozles Unknown W Warcraft X Y Rudolph Spam,$nick(%chan,%a),32) && !$regex($nick(%chan,%a),/(BigSister$|Gerty$|RuneScript$|\bVectra|\bBabylon|Noobwegian|\bOnzichtbaar|\bChanStat)/Si)) {
        inc %b
        inc %n
        if (!$istok(%u,$nick(%chan,%a),32)) var %u = %u $nick(%chan,%a)
      }
      inc %a
      inc %m
    }
    var %y = $+(%y,$iif(%y,$chr(44)),$chr(32),%chan,[,%b,/,$nick(%chan,0)])
    inc %x
  }
  if ($1 == total) return %n
  if ($1 == faketotal) return %m
  if ($1 == names) return $numtok(%u,32)
  return %y
}
