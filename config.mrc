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
  if !$hget(ge) { .hmake ge }
  if ($exists(geupdatebackup.txt)) { .hload ge geupdatebackup.txt }
  if !$hget(commands) { .hmake commands }
  if ($exists(commands.txt)) { .hload commands commands.txt }
}
on *:QUIT: {
  if ($nick == $me) {
    ; Save Data Files
    .hsave runeprice runeprice.txt
    .hsave spelluse spelluse.txt
    .hsave ge geupdatebackup.txt
    .hsave commands commands.txt
  }
  /* looping through channels needed
  else if ($nick(#,0) < 5) {
    part # Channel has fallen below the user limit (07 $+ $chanset(#,users) $+ ).
  }
  */
}
on *:DISCONNECT: {
  if ($nick != $me) return
  ; Save Data Files
  .hsave prices price.txt
  .hsave runeprice runeprice.txt
  .hsave spelluse spelluse.txt
  .hsave ge geupdatebackup.txt
  .hsave commands commands.txt

}
on *:CONNECT: {
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

  ; Start up main timer
  .timertim -o 0 1 .timecount

}
raw 421:*: {
  var %string, %x 1
  while (%x <= 5) {
    %string = %string $hget(commands, %x) $+ ,07
    inc %x
  }
  sendToDev ERROR:07 $2- Recent commands:07 $left(%string, -4)
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
on *:KICK:*: {
  if ($knick == $me) {
    sendToDevOnly KICKED:07 $chan by:07 $nick Reason:07 $1-
  }
}
on *:PART:*: {
  if ($nick == $me) {
    .msg #gertyDev PARTED:07 $chan
  }
  else if ($nick(#,0) < $chanset(#,users)) {
    part # Channel has fallen below the user limit (07 $+ $chanset(#,users) $+ ).
  }
}
on *:JOIN:*: {
  if ($nick == $me) {
    who $chan
    var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
    if (!$rowExists(channel, channel, $chan)) { noop $_network(noop $!sqlite_query(1, INSERT INTO channel (channel) VALUES (" $+ $chan $+ ");)) }
    hadd -m %thread chan $chan
    .timer 1 1 .delayedjoin %thread
  }
}
alias delayedjoin {
  var %chan = $hget($1,chan)
  if (%chan == #gerty || %chan == #howdy || %chan == #gertyDev) { goto clean }
  var %x = 1
  while (%x <= $lines(botlist.txt)) {
    if ($read(botlist.txt,%x) ison %chan && $read(botlist.txt,%x) != $me) {
      part %chan You already have a Gerty bot.
      sendToDevOnly Failed Join:07 %chan Reason:07 Two Gerty bots in channel.
      goto clean
    }
    inc %x
  }
  if (!$hget(invite,%chan)) { var %invite = %chan }
  else { var %invite = $hget(invite,%chan) }
  if ($chanset(%chan,users)) { var %min = $chanset(%chan,users) }
  if (!%min) { var %min = 5 }
  if ($nick(%chan,0) < %min) {
    .msg %chan You do not have the required minimum users to keep me here. (Minimum users for this channel is07 %min $+ ).
    .msg %chan Contact a bot admin if you wish to have the user minimum lowered for this channel.
    sendToDevOnly Failed Join:07 %chan Reason:07 Channel below user requirement.
    part %chan
    goto clean
  }
  if ($uptime(server,3) > 20) {
    .msg %chan RScape Stats Bot Gerty ~ Invited by %invite ~ Please report Bugs/Suggestions to #gerty
    sendToDevOnly JOIN:07 %chan Invited by07 %invite Modes:07 $chan(%chan).mode Users:07 $nick(%chan,0) Total Chans:07 $chan(0)
  }
  :clean
  if ($hget(invite)) { hfree invite }
  if ($hget($1)) { hfree $1 }
}
ctcp *:users:*: {
  hadd -m bot $nick $2
  if ($hget(bot,0).item == $nick(#gertyDev,0,h)) { JoinQueue }
}
ctcp *:invite:*:{
  if ($hget(buffer,$3)) halt
  hadd -mu10 buffer $3 $true
  if ($me == Gerty) {
    if ($chanset(#,blacklist) == yes) {
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
    if ($chanset($3,blacklist) == yes) {
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
  ctcp Gerty USERS $chan(0)
}
alias JoinQueue {
  if ($hget(joinqueue)) hfree joinqueue
  hadd -m joinqueue num $nick(#gertyDev,0,h)
  var %x = 1
  while ($hget(bot,%x).item) {
    %bot = $v1
    var %total = $calc(%total + $hget(bot,%bot))
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
    sendToDevOnly Join queue generated: %b $+ . Channels: $+(07,$bytes(%total,bd),/07,$bytes(%max,bd)) $parenthesis($round($calc(%total / %max * 100),2) $+ $%)
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
  else { .ctcp Gerty users $chan(0) }
}
on *:quit:{ if (%* iswm $nick(#gertyDev,$nick).pnick && $me == Gerty) { JoinQueueStart } }
