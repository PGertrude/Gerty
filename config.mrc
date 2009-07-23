on *:START: {

  ; Authenticate Host
  if (!$readini(Gerty.Config.ini,global,pass)) { writeini Gerty.Config.ini global pass $?="Update Password?" }
  if (!$readini(Gerty.Config.ini,admin,pass)) { writeini Gerty.Config.ini admin pass $?="Admin Password?" }

  ; Set off update check
  !echo -at Checking for updates...
  findupdate

  ; Load Data Files
  if !$hget(prices) { .hmake prices }
  if !$hget(runeprice) { .hmake runeprice }
  if !$hget(spelluse) { .hmake spelluse }
  if !$hget(ge) { .hmake ge }
  if ($exists($mircdirData\price.data)) { .hload prices $mircdirData\price.data }
  if ($exists($mircdirData\runeprice.data)) { .hload runeprice $mircdirData\runeprice.data }
  if ($exists($mircdirData\spelluse.data)) { .hload spelluse $mircdirData\spelluse.data }
  if ($exists($mircdirData\geupdatebackup.data)) { .hload spelluse $mircdirData\geupdatebackup.data }

}
on *:QUIT: {

  ; Save Data Files
  .hsave prices $mircdirData\price.data
  .hsave runeprice $mircdirData\runeprice.data
  .hsave spelluse $mircdirData\spelluse.data
  .hsave ge $mircdirData\geupdatebackup.data

}
on *:CONNECT: {
  if ($network == SwiftIrc) {

    ; Join Gerty and Load Addressess
    join #gerty
    who #gerty

    ; Get other startup commands (Unique to each bot.)
    var %x = 1
    while (%x <= $lines(Perform.txt)) {
      [ [ $read(Perform.txt,%x) ] ]
      inc %x
    }

    ; Set admins to save time.
    _setAdmin

  }

  ; Start up timers
  .timertim 0 1 .timecount
  .timerge 0 60 .CheckGePrices

}
