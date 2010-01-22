>start<|join.mrc|admin sorted|2.25|rs
on *:INVITE:*: {
  .msg #gertyDev Invite:07 # Invited by:07 $nick
  if ($chanset(#,blacklist) == yes) {
    .notice $nick Channel $chan is blacklisted. Speak to an admin to remove the blacklist.
    .msg #gertyDev Failed Join:07 # Reason:07 Channel is blacklisted.
    halt
  }
  if ($hget(join)) { hfree join }
  hadd -m invite $chan $nick
  if ($chan(0) < 30) {
    hadd -m join top $chan(0)
    hadd -m join bot $me
  }
  var %x = $hget(botlist,0).item
  while (%x) {
    if ($hget(botlist,%x) != $me) ctcp $v1 join
    dec %x
  }
  .timer 1 3 .notifybot $nick $chan
}
on *:KICK:*: {
  if ($knick == $me) {
    .msg #gertyDev KICKED:07 $chan by:07 $nick Reason:07 $1-
  }
}
on *:PART:*: {
  if ($nick == $me) {
    .msg #gertyDev PARTED:07 $chan
  }
  else if ($nick(#,0) < 5) {
    part # Channel has fallen below the user limit (07 $+ $chanset(#,users) $+ ).
  }
}
on *:JOIN:*: {
  if ($nick == $me) {
    who $chan
    var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
    if (!$rowExists(channel, channel, $chan)) { noop $_network(noop $!sqlite_query(1, INSERT INTO channel (channel) VALUES (' $+ $chan $+ ');)) }
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
      .msg #gertyDev Failed Join:07 %chan Reason:07 Channel below user requirement.
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
    .msg #gertyDev Failed Join:07 %chan Reason:07 Channel below user requirement.
    part %chan
    goto clean
  }
  .msg %chan RScape Stats Bot Gerty ~ Invited by %invite ~ Please report Bugs/Suggestions to P_Gertrude.
  .msg #gertyDev JOIN:07 %chan Invited by07 %invite Modes:07 $chan(%chan).mode Users:07 $nick(%chan,0) Total Chans:07 $chan(0)
  :clean
  if ($hget(invite)) { hfree invite }
  if ($hget($1)) { hfree $1 }
}
ctcp *:join:*: {
  if ($chan(0) <= 30) {
    ctcp $nick users $chan(0)
  }
}
ctcp *:users:*: {
  if ($2 < $hget(join,top) || !$hget(join,top)) {
    hadd -m join top $2
    hadd -m join bot $nick
  }
}
ctcp *:rawcommand:*: {
  if (!$admin($nick) && $nick != P_Gertrude) { halt }
  [ [ $2- ] ]
  return
  :error
  .msg #gertyDev ERROR:07 rawcommand From:07 $nick Text:07 $1-
  reseterror
}
alias notifybot {
  if ($hget(join,bot)) {
    ctcp $hget(join,bot) rawcommand hadd -m invite $2 $1
    ctcp $hget(join,bot) rawcommand join $2
    return
  }
  .notice $1 Sorry but all bots are currently full.
  if ($hget(join)) hfree join
}
