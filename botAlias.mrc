>start<|botAlias.mrc|internal bot commands|3.4|a
;@SYNTAX /timeCount
;@SUMMARY The main timer for the program, all automated events processed in here.
timeCount {
  ; 1 second timer
  if ($dbSelect(timers, id;ircnick;fingerprint;startTime;message, endTime, $gmt) != $null) {
    var %timer $v1
    if ($ial($trim($gettok(%timer, 2, 59)), 1).nick != $null) {
      .msg $v1 $gettok(%timer, 5, 59) $+ , this timer (07# $+ $trim($gettok(%timer, 1, 59)) $+ ) ran for07 $duration($calc($gmt - $gettok(%timer, 4, 59))) $+ .
    }
    elseif ($ial($chr(42) $+ $trim($gettok(%timer, 3, 59)), 1).nick != $null) {
      .msg $v1 $gettok(%timer, 5, 59) $+ , this timer (07# $+ $trim($gettok(%timer, 1, 59)) $+ ) ran for07 $duration($calc($gmt - $gettok(%timer, 4, 59))) $+ .
    }
    noop $sqlite_query(1, DELETE FROM timers WHERE endTime <= $gmt $+ ;)
  }
  ; 10 second timer
  if ($calc($ctime % 10) == 0) {
    if (!$server) {
      server irc.swiftirc.net
    }
  }
  ; 15 second timer
  if ($calc($ctime % 15) == 0) {
    if ($me == Gerty && (!$hget(joinqueue,list) || $ctime > $hget(joinqueue,time) || $nick(#gertyDev,0,h) != $hget(joinqueue,num))) {
      JoinQueueStart
    }
    if (Gerty !ison #gertyDev && $me ison #gertyDev) { nick Gerty }
  }
  ; 1 minute timer
  if ($calc($ctime % 60) == 0) {
    if ($me == Gerty) startGeUpdate
    noop $findEmptyChannels
  }
  ; 5 minute timer
  if ($calc($ctime % 300) == 0) {
    if ($server) {
      _setAdmin
    }
    ; ge price updates
    var %thread = $+(a,$r(0,999))
    var %search = $dbSelectWhere(prices, name, `price`='0' LIMIT 1)
    var %url http://gerty.rsportugal.org/parsers/ge.php?item= $+ $replace(%search,$chr(32),+)
    noop $download.break(downloadGe %thread,%thread,%url)
    ; save command count
    hsave commands commands.txt
  }
}
;@SYNTAX /_setAdmin
;@SUMMARY Loads the preset admins hostmasks into the admin table.
;@NOTE It is important that the bots have each other (and themselves) set as admin for most functions to work.
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
  AdminToHash
}
;@SYNTAX $bots
;@SUMMARY Returns the list of bots in the network, in the order of priority.
;@NOTE The order of bots must be the same on all bots, the order is taken from the botlist.txt file.
bots {
  var %x 2, %bots
  while (%x <= $lines(botlist.txt)) {
    %bots = %bots $read(botlist.txt,%x)
    inc %x
  }
  return %bots
}
;@SYNTAX /_checkMain
;@SUMMARY This will halt the script if this client is not found to be the bot with the highest priority in the channel.
_checkMain {
  if ($isid) {
    if (!$1) { return $true }
    tokenize 32 $bots
    var %x 1
    while (%x <= $0) {
      if ($($ $+ %x,2) ison $chan && $me != $($ $+ %x,2)) { return $false }
      else if ($me == $($ $+ %x,2)) { return $true }
      inc %x
    }
    return $true
  }
  else {
    if (!$chan) { return }
    tokenize 32 $bots
    var %x 1
    while (%x <= $0) {
      if ($($ $+ %x,2) ison $chan && $me != $($ $+ %x,2)) { halt }
      else if ($me == $($ $+ %x,2)) { return }
      inc %x
    }
    return
  }
}
;@SYNTAX $_checkMainReturn(#chan)
;@SUMMARY Boolean return style, similar use to the /_checkMain function.
_checkMainReturn {
  deprecated _checkMainReturn
  if (!$1) { return $true }
  tokenize 32 $bots
  var %x 1
  while (%x <= $0) {
    if ($($ $+ %x,2) ison $chan && $me != $($ $+ %x,2)) { return $false }
    else if ($me == $($ $+ %x,2)) { return $true }
    inc %x
  }
  return $true
}
;@SYNTAX /_throw $nopath($script) %thread
;@SUMMARY Will throw an exception for errors in a script, saves the command data to the errorlog.txt file, and notifies the dev channel.
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
    sendToDev Error: %script %thread $([,) $+ %info $+ $(],) $3-
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
  sendToDev $date $timestamp Error: %script %thread $([,) $+ %info $+ $(],) $3-
}
;@SYNTAX /_network <command>
;@SUMMARY Will pass a command onto all bots in the network. Bots must be in the dev channel to recieve the message.
_network {
  sendToDevOnly raw $1
  [ [ $1 ] ]
}
;@SYNTAX $host(<timespan>)[.3]
;@SUMMARY Returns the UTC DateTime in the selected format.
;@PARAM Accepted formats: timezone, offset, time, day, date, month; Prop: 3 (changes the month output.)
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
;@SYNTAX $bot(<information>)
;@SUMMARY returns information on the clients activity.
;@PARAM Accepted activities: id, users, chanlist
bot {
  ; bot ID
  if ($1 == id) {
    noop $regex($me,/(\[.{2}\])|)/i)
    return $iif($regml(1),$v1,[00])
  }
  ; Current Users
  if ($1 == users) {
    return $ial(*,0)
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
;@SYNTAX $command(%thread[command ID], key)
;@SUMMARY Returns information about a current command.
command {
  if (!$2) { return }
  return $hget($1,$2)
}
cmd {
  if (!$2) { return }
  return $hget($1,$2)
}
;@SYNTAX /_fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) <command> [args...]
;@SUMMARY Creates an object storing information about a command.
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
;@SYNTAX /_clearCommand %thread[command ID]
;@SUMMARY Cleans up a command object at the end of a command.
_clearCommand {
  if (!$1) { return }
  var %thread = $1
  if ($hget(%thread)) hfree %thread
}
;@SYNTAX $timeToday
;@SUMMARY Returns four integers representing how far into the current day/week/month/year the bot currently is.
;@NOTE Integer is the TimeSpan in seconds, useful for using the rscript parsers.
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
;@SYNTAX $downloadstring(<socket id>, <url>)
;@SUMMARY Returns the page content of the request URL.
;@NOTE This command will wait for a response from the site. Be wary of using it with unreliable servers.
downloadstring {
  .comopen $1 msxml2.xmlhttp
  var %Url = $2 $+ $iif($numtok($gettok($2, $numtok($2,47), 47),63) == 1,?,&) $+ DontCachePlease= $+ $ctime
  var %p = $com($1 , open, 1, bstr, get, bstr, %Url, bool, -1)
  %p = $com($1 ,send,1)
  %p = $com($1 ,responseText,2)
  %p = $com($1 ).result
  .comclose $1
  return %p
  :error
  reseterror
  return $false
}
;@SYNTAX /noop $download.break(<callback function>, <socket id>, <url>)
;@SUMMARY This will pass the content of the requested url to the callback function in parameter $1.
download.break {
  .comopen $2 msxml2.xmlhttp
  var %url = $3 $+ $iif($numtok($gettok($3, $numtok($3,47), 47), 63) == 1, ?, &) $+ DontCachePlease= $+ $ctime
  noop $com($2, open, 1, bstr, get, bstr, %url, bool, 0)
  noop $comcall($2, noop $!com($1, responseText, 2) $(|,) $1 $!com($1).result $(|,) .comclose $!1, send, 1)
}
;@SYNTAX $cleanHash
;@SUMMARY does a wildcard clean of the hash tables starting with 'a', also closes any open coms.
;@NOTE Because of this function, please don't make permanent hash tables beginning with a.
cleanhash {
  .hfree -w a*
  var %x 1, %y = $com(0)
  while (%x <= %y) {
    .comclose $com(1)
    inc %x
  }
}
removeSpam if ($hget($1)) hfree $1
;@SYNTAX /spamCheck $nick
;@SUMMARY Performs a check on the users recent bot-use, and will ignore them for abuse if necessary.
;@NOTE Will inform the dev channel of any abuse.
spamCheck {
  if ($hget($1,spam) >= 5) {
    ignore -pcntikdu18000 $1
    if ($address($1,3)) { ignore -pcntikdu18000 $address($1,3) }
    .msg $1 $1 Blacklisted for 5 hours for spamming. (5 commands in 5 seconds).
    sendToDevOnly SPAM:07 $1 detected spamming.
    return $true
  }
  return $false
}
;@SYNTAX /die
;@SUMMARY used as a callback to a threaded com call, when the data recieved is not required.
die return
;@SYNTAX $shuffleHash(string commandLine)
;@SUMMARY manages the store of recent commands. (up to 5)
shuffleHash {
  var %newLine $1
  var %x 4
  while (%x) {
    hadd -m commands $calc(%x + 1) $hget(commands, %x))
    dec %x
  }
  hadd -m commands 1 %newLine
  ; Chan specific commands
  var %last4 = $gettok($hget(commands,$chan),1-4,9)
  hadd -m commands $chan $addtok(%newLine,%last4,9)
  hinc commands amount
}
;@SYNTAX $bot(<bot tag|bot name>)
;@SUMMARY Boolean return style, true if the id/botnick is the clients nickname.
botid {
  var %id = $bot(id)
  if ($1 == $me) return $true
  elseif ($istok($1-,%id,44) || $+([,$1,]) == %id || $1 == [**]) { return $true }
  elseif ($1 == Gerty && Gerty !ison $chan) { return $true }
  elseif ($+([,$1,]Gerty) ison #gertyDev) { return $false }
  tokenize 44 $1-
  var %x = 1
  while (%x <= $0) {
    if ($regsubex($($ $+ %x,2),/^\[(\w{2})\](?:Gerty)?$/Si,[ $+ \1 $+ ]Gerty) ison #gertyDev) { return $false }
    inc %x
  }
}
;@SYNTAX /sendToDev errorMessage
;@SUMMARY sends an error message to the developers channel, also echos to the status window.
sendToDev {
  if (!$1 || $me !ison #gertyDev) return
  linesep
  echo $color(info) $timestamp * $1-
  linesep
  .msg #gertyDev $1-
}
;@SYNTAX /sendToDevOnly errorMessage
;@SUMMARY sends an error message to the developers channel only.
sendToDevOnly if ($me ison #gertyDev) .msg #gertyDev $1-
userCount {
  var %x = 1, %n = 0, %m = 0, %u, %nick
  if ($# $+ * iswm $1) {
    if ($me !ison $1) return 0
    while ($nick($1,%x)) {
      if (!$isbot($v1)) inc %n
      inc %x
    }
    return %n
  }
  while ($chan(%x)) {
    var %chan = $chan(%x), %a = 1, %b = 0
    while ($nick(%chan,%a)) {
      if (!$isBot($nick(%chan,%a))) {
        inc %b
        inc %n
        if (!$istok(%u,$nick(%chan,%a),32)) var %u = %u $nick(%chan,%a)
      }
      inc %a
      inc %m
    }
    var %y = $+(%y,$iif(%y,$chr(44)),$chr(32),%chan,[,%b,/,$nick(%chan,0),])
    inc %x
  }
  if ($1 == total) return %n
  if ($1 == faketotal) return %m
  if ($1 == names) return $numtok(%u,32)
  return %y
}
;@SYNTAX $findEmptyChannels
;@SUMMARY Will identify any low user channels using the $userCount alias. returns the list of low user channels.
;@NOTE Will automatically part any channel found to have no 'real' users.
findEmptyChannels {
  var %x 1, %chans, %min $iif(!$1,2,$1)
  while (%x <= $chan(0)) {
    if ($usercount($chan(%x)) <= %min) {
      %chans = %chans $chan(%x) $v1 $+ ;
      if ($v1 == 0 && $chan(%x) != #gertyDev) { part $chan(%x) }
    }
    inc %x
  }
  return %chans
}
;@SYNTAX /adminToHash
;@SUMMARY Will copy all admin signatures to the admin table.
;@NOTE Worker function for _setAdmin.
adminToHash {
  if ($hget(admin)) hfree admin
  var %admins = $readini(gerty.config.ini,admin,rsn), %x = $numtok(%admins,124), %string
  while (%x) { %string = %string rsn=" $+ $gettok(%admins,%x,124) $+ " OR | dec %x }
  tokenize 44 $dbSelectWhere(users, fingerprint;rsn, $left(%string,-3) )
  var %a = $0
  while ($($ $+ %a,2)) { hadd -m admin $gettok($($ $+ %a,2),1,59) $gettok($($ $+ %a,2),2,59) | dec %a }
}
;@SYNTAX /runePriceUpdater
;@SUMMARY Downloads the prices of all runes.
;@NOTE Deprecated.
runepriceupdater {
  sockopen runeprice.rune1 itemdb-rs.runescape.com 80
  sockopen runeprice.rune2 itemdb-rs.runescape.com 80
  if ($hget(potprice)) { hfree potprice }
}
;@SYNTAX /gertyQuit
;@SUMMARY Will move all channels with 5 or more (real) users to another bot, then quit automatically when done.
gertyQuit {
  if ($me == Gerty) { .notice $nick Don't quit main bot. Tag me and set one of the others as main first. | halt }
  if ($chan) { .notice $nick This alias can only be used in PM. | halt }
  if ($me ison #gertyDev) part #gertyDev Quitting
  if (!$1) var %x = 1, %chanlist = $bot(chanlist)
  else var %x = $1, %chanlist = $2-
  ; Checks what the next channel on the list is, parts that, then 3sec timer to run this alias again.
  while ($usercount($gettok(%chanlist,%x,44)) < 5 && %x <= $numtok(%chanlist,44)) { inc %x }
  if (%x <= $numtok(%chanlist,44)) {
    part $gettok(%chanlist,%x,44) Switching bot, brb!
    .ctcp Gerty invite Gerty $gettok(%chanlist,%x,44)
    .timerQuit 1 3 gertyQuit $calc(%x + 1) %chanlist
  }
  else {
    timertim off
    quit Gerty shutting down. Please /invite Gerty or /join #gerty
  }
}
;@SYNTAX /statusOut %thread
;@SUMMARY Will return the reply to a .status command performed by an admin.
statusOut {
  var %thread = $1, %ping = $calc($ticks - $hget(%thread,ticks)), %saystyle = $hget(%thread,out)
  %saystyle Chans:07 $chan(0) | Nicks:07 $bot(users) | Uptime:07 $swaptime($uptime(server,1)) | Total Commands:07 $bytes($hget(commands,amount),bd) | Server ping:07 $bytes(%ping,bd)
  hfree %thread
}
;@SYNTAX $isBot(nick)[.excepts]
;@SUMMARY Boolean return style, $true if the nick is a bot, ie. Not a 'real' user.
;@PARAM Valid props: cs, stat, other
isBot {
  ; ChanServ bots:
  if ($istok(BanHammer Captain_Falcon ClanWars Client Coder Machine milk mIRC Noobs Q RuneScape snoozles Unknown W Warcraft X Y Rudolph Spam Minibar ChanServ,$1,32) && cs !isin $prop) { return $true }
  ; Stat bots:
  if ($regex($1,/(BigSister$|Gerty$|RuneScript$|^Vectra|ChaosScript$|^GwBot)/Si) && stat !isin $prop) { return $true }
  ; Other:
  if ($regex($1,/(^Noobwegian$|^Onzichtbaar|^ChanStat-|GrandExchange$)/Si) && other !isin $prop) { return $true }
  return $false
}
;@SYNTAX /parseGe
;@SUMMARY will take a file of syntax id,name,price,change and updates the database with the data.
;@NOTE causes roughly 4s of lag. The amount of commands can be reduced in future if lag is a problem.
parseGe {
  if (!$exists(dlGe.txt)) return
  .fopen dlge dlGe.txt
  sqlite_begin 1
  while (!$feof) {
    tokenize 44 $fread(dlge)
    if ($0 == 4) noop $sqlite_exec(1, UPDATE prices SET price=' $+ $3 $+ ' $chr(44) change=' $+ $4 $+ ' WHERE id=' $+ $1 $+ ';)
  }
  sqlite_commit 1
  .fclose dlge
  .remove dlGe.txt
  echo -at finished
}
;@SYNTAX $newThread
;@SUMMARY shortcut for creating a new thread id.
newThread return $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
;@SYNTAX /deprecated <command name>
;@SUMMARY use this to flag deprecated functions, for easy tracking throughout bot.
deprecated {
  var %string, %x 1
  while (%x <= 5) {
    %string = %string $hget(commands, %x) $+ ,07
    inc %x
  }
  sendToDev use of deprecated function $1 $left(%string, -4)
}
;@SYNTAX $parser
;@SUMMARY returns the main parser link
parser return http://sselessar.net/Gerty/parser.php?type=
