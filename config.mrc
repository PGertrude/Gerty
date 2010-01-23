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
