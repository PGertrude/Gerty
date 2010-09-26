>start<|config.mrc|config and join merged|3.51|rs
on *:START: {
  ; Authenticate Host
  if (!$exists(Gerty.Config.ini)) {
    writeini Gerty.Config.ini admin rsn P_Gertrude|Tiedemanns|Gerty
  }
  if (!$readini(Gerty.Config.ini,global,pass)) { writeini Gerty.Config.ini global pass $?="Update Password?" }
  if (!$readini(Gerty.Config.ini,admin,pass) || $readini(Gerty.Config.ini,admin,pass) == fail) { writeini Gerty.Config.ini admin pass $?="Admin Password?" }
  if (!$readini(Gerty.Config.ini,host,tzone)) { writeini Gerty.Config.ini host tzone $?="Please fill in your timezone (Initials)" }
  if (!$exists(Perform.txt)) {
    write -l1 Perform.txt NS ID $?="Group Password?"
    write -l2 Perform.txt MODE +Bp
    write -l3 Perform.txt JOIN $?="Any AutoJoin channels?"
  }
  ; Set off update check
  !echo -at Checking for updates...
  ;findupdate
  ; Load Data Files
  if !$hget(runeprice) { .hmake runeprice }
  if ($exists(runeprice.txt)) { .hload runeprice runeprice.txt }
  if !$hget(spelluse) { .hmake spelluse }
  if ($exists(spelluse.txt)) { .hload spelluse spelluse.txt }
  if !$hget(commands) { .hmake commands }
  if ($exists(commands.txt)) { .hload commands commands.txt }
  ; Check for last ge update
  noop $download.break(checkForOfflineGeUpdate, $newThread, $parser $+ lastupdate)
  noop $sqlite_query(1, DELETE FROM timers WHERE endTime < $gmt $+ ;)
}
on *:QUIT: {
  if ($nick == $me) {
    ; Save Data Files
    .hsave runeprice runeprice.txt
    .hsave spelluse spelluse.txt
    .hsave commands commands.txt
  }
}
on *:DISCONNECT: {
  if ($nick != $me) return
  ; Save Data Files
  .hsave runeprice runeprice.txt
  .hsave spelluse spelluse.txt
  .hsave commands commands.txt
}
on *:CONNECT: {
  remini Gerty.Config.ini GeUpdate
  if ($network == SwiftIrc) {
    ; Join #Gerty and Load Addressess
    join #gerty,#gertyDev
    who #gertyDev
    ; Get other startup commands (Unique to each bot.)
    var %x = 1
    while (%x <= $lines(Perform.txt)) {
      [ [ $read(Perform.txt,%x) ] ]
      inc %x
    }
    ; Set admin hash tables
    AdminToHash
    ; Set admins to save time.
    _setAdmin
  }
  loadChans
  ; Start up main timer
  .timertim -o 0 1 .timecount
}
raw 421:*: {
  if (status.* iswm $2) {
    statusOut $gettok($2,2,46)
  }
  else {
    var %string, %x 1
    while (%x <= 5) {
      %string = %string $hget(commands, %x) $+ ,07
      inc %x
    }
    sendToDev ERROR:07 $2- Recent commands:07 $left(%string, -4)
  }
  haltdef
}
raw 352:*:haltdef
raw 315:*:haltdef
on *:INVITE:*: {
  if ($hget(buffer,#)) halt
  hadd -mu10 buffer # $true
  .msg #gertyDev Invite:07 # Invited by:07 $nick
  if ($me == Gerty) {
    if ($chanset(#,blacklist) == yes) {
      .notice $nick Channel $chan is blacklisted. Speak to an admin to remove the blacklist.
      sendToDevOnly Failed Join:07 # Reason:07 Channel is blacklisted.
      halt
    }
    elseif (!$hget(joinqueue,list)) {
      JoinQueueStart
      .timer 1 3 OnInvite $nick $chan
    }
    else {
      OnInvite $nick $chan
    }
  }
  elseif (Gerty ison #gertyDev) { ctcp Gerty INVITE $nick $chan }
  elseif ($chan(0) < 30) {
    if ($chanset(#,blacklist) == yes) {
      .notice $nick Channel $chan is blacklisted. Speak to an admin to remove the blacklist.
      sendToDevOnly Failed Join:07 # Reason:07 Channel is blacklisted.
      halt
    }
    hadd -m invite # $nick
    join #
  }
}
on *:KICK:*: if ($knick == $me) sendToDevOnly KICKED:07 $chan by:07 $nick Reason:07 $1-
on *:PART:*: {
  if ($nick == $me) sendToDevOnly PARTED:07 $chan
  else if ($nick(#,0) < $chanset(#,users)) part # Channel has fallen below the user limit (07 $+ $chanset(#,users) $+ ).
}
on *:JOIN:*: {
  if ($nick == $me) {
    reloadChannel $chan
    who $chan
    var %thread $newThread
    if (!$rowExists(channel, channel, $lower($chan))) { noop $_network(noop $!sqlite_query(1, INSERT INTO channel (channel) VALUES (" $+ $lower($chan) $+ ");)) }
    .timer 1 1 .delayedjoin %thread $chan
  }
  else {
    _checkMain
    var %url http://hiscore.runescape.com/index_lite.ws?player= $+ $rsn($nick), %thread
    if ($chanset(#,autocmb) == on) {
      %thread = $newThread
      _fillCommand %thread @ $nick $iif($chan,$v1,PM) autocmb true
      noop $download.break(stats $cmd(%thread,out) combat null $rsn($nick) null null 1 200000001 %thread yes yes null , %thread , %url )
    }
    if ($chanset(#,autooa) == on) {
      %thread = $newThread
      _fillCommand %thread @ $nick $iif($chan,$v1,PM) autooa true
      noop $download.break(stats $cmd(%thread,out) overall 1 $rsn($nick) null null 1 200000001 %thread yes yes null , %thread , %url )
    }
    if ($chanset(#,autoclan) == on) {
      %thread = $newThread
      var %user $rsn($nick)
      _fillCommand %thread @ $nick $iif($chan,$v1,PM) autoclan true
      noop $download.break(getClans %user $hget(%thread,out) clan %thread , $newThread, http://runehead.com/feeds/lowtech/searchuser.php?user= $+ %user )
      noop $download.break(getClans %user $hget(%thread,out) non-clan %thread, $newThread, http://runehead.com/feeds/lowtech/searchuser.php?type=1&user= $+ %user)
    }
  }
}
alias delayedjoin {
  var %chan $2
  if (%chan isin #gertydev#howdy) { goto clean }
  var %x = 1
  while (%x <= $lines(botlist.txt)) {
    if ($read(botlist.txt,%x) ison %chan && $read(botlist.txt,%x) != $me) {
      part %chan You already have a Gerty bot.
      sendToDevOnly Failed Join:07 %chan Reason:07 Two bots in channel.
      goto clean
    }
    inc %x
  }
  var %invite $hget(invite,%chan), %min $chanset(%chan,users)
  if (!%invite) { %invite = %chan }
  if (!%min) { %min = 5 }
  if ($nick(%chan,0) < %min && $userCount(%chan) < 2) {
    .msg %chan You do not have the required minimum users to keep me here. (Minimum users for this channel is07 %min $+ ).
    .msg %chan Contact a bot admin if you wish to have the user minimum lowered for this channel.
    sendToDevOnly Failed Join:07 %chan Reason:07 Channel below user requirement.
    part %chan
    goto clean
  }
  if ($uptime(server,3) > 60) {
    .msg %chan RScape Stats Bot Gerty ~ Invited by %invite ~ Please report Bugs/Suggestions to #gerty
    sendToDevOnly JOIN:07 %chan Invited by07 %invite Modes:07 $chan(%chan).mode Users:07 $nick(%chan,0) Total Chans:07 $chan(0)
  }
  :clean
  if ($hget(invite)) { hfree invite }
}
ctcp *:users:*: {
  hadd -m bot $nick $2
  hadd -m botcount $nick $3
  if ($hget(bot,0).item == $nick(#gertyDev,0,h)) { JoinQueue }
}
ctcp *:invite:*:{
  if ($hget(buffer,$3)) halt
  hadd -mu10 buffer $3 $true
  if ($me == Gerty) {
    if ($gettok($chanset(#,blacklist),1,59) == yes) {
      .notice $2 Channel $3 is blacklisted. Speak to an admin to remove the blacklist.
      sendToDevOnly Failed Join:07 $3 Reason:07 Channel is blacklisted.
      halt
    }
    elseif (!$hget(joinqueue,list)) {
      JoinQueueStart
      .timer 1 3 OnInvite $2 $3
    }
    else {
      OnInvite $2 $3
    }
  }
  elseif (Gerty ison #gertyDev) { ctcp Gerty INVITE $2 $3 }
  elseif ($chan(0) < 30) {
    if ($gettok($chanset($3,blacklist),1,59) == yes) {
      .notice $2 Channel $3 is blacklisted. Speak to an admin to remove the blacklist.
      sendToDevOnly Failed Join:07 $3 Reason:07 Channel is blacklisted.
      halt
    }
    hadd -m invite $3 $2
    join $3
  }
}
ctcp *:rawcommand:*: {
  if (!$admin($nick) && $nick != P_Gertrude) { halt }
  [ [ $2- ] ]
  return
  :error
  sendToDev ERROR:07 rawcommand From:07 $nick Text:07 $1-
  reseterror
}
alias JoinQueueStart {
  if ($me == Gerty) .msg #gertyDev !!users
  var %x = 1, %y
  while ($chan(%x)) { %y = $calc(%y + $nick($chan(%x),0)) | inc %x }
  ctcp Gerty USERS $chan(0) %y
}
alias JoinQueue {
  if ($hget(joinqueue)) hfree joinqueue
  hadd -m joinqueue num $nick(#gertyDev,0,h)
  var %x = 1
  while ($hget(bot,%x).item) {
    %bot = $v1
    var %total = $calc(%total + $hget(bot,%bot))
    var %totalcount = $calc(%totalcount + $hget(botcount,%bot))
    var %y = $+(%y,$iif(%y,|),$hget(bot,%bot) %bot)
    inc %x
  }
  while ($numtok(%z,124) < 4) {
    var %y = $sorttok(%y,124,n)
    var %bot = $gettok(%y,1,124)
    if ($gettok(%bot,1,32) >= 30 && !%z) {
      hadd -m joinqueue list Full
      goto skip
    }
    else if ($gettok(%bot,1,32) >= 30) {
      break
    }
    var %z = $+(%z,$iif(%z,|),$gettok(%bot,2,32))
    var %y = $+($calc($gettok(%bot,1,32) + 1) $gettok(%bot,2,32),|,$gettok(%y,2-,124))
  }
  hadd -m joinqueue list %z
  :skip
  hadd -m joinqueue time $calc($ctime + 900)
  if ($hget(bot)) hfree bot
  var %a = 1
  while ($gettok(%z,%a,124)) {
    var %b = %b %a $+ :07 $iif($remove($gettok(%z,%a,124),Gerty),$v1,[00]) $+ 
    inc %a
  }
  %max = $calc(30 * $numtok(%y,124))
  if (%b) {
    sendToDevOnly Join queue generated: %b $+ . Channels: $+(07,$bytes(%total,bd),/07,$bytes(%max,bd)) $parenthesis($round($calc(%total / %max * 100),2) $+ $%) and07 $bytes(%totalcount,bd) users.
  }
  else {
    sendToDevOnly All bots are currently full.
  }
}
alias OnInvite {
  if ($hget(joinqueue,list) == Full) { .notice $1 Sorry but all bots are currently full. }
  elseif ($hget(joinqueue,list)) {
    var %bot = $gettok($v1,1,124)
    hadd -m joinqueue list $gettok($v1,2-,124)
    ctcp %bot rawcommand hadd -m invite $2 $1
    ctcp %bot rawcommand join $2
    if ($numtok($hget(joinqueue,list),124) <= 1) { JoinQueueStart }
  }
  else {
    JoinQueueStart
    .timer 1 3 OnInvite $1 $2
  }
}
on *:text:!!users:#gertyDev:{
  if ($nick !ishop $chan && $nick !isop $chan) { halt }
  .ctcp Gerty users $chan(0) $bot(users)
}
on *:quit:{ if (%* iswm $nick(#gertyDev,$nick).pnick && $me == Gerty) { JoinQueueStart } }
